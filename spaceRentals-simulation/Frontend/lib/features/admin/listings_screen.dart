import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/property_provider.dart';
import '../../features/properties/domain/property.dart';
import '../../core/utils/ui_helpers.dart';
import '../../../core/utils/ui_helpers.dart';

class AdminListingsScreen extends ConsumerStatefulWidget {
  const AdminListingsScreen({super.key});
  @override
  ConsumerState<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends ConsumerState<AdminListingsScreen> {
  // Local moderation statuses for each listing
  final Map<String, String> _statuses = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listings Moderation'),
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
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final propertiesAsync = ref.watch(marketplaceListingsProvider);
          return propertiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Failed to load properties: $err', style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: () => ref.invalidate(marketplaceListingsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (listings) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, i) {
              final p = listings[i];
              final status = _statuses[p.property.id] ?? 'active';
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    // Property image + basic info
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Image.network(
                        p.property.images.first,
                        cacheWidth: 400,
                        cacheHeight: 300,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 130, color: Colors.grey[200]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(p.property.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${p.property.location}  ·  ${p.property.category}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('Landlord ID: ${p.property.landlordId}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 12),
                          if (status != 'removed')
                            Row(
                              children: [
                                if (status != 'verified')
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() => _statuses[p.property.id] = 'verified');
                                        if (p.property.acquisitionAgentId != null && p.property.acquisitionAgentId!.isNotEmpty) {
                                        }
                                        context.showSuccessToast('"${p.property.title}" is now Verified (Level 3).');
                                      },
                                      icon: const Icon(Icons.verified, size: 16),
                                      label: const Text('Verify'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    ),
                                  ),
                                if (status != 'verified') const SizedBox(width: 8),
                                if (status != 'flagged')
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() => _statuses[p.property.id] = 'flagged');
                                        context.showToast('"${p.property.title}" flagged for review.');
                                      },
                                      icon: const Icon(Icons.flag, size: 16, color: Colors.orange),
                                      label: const Text('Flag', style: TextStyle(color: Colors.orange)),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Remove listing',
                                  onPressed: () {
                                    setState(() => _statuses[p.property.id] = 'removed');
                                    context.showToast('"${p.property.title}" removed from platform.');
                                  },
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                const Icon(Icons.block, color: Colors.red, size: 16),
                                const SizedBox(width: 6),
                                const Text('Removed from platform', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => setState(() => _statuses[p.property.id] = 'active'),
                                  child: const Text('Restore'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Color> colors = {
      'active': Colors.blue,
      'verified': Colors.green,
      'flagged': Colors.orange,
      'removed': Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (colors[status] ?? Colors.grey).withValues(alpha: 0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors[status] ?? Colors.grey),
      ),
    );
  }
}
