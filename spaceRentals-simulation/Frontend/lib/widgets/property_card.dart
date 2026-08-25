import 'package:flutter/material.dart';
import '../features/properties/domain/property.dart';
import '../core/utils/currency_formatter.dart';

class PropertyCard extends StatelessWidget {
  final PropertyWithListing item;
  final VoidCallback onTap;
  final Widget? bottomActions;

  const PropertyCard({
    super.key,
    required this.item,
    required this.onTap,
    this.bottomActions,
  });

  @override
  Widget build(BuildContext context) {
    final property = item.property;
    final listing = item.listing;
    final verification = item.verification;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'property_image_${property.id}',
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      property.images.isNotEmpty ? property.images.first : '',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      cacheWidth: 800,
                      cacheHeight: 600,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Image unavailable', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                if (verification.isVerified)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('VERIFIED', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.availabilityLabel,
                    style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${CurrencyFormatter.formatCFA(property.monthlyRentUnits.toDouble())} / month',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.bed, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${property.bedrooms}'),
                          const SizedBox(width: 12),
                          const Icon(Icons.bathtub, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${property.bathrooms}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (bottomActions != null) bottomActions!,
          ],
        ),
      ),
    );
  }
}

