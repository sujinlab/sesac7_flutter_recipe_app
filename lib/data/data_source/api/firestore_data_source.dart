import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/data/dto/message_dto.dart';

class FirestoreDataSource {
  final FirebaseFirestore _firestore;
  FirestoreDataSource(this._firestore);
  Stream<List<MessageDto>> getMessages(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageDto.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(String roomId, MessageDto messageDto) async {
    final docRef = _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageDto.id);
    await docRef.set(messageDto.toJson());
  }
}
