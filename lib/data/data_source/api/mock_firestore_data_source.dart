import 'package:flutter_recipe_app/data/data_source/api/mock_firestore.dart';
import 'package:flutter_recipe_app/data/dto/message_dto.dart';

class MockFirestoreDataSource {
  final MockFirebaseFirestore _firestore;
  MockFirestoreDataSource(this._firestore);

  Stream<List<MessageDto>> getMessages(String roomId) {
    final initialMessages = _generateInitialMockData(roomId);

    return Stream.value(initialMessages);
  }

  List<MessageDto> _generateInitialMockData(String roomId) {
    final mockMessages = [
      MessageDto(
        id: 'msg_1',
        content: '안녕하세요! Mock 채팅방입니다.',
        senderId: 'user123',
        timestamp: DateTime.now().millisecondsSinceEpoch - 300000,
      ),
      MessageDto(
        id: 'msg_2',
        content: '이것은 Mock 데이터입니다.',
        senderId: 'other_user',
        timestamp: DateTime.now().millisecondsSinceEpoch - 200000,
      ),
      MessageDto(
        id: 'msg_3',
        content: '실제 Firebase 없이도 테스트할 수 있어요!',
        senderId: 'user123',
        timestamp: DateTime.now().millisecondsSinceEpoch - 100000,
      ),
    ];

    return mockMessages;
  }

  Future<void> sendMessage(String roomId, MessageDto messageDto) async {
    print('Mock: 메시지 전송됨 - ${messageDto.content}');
  }
}
