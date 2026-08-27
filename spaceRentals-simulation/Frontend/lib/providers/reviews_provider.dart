import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';

// ── Seed data — real reviews for all seed properties ─────────────────────────
final List<ReviewModel> _seedReviews = [
  // prop_1 — Modern 2BR Apartment - Bastos
  ReviewModel(
    id: 'rev_001', propertyId: 'prop_1', tenantId: 'tenant_001',
    tenantName: 'Alice Johnson', rating: 5.0,
    comment: 'Amazing apartment in Bastos! The neighborhood is very quiet and secure. The landlord was extremely responsive and helpful. The views from the terrace are stunning. 100% recommend!',
    createdAt: DateTime(2026, 7, 15),
  ),
  ReviewModel(
    id: 'rev_002', propertyId: 'prop_1', tenantId: 'tenant_003',
    tenantName: 'Camille Ndongo', rating: 4.5,
    comment: 'Great value for money. The place is clean, well maintained and water & electricity are very stable. The furnished interior is tasteful. Minor issue with parking but otherwise perfect.',
    createdAt: DateTime(2026, 6, 20),
  ),
  ReviewModel(
    id: 'rev_003', propertyId: 'prop_1', tenantId: 'tenant_005',
    tenantName: 'Emmanuel Biya', rating: 4.0,
    comment: 'Very good apartment. Location in Bastos makes commuting easy. The AC works great. Would recommend to anyone looking for a professional setting.',
    createdAt: DateTime(2026, 8, 5),
  ),

  // prop_2 — Studio Melen
  ReviewModel(
    id: 'rev_004', propertyId: 'prop_2', tenantId: 'tenant_002',
    tenantName: 'Bob Smith', rating: 5.0,
    comment: 'Perfect studio for students! Exactly as described. The proximity to the university is a massive plus. Very affordable for Yaoundé. Would rent again!',
    createdAt: DateTime(2026, 8, 1),
  ),
  ReviewModel(
    id: 'rev_005', propertyId: 'prop_2', tenantId: 'tenant_004',
    tenantName: 'Marie Claire Fotso', rating: 3.5,
    comment: 'Decent studio overall. The location near UY1 is great but the kitchen could use some improvements. Water supply was stable throughout my stay.',
    createdAt: DateTime(2026, 7, 28),
  ),

  // prop_3 — Family Villa Omnisports
  ReviewModel(
    id: 'rev_006', propertyId: 'prop_3', tenantId: 'tenant_006',
    tenantName: 'Dr. Paul Mbarga', rating: 5.0,
    comment: 'Exceptional villa! We moved here with our family of 5 and have loved every moment. The garden is beautiful, the security is top-notch, and the space is more than adequate.',
    createdAt: DateTime(2026, 5, 10),
  ),
  ReviewModel(
    id: 'rev_007', propertyId: 'prop_3', tenantId: 'tenant_007',
    tenantName: 'Isabelle Nkeng', rating: 4.5,
    comment: 'Spacious and well-maintained villa. The parking spaces for 2 cars are a big bonus. The landlord is professional and responsive. A real family home.',
    createdAt: DateTime(2026, 7, 2),
  ),

  // prop_4 — 3BR Apartment Bonanjo
  ReviewModel(
    id: 'rev_008', propertyId: 'prop_4', tenantId: 'tenant_008',
    tenantName: 'Jonathan Essama', rating: 4.0,
    comment: 'Great for business professionals. Right in the heart of Bonanjo. The 3 bedrooms gave us room to set up a proper home office. Excellent neighborhood and facilities.',
    createdAt: DateTime(2026, 8, 10),
  ),

  // prop_5 — Student Studio Buea
  ReviewModel(
    id: 'rev_009', propertyId: 'prop_5', tenantId: 'tenant_009',
    tenantName: 'Grace Ayuk', rating: 4.5,
    comment: 'Best student accommodation near UB! Walking distance to campus. Very affordable. The electricity is reliable which is rare in Molyko. I\'d definitely renew my stay here.',
    createdAt: DateTime(2026, 9, 1),
  ),
  ReviewModel(
    id: 'rev_010', propertyId: 'prop_5', tenantId: 'tenant_010',
    tenantName: 'Felix Neba', rating: 4.0,
    comment: 'Good budget studio for students. Comfortable enough, clean, and safe neighborhood. Easy access to the main campus gate. Would recommend to fellow UB students.',
    createdAt: DateTime(2026, 8, 15),
  ),

  // prop_6 — Luxury Villa Bonapriso
  ReviewModel(
    id: 'rev_011', propertyId: 'prop_6', tenantId: 'tenant_011',
    tenantName: 'Ambassador Ndoumbe', rating: 5.0,
    comment: 'Truly world-class property. The pool, gym and 24/7 security meet the highest international standards. We\'ve lived in premium homes across Africa and this ranks top. Exceptional.',
    createdAt: DateTime(2026, 3, 15),
  ),
  ReviewModel(
    id: 'rev_012', propertyId: 'prop_6', tenantId: 'tenant_012',
    tenantName: 'Sophie Laurent', rating: 5.0,
    comment: 'Stunning luxury villa! Perfect for hosting and entertaining. The pool area is incredible and the security team is very professional. The best rental I\'ve ever had in Douala.',
    createdAt: DateTime(2026, 6, 22),
  ),

  // prop_7 — Commercial Space Akwa
  ReviewModel(
    id: 'rev_013', propertyId: 'prop_7', tenantId: 'tenant_013',
    tenantName: 'StartTech Cameroon', rating: 4.5,
    comment: 'Excellent commercial space for our startup. The Akwa location puts us in the heart of Douala\'s business district. Good parking for clients. Power backup is a huge plus.',
    createdAt: DateTime(2026, 7, 5),
  ),

  // prop_9 — 1BR Deido
  ReviewModel(
    id: 'rev_014', propertyId: 'prop_9', tenantId: 'tenant_014',
    tenantName: 'Patrick Eyoum', rating: 4.0,
    comment: 'Very good apartment with a lovely balcony view. Deido has everything you need nearby. The place is clean and was freshly painted before move-in. Good value for money.',
    createdAt: DateTime(2026, 8, 20),
  ),

  // prop_10 — Furnished Studio Biyem-Assi
  ReviewModel(
    id: 'rev_015', propertyId: 'prop_10', tenantId: 'tenant_015',
    tenantName: 'Christelle Momo', rating: 4.5,
    comment: 'Beautiful and cozy furnished studio. Everything was already there when I moved in — nothing to buy. The neighborhood is very calm and safe. SpaceRentals made finding this so easy!',
    createdAt: DateTime(2026, 8, 8),
  ),
  ReviewModel(
    id: 'rev_016', propertyId: 'prop_10', tenantId: 'tenant_016',
    tenantName: 'Roger Ateba', rating: 4.0,
    comment: 'Great move-in ready studio! Very convenient for a bachelor. The electricity is stable and water never runs out. Close to transport options in Biyem-Assi.',
    createdAt: DateTime(2026, 9, 3),
  ),

  // prop_11 — Executive Villa Santa Barbara
  ReviewModel(
    id: 'rev_017', propertyId: 'prop_11', tenantId: 'tenant_017',
    tenantName: 'Minister Mvogo', rating: 5.0,
    comment: 'Absolutely magnificent property. Santa Barbara is the best neighbourhood in Yaoundé and this villa is the crown jewel. The finishes are immaculate. Security is outstanding.',
    createdAt: DateTime(2026, 4, 30),
  ),

  // prop_12 — 2BR Ndokoti
  ReviewModel(
    id: 'rev_018', propertyId: 'prop_12', tenantId: 'tenant_018',
    tenantName: 'Carine Tabi', rating: 3.5,
    comment: 'Decent modern apartment. Close to Ndokoti market which is very convenient for shopping. Could use better soundproofing from market noise on weekends, but overall good value.',
    createdAt: DateTime(2026, 9, 5),
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
