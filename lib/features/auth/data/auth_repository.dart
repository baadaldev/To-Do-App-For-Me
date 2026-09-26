import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class IAuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password, String displayName);
  Future<UserCredential?> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class AuthRepository implements IAuthRepository {
  FirebaseAuth? _firebaseAuth;
  GoogleSignIn? _googleSignIn;
  bool _googleSignInInitialized = false;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  FirebaseAuth? get _auth {
    try {
      _firebaseAuth ??= FirebaseAuth.instance;
      return _firebaseAuth;
    } catch (e) {
      debugPrint('FirebaseAuth unavailable (running offline-first): $e');
      return null;
    }
  }

  GoogleSignIn? get _google {
    try {
      _googleSignIn ??= GoogleSignIn.instance;
      return _googleSignIn;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<User?> get authStateChanges {
    try {
      return _auth?.authStateChanges() ?? const Stream.empty();
    } catch (_) {
      return const Stream.empty();
    }
  }

  @override
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw UnsupportedError('FirebaseAuth not initialized');
    }
    return await auth
        .signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        )
        .timeout(const Duration(seconds: 4));
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password, String displayName) async {
    final auth = _auth;
    if (auth == null) {
      throw UnsupportedError('FirebaseAuth not initialized');
    }
    final credential = await auth
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        )
        .timeout(const Duration(seconds: 4));
    await credential.user?.updateDisplayName(displayName.trim());
    return credential;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    final google = _google;
    if (auth == null || google == null) {
      throw UnsupportedError('Google Auth not available in offline environment');
    }

    if (!_googleSignInInitialized) {
      await google.initialize();
      _googleSignInInitialized = true;
    }

    final googleUser = await google.authenticate();
    final accessToken = (await googleUser.authorizationClient.authorizeScopes([
      'email',
    ])).accessToken;
    final googleAuth = googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: googleAuth.idToken,
    );

    return await auth.signInWithCredential(credential).timeout(const Duration(seconds: 4));
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.sendPasswordResetEmail(email: email.trim()).timeout(const Duration(seconds: 4));
      } catch (_) {}
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _google?.signOut();
    } catch (_) {}
    try {
      await _auth?.signOut();
    } catch (_) {}
  }
}
