import '../../../features/properties/domain/property.dart';
import '../../../shared/models/enums.dart';

class VideoFeedItem {
  final String id;
  final String propertyId;
  final String title;
  final String description;
  final String location;
  final String category;
  final int monthlyRent;
  final int deposit;
  final List<String> images;
  final List<String> videoUrls;
  final int bedrooms;
  final int bathrooms;
  final bool furnished;
  final String landlordName;
  final String? landlordAvatarUrl;
  final int verificationLevel;
  final FeedEngagement engagement;
  final DateTime publishedAt;

  const VideoFeedItem({
    required this.id,
    required this.propertyId,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.monthlyRent,
    required this.deposit,
    required this.images,
    required this.videoUrls,
    required this.bedrooms,
    required this.bathrooms,
    required this.furnished,
    required this.landlordName,
    required this.landlordAvatarUrl,
    required this.verificationLevel,
    required this.publishedAt,
    required this.engagement,
  });

  VideoFeedItem copyWith({FeedEngagement? engagement}) {
    return VideoFeedItem(
      id: id,
      propertyId: propertyId,
      title: title,
      description: description,
      location: location,
      category: category,
      monthlyRent: monthlyRent,
      deposit: deposit,
      images: images,
      videoUrls: videoUrls,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      furnished: furnished,
      landlordName: landlordName,
      landlordAvatarUrl: landlordAvatarUrl,
      verificationLevel: verificationLevel,
      publishedAt: publishedAt,
      engagement: engagement ?? this.engagement,
    );
  }

  factory VideoFeedItem.fromJson(Map<String, dynamic> json) {
    final landlord = json['landlord'] is Map
        ? Map<String, dynamic>.from(json['landlord'] as Map)
        : const <String, dynamic>{};
    final verification = json['verification'] is Map
        ? Map<String, dynamic>.from(json['verification'] as Map)
        : const <String, dynamic>{};

    List<String> list(dynamic value) => value is List
        ? value
              .map((item) => item.toString())
              .where((item) => item.isNotEmpty)
              .toList()
        : const <String>[];

    return VideoFeedItem(
      id: json['id']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Apartment',
      monthlyRent: (json['monthlyRent'] as num?)?.toInt() ?? 0,
      deposit: (json['deposit'] as num?)?.toInt() ?? 0,
      images: list(json['images']),
      videoUrls: list(json['videoUrls']),
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      furnished: json['furnished'] == true,
      landlordName: landlord['name']?.toString() ?? 'Landlord',
      landlordAvatarUrl: landlord['avatarUrl']?.toString(),
      verificationLevel: (verification['level'] as num?)?.toInt() ?? 0,
      publishedAt:
          DateTime.tryParse(json['publishedAt']?.toString() ?? '') ??
          DateTime.now(),
      engagement: FeedEngagement.fromJson(json['engagement']),
    );
  }

  PropertyWithListing toPropertyWithListing() {
    return PropertyWithListing(
      property: Property(
        id: propertyId,
        landlordId: '',
        title: title,
        description: description,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        monthlyRentUnits: monthlyRent,
        depositUnits: deposit,
        images: images,
        videoTourUrls: videoUrls,
        furnished: furnished,
        category: category,
        createdAt: publishedAt,
        updatedAt: publishedAt,
      ),
      listing: PropertyListing(
        id: propertyId,
        propertyId: propertyId,
        availabilityStatus: PropertyAvailabilityStatus.available,
        lastAvailabilityConfirmedAt: publishedAt,
        publishedAt: publishedAt,
      ),
      verification: PropertyVerificationInfo(
        level:
            PropertyVerificationLevel.values[verificationLevel.clamp(
              0,
              PropertyVerificationLevel.values.length - 1,
            )],
      ),
    );
  }
}

class FeedEngagement {
  final int likes;
  final int comments;
  final int reshares;
  final bool likedByMe;
  final bool resharedByMe;

  const FeedEngagement({
    required this.likes,
    required this.comments,
    required this.reshares,
    required this.likedByMe,
    required this.resharedByMe,
  });

  factory FeedEngagement.fromJson(dynamic value) {
    final json = value is Map
        ? Map<String, dynamic>.from(value)
        : const <String, dynamic>{};
    return FeedEngagement(
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      reshares: (json['reshares'] as num?)?.toInt() ?? 0,
      likedByMe: json['likedByMe'] == true,
      resharedByMe: json['resharedByMe'] == true,
    );
  }
}

class VideoFeedPage {
  final List<VideoFeedItem> items;
  final int page;
  final int limit;
  final bool hasMore;

  const VideoFeedPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory VideoFeedPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] is List
        ? json['items'] as List
        : const <dynamic>[];
    return VideoFeedPage(
      items: rawItems
          .map(
            (item) =>
                VideoFeedItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      hasMore: json['hasMore'] == true,
    );
  }
}
