import 'package:uuid/uuid.dart';

/// Represents a sync operation history record
class SyncHistory {
  String id;
  DateTime syncStartTime;
  DateTime? syncEndTime;
  SyncStatus status;
  String? errorMessage;
  List<SyncTableResult> tableResults;
  int totalRecordsFetched;
  int totalRecordsUploaded;
  int totalRecordsUpdated;
  Duration? syncDuration;

  SyncHistory({
    String? id,
    required this.syncStartTime,
    this.syncEndTime,
    this.status = SyncStatus.inProgress,
    this.errorMessage,
    List<SyncTableResult>? tableResults,
    this.totalRecordsFetched = 0,
    this.totalRecordsUploaded = 0,
    this.totalRecordsUpdated = 0,
    this.syncDuration,
  }) : id = id ?? const Uuid().v4(),
       tableResults = tableResults ?? [];

  /// Mark sync as completed
  void markCompleted() {
    syncEndTime = DateTime.now();
    status = SyncStatus.completed;
    syncDuration = syncEndTime!.difference(syncStartTime);

    // Calculate totals from table results
    totalRecordsFetched = tableResults.fold(
      0,
      (sum, result) => sum + result.recordsFetched,
    );
    totalRecordsUploaded = tableResults.fold(
      0,
      (sum, result) => sum + result.recordsUploaded,
    );
    totalRecordsUpdated = tableResults.fold(
      0,
      (sum, result) => sum + result.recordsUpdated,
    );
  }

  /// Mark sync as failed
  void markFailed(String error) {
    syncEndTime = DateTime.now();
    status = SyncStatus.failed;
    errorMessage = error;
    syncDuration = syncEndTime!.difference(syncStartTime);
  }

  /// Get formatted sync duration
  String get formattedDuration {
    if (syncDuration == null) return 'In progress...';
    final seconds = syncDuration!.inSeconds;
    if (seconds < 60) return '${seconds}s';
    final minutes = syncDuration!.inMinutes;
    return '${minutes}m ${seconds % 60}s';
  }

  /// Get total records processed
  int get totalRecordsProcessed =>
      totalRecordsFetched + totalRecordsUploaded + totalRecordsUpdated;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syncStartTime': syncStartTime.toIso8601String(),
      'syncEndTime': syncEndTime?.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
      'tableResults': tableResults.map((result) => result.toJson()).toList(),
      'totalRecordsFetched': totalRecordsFetched,
      'totalRecordsUploaded': totalRecordsUploaded,
      'totalRecordsUpdated': totalRecordsUpdated,
      'syncDuration': syncDuration?.inMilliseconds,
    };
  }

  factory SyncHistory.fromJson(Map<String, dynamic> json) {
    return SyncHistory(
      id: json['id'] as String,
      syncStartTime: DateTime.parse(json['syncStartTime'] as String),
      syncEndTime: json['syncEndTime'] != null
          ? DateTime.parse(json['syncEndTime'] as String)
          : null,
      status: SyncStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => SyncStatus.failed,
      ),
      errorMessage: json['errorMessage'] as String?,
      tableResults: (json['tableResults'] as List<dynamic>)
          .map(
            (result) =>
                SyncTableResult.fromJson(result as Map<String, dynamic>),
          )
          .toList(),
      totalRecordsFetched: json['totalRecordsFetched'] as int? ?? 0,
      totalRecordsUploaded: json['totalRecordsUploaded'] as int? ?? 0,
      totalRecordsUpdated: json['totalRecordsUpdated'] as int? ?? 0,
      syncDuration: json['syncDuration'] != null
          ? Duration(milliseconds: json['syncDuration'] as int)
          : null,
    );
  }
}

/// Represents sync results for a specific table
class SyncTableResult {
  String tableName;
  int recordsFetched;
  int recordsUploaded;
  int recordsUpdated;
  int conflictsResolved;
  List<String> errors;
  DateTime processedAt;

  SyncTableResult({
    required this.tableName,
    this.recordsFetched = 0,
    this.recordsUploaded = 0,
    this.recordsUpdated = 0,
    this.conflictsResolved = 0,
    List<String>? errors,
    DateTime? processedAt,
  }) : errors = errors ?? [],
       processedAt = processedAt ?? DateTime.now();

  /// Get total records processed for this table
  int get totalProcessed => recordsFetched + recordsUploaded + recordsUpdated;

  /// Check if this table had any activity
  bool get hasActivity => totalProcessed > 0 || errors.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'tableName': tableName,
      'recordsFetched': recordsFetched,
      'recordsUploaded': recordsUploaded,
      'recordsUpdated': recordsUpdated,
      'conflictsResolved': conflictsResolved,
      'errors': errors,
      'processedAt': processedAt.toIso8601String(),
    };
  }

  factory SyncTableResult.fromJson(Map<String, dynamic> json) {
    return SyncTableResult(
      tableName: json['tableName'] as String,
      recordsFetched: json['recordsFetched'] as int? ?? 0,
      recordsUploaded: json['recordsUploaded'] as int? ?? 0,
      recordsUpdated: json['recordsUpdated'] as int? ?? 0,
      conflictsResolved: json['conflictsResolved'] as int? ?? 0,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      processedAt: DateTime.parse(json['processedAt'] as String),
    );
  }
}

/// Sync operation status
enum SyncStatus { inProgress, completed, failed, cancelled }

/// Extension for SyncStatus display
extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.inProgress:
        return 'In Progress';
      case SyncStatus.completed:
        return 'Completed';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get status color for UI
  String get colorHex {
    switch (this) {
      case SyncStatus.inProgress:
        return '#FFA500'; // Orange
      case SyncStatus.completed:
        return '#4CAF50'; // Green
      case SyncStatus.failed:
        return '#F44336'; // Red
      case SyncStatus.cancelled:
        return '#9E9E9E'; // Grey
    }
  }
}
