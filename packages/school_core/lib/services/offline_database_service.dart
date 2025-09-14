// SQLite-based offline database service
import '../models/models.dart';
import 'sqlite_database_service.dart';

class OfflineDatabaseService {
  static OfflineDatabaseService? _instance;
  static OfflineDatabaseService get instance =>
      _instance ??= OfflineDatabaseService._();

  OfflineDatabaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize SQLite database
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await SQLiteDatabaseService.database; // Initialize database
      print('DEBUG: OfflineDatabaseService initialized with SQLite');
      _isInitialized = true;
    } catch (e) {
      print('ERROR: Failed to initialize OfflineDatabaseService: $e');
      rethrow;
    }
  }

  // User operations
  Future<void> saveUser(User user) async {
    await SQLiteDatabaseService.saveUser(user);
  }
  
  Future<User?> getUser(String id) async {
    return await SQLiteDatabaseService.getUser(id);
  }
  
  Future<User?> getUserByEmail(String email) async {
    return await SQLiteDatabaseService.getUserByEmail(email);
  }
  
  Future<User?> getUserByAccessCode(String accessCode) async {
    return await SQLiteDatabaseService.getUserByAccessCode(accessCode);
  }
  
  User? getUserByUsername(String username) {
    // SQLite service doesn't have this method, return null for now
    return null;
  }
  Future<List<User>> getAllUsers() async {
    return await SQLiteDatabaseService.getAllUsers();
  }
  
  Future<List<User>> getUsersByRole(UserRole role) async {
    return await SQLiteDatabaseService.getUsersByRole(role);
  }
  
  Future<List<User>> getUsersBySchool(String schoolId) async {
    return await SQLiteDatabaseService.getUsersBySchool(schoolId);
  }
  
  Future<void> deleteUser(String id) async {
    await SQLiteDatabaseService.deleteUser(id);
  }

  // Student operations
  Future<void> saveStudent(Student student) async {
    await SQLiteDatabaseService.saveStudent(student);
  }
  
  Future<Student?> getStudent(String id) async {
    return await SQLiteDatabaseService.getStudent(id);
  }
  
  Future<List<Student>> getAllStudents() async {
    return await SQLiteDatabaseService.getAllStudents();
  }
  
  Future<List<Student>> getStudentsByClass(String classId) async {
    // TODO: Implement getStudentsByClass in SQLiteDatabaseService
    print('getStudentsByClass not yet implemented in SQLiteDatabaseService');
    return [];
  }
  
  Future<List<Student>> getStudentsBySchool(String schoolId) async {
    // TODO: Implement getStudentsBySchool in SQLiteDatabaseService
    print('getStudentsBySchool not yet implemented in SQLiteDatabaseService');
    return [];
  }
  
  Future<List<Student>> getStudentsByParent(String parentId) async {
    // TODO: Implement getStudentsByParent in SQLiteDatabaseService
    print('getStudentsByParent not yet implemented in SQLiteDatabaseService');
    return [];
  }
  
  Future<void> deleteStudent(String id) async {
    await SQLiteDatabaseService.deleteStudent(id);
  }

  // School operations
  Future<void> saveSchool(School school) async {
    await SQLiteDatabaseService.saveSchool(school);
  }
  
  Future<School?> getSchool(String id) async {
    return await SQLiteDatabaseService.getSchool(id);
  }
  
  Future<List<School>> getAllSchools() async {
    return await SQLiteDatabaseService.getAllSchools();
  }
  
  Future<void> deleteSchool(String id) async {
    // TODO: Implement deleteSchool in SQLiteDatabaseService
    print('deleteSchool not yet implemented in SQLiteDatabaseService');
  }

  // Class operations
  Future<void> saveClass(SchoolClass schoolClass) async {
    await SQLiteDatabaseService.saveClass(schoolClass);
  }
  
  Future<SchoolClass?> getClass(String id) async {
    return await SQLiteDatabaseService.getClass(id);
  }
  
  Future<List<SchoolClass>> getAllClasses() async {
    return await SQLiteDatabaseService.getAllClasses();
  }
  
  Future<List<SchoolClass>> getClassesBySchool(String schoolId) async {
    return await SQLiteDatabaseService.getClassesBySchool(schoolId);
  }
  
  Future<List<SchoolClass>> getClassesByTeacher(String teacherId) async {
    // TODO: Implement getClassesByTeacher in SQLiteDatabaseService
    print('getClassesByTeacher not yet implemented in SQLiteDatabaseService');
    return [];
  }
  
  Future<void> deleteClass(String id) async {
    // TODO: Implement deleteClass in SQLiteDatabaseService
    print('deleteClass not yet implemented in SQLiteDatabaseService');
  }

  // Subject operations
  Future<void> saveSubject(Subject subject) async {
    await SQLiteDatabaseService.saveSubject(subject);
  }
  
  Future<Subject?> getSubject(String id) async {
    return await SQLiteDatabaseService.getSubject(id);
  }
  
  Future<List<Subject>> getAllSubjects() async {
    return await SQLiteDatabaseService.getAllSubjects();
  }
  List<Subject> getSubjectsByDepartment(String department) {
    // SQLite service doesn't have this method, return empty for now
    return [];
  }
  
  Future<void> deleteSubject(String id) async {
    // TODO: Implement deleteSubject in SQLiteDatabaseService
    print('deleteSubject not yet implemented in SQLiteDatabaseService');
  }

  // Settings operations - basic implementation
  Future<void> saveSetting(String key, dynamic value) async {
    // Could be implemented with a settings table in SQLite
    // For now, this is a stub
  }
  
  T? getSetting<T>(String key) {
    // Could be implemented with a settings table in SQLite
    // For now, this is a stub
    return null;
  }
  
  Future<void> deleteSetting(String key) async {
    // Could be implemented with a settings table in SQLite
    // For now, this is a stub
  }

  // Utility methods
  Future<void> clearAllData() async {
    await SQLiteDatabaseService.clearAllData();
  }
  
  Future<void> close() async {
    await SQLiteDatabaseService.closeDatabase();
    _isInitialized = false;
  }

  // Search operations
  Future<List<Student>> searchStudents(String query) async {
    // TODO: Implement searchStudents in SQLiteDatabaseService
    print('searchStudents not yet implemented in SQLiteDatabaseService');
    return [];
  }
  
  Future<List<User>> searchUsers(String query) async {
    // TODO: Implement searchUsers in SQLiteDatabaseService
    print('searchUsers not yet implemented in SQLiteDatabaseService');
    return [];
  }
}
