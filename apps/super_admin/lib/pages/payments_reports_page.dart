import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_core/school_core.dart';

class PaymentsReportsPage extends ConsumerStatefulWidget {
  const PaymentsReportsPage({super.key});

  @override
  ConsumerState<PaymentsReportsPage> createState() =>
      _PaymentsReportsPageState();
}

class _PaymentsReportsPageState extends ConsumerState<PaymentsReportsPage> {
  String? _selectedSchool;
  String _selectedPeriod = 'month';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // TODO: Replace with actual service calls
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      setState(() {
        _reportData = {
          'totalRevenue': 125000.0,
          'totalTransactions': 1250,
          'averageTransaction': 100.0,
          'pendingPayments': 15000.0,
          'monthlyData': List.generate(
            12,
            (index) => {
              'month': DateTime.now()
                  .subtract(Duration(days: (11 - index) * 30))
                  .month,
              'revenue': (50000 + (index * 5000) + (index % 3 * 10000))
                  .toDouble(),
              'transactions': 800 + (index * 50) + (index % 2 * 100),
            },
          ),
          'paymentMethods': [
            {'method': 'Bank Transfer', 'amount': 75000.0, 'percentage': 60.0},
            {'method': 'Cash', 'amount': 30000.0, 'percentage': 24.0},
            {'method': 'Mobile Money', 'amount': 15000.0, 'percentage': 12.0},
            {'method': 'Card', 'amount': 5000.0, 'percentage': 4.0},
          ],
          'schoolBreakdown': List.generate(
            5,
            (index) => {
              'school': 'School ${index + 1}',
              'revenue': (20000 + (index * 5000)).toDouble(),
              'transactions': 200 + (index * 50),
              'pending': (2000 + (index * 500)).toDouble(),
            },
          ),
          'recentTransactions': List.generate(
            10,
            (index) => {
              'id': 'TXN${1000 + index}',
              'student': 'Student ${index + 1}',
              'amount': (50 + (index * 25)).toDouble(),
              'method': ['Bank Transfer', 'Cash', 'Mobile Money'][index % 3],
              'date': DateTime.now().subtract(Duration(days: index)),
              'status': index % 4 == 0 ? 'Pending' : 'Completed',
            },
          ),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load report data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportReport(String format) async {
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report as $format...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSchool,
                    decoration: const InputDecoration(
                      labelText: 'School',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Schools'),
                      ),
                      ...List.generate(
                        5,
                        (index) => DropdownMenuItem(
                          value: 'school_$index',
                          child: Text('School ${index + 1}'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSchool = value;
                      });
                      _loadReportData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'week', child: Text('Last Week')),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text('Last Month'),
                      ),
                      DropdownMenuItem(
                        value: 'quarter',
                        child: Text('Last Quarter'),
                      ),
                      DropdownMenuItem(value: 'year', child: Text('Last Year')),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Custom Range'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                      _loadReportData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showExportDialog(),
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Revenue',
            '\$${_reportData['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Total Transactions',
            '${_reportData['totalTransactions'] ?? 0}',
            Icons.receipt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Average Transaction',
            '\$${_reportData['averageTransaction']?.toStringAsFixed(0) ?? '0'}',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Pending Payments',
            '\$${_reportData['pendingPayments']?.toStringAsFixed(0) ?? '0'}',
            Icons.pending,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Revenue Chart Placeholder',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chart library integration needed',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_reportData['paymentMethods'] as List<Map<String, dynamic>>? ??
                    [])
                .map(
                  (method) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(method['method'])),
                        Expanded(
                          flex: 3,
                          child: LinearProgressIndicator(
                            value: method['percentage'] / 100,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${method['amount'].toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${method['percentage'].toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'School Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'School',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Revenue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Transactions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Pending',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...(_reportData['schoolBreakdown']
                            as List<Map<String, dynamic>>? ??
                        [])
                    .map(
                      (school) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(school['school']),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '\$${school['revenue'].toStringAsFixed(0)}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${school['transactions']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '\$${school['pending'].toStringAsFixed(0)}',
                              style: TextStyle(
                                color: school['pending'] > 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  (_reportData['recentTransactions'] as List?)?.length ?? 0,
              itemBuilder: (context, index) {
                final transaction =
                    (_reportData['recentTransactions'] as List)[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction['status'] == 'Completed'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Icon(
                      transaction['status'] == 'Completed'
                          ? Icons.check
                          : Icons.pending,
                      color: transaction['status'] == 'Completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  title: Text(transaction['student']),
                  subtitle: Text(
                    '${transaction['id']} • ${transaction['method']}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${transaction['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${transaction['date'].day}/${transaction['date'].month}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Report'),
              onTap: () {
                Navigator.pop(context);
                _exportReport('PDF');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                _exportReport('Excel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('CSV Data'),
              onTap: () {
                Navigator.pop(context);
                _exportReport('CSV');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReportData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReportData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payments Reports',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive payment analytics with charts and export functionality',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildFiltersCard(),
            const SizedBox(height: 16),
            _buildSummaryCards(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRevenueChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildPaymentMethodsChart()),
              ],
            ),
            const SizedBox(height: 16),
            _buildSchoolBreakdown(),
            const SizedBox(height: 16),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }
}
