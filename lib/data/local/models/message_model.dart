import '../app_database.dart';

class MessageModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
     required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromDb(Message row) {
    return MessageModel(
      id: row.id,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
