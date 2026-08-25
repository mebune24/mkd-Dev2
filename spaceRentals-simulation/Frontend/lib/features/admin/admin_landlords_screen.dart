import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:space_rentals/providers/domain_providers.dart';
import 'package:space_rentals/features/landlord/domain/kyc_submission.dart';
import 'package:space_rentals/features/rentals/domain/dispute_record.dart';
import 'package:space_rentals/features/agents/domain/agent_models.dart';
import 'package:space_rentals/core/domain/audit_entry.dart';
import '../../shared/models/enums.dart';
import '../../models/user_model.dart';
import 'dart:math';
import '../../core/utils/ui_helpers.dart';

class AdminLandlordsScreen extends ConsumerWidget {
  const AdminLandlordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allUsers = ref.watch(allUsersProvider);
    final landlords = allUsers.where((u) => u.role == Role.landlord).toList();
    
    // Split into mock Top Rated and New for UI purposes
    final topRated = landlords.take(3).toList();
    final newLandlords = landlords.skip(3).toList();
    if (topRated.isEmpty) {
      // Mock data if no real landlords exist yet
      topRated.addAll([
        UserModel(id: 'l1', email: 'thomas@example.com', name: 'Thomas Ayuk', role: Role.landlord, status: 'active', kycStatus: 'verified'),
        UserModel(id: 'l2', email: 'comfort@example.com', name: 'Comfort Homes', role: Role.landlord, status: 'active', kycStatus: 'verified'),
      ]);
      newLandlords.addAll([
        UserModel(id: 'l3', email: 'grace@example.com', name: 'Grace M.', role: Role.landlord, status: 'active', kycStatus: 'verified'),
      ]);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text('Landlords', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search landlord or agency',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                    ),
                    child: Icon(Icons.tune, color: theme.colorScheme.primary, size: 20),
                  ),
                ],
              ),
            ),
          ),
          
          _buildSectionHeader('Top Rated Landlords'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _LandlordCard(user: topRated[index]),
                childCount: topRated.length,
              ),
            ),
          ),
          
          _buildSectionHeader('New Landlords'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _LandlordCard(user: newLandlords[index]),
                childCount: newLandlords.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6C3B9A))),
          ],
        ),
      ),
    );
  }
}

class _LandlordCard extends StatelessWidget {
  final UserModel user;
  const _LandlordCard({required this.user});

  @override
  Widget build(BuildContext context) {
    // Generate pseudo-random mock data based on ID
    final random = Random(user.id.hashCode);
    final rating = 4.0 + (random.nextDouble() * 1.0);
    final reviews = 5 + random.nextInt(50);
    final properties = 2 + random.nextInt(20);
    final isAgency = random.nextBool();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${user.id}'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(isAgency ? 'Agency' : 'Individual Landlord', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(' ($reviews reviews)', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.home_outlined, color: Colors.grey.shade500, size: 14),
                    const SizedBox(width: 4),
                    Text('$properties Properties', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.showToast('Profile coming soon');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C3B9A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('View Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
