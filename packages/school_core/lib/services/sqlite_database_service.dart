import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class SQLiteDatabaseService {
  static Database? _database;
  static const String _databaseName = 'school_management.db';
  static const int _databaseVersion = 3; // Updated to fix classes table schema

  // Table names
  static const String usersTable = 'users';
  static const String studentsTable = 'students';
  static const String schoolsTable = 'schools';
  static const String classesTable = 'classes';
  static const String subjectsTable = 'subjects';
  static const String paymentsTable = 'payments';
  static const String messagesTable = 'messages';
  static const String eventsTable = 'events';
  static const String feedbackTable = 'feedback';
  static const String auditLogsTable = 'audit_logs';
  static const String syncHistoryTable = 'sync_history';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create users table (matching cloud schema)
    await db.execute('''
      CREATE TABLE $usersTable (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone_number TEXT,
        role TEXT NOT NULL CHECK (role IN ('parent', 'teacher', 'admin', 'superAdmin', 'accountant')),
        access_code TEXT UNIQUE,
        password_hash TEXT NOT NULL,
        school_id TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        bio TEXT,
        profile_image_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create students table (matching cloud schema)
    await db.execute('''
      CREATE TABLE $studentsTable (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        student_id TEXT NOT NULL UNIQUE,
        date_of_birth TEXT,
        gender TEXT CHECK (gender IN ('male', 'female', 'other')),
        address TEXT,
        profile_image_url TEXT,
        class_id TEXT,
        school_id TEXT NOT NULL,
        parent_ids TEXT, -- JSON array as string
        admission_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        emergency_contact TEXT, -- JSON as string
        medical_info TEXT, -- JSON as string
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create schools table (matching cloud schema)
    await db.execute('''
      CREATE TABLE $schoolsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        logo_url TEXT,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create classes table (matching cloud schema)
    await db.execute('''
      CREATE TABLE $classesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        grade TEXT NOT NULL,
        section TEXT,
        school_id TEXT NOT NULL,
        class_teacher_id TEXT,
        subject_ids TEXT, -- JSON array as string
        student_count INTEGER DEFAULT 0,
        room_number TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create subjects table (matching cloud schema)
    await db.execute('''
      CREATE TABLE $subjectsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        code TEXT UNIQUE,
        teacher_ids TEXT, -- JSON array as string
        class_ids TEXT, -- JSON array as string
        school_id TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create payments table (matching cloud schema)
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        due_date TEXT,
        status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
        payment_type TEXT NOT NULL,
        description TEXT,
        reference_number TEXT UNIQUE,
        created_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create messages table (matching cloud schema)
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        subject TEXT,
        content TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        parent_message_id TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create events table (matching cloud schema)
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        event_date TEXT NOT NULL,
        start_time TEXT,
        end_time TEXT,
        location TEXT,
        event_type TEXT,
        is_public INTEGER DEFAULT 1,
        school_id TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create feedback table (matching cloud schema)
    await db.execute('''
      CREATE TABLE feedback (
        id TEXT PRIMARY KEY,
        parent_id TEXT NOT NULL,
        student_id TEXT,
        subject TEXT NOT NULL,
        message TEXT NOT NULL,
        category TEXT,
        priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
        status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
        response TEXT,
        responded_by TEXT,
        responded_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create audit_logs table (matching cloud schema)
    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        old_values TEXT, -- JSON as string
        new_values TEXT, -- JSON as string
        ip_address TEXT,
        user_agent TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create sync history table
    await db.execute('''
      CREATE TABLE $syncHistoryTable (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        record_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        error_message TEXT
      )
    ''');

    // Create indexes for better performance (matching cloud schema)
    await db.execute('CREATE INDEX idx_users_email ON $usersTable(email)');
    await db.execute('CREATE INDEX idx_users_role ON $usersTable(role)');
    await db.execute(
      'CREATE INDEX idx_users_school_id ON $usersTable(school_id)',
    );
    await db.execute(
      'CREATE INDEX idx_users_access_code ON $usersTable(access_code)',
    );
    await db.execute(
      'CREATE INDEX idx_users_is_active ON $usersTable(is_active)',
    );

    await db.execute(
      'CREATE INDEX idx_students_student_id ON $studentsTable(student_id)',
    );
    await db.execute(
      'CREATE INDEX idx_students_class_id ON $studentsTable(class_id)',
    );
    await db.execute(
      'CREATE INDEX idx_students_school_id ON $studentsTable(school_id)',
    );
    await db.execute(
      'CREATE INDEX idx_students_is_active ON $studentsTable(is_active)',
    );

    await db.execute(
      'CREATE INDEX idx_classes_school_id ON $classesTable(school_id)',
    );
    await db.execute(
      'CREATE INDEX idx_classes_teacher_id ON $classesTable(class_teacher_id)',
    );
    await db.execute(
      'CREATE INDEX idx_classes_grade_section ON $classesTable(grade, section)',
    );
    await db.execute(
      'CREATE INDEX idx_classes_is_active ON $classesTable(is_active)',
    );

    await db.execute('CREATE INDEX idx_subjects_name ON $subjectsTable(name)');
    await db.execute('CREATE INDEX idx_subjects_code ON $subjectsTable(code)');
    await db.execute(
      'CREATE INDEX idx_subjects_school_id ON $subjectsTable(school_id)',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades here
    // For now, we'll just recreate the tables
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $usersTable');
      await db.execute('DROP TABLE IF EXISTS $studentsTable');
      await db.execute('DROP TABLE IF EXISTS $schoolsTable');
      await db.execute('DROP TABLE IF EXISTS $classesTable');
      await db.execute('DROP TABLE IF EXISTS $subjectsTable');
      await db.execute('DROP TABLE IF EXISTS $paymentsTable');
      await db.execute('DROP TABLE IF EXISTS $messagesTable');
      await db.execute('DROP TABLE IF EXISTS $eventsTable');
      await db.execute('DROP TABLE IF EXISTS $feedbackTable');
      await db.execute('DROP TABLE IF EXISTS $auditLogsTable');
      await db.execute('DROP TABLE IF EXISTS $syncHistoryTable');
      await _onCreate(db, newVersion);
    }
  }

  // User operations
  static Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      usersTable,
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<User?> getUser(String id) async {
    final db = await database;
    final maps = await db.query(usersTable, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  static Future<List<User>> getAllUsers() async {
    print('DEBUG: SQLiteDatabaseService.getAllUsers() called');
    final db = await database;
    print('DEBUG: Querying users table: $usersTable');
    final maps = await db.query(usersTable);
    print('DEBUG: Found ${maps.length} user records in database');
    if (maps.isNotEmpty) {
      print('DEBUG: First user record: ${maps.first}');
    }
    final users = maps.map((map) => _mapToUser(map)).toList();
    print('DEBUG: Converted to ${users.length} User objects');
    
    // Debug: Print all users and their roles
    for (final user in users) {
      print('🔍 DEBUG: User ${user.firstName} ${user.lastName} (${user.email}) - Role: ${user.role}');
    }
    
    return users;
  }

  static Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete(usersTable, where: 'id = ?', whereArgs: [id]);
  }

  // Student operations
  static Future<void> saveStudent(Student student) async {
    final db = await database;
    await db.insert(
      studentsTable,
      _studentToMap(student),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Student?> getStudent(String id) async {
    final db = await database;
    final maps = await db.query(
      studentsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToStudent(maps.first);
    }
    return null;
  }

  static Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query(studentsTable);
    return maps.map((map) => _mapToStudent(map)).toList();
  }

  static Future<void> deleteStudent(String id) async {
    final db = await database;
    await db.delete(studentsTable, where: 'id = ?', whereArgs: [id]);
  }

  // School operations
  static Future<void> saveSchool(School school) async {
    print(
      'DEBUG: SQLiteDatabaseService.saveSchool() called for: ${school.name}',
    );
    final db = await database;
    final schoolMap = _schoolToMap(school);
    print('DEBUG: Inserting school into table: $schoolsTable');
    await db.insert(
      schoolsTable,
      schoolMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('DEBUG: School saved successfully: ${school.name}');
  }

  static Future<School?> getSchool(String id) async {
    final db = await database;
    final maps = await db.query(schoolsTable, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return _mapToSchool(maps.first);
    }
    return null;
  }

  static Future<List<School>> getAllSchools() async {
    print('DEBUG: SQLiteDatabaseService.getAllSchools() called');
    final db = await database;
    print('DEBUG: Querying schools table: $schoolsTable');
    final maps = await db.query(schoolsTable);
    print('DEBUG: Found ${maps.length} school records in database');
    if (maps.isNotEmpty) {
      print('DEBUG: First school record: ${maps.first}');
    }
    final schools = maps.map((map) => _mapToSchool(map)).toList();
    print('DEBUG: Converted to ${schools.length} School objects');
    return schools;
  }

  // Class operations
  static Future<void> saveClass(SchoolClass schoolClass) async {
    final db = await database;
    await db.insert(
      classesTable,
      _classToMap(schoolClass),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<SchoolClass?> getClass(String id) async {
    final db = await database;
    final maps = await db.query(
      classesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToClass(maps.first);
    }
    return null;
  }

  static Future<List<SchoolClass>> getAllClasses() async {
    final db = await database;
    final maps = await db.query(classesTable);
    return maps.map((map) => _mapToClass(map)).toList();
  }

  // Subject operations
  static Future<List<Subject>> getAllSubjects() async {
    final db = await database;
    final maps = await db.query(subjectsTable);
    return maps.map((map) => _mapToSubject(map)).toList();
  }

  static Future<Subject?> getSubject(String id) async {
    final db = await database;
    final maps = await db.query(
      subjectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToSubject(maps.first);
    }
    return null;
  }

  static Future<void> saveSubject(Subject subject) async {
    final db = await database;
    await db.insert(
      subjectsTable,
      _subjectToMap(subject),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Helper methods to convert between objects and maps
  static Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'phone_number': user.phoneNumber,
      'role': user.role.name,
      'access_code': user.accessCode,
      'password_hash':
          user.password, // Changed from 'password' to 'password_hash'
      'school_id': user.schoolId,
      'is_active': user.isActive ? 1 : 0,
      'bio': user.notes, // Map notes to bio field
      'profile_image_url': user.profileImageUrl,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
      // Removed non-existent columns: username, address, date_of_birth, gender, national_id,
      // emergency_contact, emergency_contact_relation, qualification, department, position,
      // join_date, blood_group, medical_info
    };
  }

  static User _mapToUser(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phoneNumber: map['phone_number'],
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
      accessCode: map['access_code'],
      password:
          map['password_hash'], // Changed from 'password' to 'password_hash'
      schoolId: map['school_id'],
      isActive: map['is_active'] == 1,
      notes: map['bio'], // Map bio field to notes
      profileImageUrl: map['profile_image_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      // Set default values for removed fields
      username: '', // Default empty username
      address: '', // Default empty address
      dateOfBirth: null, // Default null date of birth
      gender: null, // Default null gender
      nationalId: '', // Default empty national ID
      emergencyContact: '', // Default empty emergency contact
      emergencyContactRelation: '', // Default empty emergency contact relation
      qualification: '', // Default empty qualification
      department: '', // Default empty department
      position: '', // Default empty position
      joinDate: null, // Default null join date
      bloodGroup: '', // Default empty blood group
      medicalInfo: '', // Default empty medical info
    );
  }

  static Map<String, dynamic> _studentToMap(Student student) {
    return {
      'id': student.id,
      'first_name': student.firstName,
      'last_name': student.lastName,
      'student_id': student.studentId,
      'date_of_birth': student.dateOfBirth.toIso8601String(),
      'gender': student.gender.name,
      'address': student.address,
      'profile_image_url': student.profileImageUrl,
      'class_id': student.classId,
      'school_id': student.schoolId,
      'parent_ids': student.parentIds.join(
        ',',
      ), // Simple comma-separated for now
      'admission_date': student.admissionDate.toIso8601String(),
      'is_active': student.isActive ? 1 : 0,
      'created_at': student.createdAt.toIso8601String(),
      'updated_at': student.updatedAt.toIso8601String(),
      'emergency_contact': student.emergencyContact,
      'medical_info': student.medicalInfo,
    };
  }

  static Student _mapToStudent(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      studentId: map['student_id'],
      dateOfBirth: map['date_of_birth'] != null && map['date_of_birth'].toString().isNotEmpty
          ? DateTime.parse(map['date_of_birth'])
          : DateTime.now(), // Default to current date if null
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.male, // Default fallback to prevent 'Bad state: No element'
      ),
      address: map['address'],
      profileImageUrl: map['profile_image_url'],
      classId: map['class_id'],
      schoolId: map['school_id'],
      parentIds: map['parent_ids'] != null
          ? map['parent_ids'].split(',').where((String s) => s.isNotEmpty).toList()
          : [],
      admissionDate: map['admission_date'] != null && map['admission_date'].toString().isNotEmpty
          ? DateTime.parse(map['admission_date'])
          : DateTime.now(), // Default to current date if null
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      emergencyContact: map['emergency_contact'],
      medicalInfo: map['medical_info'],
    );
  }

  static Map<String, dynamic> _schoolToMap(School school) {
    print('DEBUG: Converting school to map: ${school.name}');
    final map = {
      'id': school.id,
      'name': school.name,
      'address': school.address,
      'phone': school.phoneNumber,
      'email': school.email,
      'website': school.website,
      'logo_url': school.logoUrl,
      'description': school.description,
      'is_active': school.isActive ? 1 : 0,
      'created_at': school.createdAt.toIso8601String(),
      'updated_at': school.updatedAt.toIso8601String(),
    };
    print('DEBUG: School map created: $map');
    return map;
  }

  static School _mapToSchool(Map<String, dynamic> map) {
    return School(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phoneNumber: map['phone'],
      email: map['email'],
      website: map['website'],
      principalName: '', // Default value for removed column
      logoUrl: map['logo_url'],
      establishedDate: DateTime.now(), // Default value for removed column
      type: SchoolType.primary, // Default value for removed column
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      description: map['description'] ?? '', // Use actual description from database
      settings: null, // Default value for removed column
    );
  }

  static Map<String, dynamic> _classToMap(SchoolClass schoolClass) {
    return {
      'id': schoolClass.id,
      'name': schoolClass.name,
      'grade': schoolClass.grade,
      'section': schoolClass.section,
      'school_id': schoolClass.schoolId,
      'class_teacher_id': schoolClass.classTeacherId,
      'student_count': schoolClass.capacity,
      'room_number': schoolClass.classroom,
      'is_active': schoolClass.isActive ? 1 : 0,
      'created_at': schoolClass.createdAt.toIso8601String(),
      'updated_at': schoolClass.updatedAt.toIso8601String(),
    };
  }

  static SchoolClass _mapToClass(Map<String, dynamic> map) {
    return SchoolClass(
      id: map['id'],
      name: map['name'],
      grade: map['grade'],
      section: map['section'],
      schoolId: map['school_id'],
      classTeacherId: map['class_teacher_id'],
      capacity: map['student_count'] ?? 30, // Using student_count as capacity
      classroom: map['room_number'], // Using room_number as classroom
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  static Subject _mapToSubject(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      description: map['description'],
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  static Map<String, dynamic> _subjectToMap(Subject subject) {
    return {
      'id': subject.id,
      'name': subject.name,
      'code': subject.code,
      'description': subject.description,
      'school_id': '', // Default empty school_id - should be set by caller
      'is_active': subject.isActive ? 1 : 0,
      'created_at': subject.createdAt.toIso8601String(),
      'updated_at': subject.updatedAt.toIso8601String(),
    };
  }

  // Utility methods
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(usersTable);
    await db.delete(studentsTable);
    await db.delete(schoolsTable);
    await db.delete(classesTable);
    await db.delete(subjectsTable);
    await db.delete(syncHistoryTable);
  }

  // Seed super admin for offline mode
  static Future<void> seedSuperAdmin() async {
    print('DEBUG: Seeding super admin credentials for offline mode');

    // Check if super admin already exists
    final existingSuperAdmin = await getUserByAccessCode('SA001');
    if (existingSuperAdmin != null) {
      print('DEBUG: Super admin already exists, skipping seed');
      return;
    }

    // Create super admin user
    final superAdmin = User(
      email: 'superadmin@school.local',
      firstName: 'Super',
      lastName: 'Admin',
      phoneNumber: '+1234567890',
      role: UserRole.superAdmin,
      accessCode: 'SA001',
      username: 'superadmin',
      password: 'admin123', // In production, this should be hashed
      isActive: true,
      notes: 'Default super admin for offline mode',
    );

    await saveUser(superAdmin);
    print('DEBUG: Super admin seeded successfully with access code: SA001');
  }

  // Get user by access code for authentication
  static Future<User?> getUserByAccessCode(String accessCode) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      where: 'access_code = ?',
      whereArgs: [accessCode],
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  // Get user by email for authentication
  static Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  // Get user by username for authentication
  static Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  // Additional query methods
  static Future<List<User>> getUsersBySchool(String schoolId) async {
    final db = await database;
    final maps = await db.query(
      usersTable,
      where: 'school_id = ?',
      whereArgs: [schoolId],
    );
    return maps.map((map) => _mapToUser(map)).toList();
  }

  static Future<List<User>> getUsersByRole(UserRole role) async {
    final db = await database;
    final roleString = role.toString().split('.').last;
    print('🔍 DEBUG: Searching for users with role: $roleString');
    
    final maps = await db.query(
      usersTable,
      where: 'role = ?',
      whereArgs: [roleString],
    );
    
    print('🔍 DEBUG: Found ${maps.length} users with role $roleString');
    for (final map in maps) {
      print('🔍 DEBUG: Raw DB record - role: ${map['role']}, name: ${map['first_name']} ${map['last_name']}');
    }
    
    return maps.map((map) => _mapToUser(map)).toList();
  }

  static Future<List<SchoolClass>> getClassesBySchool(String schoolId) async {
    final db = await database;
    final maps = await db.query(
      classesTable,
      where: 'school_id = ?',
      whereArgs: [schoolId],
    );
    return maps.map((map) => _mapToClass(map)).toList();
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}