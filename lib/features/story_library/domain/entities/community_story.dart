import 'package:equatable/equatable.dart';

/// A story entry from the community library with its Bayesian-averaged rating.
class CommunityStory extends Equatable {
  final String id;
  final String contentHash;
  final String title;
  final String intro;
  final String crimeDescription;
  final String twist;
  final String killerName;
  final Map<String, dynamic> storyJson;
  final double bayesianRating;
  final int totalVotes;
  final DateTime uploadedAt;
  final int suspectCount;

  const CommunityStory({
    required this.id,
    required this.contentHash,
    required this.title,
    required this.intro,
    required this.crimeDescription,
    required this.twist,
    required this.killerName,
    required this.storyJson,
    required this.bayesianRating,
    required this.totalVotes,
    required this.uploadedAt,
    required this.suspectCount,
  });

  @override
  List<Object?> get props => [id, contentHash, bayesianRating, totalVotes];
}
