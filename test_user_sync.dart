import 'dart:io';
import 'package:school_core/models/user.dart';
import 'package:school_core/services/sqlite_database_service.dart';
import 'package:school_core/services/sync_service.dart';
import 'package:school_core/services/supabase_service.dart';

void main() async {
  print('🧪 Testing user sync functionality...');
  
  try {
    // Initialize services
    final dbService = SQLiteDatabaseService.instance;
    final syncService = SyncService.instance;
    final supabaseService = SupabaseService.instance;
    
    // Check if we can connect to Supabase
    final isConnected = await supabaseService.isConnected();
    print('🌐 Supabase connection: ${isConnected ? "Connected" : "Disconnected"}');
    
    if (!isConnected) {
      print('❌ Cannot test sync without Supabase connection');
      return;
    }
    
    // Get all users from local database
    final users = await dbService.getAllUsers();
    print('👥 Found ${users.length} users in local database');
    
    // Filter for teacher and accountant users
    final teacherUsers = users.where((u) => u.role == UserRole.teacher).toList();
    final accountantUsers = users.where((u) => u.role == UserRole.accountant).toList();
    
    print('👨‍🏫 Teacher users: ${teacherUsers.length}');
    print('💼 Accountant users: ${accountantUsers.length}');
    
    // Display user details
    for (final user in teacherUsers) {
      print('  - Teacher: ${user.firstName} ${user.lastName} (${user.email})');
    }
    
    for (final user in accountantUsers) {
      print('  - Accountant: ${user.firstName} ${user.lastName} (${user.email})');
    }
    
    // Test sync for users table
    print('\n🔄 Starting sync test for users table...');
    
    try {
      await syncService.syncTable('users');
      print('✅ Users table sync completed successfully');
    } catch (e) {
      print('❌ Users table sync failed: $e');
    }
    
    print('\n🎉 Sync test completed!');
    
  } catch (e) {
    print('💥 Test failed with error: $e');
  }
  
  exit(0);
}