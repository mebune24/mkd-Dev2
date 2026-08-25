import 'package:flutter/material.dart';
import '../../core/utils/ui_helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _activeAlerts = [
    {
      'id': '1',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'title': 'Payment Successful',
      'subtitle': 'Your rent payment of 150,000 FCFA was received.',
      'time': '2 hours ago',
    },
    {
      'id': '2',
      'icon': Icons.description,
      'color': Colors.purple,
      'title': 'Agreement Updated',
      'subtitle': 'The landlord has confirmed your rental agreement.',
      'time': '1 day ago',
    },
    {
      'id': '3',
      'icon': Icons.account_balance,
      'color': Colors.indigo,
      'title': 'RNLP Pre-approved',
      'subtitle': 'You are eligible for RNLP deposit financing.',
      'time': '2 days ago',
    },
  ];

  final List<Map<String, dynamic>> _historyAlerts = [
    {
      'id': 'h1',
      'icon': Icons.home,
      'color': Colors.orange,
      'title': 'Welcome to SpaceRentals',
      'subtitle': 'Your account has been successfully created.',
      'time': 'Last month',
    },
    {
      'id': 'h2',
      'icon': Icons.security,
      'color': Colors.blueGrey,
      'title': 'Password Changed',
      'subtitle': 'Your account password was updated securely.',
      'time': '2 months ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearAllAlerts() {
    setState(() {
      _historyAlerts.insertAll(0, _activeAlerts);
      _activeAlerts.clear();
    });
    context.showToast('All alerts cleared to history.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'New Alerts'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          if (_activeAlerts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear All Alerts',
              onPressed: _clearAllAlerts,
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertsList(_activeAlerts, true),
          _buildAlertsList(_historyAlerts, false),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<Map<String, dynamic>> alerts, bool isActive) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No new alerts' : 'No history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (alert['color'] as Color).withValues(alpha: 0.1),
              child: Icon(alert['icon'] as IconData, color: alert['color'] as Color),
            ),
            title: Text(alert['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(alert['subtitle'] as String),
                const SizedBox(height: 8),
                Text(alert['time'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            isThreeLine: true,
            trailing: isActive
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _historyAlerts.insert(0, alert);
                        _activeAlerts.removeAt(index);
                      });
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
