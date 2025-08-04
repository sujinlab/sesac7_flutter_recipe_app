import 'package:flutter_recipe_app/domain/model/message.dart';

abstract class IChatRepository {
  Stream<List<Message>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, Message message);
}
