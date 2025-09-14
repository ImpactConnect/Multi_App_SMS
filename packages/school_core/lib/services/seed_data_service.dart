import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../models/student.dart' show Gender;
import 'offline_database_service.dart';
import 'sqlite_database_service.dart';
import 'supabase_service.dart';

class SeedDataService {
  final OfflineDatabaseService _dbService;
  final SupabaseService? _supabaseService;
  final _uuid = const Uuid();

  SeedDataService(this._dbService, [this._supabaseService]);

  /// Seed the database with development data
  Future<bool> seedDevelopmentData() async {
    try {
      // Check if data already exists using SQLiteDatabaseService
      final existingUsers = await SQLiteDatabaseService.getAllUsers();
      final existingSchools = await SQLiteDatabaseService.getAllSchools();
      if (existingUsers.isNotEmpty && existingSchools.isNotEmpty) {
        print('Development data already exists. Skipping seed.');
        return true;
      }
      print('Creating development data...');

      // Create development school
      final school = await _createDevelopmentSchool();

      // Create development users
      await _createDevelopmentUsers(school.id);

      // Create development classes
      final classes = await _createDevelopmentClasses(school.id);

      // Create development students
      await _createDevelopmentStudents(school.id, classes);

      print('Development data seeded successfully!');
      return true;
    } catch (e) {
      print('Failed to seed development data: $e');
      return false;
    }
  }

  Future<School> _createDevelopmentSchool() async {
    final school = School(
      id: _uuid.v4(),
      name: 'Demo High School',
      address: '123 Education Street, Learning City, LC 12345',
      phoneNumber: '+1-555-0123',
      email: 'info@demohighschool.edu',
      website: 'https://demohighschool.edu',
      principalName: 'Dr. Sarah Johnson',
      logoUrl: null,
      establishedDate: DateTime(1995, 9, 1),
      type: SchoolType.secondary,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description:
          'A premier educational institution focused on academic excellence and character development.',
      settings: {
        'academic_year_start': '2024-09-01',
        'academic_year_end': '2025-06-30',
        'grading_system': 'A-F',
        'max_students_per_class': 30,
      },
    );

    await SQLiteDatabaseService.saveSchool(school);
    print('Development school created: ${school.name}');
    return school;
  }

