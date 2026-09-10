import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_endpoints.dart';
import '../../providers/auth_provider.dart';
import '../../providers/di_providers.dart';

class LandlordProfileScreen extends ConsumerStatefulWidget {
  final String landlordId;
  final String initialName;
  final String? initialAvatarUrl;

  const LandlordProfileScreen({
    required this.landlordId,
    this.initialName = 'Landlord',
    this.initialAvatarUrl,
    super.key,
  });

  @override
  ConsumerState<LandlordProfileScreen> createState() =>
      _LandlordProfileScreenState();
}

class _LandlordProfileScreenState extends ConsumerState<LandlordProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _following = false;
  bool _updatingFollow = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final response = await ref
        .read(apiClientProvider)
        .get<Map<String, dynamic>>(
          ApiEndpoints.publicUserProfile(widget.landlordId),
        );
    if (!mounted) return;
    if (!response.isSuccess || response.data == null) {
      setState(() {
        _loading = false;
        _error = 'Unable to load landlord profile.';
      });
      return;
    }
    setState(() {
      _profile = response.data;
      _following = response.data!['isFollowing'] == true;
      _loading = false;
    });
  }

  Future<void> _toggleFollow() async {
    if (_updatingFollow) return;
    if (!ref.read(authProvider).isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to follow landlords.')),
      );
      return;
    }

    setState(() => _updatingFollow = true);
    final client = ref.read(apiClientProvider);
    final response = _following
        ? await client.delete<Map<String, dynamic>>(
            ApiEndpoints.followUser(widget.landlordId),
          )
        : await client.post<Map<String, dynamic>>(
            ApiEndpoints.followUser(widget.landlordId),
          );
    if (!mounted) return;
    if (response.isSuccess) {
      setState(() {
        _following = !_following;
        if (_profile != null && response.data != null) {
          _profile!['followerCount'] = response.data!['followerCount'];
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update your follow.')),
      );
    }
    setState(() => _updatingFollow = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final name = profile?['fullName']?.toString() ?? widget.initialName;
    final avatarUrl =
        profile?['avatarUrl']?.toString() ?? widget.initialAvatarUrl;
    final properties = profile?['properties'] is List
        ? List<dynamic>.from(profile!['properties'] as List)
        : const <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF151515),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: 16,
              ),
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF242024)),
                  Center(
                    child: _Avatar(url: avatarUrl, name: name, radius: 54),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB3000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(child: Center(child: Text(_error!)))
          else ...[
            SliverToBoxAdapter(
              child: _ProfileHeader(
                profile: profile!,
                name: name,
                following: _following,
                updating: _updatingFollow,
                onFollow: _toggleFollow,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
              sliver: properties.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: Text('No active listings yet.')),
                      ),
                    )
                  : SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                      itemCount: properties.length,
                      itemBuilder: (context, index) => _ListingTile(
                        property: Map<String, dynamic>.from(
                          properties[index] as Map,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String name;
  final bool following;
  final bool updating;
  final VoidCallback onFollow;

  const _ProfileHeader({
    required this.profile,
    required this.name,
    required this.following,
    required this.updating,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final memberSince = DateTime.tryParse(
      profile['memberSince']?.toString() ?? '',
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: updating ? null : onFollow,
                icon: updating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(following ? Icons.check : Icons.add),
                label: Text(following ? 'Following' : 'Follow'),
                style: FilledButton.styleFrom(
                  backgroundColor: following
                      ? Colors.black87
                      : const Color(0xFFE64A35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            profile['role']?.toString() ?? 'Landlord',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if ((profile['bio']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              profile['bio'].toString(),
              style: const TextStyle(height: 1.4),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              _Stat(
                value: '${profile['propertyCount'] ?? 0}',
                label: 'Listings',
              ),
              _Stat(
                value: '${profile['followerCount'] ?? 0}',
                label: 'Followers',
              ),
              _Stat(
                value: '${profile['followingCount'] ?? 0}',
                label: 'Following',
              ),
              if (memberSince != null)
                _Stat(value: '${memberSince.year}', label: 'Joined'),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Active listings',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    ),
  );
}

class _ListingTile extends StatelessWidget {
  final Map<String, dynamic> property;
  const _ListingTile({required this.property});

  @override
  Widget build(BuildContext context) {
    final images = property['images'] is List
        ? property['images'] as List
        : const [];
    final image = images.isNotEmpty ? images.first.toString() : null;
    final title = property['title']?.toString() ?? 'Property';
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null && image.isNotEmpty)
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          else
            _placeholder(),
          const Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: SizedBox(height: 90, width: double.infinity),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
    color: Color(0xFFD8D1D5),
    child: Icon(Icons.home_work_outlined, size: 42, color: Colors.white),
  );
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;
  const _Avatar({required this.url, required this.name, required this.radius});

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? image;
    if (url?.startsWith('data:image/') == true) {
      final separator = url!.indexOf(',');
      if (separator > 0) {
        try {
          image = MemoryImage(base64Decode(url!.substring(separator + 1)));
        } catch (_) {}
      }
    } else if (url?.startsWith('http') == true) {
      image = NetworkImage(url!);
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: image,
      child: image == null
          ? Text(
              name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
            )
          : null,
    );
  }
}
