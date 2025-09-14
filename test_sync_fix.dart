// Test script to verify sync functionality after PostgrestException fixes
import 'package:school_core/school_core.dart';

void main() async {
  print('🧪 Testing sync functionality after PostgrestException fixes...');
  
  try {
    // Initialize services
    final syncService = SyncService();
    final localDbService = SQLiteDatabaseService();
    
    // Test 1: Check if we can create a local user without sync errors
    print('\n📝 Test 1: Creating a test user locally...');
    final testUser = User(
      id: 'test-sync-user-${DateTime.now().millisecondsSinceEpoch}',
      email: 'test.sync@example.com',
      firstName: 'Test',
      lastName: 'Sync',
      phoneNumber: '+1-555-TEST',
      role: UserRole.teacher,
      accessCode: 'TEST${DateTime.now().millisecondsSinceEpoch % 1000}',
      passwordHash: 'test-hash',
      schoolId: '440e8400-e29b-41d4-a716-446655440001',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await localDbService.saveUser(testUser);
    print('✅ Test user created locally: ${testUser.email}');
    
    // Test 2: Trigger sync and check for errors
    print('\n🔄 Test 2: Triggering sync to upload local records...');
    final syncResult = await syncService.syncAllTables();
    
    print('📊 Sync Results:');
    print('  - Total records processed: ${syncResult.totalProcessed}');
    print('  - Records uploaded: ${syncResult.totalRecordsUploaded}');
    print('  - Records fetched: ${syncResult.totalRecordsFetched}');
    print('  - Records updated: ${syncResult.totalRecordsUpdated}');
    print('  - Errors: ${syncResult.errors.length}');
    
    if (syncResult.errors.isNotEmpty) {
      print('\n❌ Sync errors found:');
      for (final error in syncResult.errors) {
        print('  - $error');
      }
    } else {
      print('\n✅ No sync errors - PostgrestException fixes working!');
    }
    
    // Test 3: Verify the test user was uploaded
    print('\n🔍 Test 3: Verifying test user upload...');
    final supabaseService = SupabaseService.instance;
    final uploadedUser = await supabaseService.getRecordById('users', testUser.id);
    
    if (uploadedUser != null) {
      print('✅ Test user successfully uploaded to cloud database');
      print('  - Cloud user email: ${uploadedUser['email']}');
      print('  - Cloud user access_code: ${uploadedUser['access_code']}');
    } else {
      print('❌ Test user not found in cloud database');
    }
    
    print('\n🎉 Sync functionality test completed!');
    
  } catch (e) {
    print('❌ Test failed with error: $e');
  }
}