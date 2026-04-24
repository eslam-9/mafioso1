import '../../domain/entities/suspect.dart';

class SuspectModel extends Suspect {
  const SuspectModel({required super.name, required super.suspiciousBehavior});

  factory SuspectModel.fromJson(Map<String, dynamic> json) {
    return SuspectModel(
      name: json['name'] as String,
      suspiciousBehavior: json['suspiciousBehavior'] as String,
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
