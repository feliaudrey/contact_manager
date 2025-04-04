import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact.dart';

class ContactService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Contact>> getContacts() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _db
        .collection('contacts')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contact.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<Contact> getContact(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _db.collection('contacts').doc(id).get();
    final data = doc.data();
    if (data == null) throw Exception('Contact not found');
    if (data['userId'] != userId) throw Exception('Unauthorized access');
    
    return Contact.fromMap(data, doc.id);
  }

  Future<void> addContact(Contact contact) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final data = contact.toMap();
    data['userId'] = userId;
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();

    await _db.collection('contacts').add(data);
  }

  Future<void> updateContact(Contact contact) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final data = contact.toMap();
    data['updatedAt'] = DateTime.now().toIso8601String();

    final doc = await _db.collection('contacts').doc(contact.id).get();
    if (!doc.exists) throw Exception('Contact not found');
    if (doc.data()?['userId'] != userId) throw Exception('Unauthorized access');

    await _db.collection('contacts').doc(contact.id).update(data);
  }

  Future<void> deleteContact(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _db.collection('contacts').doc(id).get();
    if (!doc.exists) throw Exception('Contact not found');
    if (doc.data()?['userId'] != userId) throw Exception('Unauthorized access');

    await _db.collection('contacts').doc(id).delete();
  }

  Stream<List<String>> getGroups() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('contacts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final groups = <String>{};
      for (var doc in snapshot.docs) {
        final group = doc.data()['group'] as String?;
        if (group != null && group.isNotEmpty) {
          groups.add(group);
        }
      }
      return groups.toList()..sort();
    });
  }

  Future<void> addGroup(String groupName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Groups are created implicitly when contacts are added to them
    // This method exists for consistency but doesn't need to do anything
    return;
  }

  Future<void> deleteGroup(String groupName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final batch = _db.batch();
    final snapshot = await _db
        .collection('contacts')
        .where('userId', isEqualTo: userId)
        .where('group', isEqualTo: groupName)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'group': null});
    }

    await batch.commit();
  }

  Future<void> renameGroup(String oldName, String newName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final batch = _db.batch();
    final snapshot = await _db
        .collection('contacts')
        .where('userId', isEqualTo: userId)
        .where('group', isEqualTo: oldName)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'group': newName});
    }

    await batch.commit();
  }

  Stream<List<Contact>> getContactsByGroup(String groupName) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('contacts')
        .where('userId', isEqualTo: userId)
        .where('group', isEqualTo: groupName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Contact.fromMap(doc.data(), doc.id))
            .toList());
  }
} 