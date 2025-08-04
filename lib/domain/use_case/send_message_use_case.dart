import 'package:flutter_recipe_app/domain/model/message.dart';
import 'package:flutter_recipe_app/domain/repository/chat_repository.dart';

class SendMessageUseCase {
  final IChatRepository _repository;
  SendMessageUseCase(this._repository);
  Future<void> execute(String roomId, Message message) =>
      _repository.sendMessage(roomId, message);
}
