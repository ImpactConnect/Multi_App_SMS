import 'package:uuid/uuid.dart';

// part 'class.g.dart'; // Commented out for now

class SchoolClass {
  String id;
  String name;
  String grade;
  String section;
  String schoolId;
  String? classTeacherId;
  int capacity;
  String? classroom;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> subjectIds;
  Map<String, dynamic>? schedule;

  SchoolClass({
    String? id,
    required this.name,
    required this.grade,
    required this.section,
    required this.schoolId,
    this.classTeacherId,
    this.capacity = 30,
    this.classroom,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? subjectIds,
    this.schedule,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       subjectIds = subjectIds ?? [];

  String get fullName => '$grade $section';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'section': section,
      'schoolId': schoolId,
      'classTeacherId': classTeacherId,
      'capacity': capacity,
      'classroom': classroom,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'subjectIds': subjectIds,
      'schedule': schedule,
    };
  }

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      section: json['section'],
      schoolId: json['schoolId'],
      classTeacherId: json['classTeacherId'],
      capacity: json['capacity'] ?? 30,
      classroom: json['classroom'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      subjectIds: List<String>.from(json['subjectIds'] ?? []),
      schedule: json['schedule'] != null
          ? Map<String, dynamic>.from(json['schedule'])
          : null,
    );
  }

  SchoolClass copyWith({
    String? name,
    String? grade,
    String? section,
    String? schoolId,
    String? classTeacherId,
    int? capacity,
    String? classroom,
    bool? isActive,
    List<String>? subjectIds,
    Map<String, dynamic>? schedule,
  }) {
    return SchoolClass(
      id: id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      schoolId: schoolId ?? this.schoolId,
      classTeacherId: classTeacherId ?? this.classTeacherId,
      capacity: capacity ?? this.capacity,
      classroom: classroom ?? this.classroom,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      subjectIds: subjectIds ?? this.subjectIds,
      schedule: schedule ?? this.schedule,
    );
  }
}
