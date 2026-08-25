import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

class AncillaryService {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final IconData icon;

  AncillaryService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
  });
}

class AncillaryServicesWidget extends StatefulWidget {
  final double baseRent;
  final void Function(double newTotal, List<String> selectedServices) onTotalChanged;

  const AncillaryServicesWidget({
    super.key,
    required this.baseRent,
    required this.onTotalChanged,
  });

  @override
  State<AncillaryServicesWidget> createState() => _AncillaryServicesWidgetState();
}

class _AncillaryServicesWidgetState extends State<AncillaryServicesWidget> {
  final List<AncillaryService> _availableServices = [
    AncillaryService(id: 's1', title: 'Ménage complet (Mensuel)', subtitle: 'Nettoyage professionnel 2x par mois', price: 30000, icon: Icons.cleaning_services),
    AncillaryService(id: 's2', title: 'Installation Wi-Fi Fibre', subtitle: 'Box fibre très haut débit', price: 15000, icon: Icons.wifi),
    AncillaryService(id: 's3', title: 'Assurance Habitation Premium', subtitle: 'Couverture vol et incendie', price: 5000, icon: Icons.security),
    AncillaryService(id: 's4', title: 'Parking Sécurisé', subtitle: 'Place de parking numérotée', price: 20000, icon: Icons.local_parking),
  ];

  final Set<String> _selectedServices = {};

  double get _currentTotal {
    double total = widget.baseRent;
    for (var svc in _availableServices) {
      if (_selectedServices.contains(svc.id)) {
        total += svc.price;
      }
    }
    return total;
  }

  void _toggleService(String id) {
    setState(() {
      if (_selectedServices.contains(id)) {
        _selectedServices.remove(id);
      } else {
        _selectedServices.add(id);
      }
    });
    widget.onTotalChanged(_currentTotal, _selectedServices.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Services Optionnels', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Ajoutez ces services à votre contrat de bail pour plus de confort.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableServices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final svc = _availableServices[index];
            final isSelected = _selectedServices.contains(svc.id);
            return GestureDetector(
              onTap: () => _toggleService(svc.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (!isSelected) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(svc.icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(svc.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? theme.colorScheme.primary : Colors.black87)),
                          const SizedBox(height: 2),
                          Text(svc.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+ ${CurrencyFormatter.formatCFA(svc.price)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? theme.colorScheme.primary : Colors.black87),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Loyer Mensuel Estimé', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                CurrencyFormatter.formatCFA(_currentTotal),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