  Future<void> _createDevelopmentUsers(String schoolId) async {
    final users = [
      // Super Admin
      {
        'email': 'superadmin@schoolsystem.dev',
        'firstName': 'John',
        'lastName': 'Administrator',
        'phoneNumber': '+1-555-0001',
        'role': UserRole.superAdmin,
        'accessCode': 'SUPER_ADMIN_001',
        'password': 'dev123456',
        'schoolId': null, // Super admin can access all schools
      },
      // School Admin
      {
        'email': 'admin@demohighschool.edu',
        'firstName': 'John',
        'lastName': 'Administrator',
        'phoneNumber': '+1-555-0002',
        'role': UserRole.admin,
        'accessCode': 'AD001',
        'password': 'admin123',
        'schoolId': schoolId,
      },
      // Teachers
      {
        'email': 'math.teacher@demohighschool.edu',
        'firstName': 'Emily',
        'lastName': 'Mathematics',
        'phoneNumber': '+1-555-0003',
        'role': UserRole.teacher,
        'accessCode': 'TC001',
        'password': 'teacher123',
        'schoolId': schoolId,
      },
      {
        'email': 'english.teacher@demohighschool.edu',
        'firstName': 'Michael',
        'lastName': 'Literature',
        'phoneNumber': '+1-555-0004',
        'role': UserRole.teacher,
        'accessCode': 'TC002',
        'password': 'teacher123',
        'schoolId': schoolId,
      },
      {
        'email': 'science.teacher@demohighschool.edu',
        'firstName': 'Dr. Lisa',
        'lastName': 'Chemistry',
        'phoneNumber': '+1-555-0005',
        'role': UserRole.teacher,
        'accessCode': 'TC003',
        'password': 'teacher123',
        'schoolId': schoolId,
      },
      // Accountant
      {
        'email': 'accountant@demohighschool.edu',
        'firstName': 'Robert',
        'lastName': 'Finance',
        'phoneNumber': '+1-555-0006',
        'role': UserRole.accountant,
        'accessCode': 'AC001',
        'password': 'account123',
        'schoolId': schoolId,
      },
      // Parents
      {
        'email': 'parent1@email.com',
        'firstName': 'David',
        'lastName': 'Smith',
        'phoneNumber': '+1-555-0007',
        'role': UserRole.parent,
        'accessCode': 'PR001',
        'password': 'parent123',
        'schoolId': schoolId,
      },
      {
        'email': 'parent2@email.com',
        'firstName': 'Maria',
        'lastName': 'Garcia',
        'phoneNumber': '+1-555-0008',
        'role': UserRole.parent,
        'accessCode': 'PR002',
        'password': 'parent123',
        'schoolId': schoolId,
      },
      {
        'email': 'parent3@email.com',
        'firstName': 'James',
        'lastName': 'Johnson',
        'phoneNumber': '+1-555-0009',
        'role': UserRole.parent,
        'accessCode': 'PR003',
        'password': 'parent123',
        'schoolId': schoolId,
      },
    ];

    for (final userData in users) {
      // Create user directly in Supabase (cloud-first approach)
      if (_supabaseService != null) {
        try {
          // Create user object
          final user = User(
            id: _uuid.v4(),
            email: userData['email'] as String,
            firstName: userData['firstName'] as String,
            lastName: userData['lastName'] as String,
            phoneNumber: userData['phoneNumber'] as String,
            role: userData['role'] as UserRole,
            accessCode: userData['accessCode'] as String,
            username:
                userData['username'] as String? ?? userData['email'] as String,
            schoolId: userData['schoolId'] as String?,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _supabaseService!.createUserInSupabase(
            email: userData['email'] as String,
            password: userData['password'] as String,
            userData: user,
          );
          print('✅ Created user in Supabase: ${userData['email']}');

          // Also save to local database for offline access
          await SQLiteDatabaseService.saveUser(user);
          print('✅ Cached user locally: ${userData['email']}');
        } catch (e) {
          print('❌ Failed to create user: ${userData['email']}, error: $e');
        }
      } else {
        print('⚠️ Supabase service not available, skipping user creation');
      }
    }
  }

  Future<List<SchoolClass>> _createDevelopmentClasses(String schoolId) async {
    final teachers = await SQLiteDatabaseService.getUsersByRole(
      UserRole.teacher,
    );

    final classes = [
      {
        'name': 'Mathematics 101',
        'grade': '9',
        'section': 'A',
        'teacherId': teachers.isNotEmpty ? teachers[0].id : null,
        'capacity': 30,
        'classroom': 'Room 101',
      },
      {
        'name': 'English Literature',
        'grade': '10',
        'section': 'A',
        'teacherId': teachers.length > 1 ? teachers[1].id : null,
        'capacity': 25,
        'classroom': 'Room 201',
      },
      {
        'name': 'Chemistry',
        'grade': '11',
        'section': 'A',
        'teacherId': teachers.length > 2 ? teachers[2].id : null,
        'capacity': 20,
        'classroom': 'Lab 301',
      },
      {
        'name': 'Mathematics 102',
        'grade': '9',
        'section': 'B',
        'teacherId': teachers.isNotEmpty ? teachers[0].id : null,
        'capacity': 30,
        'classroom': 'Room 102',
      },
      {
        'name': 'Physics',
        'grade': '12',
        'section': 'A',
        'teacherId': teachers.length > 2 ? teachers[2].id : null,
        'capacity': 18,
        'classroom': 'Lab 401',
      },
    ];

    final createdClasses = <SchoolClass>[];

    for (final classData in classes) {
      final schoolClass = SchoolClass(
        id: _uuid.v4(),
        name: classData['name'] as String,
        grade: classData['grade'] as String,
        section: classData['section'] as String,
        schoolId: schoolId,
        classTeacherId: classData['teacherId'] as String?,
        capacity: classData['capacity'] as int,
        classroom: classData['classroom'] as String,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subjectIds: [], // Will be populated later
        schedule: {
          'monday': ['08:00-09:00', '10:00-11:00'],
          'tuesday': ['08:00-09:00', '10:00-11:00'],
          'wednesday': ['08:00-09:00', '10:00-11:00'],
          'thursday': ['08:00-09:00', '10:00-11:00'],
          'friday': ['08:00-09:00', '10:00-11:00'],
        },
      );

      await SQLiteDatabaseService.saveClass(schoolClass);
      createdClasses.add(schoolClass);
    }

    return createdClasses;
  }

  Future<void> _createDevelopmentStudents(
    String schoolId,
    List<SchoolClass> classes,
  ) async {
    final parents = await SQLiteDatabaseService.getUsersByRole(UserRole.parent);

    final students = [
      {
        'firstName': 'Alice',
        'lastName': 'Smith',
        'studentId': 'STU001',
        'dateOfBirth': DateTime(2008, 3, 15),
        'gender': Gender.female,
        'address': '456 Student Lane, Learning City, LC 12346',
        'classId': classes.isNotEmpty ? classes[0].id : '',
        'parentIds': parents.isNotEmpty ? [parents[0].id] : <String>[],
        'emergencyContact': '+1-555-0107',
        'medicalInfo': 'No known allergies',
      },
      {
        'firstName': 'Bob',
        'lastName': 'Johnson',
        'studentId': 'STU002',
        'dateOfBirth': DateTime(2007, 7, 22),
        'gender': Gender.male,
        'address': '789 Learning Ave, Learning City, LC 12347',
        'classId': classes.length > 1 ? classes[1].id : '',
        'parentIds': parents.length > 2 ? [parents[2].id] : <String>[],
        'emergencyContact': '+1-555-0109',
        'medicalInfo': 'Asthma - carries inhaler',
      },
      {
        'firstName': 'Carmen',
        'lastName': 'Garcia',
        'studentId': 'STU003',
        'dateOfBirth': DateTime(2006, 11, 8),
        'gender': Gender.female,
        'address': '321 Education Blvd, Learning City, LC 12348',
        'classId': classes.length > 2 ? classes[2].id : '',
        'parentIds': parents.length > 1 ? [parents[1].id] : <String>[],
        'emergencyContact': '+1-555-0108',
        'medicalInfo': 'Vegetarian diet',
      },
      {
        'firstName': 'David',
        'lastName': 'Wilson',
        'studentId': 'STU004',
        'dateOfBirth': DateTime(2008, 1, 30),
        'gender': Gender.male,
        'address': '654 Knowledge St, Learning City, LC 12349',
        'classId': classes.length > 3 ? classes[3].id : classes[0].id,
        'parentIds': parents.isNotEmpty ? [parents[0].id] : <String>[],
        'emergencyContact': '+1-555-0107',
        'medicalInfo': 'Wears glasses',
      },
      {
        'firstName': 'Emma',
        'lastName': 'Brown',
        'studentId': 'STU005',
        'dateOfBirth': DateTime(2005, 9, 12),
        'gender': Gender.female,
        'address': '987 Scholar Road, Learning City, LC 12350',
        'classId': classes.length > 4 ? classes[4].id : classes[0].id,
        'parentIds': parents.length > 1 ? [parents[1].id] : <String>[],
        'emergencyContact': '+1-555-0108',
        'medicalInfo': 'No medical conditions',
      },
    ];

    for (final studentData in students) {
      final student = Student(
        id: _uuid.v4(),
        firstName: studentData['firstName'] as String,
        lastName: studentData['lastName'] as String,
        studentId: studentData['studentId'] as String,
        dateOfBirth: studentData['dateOfBirth'] as DateTime,
        gender: studentData['gender'] as Gender,
        address: studentData['address'] as String,
        profileImageUrl: null,
        classId: studentData['classId'] as String,
        schoolId: schoolId,
        parentIds: studentData['parentIds'] as List<String>,
        admissionDate: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        emergencyContact: studentData['emergencyContact'] as String,
        medicalInfo: studentData['medicalInfo'] as String,
      );

      await SQLiteDatabaseService.saveStudent(student);
    }
  }

  /// Clear all development data
  Future<void> clearDevelopmentData() async {
    await SQLiteDatabaseService.clearAllData();
    print('Development data cleared successfully!');
  }

  /// Get development login credentials summary
  Map<String, dynamic> getDevelopmentCredentials() {
    return {
      'super_admin': {
        'access_code': 'SA001',
        'password': 'admin123',
        'email': 'superadmin@demo.com',
      },
      'admin': {
        'access_code': 'AD001',
        'password': 'admin123',
        'email': 'admin@demohighschool.edu',
      },
      'teacher': {
        'access_code': 'TC001',
        'password': 'teacher123',
        'email': 'math.teacher@demohighschool.edu',
      },
      'accountant': {
        'access_code': 'AC001',
        'password': 'account123',
        'email': 'accountant@demohighschool.edu',
      },
      'parent': {
        'access_code': 'PR001',
        'password': 'parent123',
        'email': 'parent1@email.com',
      },
    };
  }
}
