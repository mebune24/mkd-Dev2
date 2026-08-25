import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/locale_provider.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  final String tenantId;
  const MaintenanceScreen({super.key, required this.tenantId});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  void _submitRequest(String type, String serviceName) {
    Fluttertoast.showToast(
      msg: '$serviceName request submitted successfully!',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFr = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isFr ? 'Maintenance & Services' : 'Maintenance & Services'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: isFr ? 'Réparations' : 'Repairs'),
            Tab(text: isFr ? 'Services Premium' : 'Premium Services'),
          ],
        ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRepairsTab(isFr, theme),
          _buildServicesTab(isFr, theme),
        ],
      ),
    );
  }

  Widget _buildRepairsTab(bool isFr, ThemeData theme) {
    final List<Map<String, dynamic>> repairTypes = [
      {'icon': Icons.plumbing, 'title': isFr ? 'Plomberie' : 'Plumbing', 'desc': isFr ? 'Fuites, canalisations, etc.' : 'Leaks, pipes, clogs'},
      {'icon': Icons.electrical_services, 'title': isFr ? 'Électricité' : 'Electrical', 'desc': isFr ? 'Prises, lumières, câblage' : 'Outlets, lights, wiring'},
      {'icon': Icons.kitchen, 'title': isFr ? 'Électroménager' : 'Appliances', 'desc': isFr ? 'Frigo, four, machine à laver' : 'Fridge, oven, washer'},
      {'icon': Icons.roofing, 'title': isFr ? 'Structure & Toit' : 'Structural & Roof', 'desc': isFr ? 'Murs, toit, fenêtres' : 'Walls, roof, windows'},
      {'icon': Icons.pest_control, 'title': isFr ? 'Désinsectisation' : 'Pest Control', 'desc': isFr ? 'Insectes, rongeurs' : 'Insects, rodents'},
      {'icon': Icons.handyman, 'title': isFr ? 'Autre réparation' : 'Other Repair', 'desc': isFr ? 'Décrivez votre problème' : 'Describe your issue'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: repairTypes.length,
      itemBuilder: (context, index) {
        final item = repairTypes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              child: Icon(item['icon'] as IconData, color: Colors.red),
            ),
            title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['desc'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showRequestForm(isFr, item['title'] as String, 'repair'),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab(bool isFr, ThemeData theme) {
    final List<Map<String, dynamic>> premiumServices = [
      {'icon': Icons.cleaning_services, 'title': isFr ? 'Nettoyage & Ménage' : 'House Cleaning', 'desc': isFr ? 'Service régulier ou ponctuel' : 'Regular or one-time service', 'price': '15,000 CFA'},
      {'icon': Icons.local_shipping, 'title': isFr ? 'Aide au Déménagement' : 'Moving Assistance', 'desc': isFr ? 'Transport et manutention' : 'Transport & handling', 'price': '50,000 CFA'},
      {'icon': Icons.dry_cleaning, 'title': isFr ? 'Blanchisserie' : 'Laundry & Dry Cleaning', 'desc': isFr ? 'Collecte et livraison' : 'Pickup & delivery', 'price': 'Varies'},
      {'icon': Icons.wifi, 'title': isFr ? 'Mise à niveau WiFi' : 'WiFi Upgrade', 'desc': isFr ? 'Fibre optique haut débit' : 'High-speed fiber upgrade', 'price': '25,000 CFA/mo'},
      {'icon': Icons.local_florist, 'title': isFr ? 'Entretien du Jardin' : 'Landscaping & Garden', 'desc': isFr ? 'Tonte et aménagement' : 'Lawn care & maintenance', 'price': '10,000 CFA'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: premiumServices.length,
      itemBuilder: (context, index) {
        final item = premiumServices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(item['icon'] as IconData, color: theme.colorScheme.primary),
            ),
            title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['desc'] as String),
                const SizedBox(height: 4),
                Text(
                  item['price'] as String,
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _submitRequest('service', item['title'] as String),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isFr ? 'Réserver' : 'Book'),
            ),
          ),
        );
      },
    );
  }

  void _showRequestForm(bool isFr, String title, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${isFr ? "Demande" : "Request"}: $title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: isFr ? 'Décrivez le problème...' : 'Describe the issue...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _submitRequest(type, title);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isFr ? 'Soumettre la Demande' : 'Submit Request'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
