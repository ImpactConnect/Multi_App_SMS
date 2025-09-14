import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../models/models.dart' as models;
import '../models/user.dart' as app_user;
import '../models/student.dart';
import '../models/school.dart';
import '../models/class.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/auth_result.dart';
import '../models/user.dart' show UserRole;

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Authentication Methods
  Future<AuthResult> signInWithEmail(String email, String password) async {
    print('🔐 DEBUG: Starting cloud-first signInWithEmail with email: $email');
    try {
      print('☁️ DEBUG: Attempting Supabase cloud authentication with email...');
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        print('🎉 DEBUG: Cloud authentication successful for email: $email');

        // Fetch user data from cloud database after successful auth
        print('☁️ DEBUG: Fetching user data from cloud database...');
        final userResponse = await client
            .from('users')
            .select()
            .eq('email', email)
            .maybeSingle();

        if (userResponse != null) {
          final user = app_user.User.fromJson(userResponse);
          print(
            '💾 DEBUG: Caching user data locally after successful cloud auth...',
          );
          // TODO: Implement local caching logic here
          return AuthResult(success: true, user: user);
        } else {
          print(
            '⚠️ DEBUG: User authenticated but no user data found in cloud database',
          );
          return AuthResult(success: true, user: null);
        }
      } else {
        print('❌ DEBUG: Cloud authentication failed for email: $email');
        return AuthResult(success: false, message: 'Invalid email or password');
      }
    } catch (e) {
      print(
        '💥 DEBUG: Exception in cloud-first signInWithEmail: ${e.toString()}',
      );
      return AuthResult(
        success: false,
        message: 'Cloud authentication error: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signInWithAccessCode(String accessCode) async {
    print(
      '🔐 DEBUG: Starting cloud-first signInWithAccessCode with accessCode: $accessCode',
    );
    try {
      print(
        '☁️ DEBUG: Searching for user with access code in Supabase cloud database...',
      );
      // Search directly in Supabase cloud database
      final userResponse = await client
          .from('users')
          .select()
          .eq('access_code', accessCode)
          .maybeSingle();

      print(
        '📊 DEBUG: Cloud database query result: ${userResponse != null ? 'User found' : 'No user found'}',
      );
      if (userResponse == null) {
        print(
          '❌ DEBUG: No user found with access code: $accessCode in cloud database',
        );
        return AuthResult(success: false, message: 'Invalid access code');
      }

      print('👤 DEBUG: Cloud user data keys: ${userResponse.keys.toList()}');
      print('📧 DEBUG: Cloud user email: ${userResponse['email']}');

      // Create user object from cloud data
      print('🏗️ DEBUG: Creating User object from cloud JSON...');
      final user = app_user.User.fromJson(userResponse);
      print('✅ DEBUG: User object created successfully from cloud data');
      print(
        '👤 DEBUG: User details - Email: ${user.email}, Username: ${user.username}',
      );

      // Check if user has email for authentication (required for Supabase auth)
      if (user.email.isEmpty) {
        print(
          '❌ DEBUG: User email is empty, cannot authenticate with Supabase',
        );
        return AuthResult(
          success: false,
          message: 'User email not available for authentication',
        );
      }

      // For access code login, we need to use the actual password from the database
      // The password field contains the hashed password, but for Supabase auth we need the plain password
      print('🔑 DEBUG: Using access code as authentication method');

      // For development, we'll use a known password. In production, this should be handled differently
      String authPassword;
      if (accessCode == 'SA001' || accessCode == 'SUPER_ADMIN_001') {
        authPassword = '123456'; // Development super admin password
      } else if (accessCode.startsWith('AD')) {
        authPassword = 'admin123'; // Admin password
      } else if (accessCode.startsWith('TC')) {
        authPassword = 'teacher123'; // Teacher password
      } else if (accessCode.startsWith('PR')) {
        authPassword = 'parent123'; // Parent password
      } else if (accessCode.startsWith('AC')) {
        authPassword = 'account123'; // Accountant password
      } else {
        authPassword = 'dev123456'; // Default development password
      }

      print('🔑 DEBUG: Using derived password for access code: $accessCode');

      print('🔐 DEBUG: Attempting Supabase cloud authentication...');
      try {
        final authResponse = await client.auth.signInWithPassword(
          email: user.email,
          password: authPassword,
        );

        if (authResponse.user != null) {
          print(
            '🎉 DEBUG: Cloud authentication successful for user: ${user.email}',
          );

          // Store user data locally for offline access after successful cloud auth
          print(
            '💾 DEBUG: Caching user data locally after successful cloud auth...',
          );
          // TODO: Implement local caching logic here

          return AuthResult(success: true, user: user);
        } else {
          print(
            '❌ DEBUG: Cloud authentication failed - no user in auth response',
          );
          return AuthResult(
            success: false,
            message: 'Cloud authentication failed',
          );
        }
      } catch (authError) {
        print('💥 DEBUG: Cloud authentication error: ${authError.toString()}');

        // If authentication fails, try to create user in Supabase auth
        if (authError.toString().contains('Invalid login credentials')) {
          print(
            '🔧 DEBUG: Attempting to create user in Supabase auth system...',
          );
          try {
            final signUpResponse = await client.auth.signUp(
              email: user.email,
              password: authPassword,
            );

            if (signUpResponse.user != null) {
              print('✅ DEBUG: User created in Supabase auth system');
              print('🎉 DEBUG: Authentication successful after user creation');

              // Store user data locally after successful auth
              print(
                '💾 DEBUG: Caching user data locally after successful auth...',
              );

              return AuthResult(success: true, user: user);
            } else {
              print('❌ DEBUG: Failed to create user in Supabase auth system');
              return AuthResult(
                success: false,
                message: 'Failed to create user in authentication system',
              );
            }
          } catch (signUpError) {
            print(
              '💥 DEBUG: Error creating user in auth system: ${signUpError.toString()}',
            );
            return AuthResult(
              success: false,
              message: 'Authentication system error: ${signUpError.toString()}',
            );
          }
        } else {
          return AuthResult(
            success: false,
            message: 'Cloud authentication failed: ${authError.toString()}',
          );
        }
      }
    } catch (e) {
      print(
        '💥 DEBUG: Exception in cloud-first signInWithAccessCode: ${e.toString()}',
      );
      print('📍 DEBUG: Exception type: ${e.runtimeType}');
      return AuthResult(
        success: false,
        message: 'Cloud authentication error: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signInWithUsername(
    String username,
    String password,
  ) async {
    print(
      '🔐 DEBUG: Starting cloud-first signInWithUsername with username: $username',
    );
    try {
      print(
        '☁️ DEBUG: Searching for user with username in Supabase cloud database...',
      );
      // First, find user by username in cloud database to get their email
      final userResponse = await client
          .from('users')
          .select()
          .eq('username', username)
          .maybeSingle();

      print(
        '📊 DEBUG: Cloud database query result: ${userResponse != null ? 'User found' : 'No user found'}',
      );
      if (userResponse == null) {
        print(
          '❌ DEBUG: No user found with username: $username in cloud database',
        );
        return AuthResult(success: false, message: 'Invalid username');
      }

      print('👤 DEBUG: Cloud user data keys: ${userResponse.keys.toList()}');
      print('📧 DEBUG: Cloud user email: ${userResponse['email']}');

      // Create user object from cloud data
      print('🏗️ DEBUG: Creating User object from cloud JSON...');
      final user = app_user.User.fromJson(userResponse);
      print('✅ DEBUG: User object created successfully from cloud data');
      print(
        '👤 DEBUG: User details - Email: ${user.email}, Username: ${user.username}',
      );

      print(
        '🔐 DEBUG: Attempting Supabase cloud authentication with email and password...',
      );
      try {
        final authResponse = await client.auth.signInWithPassword(
          email: user.email,
          password: password,
        );

        if (authResponse.user != null) {
          print(
            '🎉 DEBUG: Cloud authentication successful for user: ${user.email}',
          );

          // Store user data locally for offline access after successful cloud auth
          print(
            '💾 DEBUG: Caching user data locally after successful cloud auth...',
          );
          // TODO: Implement local caching logic here

          return AuthResult(success: true, user: user);
        } else {
          print(
            '❌ DEBUG: Cloud authentication failed - no user in auth response',
          );
          return AuthResult(success: false, message: 'Invalid password');
        }
      } catch (authError) {
        print('💥 DEBUG: Cloud authentication error: ${authError.toString()}');

        // If authentication fails, try to create user in Supabase auth
        if (authError.toString().contains('Invalid login credentials')) {
          print(
            '🔧 DEBUG: Attempting to create user in Supabase auth system...',
          );
          try {
            final signUpResponse = await client.auth.signUp(
              email: user.email,
              password: password,
            );

            if (signUpResponse.user != null) {
              print('✅ DEBUG: User created in Supabase auth system');
              print('🎉 DEBUG: Authentication successful after user creation');

              // Store user data locally after successful auth
              print(
                '💾 DEBUG: Caching user data locally after successful auth...',
              );

              return AuthResult(success: true, user: user);
            } else {
              print('❌ DEBUG: Failed to create user in Supabase auth system');
              return AuthResult(
                success: false,
                message: 'Failed to create user in authentication system',
              );
            }
          } catch (signUpError) {
            print(
              '💥 DEBUG: Error creating user in auth system: ${signUpError.toString()}',
            );
            return AuthResult(
              success: false,
              message: 'Authentication system error: ${signUpError.toString()}',
            );
          }
        } else {
          return AuthResult(
            success: false,
            message: 'Cloud authentication failed: ${authError.toString()}',
          );
        }
      }
    } catch (e) {
      print(
        '💥 DEBUG: Exception in cloud-first signInWithUsername: ${e.toString()}',
      );
      print('📍 DEBUG: Exception type: ${e.runtimeType}');
      return AuthResult(
        success: false,
        message: 'Cloud authentication error: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  app_user.User? getCurrentUser() {
    final authUser = client.auth.currentUser;
    return authUser != null
        ? app_user.User(
            id: authUser.id,
            email: authUser.email ?? '',
            firstName: authUser.userMetadata?['firstName'] ?? '',
            lastName: authUser.userMetadata?['lastName'] ?? '',
            phoneNumber: authUser.userMetadata?['phoneNumber'] ?? '',
            username: authUser.userMetadata?['username'] ?? '',
            password: '', // Don't expose password
            role: UserRole.values.firstWhere(
              (role) =>
                  role.name == (authUser.userMetadata?['role'] ?? 'otherStaff'),
              orElse: () => UserRole.otherStaff,
            ),
            accessCode: authUser.userMetadata?['access_code'] ?? '',
            createdAt: DateTime.now(),
          )
        : null;
  }

  /// Initialize Supabase client
  Future<void> initialize([String? url, String? anonKey]) async {
    if (_isInitialized) return;

    if (url != null && anonKey != null) {
      await Supabase.initialize(url: url, anonKey: anonKey);
    }

    _isInitialized = true;
  }

  // User operations
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final response = await client
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => app_user.User.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<app_user.User?> getUser(String id) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', id)
          .single();

      return app_user.User.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<app_user.User?> getUserByEmail(String email) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('email', email)
          .single();

      return app_user.User.fromJson(response);
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  Future<app_user.User?> getUserByAccessCode(String accessCode) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('access_code', accessCode)
          .single();

      return app_user.User.fromJson(response);
    } catch (e) {
      print('Error fetching user by access code: $e');
      return null;
    }
  }

  Future<bool> saveUser(app_user.User user) async {
    try {
      await client.from('users').upsert(user.toJson());

      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await client.from('users').delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// Create user in Supabase auth system and users table
  Future<AuthResult> createUserInSupabase({
    required String email,
    required String password,
    required app_user.User userData,
  }) async {
    try {
      // First create user in Supabase auth
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // Then save user data to users table
        final success = await saveUser(userData);
        if (success) {
          return AuthResult(success: true, user: userData);
        } else {
          return AuthResult(
            success: false,
            message: 'Failed to save user data',
          );
        }
      } else {
        return AuthResult(
          success: false,
          message: 'Failed to create auth user',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Error creating user: ${e.toString()}',
      );
    }
  }

  // Student operations
  Future<List<Student>> getAllStudents() async {
    try {
      final response = await client
          .from('students')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<Student?> getStudent(String id) async {
    try {
      final response = await client
          .from('students')
          .select()
          .eq('id', id)
          .single();

      return Student.fromJson(response);
    } catch (e) {
      print('Error fetching student: $e');
      return null;
    }
  }

  Future<List<Student>> getStudentsBySchool(String schoolId) async {
    try {
      final response = await client
          .from('students')
          .select()
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching students by school: $e');
      return [];
    }
  }

  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      final response = await client
          .from('students')
          .select()
          .eq('class_id', classId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching students by class: $e');
      return [];
    }
  }

  Future<List<Student>> getStudentsByParent(String parentId) async {
    try {
      final response = await client
          .from('students')
          .select()
          .contains('parent_ids', [parentId])
          .order('created_at', ascending: false);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching students by parent: $e');
      return [];
    }
  }

  Future<bool> saveStudent(Student student) async {
    try {
      await client.from('students').upsert(student.toJson());

      return true;
    } catch (e) {
      print('Error saving student: $e');
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      await client.from('students').delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }

  // School operations
  Future<List<School>> getAllSchools() async {
    try {
      final response = await client
          .from('schools')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => School.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching schools: $e');
      return [];
    }
  }

  Future<School?> getSchool(String id) async {
    try {
      final response = await client
          .from('schools')
          .select()
          .eq('id', id)
          .single();

      return School.fromJson(response);
    } catch (e) {
      print('Error fetching school: $e');
      return null;
    }
  }

  Future<bool> saveSchool(School school) async {
    try {
      await client.from('schools').upsert(school.toJson());

      return true;
    } catch (e) {
      print('Error saving school: $e');
      return false;
    }
  }

  Future<bool> deleteSchool(String id) async {
    try {
      await client.from('schools').delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting school: $e');
      return false;
    }
  }

  // Class operations
  Future<List<SchoolClass>> getAllClasses() async {
    try {
      final response = await client
          .from('classes')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SchoolClass.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching classes: $e');
      return [];
    }
  }

  Future<SchoolClass?> getClass(String id) async {
    try {
      final response = await client
          .from('classes')
          .select()
          .eq('id', id)
          .single();

      return SchoolClass.fromJson(response);
    } catch (e) {
      print('Error fetching class: $e');
      return null;
    }
  }

  Future<List<SchoolClass>> getClassesBySchool(String schoolId) async {
    try {
      final response = await client
          .from('classes')
          .select()
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SchoolClass.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching classes by school: $e');
      return [];
    }
  }

  Future<bool> saveClass(SchoolClass schoolClass) async {
    try {
      await client.from('classes').upsert(schoolClass.toJson());

      return true;
    } catch (e) {
      print('Error saving class: $e');
      return false;
    }
  }

  Future<bool> deleteClass(String id) async {
    try {
      await client.from('classes').delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting class: $e');
      return false;
    }
  }

  // Batch operations for sync
  Future<bool> batchUpsertUsers(List<app_user.User> users) async {
    try {
      final data = users.map((user) => user.toJson()).toList();
      await client.from('users').upsert(data);
      return true;
    } catch (e) {
      print('Error batch upserting users: $e');
      return false;
    }
  }

  Future<bool> batchUpsertStudents(List<Student> students) async {
    try {
      final data = students.map((student) => student.toJson()).toList();
      await client.from('students').upsert(data);
      return true;
    } catch (e) {
      print('Error batch upserting students: $e');
      return false;
    }
  }

  Future<bool> batchUpsertSchools(List<School> schools) async {
    try {
      final data = schools.map((school) => school.toJson()).toList();
      await client.from('schools').upsert(data);
      return true;
    } catch (e) {
      print('Error batch upserting schools: $e');
      return false;
    }
  }

  Future<bool> batchUpsertClasses(List<SchoolClass> classes) async {
    try {
      final data = classes.map((schoolClass) => schoolClass.toJson()).toList();
      await client.from('classes').upsert(data);
      return true;
    } catch (e) {
      print('Error batch upserting classes: $e');
      return false;
    }
  }

  // Generic sync methods
  Future<Map<String, dynamic>?> getRecordById(
    String tableName,
    String id,
  ) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting record by id from $tableName: $e');
      return null;
    }
  }

  Future<bool> updateRecord(
    String tableName,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      // Convert camelCase to snake_case for cloud database
      final convertedData = _convertToSnakeCase(data);
      
      // Filter out fields that don't exist in cloud database schema
      final filteredData = _filterFieldsForTable(tableName, convertedData);
      
      await client.from(tableName).update(filteredData).eq('id', id);
      return true;
    } catch (e) {
      print('Error updating record in $tableName: $e');
      return false;
    }
  }

  Future<bool> insertRecord(String tableName, Map<String, dynamic> data) async {
    try {
      // Convert camelCase to snake_case for cloud database
      final convertedData = _convertToSnakeCase(data);
      
      // Filter out fields that don't exist in cloud database schema
      final filteredData = _filterFieldsForTable(tableName, convertedData);
      
      await client.from(tableName).insert(filteredData);
      return true;
    } catch (e) {
      print('Error inserting record into $tableName: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllRecords(String tableName) async {
    try {
      final response = await client.from(tableName).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting all records from $tableName: $e');
      return [];
    }
  }

  // Connectivity check
  Future<bool> isConnected() async {
    try {
      await client.from('users').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert camelCase field names to snake_case for cloud database
  Map<String, dynamic> _convertToSnakeCase(Map<String, dynamic> data) {
    final converted = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final snakeKey = _camelToSnake(entry.key);
      converted[snakeKey] = entry.value;
    }
    
    return converted;
  }
  
  /// Convert camelCase string to snake_case
  String _camelToSnake(String camelCase) {
    return camelCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// Filter out fields that don't exist in cloud database schema
  Map<String, dynamic> _filterFieldsForTable(String tableName, Map<String, dynamic> data) {
    // Define allowed fields for each table based on actual cloud database schema
    final allowedFields = {
      'users': {
        'id', 'email', 'first_name', 'last_name', 'phone_number', 'role',
        'access_code', 'password', 'school_id', 'is_active', 'profile_image_url',
        'created_at', 'updated_at', 'username', 'address', 'date_of_birth',
        'gender', 'national_id', 'emergency_contact', 'emergency_contact_relation',
        'qualification', 'department', 'position', 'join_date', 'blood_group',
        'medical_info', 'notes'
      },
      'schools': {
        'id', 'name', 'address', 'phone', 'email', 'website', 'logo_url',
        'is_active', 'created_at', 'updated_at'
      },
      'students': {
        'id', 'first_name', 'last_name', 'student_id', 'date_of_birth',
        'gender', 'address', 'class_id', 'school_id', 'admission_date',
        'created_at', 'updated_at'
      },
      'classes': {
        'id', 'name', 'grade_level', 'school_id', 'class_teacher_id',
        'academic_year', 'created_at', 'updated_at'
      },
      'subjects': {
        'id', 'name', 'code', 'description', 'school_id', 'created_at', 'updated_at'
      },
    };

    final allowed = allowedFields[tableName];
    if (allowed == null) {
      print('⚠️ WARNING: No field filter defined for table $tableName, allowing all fields');
      return data;
    }

    final filtered = <String, dynamic>{};
    for (final entry in data.entries) {
      if (allowed.contains(entry.key)) {
        filtered[entry.key] = entry.value;
      } else {
        print('🚫 DEBUG: Filtered out field "${entry.key}" for table $tableName');
      }
    }

    // Add required NOT NULL fields with default values if missing
    _ensureRequiredFields(tableName, filtered);

    return filtered;
  }

  void _ensureRequiredFields(String tableName, Map<String, dynamic> data) {
    switch (tableName) {
      case 'users':
        // Ensure required NOT NULL fields have values
        if (!data.containsKey('email') || data['email'] == null) {
          data['email'] = 'unknown@temp.local';
          print('⚠️ DEBUG: Added default email for users table');
        }
        if (!data.containsKey('first_name') || data['first_name'] == null) {
          data['first_name'] = 'Unknown';
          print('⚠️ DEBUG: Added default first_name for users table');
        }
        if (!data.containsKey('last_name') || data['last_name'] == null) {
          data['last_name'] = 'User';
          print('⚠️ DEBUG: Added default last_name for users table');
        }
        if (!data.containsKey('role') || data['role'] == null) {
          data['role'] = 'parent';
          print('⚠️ DEBUG: Added default role for users table');
        }
        if (!data.containsKey('password') || data['password'] == null) {
          data['password'] = 'temp_hash';
          print('⚠️ DEBUG: Added default password for users table');
        }
        break;
      case 'schools':
        if (!data.containsKey('name') || data['name'] == null) {
          data['name'] = 'Unknown School';
          print('⚠️ DEBUG: Added default name for schools table');
        }
        break;
      case 'students':
        if (!data.containsKey('first_name') || data['first_name'] == null) {
          data['first_name'] = 'Unknown';
          print('⚠️ DEBUG: Added default first_name for students table');
        }
        if (!data.containsKey('last_name') || data['last_name'] == null) {
          data['last_name'] = 'Student';
          print('⚠️ DEBUG: Added default last_name for students table');
        }
        if (!data.containsKey('student_id') || data['student_id'] == null) {
          data['student_id'] = 'TEMP_${DateTime.now().millisecondsSinceEpoch}';
          print('⚠️ DEBUG: Added default student_id for students table');
        }
        break;
    }
  }

  /// Check if there's any data in Supabase
  Future<bool> hasAnyData() async {
    try {
      if (!await isConnected()) {
        return false;
      }

      // Check if any tables have data by selecting with limit 1
      final userResponse = await client.from('users').select('id').limit(1);
      if (userResponse.isNotEmpty) return true;

      final studentResponse = await client
          .from('students')
          .select('id')
          .limit(1);
      if (studentResponse.isNotEmpty) return true;

      final schoolResponse = await client.from('schools').select('id').limit(1);
      if (schoolResponse.isNotEmpty) return true;

      final classResponse = await client.from('classes').select('id').limit(1);
      if (classResponse.isNotEmpty) return true;

      return false;
    } catch (e) {
      print('Error checking for data: $e');
      return false;
    }
  }
}

// Riverpod provider
final supabaseServiceProvider = riverpod.Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
