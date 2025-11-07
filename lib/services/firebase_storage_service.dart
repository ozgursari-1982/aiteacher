import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Upload study material file
  Future<String> uploadStudyMaterial(File file, String studentId, String courseId) async {
    try {
      final String fileName = '${_uuid.v4()}_${file.path.split('/').last}';
      final String path = 'students/$studentId/courses/$courseId/materials/$fileName';
      
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putFile(file);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Dosya yüklenirken hata oluştu: $e';
    }
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw 'Dosya silinirken hata oluştu: $e';
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      throw 'Dosya bilgisi alınırken hata oluştu: $e';
    }
  }
}

