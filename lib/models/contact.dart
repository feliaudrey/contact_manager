import 'package:cloud_firestore/cloud_firestore.dart';

class ContactGroup {
  static const String family = 'Family';
  static const String friends = 'Friends';
  static const String work = 'Work';
  static const String other = 'Other';

  static List<String> values = [family, friends, work, other];
}

class Contact {
  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final String? photoUrl;
  final String? imageUrl; // Alias for photoUrl for backward compatibility
  final DateTime? birthday;
  final bool? birthdayReminder;
  final bool isFavorite;
  final String? groupId;
  final String? group; // For backward compatibility
  final String? notes;
  final String? address;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  Contact({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.photoUrl,
    this.imageUrl,
    this.birthday,
    this.birthdayReminder,
    this.isFavorite = false,
    this.groupId,
    this.group,
    this.notes,
    this.address,
    this.updatedAt,
    this.createdAt,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? imageUrl,
    DateTime? birthday,
    bool? birthdayReminder,
    bool? isFavorite,
    String? groupId,
    String? group,
    String? notes,
    String? address,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      imageUrl: imageUrl ?? this.imageUrl ?? this.photoUrl,
      birthday: birthday ?? this.birthday,
      birthdayReminder: birthdayReminder ?? this.birthdayReminder,
      isFavorite: isFavorite ?? this.isFavorite,
      groupId: groupId ?? this.groupId,
      group: group ?? this.group,
      notes: notes ?? this.notes,
      address: address ?? this.address,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'imageUrl': imageUrl ?? photoUrl,
      'birthday': birthday?.toIso8601String(),
      'birthdayReminder': birthdayReminder,
      'isFavorite': isFavorite,
      'groupId': groupId,
      'group': group,
      'notes': notes,
      'address': address,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Contact(
      id: docId ?? map['id'],
      name: map['name'] ?? '',
      phone: map['phone'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      imageUrl: map['imageUrl'] ?? map['photoUrl'],
      birthday: map['birthday'] != null ? DateTime.parse(map['birthday']) : null,
      birthdayReminder: map['birthdayReminder'],
      isFavorite: map['isFavorite'] ?? false,
      groupId: map['groupId'],
      group: map['group'] ?? map['groupId'],
      notes: map['notes'],
      address: map['address'],
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
} 