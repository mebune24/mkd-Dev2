import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';

// ── Seed data ─────────────────────────────────────────────────────────────────
final List<ReviewModel> _seedReviews = [
  ReviewModel(
    id: 'rev_001',
    propertyId: 'prop_001',
    tenantId: 'tenant_001',
    tenantName: 'Alice Johnson',
    rating: 4.5,
    comment: 'Amazing apartment! The neighborhood is quiet and the landlord is very responsive. Highly recommend!',
    createdAt: DateTime(2026, 7, 15),
  ),
  ReviewModel(
    id: 'rev_002',
    propertyId: 'prop_001',
    tenantId: 'tenant_003',
    tenantName: 'Camille Ndongo',
    rating: 4.0,
    comment: 'Great value for money. The place is clean and well maintained. Water and electricity are very stable.',
    createdAt: DateTime(2026, 6, 20),
  ),
  ReviewModel(
    id: 'rev_003',
    propertyId: 'prop_002',
    tenantId: 'tenant_002',
    tenantName: 'Bob Smith',
    rating: 5.0,
    comment: 'Perfect studio! Exactly as described. The proximity to main roads is a big plus. Would rent again.',
    createdAt: DateTime(2026, 8, 1),
  ),
  ReviewModel(
    id: 'rev_004',
    propertyId: 'prop_002',
    tenantId: 'tenant_004',
    tenantName: 'Marie Claire',
    rating: 3.5,
    comment: 'Decent place overall. Could use some improvements in the kitchen, but the location is great.',
    createdAt: DateTime(2026, 7, 28),
  ),
];

// ── Notifier ──────────────────────────────────────────────────────────────────
class ReviewsNotifier extends Notifier<List<ReviewModel>> {
  @override
  List<ReviewModel> build() => List.from(_seedReviews);

  void addReview(ReviewModel review) {
    state = [review, ...state];
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final reviewsNotifierProvider = NotifierProvider<ReviewsNotifier, List<ReviewModel>>(() => ReviewsNotifier());

final propertyReviewsProvider = Provider.family<List<ReviewModel>, String>((ref, propertyId) {
  final all = ref.watch(reviewsNotifierProvider);
  return all.where((r) => r.propertyId == propertyId).toList();
});

final propertyAverageRatingProvider = Provider.family<double, String>((ref, propertyId) {
  final reviews = ref.watch(propertyReviewsProvider(propertyId));
  if (reviews.isEmpty) return 0.0;
  final total = reviews.fold(0.0, (sum, r) => sum + r.rating);
  return double.parse((total / reviews.length).toStringAsFixed(1));
});
