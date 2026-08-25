import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';

class AgentClientsScreen extends StatelessWidget {
  const AgentClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Referred Clients'),
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
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Invite Client Button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add),
            label: const Text('Invite a new Tenant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Your Referral Pipeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          
          _buildClientCard(
            context,
            name: 'Alice M.',
            phone: '+237 6 70 00 00 00',
            status: 'Completed',
            property: 'Appartement Bastos',
            commission: 50000,
          ),
          
          _buildClientCard(
            context,
            name: 'Bob T.',
            phone: '+237 6 90 00 00 00',
            status: 'Viewing Scheduled',
            property: 'Studio Bonamoussadi',
            commission: 25000,
          ),
          
          _buildClientCard(
            context,
            name: 'Charlie K.',
            phone: '+237 6 50 00 00 00',
            status: 'Account Created',
            property: 'Not yet selected',
            commission: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, {
    required String name,
    required String phone,
    required String status,
    required String property,
    required double commission,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Viewing Scheduled':
        statusColor = Colors.blue;
        statusIcon = Icons.calendar_today;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Interested in', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(property, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                if (commission > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Commission', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(
                        CurrencyFormatter.formatCFA(commission),
                        style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
