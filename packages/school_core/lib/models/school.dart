import 'package:uuid/uuid.dart';

// part 'school.g.dart'; // Commented out for now

class School {
  String id;
  String name;
  String address;
  String phoneNumber;
  String email;
  String? website;
  String principalName;
  String? logoUrl;
  DateTime establishedDate;
  SchoolType type;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String? description;
  Map<String, dynamic>? settings;

  School({
    String? id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    this.website,
    required this.principalName,
    this.logoUrl,
    required this.establishedDate,
    required this.type,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.description,
    this.settings,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'principalName': principalName,
      'logoUrl': logoUrl,
      'establishedDate': establishedDate.toIso8601String(),
      'type': type.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'settings': settings,
    };
  }

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      principalName: json['principalName'] ?? '',
      logoUrl: json['logoUrl'],
      establishedDate: json['establishedDate'] != null && json['establishedDate'].toString().isNotEmpty
          ? DateTime.parse(json['establishedDate'])
          : DateTime.now(),
      type: SchoolType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SchoolType.primary,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null && json['createdAt'].toString().isNotEmpty
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null && json['updatedAt'].toString().isNotEmpty
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      description: json['description'],
      settings: json['settings'] != null
          ? Map<String, dynamic>.from(json['settings'])
          : null,
    );
  }

  School copyWith({
    String? name,
    String? address,
    String? phoneNumber,
    String? email,
    String? website,
    String? principalName,
    String? logoUrl,
    DateTime? establishedDate,
    SchoolType? type,
    bool? isActive,
    String? description,
    Map<String, dynamic>? settings,
  }) {
    return School(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      principalName: principalName ?? this.principalName,
      logoUrl: logoUrl ?? this.logoUrl,
      establishedDate: establishedDate ?? this.establishedDate,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      description: description ?? this.description,
      settings: settings ?? this.settings,
    );
  }
}

enum SchoolType { primary, secondary, combined, international, vocational }
