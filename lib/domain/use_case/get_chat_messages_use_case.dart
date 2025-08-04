import 'package:flutter_recipe_app/domain/model/message.dart';
import 'package:flutter_recipe_app/domain/repository/chat_repository.dart';

class GetChatMessagesUseCase {
  final IChatRepository _repository;
  GetChatMessagesUseCase(this._repository);
  Stream<List<Message>> execute(String roomId) =>
      _repository.getMessages(roomId);
}
