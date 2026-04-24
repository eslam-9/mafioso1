import '../../domain/entities/suspect.dart';

class SuspectModel extends Suspect {
  const SuspectModel({required super.name, required super.suspiciousBehavior});

  factory SuspectModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim() ?? '';
    final suspiciousBehavior =
        (json['suspiciousBehavior'] as String?)?.trim() ?? '';

    if (name.isEmpty || suspiciousBehavior.isEmpty) {
      throw const FormatException(
        'Invalid suspect payload: name and suspiciousBehavior are required.',
      );
    }

    return SuspectModel(
      name: name,
      suspiciousBehavior: suspiciousBehavior,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'suspiciousBehavior': suspiciousBehavior};
  }

  SuspectModel copyWith({String? name, String? suspiciousBehavior}) {
    return SuspectModel(
      name: name ?? this.name,
      suspiciousBehavior: suspiciousBehavior ?? this.suspiciousBehavior,
    );
  }
}
