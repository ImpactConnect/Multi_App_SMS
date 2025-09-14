import 'package:uuid/uuid.dart';

// part 'subject.g.dart'; // Commented out for now

class Subject {
  String id;
  String name;
  String? description;
  String? code;
  int? credits;
  String? department;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> teacherIds;
  List<String> classIds;

  Subject({
    String? id,
    required this.name,
    this.description,
    this.code,
    this.credits,
    this.department,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? teacherIds,
    List<String>? classIds,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       teacherIds = teacherIds ?? [],
       classIds = classIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'code': code,
      'credits': credits,
      'department': department,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'teacherIds': teacherIds,
      'classIds': classIds,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      code: json['code'],
      credits: json['credits'],
      department: json['department'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      teacherIds: List<String>.from(json['teacherIds'] ?? []),
      classIds: List<String>.from(json['classIds'] ?? []),
    );
  }

  Subject copyWith({
    String? name,
    String? description,
    String? code,
    int? credits,
    String? department,
    bool? isActive,
    List<String>? teacherIds,
    List<String>? classIds,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      teacherIds: teacherIds ?? this.teacherIds,
      classIds: classIds ?? this.classIds,
    );
  }
}
