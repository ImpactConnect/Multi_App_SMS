// import 'package:hive/hive.dart'; // Hive disabled
import 'package:uuid/uuid.dart';
import 'student.dart' show Gender;

// part 'user.g.dart'; // Commented out for now

class User {
  String id;
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  UserRole role;
  String? profileImageUrl;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String? schoolId;
  String accessCode;

  // Authentication fields
  String username;
  String? password; // This will be hashed in production, nullable for security

  // Bio data fields
  String? address;
  DateTime? dateOfBirth;
  Gender? gender;
  String? nationalId;
  String? emergencyContact;
  String? emergencyContactRelation;
  String? qualification;
  String? department;
  String? position;
  DateTime? joinDate;
  String? bloodGroup;
  String? medicalInfo;
  String? notes;

  User({
    String? id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.schoolId,
    required this.accessCode,
    required this.username,
    this.password,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.nationalId,
    this.emergencyContact,
    this.emergencyContactRelation,
    this.qualification,
    this.department,
    this.position,
    this.joinDate,
    this.bloodGroup,
    this.medicalInfo,
    this.notes,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'schoolId': schoolId,
      'accessCode': accessCode,
      'username': username,
      'password': password,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender?.name,
      'nationalId': nationalId,
      'emergencyContact': emergencyContact,
      'emergencyContactRelation': emergencyContactRelation,
      'qualification': qualification,
      'department': department,
      'position': position,
      'joinDate': joinDate?.toIso8601String(),
      'bloodGroup': bloodGroup,
      'medicalInfo': medicalInfo,
      'notes': notes,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.otherStaff,
      ),
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      schoolId: json['schoolId'],
      accessCode: json['accessCode'] ?? '',
      username: json['username'] ?? '',
      password: json['password'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'] != null
          ? Gender.values.firstWhere((e) => e.name == json['gender'])
          : null,
      nationalId: json['nationalId'],
      emergencyContact: json['emergencyContact'],
      emergencyContactRelation: json['emergencyContactRelation'],
      qualification: json['qualification'],
      department: json['department'],
      position: json['position'],
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : null,
      bloodGroup: json['bloodGroup'],
      medicalInfo: json['medicalInfo'],
      notes: json['notes'],
    );
  }

  User copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole? role,
    String? profileImageUrl,
    bool? isActive,
    String? schoolId,
    String? accessCode,
    String? username,
    String? password,
    String? address,
    DateTime? dateOfBirth,
    Gender? gender,
    String? nationalId,
    String? emergencyContact,
    String? emergencyContactRelation,
    String? qualification,
    String? department,
    String? position,
    DateTime? joinDate,
    String? bloodGroup,
    String? medicalInfo,
    String? notes,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      schoolId: schoolId ?? this.schoolId,
      accessCode: accessCode ?? this.accessCode,
      username: username ?? this.username,
      password: password ?? this.password,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationalId: nationalId ?? this.nationalId,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      qualification: qualification ?? this.qualification,
      department: department ?? this.department,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      notes: notes ?? this.notes,
    );
  }
}

enum UserRole { superAdmin, admin, teacher, accountant, parent, otherStaff }
