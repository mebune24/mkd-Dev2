class ReviewModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String tenantName;
  final double rating; // 1.0 – 5.0
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.tenantName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
