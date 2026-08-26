import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../../features/properties/domain/property.dart';
import '../../models/review_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/reviews_provider.dart';
import '../../core/utils/ui_helpers.dart';
import '../../widgets/guest_guard.dart';

class PropertyDetails extends ConsumerStatefulWidget {
  final PropertyWithListing property;
  const PropertyDetails({super.key, required this.property});

  @override
  ConsumerState<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends ConsumerState<PropertyDetails> with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final theme = Theme.of(context);
    final isFav = ref.watch(favoritesProvider).any((p) => p.property.id == property.property.id);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Image Carousel SliverAppBar ─────────────────────────────
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white),
                  onPressed: () => GuestGuard.check(
                    context, ref,
                    () => ref.read(favoritesProvider.notifier).toggleFavorite(property),
                    featureName: 'saved properties',
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // PageView carousel
                    PageView.builder(
                      controller: _pageController,
                      itemCount: property.property.images.length,
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemBuilder: (context, index) {
                        return Image.network(
                          property.property.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          cacheWidth: 800,
                          cacheHeight: 600,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.image_not_supported, size: 60, color: Colors.white38),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    // Dot indicators
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(property.property.images.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == i ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == i ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Photo counter badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1} / ${property.property.images.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title & Verified ───────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(property.property.title,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        if (property.verification.level.index >= 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.verified, color: Colors.green, size: 20),
                                const SizedBox(width: 4),
                                Text('Verified', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Location ───────────────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text(property.property.location, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Rating & Category ──────────────────────────────
                    Row(
                      children: [
                        _buildStarRating(4.5),
                        const SizedBox(width: 8),
                        Text('${4.5}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(property.property.category,
                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Price ──────────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${CurrencyFormatter.formatCFA(property.property.monthlyRentUnits.toDouble())} / month',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deposit: ${CurrencyFormatter.formatCFA(property.property.depositUnits.toDouble())}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Quick Stats ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: _buildStatChip(context, Icons.bed, '${property.property.bedrooms}', 'Beds')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatChip(context, Icons.bathtub, '${property.property.bathrooms}', 'Baths')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildStatChip(context, Icons.square_foot, '${property.property.areaSqM.toInt()} m²', 'Area')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Extra Details ──────────────────────────────────────
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (property.property.furnished) _buildDetailBadge(Icons.chair, 'Furnished', Colors.teal),
                        if (property.property.parkingSpaces > 0) _buildDetailBadge(Icons.local_parking, '${property.property.parkingSpaces} Parking', Colors.indigo),
                        if (false) _buildDetailBadge(Icons.stairs, 'Floor ${0}/${0}', Colors.purple),
                        if (false) _buildDetailBadge(Icons.calendar_today, 'Built ${0}', Colors.blueGrey),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Multimedia buttons ─────────────────────────────
                    if ((<String>[]).isNotEmpty || (<String>[]).isNotEmpty) ...[
                      Row(
                        children: [
                          if ((<String>[]).isNotEmpty)
                            Expanded(
                              child: _buildMediaButton(
                                icon: Icons.architecture,
                                label: 'Floor Plan',
                                color: Colors.indigo,
                                onTap: () => _showFloorPlanGallery(context, (<String>[])),
                              ),
                            ),
                          if ((<String>[]).isNotEmpty && (<String>[]).isNotEmpty)
                            const SizedBox(width: 12),
                          if ((<String>[]).isNotEmpty)
                            Expanded(
                              child: _buildMediaButton(
                                icon: Icons.play_circle_filled,
                                label: 'Video Tour',
                                color: Colors.red,
                                onTap: () => _showVideoDialog(context, (<String>[])),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Description ────────────────────────────────────
                    _buildSectionHeader('Description'),
                    const SizedBox(height: 10),
                    Text(property.property.description, style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 14)),
                    const SizedBox(height: 28),

                    // ── Amenities ──────────────────────────────────────
                    _buildSectionHeader('Amenities & Features'),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.8,
                      children: [
                        _buildAmenityTile(Icons.water_drop, 'Water', property.property.hasWater),
                        _buildAmenityTile(Icons.bolt, 'Electricity', property.property.hasElectricity),
                        _buildAmenityTile(Icons.fence, 'Fenced', property.property.isFenced),
                        _buildAmenityTile(Icons.traffic, 'Near Road', property.property.closeToRoad),
                        _buildAmenityTileText(Icons.security, 'Security', property.property.securityMeans),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Rental Agreement Terms ─────────────────────────
                    _buildSectionHeader('Rental Agreement Terms'),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: (['No smoking inside the apartment', 'No loud noise after 10PM']).asMap().entries.map((entry) {
                          final isLast = entry.key == (['No smoking inside the apartment', 'No loud noise after 10PM']).length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 13, height: 1.4))),
                                  ],
                                ),
                              ),
                              if (!isLast) Divider(height: 1, indent: 46, color: Colors.grey.shade200),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Nearby Amenities ───────────────────────────────
                    if ((['Supermarket (200m)', 'Pharmacy (500m)']).isNotEmpty) ...[  
                      _buildSectionHeader('Nearby Amenities'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (['Supermarket (200m)', 'Pharmacy (500m)']).map((amenity) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.place, size: 13, color: Colors.teal),
                            const SizedBox(width: 4),
                            Text(amenity, style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w500)),
                          ]),
                        )).toList(),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Map ────────────────────────────────────────────
                    _buildSectionHeader('Location on Map'),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 220,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng((property.property.latitude ?? 3.848), (property.property.longitude ?? 11.502)),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(property.property.id),
                              position: LatLng((property.property.latitude ?? 3.848), (property.property.longitude ?? 11.502)),
                              infoWindow: InfoWindow(title: property.property.title, snippet: property.property.location),
                            ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Reviews ────────────────────────────────────────
                    _ReviewsSection(propertyId: property.property.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom CTA ─────────────────────────────────────────────────
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Consumer(
          builder: (context, ref, child) {
            final auth = ref.watch(authProvider);
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
                    onPressed: () => GuestGuard.check(
                      context, ref,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening chat with landlord...')),
                      ),
                      featureName: 'landlord chat',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => GuestGuard.check(
                      context, ref,
                      () => context.push('/tenant/apply', extra: property),
                      featureName: 'property applications',
                    ),
                    child: const Text('Apply / Rent Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Helper Builders ─────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (i < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMediaButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityTile(IconData icon, String label, bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: available ? Colors.green.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: available ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: available ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: available ? Colors.green[700] : Colors.grey[600]))),
          Icon(available ? Icons.check : Icons.close, size: 14, color: available ? Colors.green : Colors.grey),
        ],
      ),
    );
  }

  Widget _buildAmenityTileText(IconData icon, String label, String value) {
    final hasValue = value != 'None' && value.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasValue ? Colors.blue.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: hasValue ? Colors.blue.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: hasValue ? Colors.blue : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value != 'None' ? value : 'No Security',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: hasValue ? Colors.blue[700] : Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showFloorPlanGallery(BuildContext context, List<String> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(children: [Icon(Icons.architecture, color: Colors.indigo), SizedBox(width: 8), Text('Floor Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final path = images[index];
                    final isLocal = path.startsWith('/');
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isLocal 
                          ? Image.file(File(path), fit: BoxFit.contain, cacheWidth: 800, cacheHeight: 600, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.grey))
                          : Image.network(path, fit: BoxFit.contain, cacheWidth: 800, cacheHeight: 600, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoDialog(BuildContext context, List<String> videoUrls) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [Icon(Icons.play_circle_filled, color: Colors.red), SizedBox(width: 10), Text('Video Tour')],
        ),
        content: Container(
          height: 180,
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_filled, size: 64, color: Colors.red),
                const SizedBox(height: 12),
                Text('${videoUrls.length} video(s) uploaded', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                const Text('Contact the landlord to watch the tour', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white54)),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Reviews Section ────────────────────────────────────────────────────────────
class _ReviewsSection extends ConsumerStatefulWidget {
  final String propertyId;
  const _ReviewsSection({required this.propertyId});

  @override
  ConsumerState<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends ConsumerState<_ReviewsSection> {
  int _selectedStars = 0;
  final _commentCtrl = TextEditingController();
  bool _showForm = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviews = ref.watch(propertyReviewsProvider(widget.propertyId));
    final avgRating = ref.watch(propertyAverageRatingProvider(widget.propertyId));
    final user = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Reviews', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                if (reviews.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text('$avgRating (${reviews.length})', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (user != null)
              GestureDetector(
                onTap: () => setState(() => _showForm = !_showForm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(_showForm ? 'Cancel' : '+ Review', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        if (_showForm) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setState(() => _selectedStars = i + 1),
                    child: Icon(i < _selectedStars ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                  )),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this property...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _selectedStars == 0 || _commentCtrl.text.trim().isEmpty ? null : () {
                    final review = ReviewModel(
                      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                      propertyId: widget.propertyId,
                      tenantId: user.session!.userId,
                      tenantName: user.session?.fullName ?? "Unknown",
                      rating: _selectedStars.toDouble(),
                      comment: _commentCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    ref.read(reviewsNotifierProvider.notifier).addReview(review);
                    setState(() { _showForm = false; _selectedStars = 0; _commentCtrl.clear(); });
                    context.showSuccessToast('Review submitted! Thank you 🌟');
                  },
                  child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14)),
            child: const Center(
              child: Column(children: [
                Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('No reviews yet', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                Text('Be the first to review!', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
          )
        else
          ...reviews.map((review) => _ReviewCard(review: review)),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(review.tenantName.isNotEmpty ? review.tenantName[0].toUpperCase() : '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.tenantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating.floor() ? Icons.star : (i < review.rating ? Icons.star_half : Icons.star_border),
                  color: Colors.amber, size: 14,
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }
}


