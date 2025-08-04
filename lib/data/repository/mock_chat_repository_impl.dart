import 'package:flutter_recipe_app/data/data_source/api/mock_firestore_data_source.dart';
import 'package:flutter_recipe_app/data/dto/message_dto.dart';
import 'package:flutter_recipe_app/data/mapper/message_mapper.dart';
import 'package:flutter_recipe_app/domain/model/message.dart';
import 'package:flutter_recipe_app/domain/repository/chat_repository.dart';

class MockChatRepository implements IChatRepository {
  final MockFirestoreDataSource _dataSource;
  MockChatRepository(this._dataSource);

  @override
  Stream<List<Message>> getMessages(String roomId) {
    return _dataSource
        .getMessages(roomId)
        .map((dtos) => dtos.map((dto) => MessageMapper.fromDto(dto)).toList());
  }

  @override
  Future<void> sendMessage(String roomId, Message message) async {
    final dto = MessageDto(
      id: message.id,
      content: message.content,
      senderId: message.senderId,
      timestamp: message.timestamp,
    );
    await _dataSource.sendMessage(roomId, dto);
  }
}
