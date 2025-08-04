import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_recipe_app/data/data_source/api/firestore_data_source.dart';
import 'package:flutter_recipe_app/data/data_source/api/mock_firestore.dart';
import 'package:flutter_recipe_app/data/data_source/api/mock_firestore_data_source.dart';
import 'package:flutter_recipe_app/data/data_source/local/connectivity_service.dart';
import 'package:flutter_recipe_app/data/data_source/local/local_cache.dart';
import 'package:flutter_recipe_app/data/repository/chat_repository_impl.dart';
import 'package:flutter_recipe_app/data/repository/mock_chat_repository_impl.dart';
import 'package:flutter_recipe_app/domain/repository/chat_repository.dart';
import 'package:flutter_recipe_app/domain/use_case/get_chat_messages_use_case.dart';
import 'package:flutter_recipe_app/domain/use_case/send_message_use_case.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_view_model.dart';

final getIt = GetIt.instance;

const bool isMockMode = true;

void setupDependencies() {
  getIt.registerSingleton<ConnectivityService>(ConnectivityService());
  getIt.registerSingleton<LocalCache>(LocalCache());
  if (isMockMode) {
    getIt.registerSingleton<MockFirebaseFirestore>(MockFirebaseFirestore());
    getIt.registerSingleton<MockFirestoreDataSource>(
      MockFirestoreDataSource(getIt<MockFirebaseFirestore>()),
    );
    getIt.registerSingleton<IChatRepository>(
      MockChatRepository(getIt<MockFirestoreDataSource>()),
    );
  } else {
    getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
    getIt.registerSingleton<FirestoreDataSource>(
      FirestoreDataSource(getIt<FirebaseFirestore>()),
    );
    getIt.registerSingleton<IChatRepository>(
      ChatRepository(getIt<FirestoreDataSource>()),
    );
  }
  getIt.registerSingleton<GetChatMessagesUseCase>(
    GetChatMessagesUseCase(getIt<IChatRepository>()),
  );
  getIt.registerSingleton<SendMessageUseCase>(
    SendMessageUseCase(getIt<IChatRepository>()),
  );
  getIt.registerFactory<ChatViewModel>(
    () => ChatViewModel(
      getIt<GetChatMessagesUseCase>(),
      getIt<SendMessageUseCase>(),
      getIt<ConnectivityService>(),
      getIt<LocalCache>(),
    ),
  );
}
