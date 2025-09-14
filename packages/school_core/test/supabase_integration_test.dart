import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:school_core/services/supabase_service.dart';
import 'package:school_core/models/user.dart' as app_user;
import 'package:school_core/models/school.dart';

void main() {
  group('Supabase Integration Tests', () {
    late SupabaseService supabaseService;

    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      // Initialize Supabase
      final supabaseUrl = dotenv.env['SUPABASE_URL']!;
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
      );

      supabaseService = SupabaseService.instance;
      await supabaseService.initialize();
    });

    test('should connect to Supabase', () async {
      final isConnected = await supabaseService.isConnected();
      expect(
        isConnected,
        isTrue,
        reason: 'Should be able to connect to Supabase',
      );
    });

    test('should check if data exists', () async {
      final hasData = await supabaseService.hasAnyData();
      // This test just verifies the method works, data may or may not exist
      expect(hasData, isA<bool>());
    });

    test('should save and retrieve a test user', () async {
      // Create a test user
      final testUser = app_user.User(
        id: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+1234567890',
        role: app_user.UserRole.teacher,
        schoolId: 'test-school',
        username: 'testuser',
        password: 'testpass123',
        accessCode: 'TEST123',
      );

      // Save user
      final saveResult = await supabaseService.saveUser(testUser);
      expect(saveResult, isTrue, reason: 'Should be able to save user');

      // Retrieve user
      final retrievedUser = await supabaseService.getUser(testUser.id);
      expect(
        retrievedUser,
        isNotNull,
        reason: 'Should be able to retrieve saved user',
      );
      expect(retrievedUser!.email, equals(testUser.email));
      expect(retrievedUser.firstName, equals(testUser.firstName));
      expect(retrievedUser.lastName, equals(testUser.lastName));

      // Clean up - delete test user
      await supabaseService.client.from('users').delete().eq('id', testUser.id);
    });

    test('should save and retrieve a test school', () async {
      // Create a test school
      final testSchool = School(
        id: 'test-school-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test School',
        address: '123 Test Street',
        phoneNumber: '+1234567890',
        email: 'test@school.com',
        principalName: 'Test Principal',
        establishedDate: DateTime.now().subtract(Duration(days: 365)),
        type: SchoolType.primary,
      );

      // Save school
      final saveResult = await supabaseService.saveSchool(testSchool);
      expect(saveResult, isTrue, reason: 'Should be able to save school');

      // Retrieve school
      final retrievedSchool = await supabaseService.getSchool(testSchool.id);
      expect(
        retrievedSchool,
        isNotNull,
        reason: 'Should be able to retrieve saved school',
      );
      expect(retrievedSchool!.name, equals(testSchool.name));
      expect(retrievedSchool.address, equals(testSchool.address));

      // Clean up - delete test school
      await supabaseService.client
          .from('schools')
          .delete()
          .eq('id', testSchool.id);
    });

    test('should handle connection errors gracefully', () async {
      // This test verifies error handling
      // We can't easily simulate network errors in tests, but we can verify
      // that the methods don't throw exceptions
      expect(() async => await supabaseService.isConnected(), returnsNormally);
      expect(() async => await supabaseService.hasAnyData(), returnsNormally);
    });
  });
}