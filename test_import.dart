import 'package:school_core/school_core.dart';

void main() {
  // Test that we can create instances of the models
  final user = User(
    id: '1',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    phoneNumber: '+1234567890',
    role: UserRole.superAdmin,
    isActive: true,
    accessCode: 'TEST001',
    username: 'test_user',
    password: 'password123',
  );

  final student = Student(
    id: '1',
    firstName: 'John',
    lastName: 'Doe',
    dateOfBirth: DateTime(2010, 1, 1),
    gender: Gender.male,
    schoolId: 'school1',
    classId: 'class1',
    address: '456 Student St',
    studentId: 'STU001',
  );

  final school = School(
    id: '1',
    name: 'Test School',
    address: '123 Test St',
    phoneNumber: '123-456-7890',
    email: 'school@test.com',
    type: SchoolType.primary,
    establishedDate: DateTime(2000, 1, 1),
    principalName: 'Dr. Smith',
  );

  print('User: ${user.firstName} ${user.lastName}');
  print('Student: ${student.firstName} ${student.lastName}');
  print('School: ${school.name}');
  print('All imports working correctly!');
}
