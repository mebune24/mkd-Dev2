import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:go_router/go_router.dart';

class AgentPropertiesScreen extends StatelessWidget {
  const AgentPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Managed Properties'),
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
          // Add Property Button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_business),
            label: const Text('Add Property on behalf of Landlord'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Your Active Listings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          
          _buildAgentPropertyCard(
            context,
            title: 'Appartement Bastos',
            location: 'Yaoundé, Bastos',
            rent: 150000,
            commission: 75000,
            status: 'Rented',
            imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500&auto=format&fit=crop',
          ),
          
          _buildAgentPropertyCard(
            context,
            title: 'Studio Bonamoussadi',
            location: 'Douala, Bonamoussadi',
            rent: 50000,
            commission: 25000,
            status: 'Available',
            imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1de2d9d1ab?w=500&auto=format&fit=crop',
          ),
        ],
      ),
    );
  }

  Widget _buildAgentPropertyCard(BuildContext context, {
    required String title,
    required String location,
    required double rent,
    required double commission,
    required String status,
    required String imageUrl,
  }) {
    final theme = Theme.of(context);
    final isRented = status == 'Rented';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 140, color: Colors.grey[200]),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRented ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      CurrencyFormatter.formatCFA(rent),
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                        const Text('Expected Commission', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(
                          CurrencyFormatter.formatCFA(commission),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
