import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign Up
  Future<User?> signUpWithEmail(String email, String password, String fullName) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create student document
        final student = Student(
          id: credential.user!.uid,
          fullName: fullName,
          email: email,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('students').doc(credential.user!.uid).set(student.toMap());
        
        // Update display name
        await credential.user!.updateDisplayName(fullName);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email & Password Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      // Google ile oturum açma akışını başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanıcı oturum açmayı iptal etti
        return null;
      }

      // Google kimlik doğrulama bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase kimlik bilgisi oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile oturum aç
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Kullanıcı bilgilerini yenile (pigeonuserdetails hatasını önlemek için)
      if (userCredential.user != null) {
        await userCredential.user!.reload();
        final updatedUser = _auth.currentUser;
        
        // Eğer kullanıcı ilk defa Google ile giriş yapıyorsa Firestore'a kaydet
        if (updatedUser != null) {
          final doc = await _firestore.collection('students').doc(updatedUser.uid).get();
          
          if (!doc.exists) {
            // Google hesabından gelen bilgileri kullan (fallback olarak)
            final displayName = updatedUser.displayName ?? googleUser.displayName ?? '';
            final email = updatedUser.email ?? googleUser.email;
            final photoUrl = updatedUser.photoURL ?? googleUser.photoUrl;
            
            final student = Student(
              id: updatedUser.uid,
              fullName: displayName,
              email: email ?? '',
              photoUrl: photoUrl,
              createdAt: DateTime.now(),
            );
            
            await _firestore.collection('students').doc(updatedUser.uid).set(student.toMap());
          }
          
          return updatedUser;
        }
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Google ile oturum açma hatası: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Hata yönetimi ekle
      print('Şifre sıfırlama hatası: $e');
      rethrow;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem devre dışı bırakılmış.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}

