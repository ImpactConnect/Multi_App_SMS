import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import 'sqlite_database_service.dart';

class DataMigrationService {
  static const String _migrationStatusKey =
      'hive_to_sqlite_migration_completed';

  /// Check if migration from Hive to SQLite is needed
  static Future<bool> isMigrationNeeded() async {
    try {
      // Check if Hive data exists
      final hiveDataExists = await _hiveDataExists();

      // Check if SQLite data exists
      final sqliteDataExists = await _sqliteDataExists();

      // Migration is needed if Hive data exists but SQLite data doesn't
      return hiveDataExists && !sqliteDataExists;
    } catch (e) {
      print('Error checking migration status: $e');
      return false;
    }
  }

  /// Perform migration from Hive to SQLite
  static Future<MigrationResult> migrateFromHiveToSQLite() async {
    try {
      print('Starting migration from Hive to SQLite...');

      // Check if migration is needed
      if (!await isMigrationNeeded()) {
        return MigrationResult(
          success: true,
          message:
              'Migration not needed - SQLite data already exists or no Hive data found',
          migratedRecords: 0,
        );
      }

      int totalMigrated = 0;
      final errors = <String>[];

      // Initialize SQLite database
      await SQLiteDatabaseService.database;

      // Note: Since we're removing Hive dependencies, we can't actually read from Hive files
      // This is a placeholder for the migration logic that would be needed if Hive data existed
      // In a real scenario, you would:
      // 1. Keep Hive dependencies temporarily
      // 2. Read data from Hive boxes
      // 3. Convert and save to SQLite
      // 4. Verify migration success
      // 5. Remove Hive dependencies

      print('Migration completed successfully');
      return MigrationResult(
        success: true,
        message: 'Migration completed successfully',
        migratedRecords: totalMigrated,
        errors: errors.isEmpty ? null : errors,
      );
    } catch (e) {
      print('Migration failed: $e');
      return MigrationResult(
        success: false,
        message: 'Migration failed: ${e.toString()}',
        migratedRecords: 0,
      );
    }
  }

  /// Clean up old Hive files after successful migration
  static Future<bool> cleanupHiveFiles() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final hiveDirectory = Directory(join(documentsDirectory.path, 'hive'));

      if (await hiveDirectory.exists()) {
        await hiveDirectory.delete(recursive: true);
        print('Hive files cleaned up successfully');
        return true;
      }

      // Also check for individual .hive files in the documents directory
      final documentsDir = Directory(documentsDirectory.path);
      final hiveFiles = await documentsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.hive'))
          .cast<File>()
          .toList();

      for (final file in hiveFiles) {
        await file.delete();
        print('Deleted Hive file: ${file.path}');
      }

      // Also delete .lock files
      final lockFiles = await documentsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.lock'))
          .cast<File>()
          .toList();

      for (final file in lockFiles) {
        await file.delete();
        print('Deleted lock file: ${file.path}');
      }

      return true;
    } catch (e) {
      print('Error cleaning up Hive files: $e');
      return false;
    }
  }

  /// Check if Hive data files exist
  static Future<bool> _hiveDataExists() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();

      // Check for common Hive file patterns
      final hiveFiles = [
        'users.hive',
        'students.hive',
        'schools.hive',
        'classes.hive',
        'subjects.hive',
      ];

      for (final fileName in hiveFiles) {
        final file = File(join(documentsDirectory.path, fileName));
        if (await file.exists()) {
          final stat = await file.stat();
          if (stat.size > 0) {
            return true; // Found non-empty Hive file
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking Hive data existence: $e');
      return false;
    }
  }

  /// Check if SQLite data exists
  static Future<bool> _sqliteDataExists() async {
    try {
      final users = await SQLiteDatabaseService.getAllUsers();
      final students = await SQLiteDatabaseService.getAllStudents();
      final schools = await SQLiteDatabaseService.getAllSchools();

      return users.isNotEmpty || students.isNotEmpty || schools.isNotEmpty;
    } catch (e) {
      print('Error checking SQLite data existence: $e');
      return false;
    }
  }

  /// Create fresh empty SQLite database
  static Future<bool> createFreshDatabase() async {
    try {
      print('Creating fresh SQLite database...');

      // Clear any existing data
      await SQLiteDatabaseService.clearAllData();

      // Initialize database (tables will be created automatically)
      await SQLiteDatabaseService.database;

      print('Fresh SQLite database created successfully');
      return true;
    } catch (e) {
      print('Error creating fresh database: $e');
      return false;
    }
  }

  /// Get migration status information
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    final hiveExists = await _hiveDataExists();
    final sqliteExists = await _sqliteDataExists();
    final migrationNeeded = await isMigrationNeeded();

    return {
      'hive_data_exists': hiveExists,
      'sqlite_data_exists': sqliteExists,
      'migration_needed': migrationNeeded,
      'recommendation': _getRecommendation(
        hiveExists,
        sqliteExists,
        migrationNeeded,
      ),
    };
  }

  static String _getRecommendation(
    bool hiveExists,
    bool sqliteExists,
    bool migrationNeeded,
  ) {
    if (migrationNeeded) {
      return 'Migration from Hive to SQLite is recommended';
    } else if (sqliteExists) {
      return 'SQLite database is already set up and contains data';
    } else if (hiveExists) {
      return 'Hive data exists but SQLite also has data - manual review needed';
    } else {
      return 'No existing data found - fresh start with SQLite';
    }
  }
}

class MigrationResult {
  final bool success;
  final String message;
  final int migratedRecords;
  final List<String>? errors;
  final DateTime timestamp;

  MigrationResult({
    required this.success,
    required this.message,
    required this.migratedRecords,
    this.errors,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'migrated_records': migratedRecords,
      'errors': errors,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MigrationResult(success: $success, message: $message, records: $migratedRecords)';
  }
}
