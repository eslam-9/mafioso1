import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../story_library/domain/entities/community_story.dart';

abstract class StoryLibraryRemoteDataSource {
  Future<List<CommunityStory>> getCommunityStories({
    int page = 0,
    int limit = 20,
  });
  Future<String> uploadStory(Map<String, dynamic> storyJson, String deviceId);
  Future<void> rateStory(String storyId, int rating, String deviceId);
}

class StoryLibraryRemoteDataSourceImpl implements StoryLibraryRemoteDataSource {
  final SupabaseClient client;
  static const String _storiesTable = 'community_stories';
  static const String _ratingsTable = 'story_ratings';
  static const String _ratedStoriesView = 'community_stories_with_ratings';

  const StoryLibraryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CommunityStory>> getCommunityStories({
    int page = 0,
    int limit = 20,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await client
        .from(_ratedStoriesView)
        .select()
        .order('bayesian_rating', ascending: false)
        .range(from, to);

    return (response as List<dynamic>)
        .map((row) => _mapToCommunityStory(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> uploadStory(
    Map<String, dynamic> storyJson,
    String deviceId,
  ) async {
    final contentHash = _computeHash(storyJson);

    // Upsert — if story already exists, returns existing row
    final response = await client
        .from(_storiesTable)
        .upsert({
          'content_hash': contentHash,
          'title': storyJson['title'] as String? ?? '',
          'intro': storyJson['intro'] as String? ?? '',
          'crime_description': storyJson['crimeDescription'] as String? ?? '',
          'twist': storyJson['twist'] as String? ?? '',
          'killer_name': storyJson['killerName'] as String? ?? '',
          'story_json': jsonEncode(storyJson),
          'uploaded_by_device': deviceId,
        }, onConflict: 'content_hash')
        .select('id')
        .single();

    return response['id'] as String;
  }

  @override
  Future<void> rateStory(String storyId, int rating, String deviceId) async {
    await client.from(_ratingsTable).upsert({
      'story_id': storyId,
      'device_id': deviceId,
      'rating': rating,
    }, onConflict: 'story_id,device_id');
  }

  /// Computes a deterministic SHA-256 hash of the story's core content fields.
  static String _computeHash(Map<String, dynamic> storyJson) {
    // Canonical representation: sort keys, take only content fields
    final canonical = jsonEncode({
      'title': storyJson['title'],
      'intro': storyJson['intro'],
      'crimeDescription': storyJson['crimeDescription'],
      'killerName': storyJson['killerName'],
      'twist': storyJson['twist'],
    });
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static CommunityStory _mapToCommunityStory(Map<String, dynamic> row) {
    final rawJson = row['story_json'];
    final storyJson = rawJson is String
        ? jsonDecode(rawJson) as Map<String, dynamic>
        : rawJson as Map<String, dynamic>;

    return CommunityStory(
      id: row['id'] as String,
      contentHash: row['content_hash'] as String,
      title: row['title'] as String? ?? '',
      intro: row['intro'] as String? ?? '',
      crimeDescription: row['crime_description'] as String? ?? '',
      twist: row['twist'] as String? ?? '',
      killerName: row['killer_name'] as String? ?? '',
      storyJson: storyJson,
      bayesianRating: (row['bayesian_rating'] as num?)?.toDouble() ?? 0.0,
      totalVotes: (row['total_votes'] as num?)?.toInt() ?? 0,
      uploadedAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
