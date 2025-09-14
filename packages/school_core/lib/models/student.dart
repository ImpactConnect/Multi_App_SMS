import 'package:uuid/uuid.dart';

// part 'student.g.dart'; // Commented out for now

class Student {
  String id;
  String firstName;
  String lastName;
  String studentId;
  DateTime dateOfBirth;
  Gender gender;
  String address;
  String? profileImageUrl;
  String classId;
  String schoolId;
  List<String> parentIds;
  DateTime admissionDate;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String? emergencyContact;
  String? medicalInfo;

  Student({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    this.profileImageUrl,
    required this.classId,
    required this.schoolId,
    List<String>? parentIds,
    DateTime? admissionDate,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.emergencyContact,
    this.medicalInfo,
  }) : id = id ?? const Uuid().v4(),
       parentIds = parentIds ?? [],
       admissionDate = admissionDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'studentId': studentId,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender.name,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'classId': classId,
      'schoolId': schoolId,
      'parentIds': parentIds,
      'admissionDate': admissionDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'emergencyContact': emergencyContact,
      'medicalInfo': medicalInfo,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? const Uuid().v4(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      studentId: json['studentId'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null && json['dateOfBirth'].toString().isNotEmpty
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime.now(), // Default to current date if null
      gender: Gender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => Gender.male, // Default fallback to prevent 'Bad state: No element'
      ),
      address: json['address'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      classId: json['classId'] ?? '',
      schoolId: json['schoolId'] ?? '',
      parentIds: List<String>.from(json['parentIds'] ?? []),
      admissionDate: json['admissionDate'] != null && json['admissionDate'].toString().isNotEmpty
          ? DateTime.parse(json['admissionDate'])
          : DateTime.now(), // Default to current date if null
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null && json['createdAt'].toString().isNotEmpty
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null && json['updatedAt'].toString().isNotEmpty
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      emergencyContact: json['emergencyContact'],
      medicalInfo: json['medicalInfo'],
    );
  }

  Student copyWith({
    String? firstName,
    String? lastName,
    String? studentId,
    DateTime? dateOfBirth,
    Gender? gender,
    String? address,
    String? profileImageUrl,
    String? classId,
    String? schoolId,
    List<String>? parentIds,
    DateTime? admissionDate,
    bool? isActive,
    String? emergencyContact,
    String? medicalInfo,
  }) {
    return Student(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentId: studentId ?? this.studentId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      classId: classId ?? this.classId,
      schoolId: schoolId ?? this.schoolId,
      parentIds: parentIds ?? this.parentIds,
      admissionDate: admissionDate ?? this.admissionDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalInfo: medicalInfo ?? this.medicalInfo,
    );
  }
}

enum Gender { male, female, other }
