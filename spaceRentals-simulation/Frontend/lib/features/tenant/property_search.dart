import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/property_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/property_card.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../features/properties/domain/property.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/utils/currency_formatter.dart';

class PropertySearch extends ConsumerStatefulWidget {
  final bool showMap;
  const PropertySearch({super.key, this.showMap = false});

  @override
  ConsumerState<PropertySearch> createState() => _PropertySearchState();
}

class _PropertySearchState extends ConsumerState<PropertySearch> {
  late bool _showMap;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Price: Low to High';
  double _minPrice = 0;
  double _maxPrice = 500000;
  int? _bedrooms;
  bool _isVerifiedOnly = false;
  int _currentPage = 1;
  static const int _pageSize = 6;

  final List<String> _categories = ['All', 'Apartments', 'Studios', 'Villas', 'Commercial'];
  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Price ↑', 'value': 'Price: Low to High', 'icon': Icons.arrow_upward},
    {'label': 'Price ↓', 'value': 'Price: High to Low', 'icon': Icons.arrow_downward},
    {'label': 'Newest', 'value': 'Newest First', 'icon': Icons.new_releases_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _showMap = widget.showMap;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PropertyWithListing> _applyFilters(List<PropertyWithListing> properties) {
    List<PropertyWithListing> result = List.from(properties);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) =>
        p.property.title.toLowerCase().contains(q) ||
        p.property.location.toLowerCase().contains(q) ||
        p.property.category.toLowerCase().contains(q)).toList();
    }

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.property.category == _selectedCategory).toList();
    }
    
    if (_bedrooms != null) {
      result = result.where((p) => p.property.bedrooms >= _bedrooms!).toList();
    }
    
    if (_isVerifiedOnly) {
      result = result.where((p) => p.verification.isVerified).toList();
    }
    
    result = result.where((p) => p.property.monthlyRentUnits >= _minPrice && p.property.monthlyRentUnits <= _maxPrice).toList();

    switch (_sortBy) {
      case 'Price: Low to High':
        result.sort((a, b) => a.property.monthlyRentUnits.compareTo(b.property.monthlyRentUnits));
        break;
      case 'Price: High to Low':
        result.sort((a, b) => b.property.monthlyRentUnits.compareTo(a.property.monthlyRentUnits));
        break;
      case 'Newest First':
        result = result.reversed.toList();
        break;
    }
    return result;
  }

  void _showFilterSheet(BuildContext context, bool isFr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isFr ? 'Filtres & Tri' : 'Filters & Sort',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _sortBy = 'Price: Low to High';
                        _minPrice = 0;
                        _maxPrice = 500000;
                        _bedrooms = null;
                        _isVerifiedOnly = false;
                        _currentPage = 1;
                      });
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(isFr ? 'Réinitialiser' : 'Reset'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Text(isFr ? 'Catégorie' : 'Category',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => _selectedCategory = cat);
                      setState(() { _selectedCategory = cat; _currentPage = 1; });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? Colors.white : Colors.grey[800],
                        )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(isFr ? 'Fourchette de prix (FCFA)' : 'Price Range (FCFA)',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 1000000,
                divisions: 20,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Colors.grey[200],
                labels: RangeLabels(
                  CurrencyFormatter.formatCFA(_minPrice),
                  _maxPrice == 1000000 ? '${CurrencyFormatter.formatCFA(_maxPrice)}+' : CurrencyFormatter.formatCFA(_maxPrice),
                ),
                onChanged: (RangeValues values) {
                  setModalState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                    _currentPage = 1;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(CurrencyFormatter.formatCFA(_minPrice), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(_maxPrice == 1000000 ? '${CurrencyFormatter.formatCFA(_maxPrice)}+' : CurrencyFormatter.formatCFA(_maxPrice), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isFr ? 'Chambres (Min)' : 'Bedrooms (Min)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [null, 1, 2, 3, 4].map((beds) {
                            final selected = _bedrooms == beds;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() => _bedrooms = beds);
                                setState(() { _bedrooms = beds; _currentPage = 1; });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(beds == null ? 'Any' : '$beds+',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    color: selected ? Colors.white : Colors.grey[800],
                                  )),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(isFr ? 'Propriétés Vérifiées Seulement' : 'Verified Properties Only',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
                subtitle: Text(isFr ? 'Afficher uniquement les biens vérifiés par un agent' : 'Show only properties verified by an agent',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                value: _isVerifiedOnly,
                activeColor: Theme.of(context).colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setModalState(() => _isVerifiedOnly = val);
                  setState(() { _isVerifiedOnly = val; _currentPage = 1; });
                },
              ),
              const SizedBox(height: 20),
              Text(isFr ? 'Trier par' : 'Sort By',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              ..._sortOptions.map((opt) {
                final isSelected = _sortBy == opt['value'];
                return GestureDetector(
                  onTap: () {
                    setModalState(() => _sortBy = opt['value']!);
                    setState(() => _sortBy = opt['value']!);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[200]!,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(opt['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                        const SizedBox(width: 12),
                        Text(opt['value']! as String,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
                          )),
                        const Spacer(),
                        if (isSelected)
                          Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(isFr ? 'Appliquer' : 'Apply Filters',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(marketplaceListingsProvider);
    final locale = ref.watch(localeProvider);
    final isFr = locale.languageCode == 'fr';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header with Search ───────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // ── Breadcrumb ────────────────────────
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.go('/tenant'),
                              child: Text(
                                isFr ? 'Accueil' : 'Home',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.chevron_right, color: Colors.white54, size: 14),
                            ),
                            Text(
                              isFr ? 'Recherche' : 'Search',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedCategory != 'All') ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.chevron_right, color: Colors.white54, size: 14),
                              ),
                              Text(
                                _selectedCategory,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        // ── Search Field ─────────────────────
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() {
                              _searchQuery = val;
                              _currentPage = 1;
                            }),
                            decoration: InputDecoration(
                              hintText: isFr ? 'Rechercher Yaoundé, Douala...' : 'Search Yaoundé, Douala...',
                              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                      onPressed: () => setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      }),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                icon: Icon(_showMap ? Icons.list_alt : Icons.map_outlined, color: Colors.white),
                onPressed: () => setState(() => _showMap = !_showMap),
                tooltip: _showMap ? (isFr ? 'Vue liste' : 'List View') : (isFr ? 'Vue carte' : 'Map View'),
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () => _showFilterSheet(context, isFr),
                tooltip: isFr ? 'Filtres' : 'Filters',
              ),
            ],
          ),

          // ── Sort chips bar (always visible) ──────────────────
          SliverToBoxAdapter(
            child: ColoredBox(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort options row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 15, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          isFr ? 'Trier :' : 'Sort:',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _sortOptions.map((opt) {
                                final isActive = _sortBy == opt['value'];
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _sortBy = opt['value'] as String;
                                    _currentPage = 1;
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isActive ? theme.colorScheme.primary : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isActive ? theme.colorScheme.primary : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          opt['icon'] as IconData,
                                          size: 12,
                                          color: isActive ? Colors.white : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          opt['label'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                            color: isActive ? Colors.white : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Active filter chips
                  if (_selectedCategory != 'All')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Chip(
                            label: Text(_selectedCategory, style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 13),
                            onDeleted: () => setState(() { _selectedCategory = 'All'; _currentPage = 1; }),
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            deleteIconColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                            side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),

          // ── Map or List Results ───────────────────────────────
          if (_showMap)
            propertiesAsync.when(
              data: (allProperties) {
                final filtered = _applyFilters(allProperties);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(isFr ? 'Aucune propriété trouvée' : 'No properties found')),
                  );
                }
                // ── Map placeholder with property location cards ──────
                return SliverFillRemaining(
                  hasScrollBody: true,
                  child: Column(
                    children: [
                      // Map placeholder banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary.withValues(alpha: 0.08), const Color(0xFF5D3F6A).withValues(alpha: 0.05)],
                          ),
                          border: Border(bottom: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.12))),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.map_outlined, color: theme.colorScheme.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isFr ? '${filtered.length} propriétés trouvées' : '${filtered.length} properties found',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.primary),
                                  ),
                                  Text(
                                    isFr ? 'Vue carte interactive bientôt disponible' : 'Interactive map view coming soon',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Property location cards
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = filtered[index];
                            return GestureDetector(
                              onTap: () => context.push('/tenant/property/${p.property.id}', extra: p),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        p.property.images.isNotEmpty ? p.property.images.first : '',
                                        width: 64, height: 64, fit: BoxFit.cover,
                                        cacheWidth: 128, cacheHeight: 128,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 64, height: 64,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.home_outlined, color: theme.colorScheme.primary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.property.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Row(children: [
                                            Icon(Icons.location_on, size: 12, color: theme.colorScheme.primary),
                                            const SizedBox(width: 3),
                                            Expanded(child: Text(p.property.location, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ]),
                                          if (p.property.latitude != null) ...[
                                            const SizedBox(height: 2),
                                            Text('${p.property.latitude!.toStringAsFixed(4)}°N, ${p.property.longitude!.toStringAsFixed(4)}°E',
                                              style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyFormatter.formatCFA(p.property.monthlyRentUnits.toDouble()),
                                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text('/mo', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                        const SizedBox(height: 6),
                                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[300]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text('Failed to load properties', style: TextStyle(color: Colors.red)),
                      TextButton(
                        onPressed: () => ref.invalidate(marketplaceListingsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )

          else
            propertiesAsync.when(
              data: (allProperties) {
                final filtered = _applyFilters(allProperties);
                final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 999);
                // clamp current page
                if (_currentPage > totalPages) _currentPage = totalPages;
                final startIndex = (_currentPage - 1) * _pageSize;
                final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
                final visibleProperties = filtered.sublist(startIndex, endIndex);

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              isFr ? 'Aucune propriété trouvée' : 'No properties found',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isFr ? 'Essayez d\'autres mots-clés ou filtres' : 'Try different keywords or filters',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    // Result count + page indicator
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isFr
                                  ? '${filtered.length} propriété${filtered.length != 1 ? 's' : ''} trouvée${filtered.length != 1 ? 's' : ''}'
                                  : '${filtered.length} propert${filtered.length != 1 ? 'ies' : 'y'} found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (totalPages > 1)
                              Text(
                                isFr ? 'Page $_currentPage sur $totalPages' : 'Page $_currentPage of $totalPages',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Property list
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => PropertyCard(
                            item: visibleProperties[index],
                            onTap: () => context.push(
                              '/tenant/property/${visibleProperties[index].property.id}',
                              extra: visibleProperties[index],
                            ),
                          ),
                          childCount: visibleProperties.length,
                        ),
                      ),
                    ),

                    // ── Pagination controls ───────────────────
                    if (totalPages > 1)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: Column(
                            children: [
                              // Showing x–y of n
                              Text(
                                isFr
                                    ? 'Affichage de ${startIndex + 1}–$endIndex sur ${filtered.length}'
                                    : 'Showing ${startIndex + 1}–$endIndex of ${filtered.length}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              // Page number buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Prev button
                                  _pageBtn(
                                    child: const Icon(Icons.chevron_left, size: 20),
                                    enabled: _currentPage > 1,
                                    theme: theme,
                                    onTap: () => setState(() => _currentPage--),
                                  ),
                                  const SizedBox(width: 8),
                                  // Page number chips
                                  ...List.generate(totalPages, (i) {
                                    final page = i + 1;
                                    final isActive = page == _currentPage;
                                    // Show first, last, current ±1, and ellipsis
                                    final showPage = page == 1 ||
                                        page == totalPages ||
                                        (page >= _currentPage - 1 && page <= _currentPage + 1);
                                    final showEllipsisBefore = page == _currentPage - 2 && _currentPage > 3;
                                    final showEllipsisAfter = page == _currentPage + 2 && _currentPage < totalPages - 2;

                                    if (!showPage && !showEllipsisBefore && !showEllipsisAfter) {
                                      return const SizedBox.shrink();
                                    }
                                    if (showEllipsisBefore || showEllipsisAfter) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                        child: Text('…', style: TextStyle(color: Colors.grey)),
                                      );
                                    }
                                    return _pageBtn(
                                      child: Text('$page',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isActive ? Colors.white : theme.colorScheme.primary,
                                        )),
                                      enabled: true,
                                      isActive: isActive,
                                      theme: theme,
                                      onTap: () => setState(() => _currentPage = page),
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  // Next button
                                  _pageBtn(
                                    child: const Icon(Icons.chevron_right, size: 20),
                                    enabled: _currentPage < totalPages,
                                    theme: theme,
                                    onTap: () => setState(() => _currentPage++),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const PropertyCardShimmer(),
                    childCount: 5,
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text('Failed to load properties', style: TextStyle(color: Colors.red)),
                      TextButton(
                        onPressed: () => ref.invalidate(marketplaceListingsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pageBtn({
    required Widget child,
    required bool enabled,
    required ThemeData theme,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : enabled
                  ? Colors.white
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : enabled
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : Colors.grey[200]!,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 6)]
              : [],
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: isActive
                  ? Colors.white
                  : enabled
                      ? theme.colorScheme.primary
                      : Colors.grey[400],
              size: 16,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: enabled ? theme.colorScheme.primary : Colors.grey[400]),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
