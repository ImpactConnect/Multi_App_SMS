import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

import '../widgets/sync_history_widget.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  bool _isSyncing = false;
  SyncHistory? _currentSync;
  String? _syncMessage;
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final syncService = ref.watch(syncServiceProvider);
    final theme = Theme.of(context);

    // Check if app is in offline-only mode
    if (authService.isOfflineOnly) {
      return _buildOfflineModeMessage(theme);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.sync, size: 32, color: theme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Data Synchronization',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                // Toggle history view button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showHistory = !_showHistory;
                    });
                  },
                  icon: Icon(_showHistory ? Icons.dashboard : Icons.history),
                  label: Text(_showHistory ? 'Dashboard' : 'History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Content based on view mode
            Expanded(
              child: _showHistory
                  ? SyncHistoryWidget(syncService: syncService)
                  : _buildSyncDashboard(syncService, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncDashboard(SyncService syncService, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Sync status cards
          _buildSyncStatusCards(syncService, theme),
          const SizedBox(height: 32),

          // Main sync section
          _buildMainSyncSection(syncService, theme),
          const SizedBox(height: 32),

          // Current sync progress
          if (_isSyncing || _currentSync != null) ...[
            _buildSyncProgress(theme),
            const SizedBox(height: 32),
          ],

          // Recent sync history preview
          _buildRecentSyncPreview(syncService, theme),
        ],
      ),
    );
  }

  Widget _buildSyncStatusCards(SyncService syncService, ThemeData theme) {
    final stats = syncService.getSyncStatistics();
    final latestSync = syncService.latestSync;

    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Last Sync',
            latestSync != null
                ? _formatDateTime(latestSync.syncStartTime)
                : 'Never',
            Icons.access_time,
            latestSync?.status == SyncStatus.completed
                ? Colors.green
                : latestSync?.status == SyncStatus.failed
                ? Colors.red
                : Colors.grey,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Total Syncs',
            '${stats['totalSyncs']}',
            Icons.sync_alt,
            Colors.blue,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Success Rate',
            stats['totalSyncs'] > 0
                ? '${((stats['successfulSyncs'] / stats['totalSyncs']) * 100).toStringAsFixed(1)}%'
                : '0%',
            Icons.check_circle,
            Colors.green,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Avg Duration',
            stats['averageSyncDuration'] != null
                ? _formatDuration(stats['averageSyncDuration'])
                : 'N/A',
            Icons.timer,
            Colors.orange,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSyncSection(SyncService syncService, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sync icon and title
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSyncing ? Icons.sync : Icons.cloud_sync,
              size: 40,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Synchronize Data',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Sync all local data with the cloud database.\nThis will upload your changes and fetch updates from other users.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Sync button
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSyncing ? null : () => _performSync(syncService),
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                _isSyncing ? 'Syncing...' : 'Start Sync',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          // Sync message
          if (_syncMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    _syncMessage!.contains('Error') ||
                        _syncMessage!.contains('Failed')
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _syncMessage!.contains('Error') ||
                          _syncMessage!.contains('Failed')
                      ? Colors.red.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                ),
              ),
              child: Text(
                _syncMessage!,
                style: TextStyle(
                  color:
                      _syncMessage!.contains('Error') ||
                          _syncMessage!.contains('Failed')
                      ? Colors.red[700]
                      : Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncProgress(ThemeData theme) {
    if (_currentSync == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sync Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress details
          if (_currentSync!.tableResults.isNotEmpty) ...[
            ..._currentSync!.tableResults.map(
              (result) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      result.errors.isEmpty ? Icons.check_circle : Icons.error,
                      color: result.errors.isEmpty ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${result.tableName}: ${result.recordsUploaded} uploaded, ${result.recordsFetched} fetched, ${result.recordsUpdated} updated',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            'Status: ${_currentSync!.status.displayName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: _currentSync!.status == SyncStatus.completed
                  ? Colors.green[700]
                  : _currentSync!.status == SyncStatus.failed
                  ? Colors.red[700]
                  : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSyncPreview(SyncService syncService, ThemeData theme) {
    final recentSyncs = syncService.syncHistory.take(3).toList();

    if (recentSyncs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Sync History',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first sync to see history here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent Sync History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showHistory = true;
                  });
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...recentSyncs.map(
            (sync) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    sync.status == SyncStatus.completed
                        ? Icons.check_circle
                        : sync.status == SyncStatus.failed
                        ? Icons.error
                        : Icons.pending,
                    color: sync.status == SyncStatus.completed
                        ? Colors.green
                        : sync.status == SyncStatus.failed
                        ? Colors.red
                        : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTime(sync.syncStartTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${sync.totalRecordsProcessed} records processed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sync.syncDuration != null)
                    Text(
                      _formatDuration(sync.syncDuration!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSync(SyncService syncService) async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
      _currentSync = null;
    });

    try {
      final syncResult = await syncService.performFullSync();

      setState(() {
        _currentSync = syncResult;
        _isSyncing = false;

        if (syncResult.status == SyncStatus.completed) {
          _syncMessage =
              'Sync completed successfully! ${syncResult.totalRecordsProcessed} records processed.';
        } else {
          _syncMessage =
              'Sync failed: ${syncResult.errorMessage ?? "Unknown error"}';
        }
      });

      // Clear message after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _syncMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _syncMessage = 'Sync failed: ${e.toString()}';
      });

      // Clear error message after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _syncMessage = null;
          });
        }
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  Widget _buildOfflineModeMessage(ThemeData theme) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          margin: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.orange[600]),
              const SizedBox(height: 24),
              Text(
                'Offline Mode',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cloud synchronization is not available in offline-only mode.\n\nAll data is stored locally and will not sync to the cloud database.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'To enable cloud sync, restart the app with internet connectivity.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
