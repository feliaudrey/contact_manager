import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      phone: firebaseUser.phoneNumber,
    );
  }

  // Auth state changes stream
  Stream<User?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      // Get additional user data from Firestore
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;
      
      return User.fromMap(doc.data()!, firebaseUser.uid);
    });
  }

  // Sign up with email and password
  Future<User> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        id: userCredential.user!.uid,
        email: email,
        name: name ?? '',
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(user.id).set(user.toMap());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      return User.fromMap(doc.data()!, userCredential.user!.uid);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firestore profile first
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (phoneNumber != null) updates['phone'] = phoneNumber;

      await _firestore.collection('users').doc(user.uid).update(updates);

      // Update Firebase Auth profile
      // Note: We don't update photoURL in Auth since we're using base64
      if (name != null) await user.updateDisplayName(name);
    } catch (e) {
      rethrow;
    }
  }
} 