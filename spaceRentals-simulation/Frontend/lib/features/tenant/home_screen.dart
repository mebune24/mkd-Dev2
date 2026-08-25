import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../features/properties/domain/property.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/ui_helpers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPropertyTapped(PropertyWithListing property) {
    ref.read(recentlyViewedProvider.notifier).addProperty(property);
    context.push('/tenant/property/${property.property.id}', extra: property);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptReview();
    });
  }

  void _checkAndPromptReview() async {
    // Mock check for a recently rented property that needs review
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    // In a real app, this checks if the user has an unreviewed rental.
    // For this simulation, we'll prompt once.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 10),
            Text('Rate Your Rental'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You recently rented "Modern 2-Bedroom Apartment". How was your experience?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                icon: const Icon(Icons.star_border, color: Colors.amber, size: 36),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.showSuccessToast('Thank you for your rating! It is now visible to others.');
                },
              )),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not Now'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final isFr = locale.languageCode == 'fr';
    
    final recentlyViewed = ref.watch(recentlyViewedProvider);
    final recommendedLocationAsync = ref.watch(recommendedLocationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      const Color(0xFF5D3F6A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.menu, color: Colors.white),
                                      onPressed: () => Scaffold.of(context).openDrawer(),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isFr ? 'Bonjour, ${user.session?.fullName.split(' ').first ?? 'Invité'} 👋' : 'Hello, ${user.session?.fullName.split(' ').first ?? 'Guest'} 👋',
                                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isFr ? 'Trouvez votre espace idéal' : 'Find your perfect space',
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        GestureDetector(
                          onTap: () {
                            // Switch to search tab programmatically via tenant dashboard (bottom nav index 1 usually but here we can push a search screen)
                            // or just push property search directly
                            context.push('/tenant/search');
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 12),
                                Text(
                                  isFr ? 'Rechercher Yaoundé, Douala...' : 'Search Yaoundé, Douala...',
                                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.map, color: Colors.white),
                tooltip: isFr ? 'Voir sur la carte' : 'Map View',
                onPressed: () => context.push('/tenant/search', extra: {'showMap': true}),
              ),
              IconButton(
                icon: const Badge(child: Icon(Icons.notifications_outlined, color: Colors.white)),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),

          // ── Recently Viewed ──────────────────────────────────────
          if (recentlyViewed.isNotEmpty)
            _buildHorizontalSection(
              title: isFr ? 'Vus Récemment' : 'Recently Viewed',
              properties: recentlyViewed,
            ),

          // ── Recommended Location (Rotating) ─────────────────────
          SliverToBoxAdapter(
            child: recommendedLocationAsync.when(
              data: (location) {
                return Consumer(
                  builder: (context, ref, child) {
                    final recommendedPropsAsync = ref.watch(marketplaceListingsProvider);
                    return recommendedPropsAsync.when(
                      data: (props) {
                        if (props.isEmpty) return const SizedBox.shrink();
                        return _buildHorizontalSectionWidget(
                          title: isFr ? 'Recommandé à $location' : 'Recommended in $location',
                          properties: props,
                        );
                      },
                      loading: () => const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      )),
                      error: (_, __) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Could not load data. Pull to refresh.', style: TextStyle(color: Colors.red.shade400)),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Could not load data. Pull to refresh.', style: TextStyle(color: Colors.red.shade400)),
              ),
            ),
          ),

          // ── Latest Properties ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final latestAsync = ref.watch(marketplaceListingsProvider);
                return latestAsync.when(
                  data: (props) {
                    if (props.isEmpty) return const SizedBox.shrink();
                    return _buildHorizontalSectionWidget(
                      title: isFr ? 'Dernières Propriétés' : 'Latest Properties',
                      properties: props,
                    );
                  },
                  loading: () => _buildShimmerSection(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Could not load data. Pull to refresh.', style: TextStyle(color: Colors.red.shade400)),
                  ),
                );
              },
            ),
          ),

          // ── Last Month ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final lastMonthAsync = ref.watch(marketplaceListingsProvider);
                return lastMonthAsync.when(
                  data: (props) {
                    if (props.isEmpty) return const SizedBox.shrink();
                    return _buildHorizontalSectionWidget(
                      title: isFr ? 'Le Mois Dernier' : 'Last Month',
                      properties: props,
                    );
                  },
                  loading: () => _buildShimmerSection(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Could not load data. Pull to refresh.', style: TextStyle(color: Colors.red.shade400)),
                  ),
                );
              },
            ),
          ),

          // ── Agent Promo Banner ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Image.asset(
                          'assets/images/agent_promo.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: const Color(0xFF6A1B9A),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isFr ? 'Rejoignez-nous' : 'Join Network',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context.push('/agent/onboarding'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF6A1B9A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isFr ? 'Devenir Agent' : 'Become Agent',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Popular Properties ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final popularAsync = ref.watch(marketplaceListingsProvider);
                return popularAsync.when(
                  data: (props) {
                    if (props.isEmpty) return const SizedBox.shrink();
                    return _buildHorizontalSectionWidget(
                      title: isFr ? 'Propriétés les Mieux Notées' : 'Most Rated Properties',
                      properties: props,
                    );
                  },
                  loading: () => _buildShimmerSection(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Could not load data. Pull to refresh.', style: TextStyle(color: Colors.red.shade400)),
                  ),
                );
              },
            ),
          ),

          // ── Categories ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildCategoriesSection(isFr, theme),
          ),

          // ── All Properties (Explore) ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                isFr ? 'Explorer Tout' : 'Explore All',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final allAsync = ref.watch(marketplaceListingsProvider);
                return allAsync.when(
                  data: (props) {
                    final grouped = <String, List<PropertyWithListing>>{};
                    for (final p in props) {
                      grouped.putIfAbsent(p.property.category, () => []).add(p);
                    }
                    final categories = grouped.keys.toList()..sort();

                    return Column(
                      children: categories.map((cat) {
                        final widget = _buildHorizontalSectionWidget(
                          title: cat,
                          properties: grouped[cat]!,
                        );
                        if (cat == 'Villas') {
                          return Column(
                            children: [
                              widget,
                              const SizedBox(height: 16),
                              _buildUserReviewsSection(),
                              const SizedBox(height: 16),
                              _buildPartnershipsSection(),
                            ],
                          );
                        }
                        return widget;
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 270,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                );
              },
            ),
          ),

          // ── Platform Statistics ────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildPlatformStatistics(),
          ),

          // ── What Are You Waiting For Banner ──────────────────────
          SliverToBoxAdapter(
            child: _buildWaitingForSection(theme),
          ),

          // ── Map + Regions ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildMapAndRegionsSection(theme),
          ),

          // ── FAQ ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildFaqSection(theme),
          ),

          // ── Footer ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildFooter(isFr, theme),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHorizontalSection({required String title, required List<PropertyWithListing> properties}) {
    return SliverToBoxAdapter(
      child: _buildHorizontalSectionWidget(title: title, properties: properties),
    );
  }

  Widget _buildHorizontalSectionWidget({required String title, required List<PropertyWithListing> properties}) {
    final theme = Theme.of(context);
    final isFr = ref.read(localeProvider).languageCode == 'fr';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => context.push('/tenant/search'),
                child: Row(
                  children: [
                    Text(
                      isFr ? 'Voir tout' : 'See all',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 270,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: properties.take(5).length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == properties.take(5).length) {
                final bgImage = properties.isNotEmpty ? properties.first.property.images.first : 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800';
                return GestureDetector(
                  onTap: () => context.push('/tenant/category/${Uri.encodeComponent(title)}', extra: properties.map((p) => p.property.id).toList()),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(bgImage),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 12),
                          const Text('See more', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('in $title', style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center, maxLines: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final property = properties[index];
              return GestureDetector(
                onTap: () => _onPropertyTapped(property),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Hero(
                          tag: 'property_image_${property.property.id}_home_${title.hashCode}',
                          child: Image.network(
                            property.property.images.first,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(height: 140, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
                            },
                            errorBuilder: (_, __, ___) => Container(height: 140, width: double.infinity, color: Colors.grey[200], child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (property.verification.level.index >= 3)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 10, color: Colors.green),
                                    SizedBox(width: 3),
                                    Text('Verified', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            Text(
                              property.property.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 11, color: Colors.grey),
                                Expanded(
                                  child: Text(
                                    property.property.location,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${CurrencyFormatter.formatCFA(property.property.monthlyRentUnits.toDouble())}/mo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(height: 20, width: 100, color: Colors.grey[200]),
          const SizedBox(height: 12),
          const PropertyCardShimmer(),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(bool isFr, ThemeData theme) {
    final categories = [
      {'name': isFr ? 'Appartements' : 'Apartments'},
      {'name': isFr ? 'Studios' : 'Studios'},
      {'name': isFr ? 'Villas' : 'Villas'},
      {'name': isFr ? 'Commercial' : 'Commercial'},
      {'name': isFr ? 'Luxe' : 'Luxury'},
      {'name': isFr ? 'Étudiants' : 'Student Housing'},
      {'name': 'Colocation', 'nameEn': 'Shared'},
      {'name': isFr ? 'Courts Séjours' : 'Short Stays'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            isFr ? 'Catégories' : 'Categories',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  context.push('/tenant/search', extra: {'category': cat['name']});
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    cat['name'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserReviewsSection() {
    final theme = Theme.of(context);
    final reviews = [
      {'name': 'Jean Dupont', 'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100', 'rating': 5, 'text': 'Found a great apartment in Douala very quickly. The platform is secure and the landlord was responsive!'},
      {'name': 'Marie K.', 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100', 'rating': 4, 'text': 'Very useful application for students looking for housing near the university.'},
      {'name': 'Paul B.', 'avatar': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100', 'rating': 5, 'text': 'The 3D tours and floor plans saved me so much time. Highly recommend SpaceRentals!'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text('User Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                width: MediaQuery.sizeOf(context).width * 0.75,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: NetworkImage(review['avatar'] as String),
                            ),
                            const SizedBox(width: 8),
                            Text(review['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < (review['rating'] as int) ? Icons.star : Icons.star_border,
                            color: Colors.amber, size: 14,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        review['text'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPartnershipsSection() {
    final partners = [
      {'name': 'Google', 'icon': Icons.g_mobiledata, 'color': Colors.red},
      {'name': 'Facebook', 'icon': Icons.facebook, 'color': Colors.blue},
      {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': Colors.pink},
      {'name': 'Orange', 'icon': Icons.signal_cellular_alt, 'color': Colors.orange},
      {'name': 'Cameroon Real Estate', 'icon': Icons.business, 'color': Colors.grey.shade800},
      {'name': 'MTN', 'icon': Icons.wifi, 'color': Colors.yellow.shade700},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text('Our Partnerships', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 50,
          child: _AutoScrollMarquee(
            children: partners.map((partner) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(partner['icon'] as IconData, color: partner['color'] as Color),
                    const SizedBox(width: 8),
                    Text(partner['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformStatistics() {
    final stats = [
      {'title': '10K+ Properties', 'desc': 'Find the perfect place from an extensive list in Yaoundé and Douala.'},
      {'title': '50+ Universities', 'desc': 'Best student homes near Buea, Ngoa-Ekélé, and major campuses.'},
      {'title': '10 Regions', 'desc': 'We cover every major region in Cameroon.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text('Platform Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Container(
                width: 250,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(stats[index]['title']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(stats[index]['desc']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── "What Are You Waiting For" Banner ─────────────────────────────────────
  Widget _buildWaitingForSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Background app showcase image
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_showcase.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary.withValues(alpha: 0.85), const Color(0xFF5D3F6A).withValues(alpha: 0.70)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'What Are You\nWaiting For?',
                  style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Join Us',
                  style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thousands of tenants and landlords are already\nusing SpaceRentals to find and list properties\nacross Cameroon.',
                  style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.6),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse('https://wa.me/652856939');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.message_rounded, size: 18),
                      label: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6C3B9A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Learn More', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Google Map + Cameroon Regions ─────────────────────────────────────────
  Widget _buildMapAndRegionsSection(ThemeData theme) {
    final regions = [
      {'name': 'Centre', 'capital': 'Yaoundé', 'icon': Icons.location_city},
      {'name': 'Littoral', 'capital': 'Douala', 'icon': Icons.water},
      {'name': 'Nord-Ouest', 'capital': 'Bamenda', 'icon': Icons.landscape},
      {'name': 'Sud-Ouest', 'capital': 'Buea', 'icon': Icons.park},
      {'name': 'Ouest', 'capital': 'Bafoussam', 'icon': Icons.terrain},
      {'name': 'Nord', 'capital': 'Garoua', 'icon': Icons.wb_sunny},
      {'name': 'Adamaoua', 'capital': 'Ngaoundéré', 'icon': Icons.grass},
      {'name': 'Est', 'capital': 'Bertoua', 'icon': Icons.forest},
      {'name': 'Sud', 'capital': 'Ebolowa', 'icon': Icons.nature},
      {'name': 'Extrême-Nord', 'capital': 'Maroua', 'icon': Icons.thermostat},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('We Operate Across Cameroon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Find properties in all 10 regions', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map side — static tile image, opens Google Maps on tap
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse('https://www.google.com/maps/@5.5,12.3,7z');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    height: 340,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Static OpenStreetMap tile of Cameroon
                        Image.network(
                          'https://tile.openstreetmap.org/6/33/30.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: const Color(0xFFD4E6C3),
                            child: Center(
                              child: Icon(Icons.map_outlined, size: 60, color: Colors.green.shade700),
                            ),
                          ),
                        ),
                        // City pin overlays
                        ..._mapPins(theme),
                        // Open Maps badge
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.open_in_new, size: 12, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text('Open Maps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Regions list side
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  height: 340,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: regions.length,
                    itemBuilder: (context, index) {
                      final region = regions[index];
                      return GestureDetector(
                        onTap: () => context.push('/tenant/search', extra: {'location': region['capital']}),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                          ),
                          child: Row(
                            children: [
                              Icon(region['icon'] as IconData, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(region['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(region['capital'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _mapPins(ThemeData theme) {
    // Alignment ranges: -1=left/top, 0=center, 1=right/bottom
    final pins = [
      {'label': 'Yaoundé',  'ax': 0.0,   'ay': 0.2},
      {'label': 'Douala',   'ax': -0.5,  'ay': 0.35},
      {'label': 'Bamenda',  'ax': -0.55, 'ay': -0.2},
      {'label': 'Garoua',   'ax': 0.05,  'ay': -0.65},
      {'label': 'Buea',     'ax': -0.6,  'ay': 0.15},
    ];
    return pins.map((pin) {
      return Align(
        alignment: Alignment(pin['ax'] as double, pin['ay'] as double),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
              ),
              child: Text(pin['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
            const Icon(Icons.location_on, color: Colors.red, size: 16),
          ],
        ),
      );
    }).toList();
  }

  // ── FAQ ──────────────────────────────────────────────────────────────────
  Widget _buildFaqSection(ThemeData theme) {
    return _FaqSection(theme: theme);
  }

  Widget _buildFooter(bool isFr, ThemeData theme) {

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F3), // light grey/white background
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo.png', width: 32, height: 32, errorBuilder: (_, __, ___) => Icon(Icons.apartment, color: theme.colorScheme.primary, size: 32)),
              const SizedBox(width: 10),
              Text(
                'SpaceRentals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: -0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isFr 
                ? 'L\'avenir de la location immobilière en Afrique. Sécurisé, rapide et transparent.' 
                : 'The future of real estate rentals in Africa. Secure, fast, and transparent.',
            style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isFr ? 'Société' : 'Company', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    _footerLink(isFr ? 'À propos' : 'About Us'),
                    _footerLink(isFr ? 'Carrières' : 'Careers'),
                    _footerLink(isFr ? 'Contact' : 'Contact'),
                    _footerLink(isFr ? 'Blog' : 'Blog'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isFr ? 'Assistance' : 'Support', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    _footerLink(isFr ? 'Centre d\'aide' : 'Help Center'),
                    _footerLink(isFr ? 'Signaler un problème' : 'Report Issue'),
                    _footerLink(isFr ? 'Conditions générales' : 'Terms of Service'),
                    _footerLink(isFr ? 'Confidentialité' : 'Privacy Policy'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Color(0xFFE5E5E5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('© 2026 SpaceRentals. All rights reserved.', style: TextStyle(color: Colors.black45, fontSize: 11)),
              Row(
                children: [
                  _socialIcon(Icons.facebook),
                  const SizedBox(width: 12),
                  _socialIcon(Icons.camera_alt),
                  const SizedBox(width: 12),
                  _socialIcon(Icons.link), // Using link as generic social icon
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 13)),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Icon(icon, size: 14, color: Colors.black54),
    );
  }
}

class _AutoScrollMarquee extends StatefulWidget {
  final List<Widget> children;
  const _AutoScrollMarquee({required this.children});
  
  @override
  State<_AutoScrollMarquee> createState() => _AutoScrollMarqueeState();
}

class _AutoScrollMarqueeState extends State<_AutoScrollMarquee> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final currentPos = _scrollController.offset;
        _scrollController.jumpTo(currentPos + 1.5);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: widget.children[index % widget.children.length],
        );
      },
    );
  }
}

// ── FAQ Section Widget ────────────────────────────────────────────────────────
class _FaqSection extends StatefulWidget {
  final ThemeData theme;
  const _FaqSection({required this.theme});

  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  int? _selectedIndex;

  final _faqs = const [
    {
      'q': 'How do I rent a property on SpaceRentals?',
      'a': 'Simply browse our listings, select your ideal property, and submit a rental application. Our landlords typically respond within 24 hours. Once approved, you\'ll receive a digital rental agreement to sign.',
    },
    {
      'q': 'Is SpaceRentals available across Cameroon?',
      'a': 'Yes! We operate in all 10 regions of Cameroon including Centre, Littoral, Nord-Ouest, Sud-Ouest, Ouest, Nord, Adamaoua, Est, Sud, and Extrême-Nord.',
    },
    {
      'q': 'How are payments handled?',
      'a': 'Payments are made securely through the app via Mobile Money (MTN, Orange) or bank transfer. All transactions are logged and both tenant and landlord receive instant receipts.',
    },
    {
      'q': 'Can I list my property as a landlord?',
      'a': 'Absolutely! Register as a landlord, complete a quick KYC verification, and start listing your property with full details, photos, videos, and floor plans.',
    },
    {
      'q': 'How do I leave a review?',
      'a': 'After your rental period ends, you\'ll receive an in-app prompt to rate your experience from 1 to 5 stars. Your review will be visible to all other users on the platform.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Got questions? We have answers.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Questions list (left)
              Expanded(
                flex: 2,
                child: Column(
                  children: List.generate(_faqs.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = isSelected ? null : index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? widget.theme.colorScheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? widget.theme.colorScheme.primary : Colors.grey.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.04), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _faqs[index]['q']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.remove : Icons.add,
                              size: 16,
                              color: isSelected ? Colors.white : widget.theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              // Answer panel (right)
              Expanded(
                flex: 3,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedIndex != null
                      ? Container(
                          key: ValueKey(_selectedIndex),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Answer',
                                  style: TextStyle(color: widget.theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _faqs[_selectedIndex!]['q']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _faqs[_selectedIndex!]['a']!,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.6),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          key: const ValueKey('empty'),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.quiz_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'Select a question\non the left to see\nthe answer here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

