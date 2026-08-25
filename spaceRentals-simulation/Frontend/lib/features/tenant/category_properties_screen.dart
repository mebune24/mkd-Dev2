import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/property_provider.dart';
import '../../features/properties/domain/property.dart';
import '../../core/utils/currency_formatter.dart';

class CategoryPropertiesScreen extends ConsumerWidget {
  final String categoryName;
  final List<String>? propertyIds;

  const CategoryPropertiesScreen({super.key, required this.categoryName, this.propertyIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allAsync = ref.watch(propertiesByCategoryProvider(categoryName));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(categoryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black45, blurRadius: 4)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          allAsync.when(
            data: (props) {
              List<PropertyWithListing> categoryProps;
              
              if (propertyIds != null && propertyIds!.isNotEmpty) {
                categoryProps = props.where((p) => propertyIds!.contains(p.property.id)).toList();
              } else {
                categoryProps = props.where((p) => 
                  p.property.category.toLowerCase() == categoryName.toLowerCase() || 
                  categoryName.toLowerCase().contains(p.property.category.toLowerCase()) || 
                  p.property.location.toLowerCase().contains(categoryName.toLowerCase())
                ).toList();
              }
              
              if (categoryProps.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No properties found in this category.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = categoryProps[index];
                      return _buildGridCard(context, property, theme);
                    },
                    childCount: categoryProps.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
            ),
            error: (e, _) => const SliverFillRemaining(
              child: Center(child: Text('Failed to load properties', style: TextStyle(color: Colors.red))),
            ),
          ),
          SliverToBoxAdapter(child: _buildFooter(theme)),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, PropertyWithListing property, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // We use property detail directly
        context.push('/tenant/property/${property.property.id}', extra: property);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Hero(
                  tag: 'property_image_${property.property.id}_category_${categoryName.hashCode}',
                  child: Image.network(
                    property.property.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (property.verification.level.index >= 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 10, color: Colors.green),
                            SizedBox(width: 3),
                            Text('Verified', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    Text(property.property.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 10, color: Colors.grey),
                        Expanded(child: Text(property.property.location, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const Spacer(),
                    Text('${CurrencyFormatter.formatCFA(property.property.monthlyRentUnits.toDouble())}/mo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F3),
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 28, height: 28, errorBuilder: (_, __, ___) => Icon(Icons.apartment, color: theme.colorScheme.primary, size: 28)),
              const SizedBox(width: 8),
              Text('SpaceRentals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('© 2026 SpaceRentals. All rights reserved.', style: TextStyle(color: Colors.black45, fontSize: 11)),
        ],
      ),
    );
  }
}
