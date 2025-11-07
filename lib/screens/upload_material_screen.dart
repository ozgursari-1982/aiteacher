import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/course.dart';
import '../models/study_material.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';
import '../services/gemini_ai_service.dart';

class UploadMaterialScreen extends StatefulWidget {
  final Course course;

  const UploadMaterialScreen({super.key, required this.course});

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _storageService = FirebaseStorageService();
  final _firestoreService = FirestoreService();
  final _aiService = GeminiAIService();
  final _imagePicker = ImagePicker();

  File? _selectedFile;
  String? _fileName;
  StudyMaterialType _materialType = StudyMaterialType.note;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _fileName = image.name;
          _materialType = StudyMaterialType.image;
        });
      }
    } catch (e) {
      _showError('Resim seçilirken hata oluştu: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', // Dokümanlar
          'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic', 'heif', // Resimler
        ],
      );

      if (result != null && result.files.single.path != null) {
        final extension = result.files.single.extension?.toLowerCase() ?? '';
        
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          
          // Dosya türünü otomatik belirle
          if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic', 'heif'].contains(extension)) {
            _materialType = StudyMaterialType.image;
          } else if (extension == 'pdf') {
            _materialType = StudyMaterialType.pdf;
          } else {
            // Eğer PDF veya resim değilse, genel bir not olarak kabul et
            _materialType = StudyMaterialType.note;
          }
        });
      }
    } catch (e) {
      _showError('Dosya seçilirken hata oluştu: $e');
    }
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      _showError('Lütfen bir dosya seçin');
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload file to Firebase Storage
      final fileUrl = await _storageService.uploadStudyMaterial(
        _selectedFile!,
        widget.course.studentId,
        widget.course.id,
      );

      // Create study material document
      final material = StudyMaterial(
        id: '',
        courseId: widget.course.id,
        studentId: widget.course.studentId,
        title: _titleController.text.trim(),
        type: _materialType,
        fileUrl: fileUrl,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        uploadedAt: DateTime.now(),
      );

      final materialId = await _firestoreService.addStudyMaterial(material);

      // AI analizi yap (GERÇEK DOSYA İÇERİĞİ ile!)
      _performAIAnalysis(materialId, _selectedFile!.path);

      // Update course file count
      await _firestoreService.updateCourse(
        widget.course.id,
        {'uploadedFilesCount': widget.course.uploadedFilesCount + 1},
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materyal yüklendi. AI analizi devam ediyor...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _showError('Yükleme sırasında hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _performAIAnalysis(String materialId, String localFilePath) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        print('🤖 GERÇEK DOSYA İÇERİĞİ analiz ediliyor (Deneme ${retryCount + 1}/$maxRetries)...');
        print('📁 Dosya yolu: $localFilePath');
        
        // GERÇEK DOSYA İÇERİĞİ ile AI analizi (Vision API)
        final analysis = await _aiService.analyzeStudyMaterialWithFile(
          filePath: localFilePath,
          courseName: widget.course.name,
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        );

        // Analizi Firestore'a kaydet
        await _firestoreService.updateMaterialAnalysis(materialId, analysis);
        
        print('✅ GERÇEK DOSYA İÇERİĞİ başarıyla analiz edildi: $materialId');
        return; // Başarılı, döngüden çık
        
      } catch (e) {
        retryCount++;
        print('❌ Dosya analizi hatası (Deneme $retryCount): $e');
        
        if (retryCount >= maxRetries) {
          print('⚠️ Dosya analizi $maxRetries denemeden sonra başarısız oldu');
          // Hata bildirimi
          await _firestoreService.updateMaterialAnalysis(
            materialId,
            '❌ HATA: Dosya içeriği analiz edilemedi.\n\n'
            'Sebep: $e\n\n'
            '🔄 Lütfen:\n'
            '• Dosyanın bozuk olmadığından emin olun\n'
            '• Dosya boyutunu kontrol edin (max 20MB)\n'
            '• Desteklenen format: JPG, PNG, PDF\n'
            '• Bu materyali silin ve yeniden yükleyin'
          );
          return;
        }
        
        // Tekrar denemeden önce kısa bekle
        await Future.delayed(Duration(seconds: 2 * retryCount));
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materyal Yükle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Upload area
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 64,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedFile == null)
                        Text(
                          'Dosya Seçin',
                          style: Theme.of(context).textTheme.displaySmall,
                        )
                      else
                        Column(
                          children: [
                            Icon(
                              _materialType == StudyMaterialType.image
                                  ? Icons.image
                                  : Icons.picture_as_pdf,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _fileName ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickDocument,
                    icon: const Icon(Icons.description),
                    label: const Text('Dosya Seç (PDF/Resim)'),
                  ),
                ),
                const SizedBox(height: 8),
                // Desteklenen formatlar bilgisi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Desteklenen formatlar: JPG, PNG, WEBP, GIF, BMP, HEIC, PDF',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık *',
                    hintText: 'Örn: Ders Notu - Bölüm 3',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Başlık gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (Opsiyonel)',
                    hintText: 'Materyal hakkında notlar...',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                // Upload button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadMaterial,
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Yükle & Analiz Et'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

