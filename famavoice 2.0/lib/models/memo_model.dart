
import 'package:hive/hive.dart';

part 'memo_model.g.dart';

@HiveType(typeId: 0)
class Memo extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String filePath;
  @HiveField(3)
  final DateTime createdAt;

  Memo({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
  });

  Memo copyWith({
    String? id,
    String? title,
    String? filePath,
    DateTime? createdAt,
  }) {
    return Memo(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
