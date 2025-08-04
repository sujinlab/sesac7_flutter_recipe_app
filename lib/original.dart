import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
// build_runner를 통해 생성될 파일들
part 'study/main.freezed.dart';
part 'study/main.g.dart';

final getIt = GetIt.instance;
const uuid = Uuid();

// 이 값을 변경하여 Mock과 실제 Firebase 연결을 전환할 수 있습니다.
const bool isMockMode = true;

// --- 유틸리티 ---
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success;
  const factory Result.error(Exception e) = Error;
}

// --- Mock Firestore 구현 ---
class FakeStreamController<T> {
  final _controller = StreamController<T>.broadcast();
  Stream<T> get stream => _controller.stream;
  void add(T data) {
    _controller.add(data);
  }

  void close() {
    _controller.close();
  }
}

// 실제 FirebaseFirestore 클래스를 모방하는 Mock 클래스
class MockFirebaseFirestore {
  final Map<String, MockCollectionReference> _collections = {};

  MockCollectionReference collection(String collectionPath) {
    _collections.putIfAbsent(collectionPath, () => MockCollectionReference());
    return _collections[collectionPath]!;
  }
}

class MockCollectionReference {
  final Map<String, MockDocumentReference> _documents = {};

  MockDocumentReference doc([String? path]) {
    final docId = path ?? uuid.v4();
    _documents.putIfAbsent(docId, () => MockDocumentReference());
    return _documents[docId]!;
  }

  MockQuery<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) {
    return MockQuery(this, field as String, descending);
  }
}

class MockQuery<T extends Object?> {
  final MockCollectionReference _collection;
  final String _orderByField;
  final bool _descending;
  final FakeStreamController<MockQuerySnapshot> _controller =
      FakeStreamController();
  MockQuery(this._collection, this._orderByField, this._descending);

  Stream<MockQuerySnapshot> snapshots({
    bool includeMetadataChanges = false,
  }) {
    return _controller.stream;
  }

  void addDocument(Map<String, dynamic> data) {
    // 새 문서를 추가하고 스트림에 변경 사항을 알림
    final docId = data['id'] as String;
    final docRef = _collection.doc(docId);
    docRef.data = data;
    final docs = _collection._documents.values
        .where((d) => d.data != null)
        .map((d) => MockQueryDocumentSnapshot(d.data!))
        .toList();
    docs.sort(
      (a, b) => _descending
          ? b.data[_orderByField].compareTo(a.data[_orderByField])
          : a.data[_orderByField].compareTo(b.data[_orderByField]),
    );
    _controller.add(MockQuerySnapshot(docs));
  }
}

class MockDocumentReference {
  Map<String, dynamic>? data;
  final Map<String, MockCollectionReference> _subCollections = {};

  MockCollectionReference collection(String collectionPath) {
    _subCollections.putIfAbsent(
      collectionPath,
      () => MockCollectionReference(),
    );
    return _subCollections[collectionPath]!;
  }

  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) {
    this.data = data;
    // 상위 컬렉션에서 스트림 업데이트를 트리거합니다.
    final parentCollectionRef = _parentCollection();
    final parentQuery = parentCollectionRef.orderBy(
      'timestamp',
      descending: true,
    );
    parentQuery.addDocument(data);
    return Future.value();
  }

  MockCollectionReference _parentCollection() {
    // 상위 컬렉션 참조를 찾는 Mock 로직 (단순화)
    return getIt<MockFirebaseFirestore>()._collections.values.first;
  }
}

class MockQuerySnapshot {
  final List<MockQueryDocumentSnapshot> docs;
  MockQuerySnapshot(this.docs);
}

class MockQueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  MockQueryDocumentSnapshot(this._data);

  Map<String, dynamic> get data => _data;
}

// --- 데이터 계층 ---
@JsonSerializable()
class MessageDto {
  final String id;
  final String content;
  final String senderId;
  final int timestamp;
  MessageDto({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
  });
  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

// 실제 Firestore 데이터 소스
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

// Mock Firestore 데이터 소스
class MockFirestoreDataSource {
  final MockFirebaseFirestore _firestore;
  MockFirestoreDataSource(this._firestore);

  Stream<List<MessageDto>> getMessages(String roomId) {
    // 초기 Mock 데이터 생성
    final initialMessages = _generateInitialMockData(roomId);

    // 즉시 데이터를 전달하는 스트림
    return Stream.value(initialMessages);
  }

  List<MessageDto> _generateInitialMockData(String roomId) {
    // 초기 Mock 메시지들 생성
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
    // Mock에서는 아무것도 하지 않음 (실제로는 데이터베이스에 저장)
    print('Mock: 메시지 전송됨 - ${messageDto.content}');
  }
}

// Connectivity 체크 (실제 네트워크 상태 확인)
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }
}

// 로컬 캐시 (간단한 메모리 캐시로 대체)
class LocalCache {
  final Map<String, Message> _messages = {};
  List<Message> getAllMessages() {
    return _messages.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void saveMessage(Message message) {
    _messages[message.id] = message;
  }

  void updateMessageStatus(String messageId, MessageStatus status) {
    final message = _messages[messageId];
    if (message != null) {
      _messages[messageId] = message.copyWith(status: status);
    }
  }

  void clearCache() {
    _messages.clear();
  }
}

// --- 도메인 계층 ---
@freezed
sealed class MessageStatus with _$MessageStatus {
  const factory MessageStatus.sending() = Sending;
  const factory MessageStatus.sent() = Sent;
  const factory MessageStatus.failed() = Failed;
  const factory MessageStatus.incoming() = Incoming;
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String content,
    required String senderId,
    required int timestamp,
    required MessageStatus status,
  }) = _Message;
}

class MessageMapper {
  static Message fromDto(MessageDto dto) => Message(
        id: dto.id,
        content: dto.content,
        senderId: dto.senderId,
        timestamp: dto.timestamp,
        status: const MessageStatus.incoming(),
      );
}

abstract class IChatRepository {
  Stream<List<Message>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, Message message);
}

class ChatRepository implements IChatRepository {
  final FirestoreDataSource _dataSource;
  ChatRepository(this._dataSource);

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

class GetChatMessagesUseCase {
  final IChatRepository _repository;
  GetChatMessagesUseCase(this._repository);
  Stream<List<Message>> execute(String roomId) =>
      _repository.getMessages(roomId);
}

class SendMessageUseCase {
  final IChatRepository _repository;
  SendMessageUseCase(this._repository);
  Future<void> execute(String roomId, Message message) =>
      _repository.sendMessage(roomId, message);
}

// --- 프레젠테이션 계층 ---
@freezed
sealed class ChatAction with _$ChatAction {
  const factory ChatAction.sendMessage(String content) = SendMessage;
}

@freezed
sealed class ChatEvent with _$ChatEvent {
  const factory ChatEvent.showSnackbar(String message) = ShowSnackbar;
}

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<Message> messages,
    @Default(false) bool isLoading,
    @Default('') String currentUserId,
    String? errorMessage,
  }) = _ChatState;
}

class ChatViewModel with ChangeNotifier {
  final GetChatMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final ConnectivityService _connectivityService;
  final LocalCache _localCache;
  final _eventController = StreamController<ChatEvent>.broadcast();
  Stream<ChatEvent> get eventStream => _eventController.stream;
  StreamSubscription? _messageSubscription;
  String _currentRoomId = '';
  ChatViewModel(
    this._getMessagesUseCase,
    this._sendMessageUseCase,
    this._connectivityService,
    this._localCache,
  );
  ChatState _state = const ChatState(currentUserId: 'user123');
  ChatState get state => _state;
  void openChatRoom(String roomId) {
    if (_messageSubscription != null) return;
    _currentRoomId = roomId;
    final cachedMessages = _localCache.getAllMessages();
    _state = state.copyWith(isLoading: true, messages: cachedMessages);
    notifyListeners();

    // Firestore 실시간 구독 시작
    _messageSubscription = _getMessagesUseCase.execute(roomId).listen(
      (newMessages) {
        final List<Message> updatedMessages = List.from(state.messages);
        for (final newMessage in newMessages) {
          final existingIndex = updatedMessages.indexWhere(
            (m) => m.id == newMessage.id,
          );
          if (existingIndex != -1) {
            if (updatedMessages[existingIndex].status is Sending) {
              updatedMessages[existingIndex] = newMessage.copyWith(
                status: const MessageStatus.sent(),
              );
              _localCache.updateMessageStatus(
                newMessage.id,
                const MessageStatus.sent(),
              );
            }
          } else {
            updatedMessages.add(newMessage);
            _localCache.saveMessage(newMessage);
          }
        }
        updatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _state = state.copyWith(
          messages: updatedMessages,
          isLoading: false, // 로딩 완료
        );
        notifyListeners();
      },
      onError: (e) {
        _eventController.add(ChatEvent.showSnackbar('메시지 로드 오류: $e'));
        _state = state.copyWith(isLoading: false);
        notifyListeners();
      },
    );

    // Mock 환경에서는 즉시 로딩 완료
    if (isMockMode) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (_messageSubscription != null) {
          _state = state.copyWith(isLoading: false);
          notifyListeners();
        }
      });
    }
  }

  void closeChatRoom() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _currentRoomId = '';
    _state = const ChatState(currentUserId: 'user123');
    _localCache.clearCache();
    notifyListeners();
  }

  Future<void> onAction(ChatAction action) async {
    switch (action) {
      case SendMessage(:final content):
        final hasConnection = await _connectivityService.hasConnection();
        if (!hasConnection) {
          _eventController.add(const ChatEvent.showSnackbar('오프라인 상태입니다.'));
          return;
        }
        final newMessage = Message(
          id: uuid.v4(),
          content: content,
          senderId: state.currentUserId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          status: const MessageStatus.sending(),
        );
        final updatedMessages = [...state.messages, newMessage];
        _state = state.copyWith(messages: updatedMessages);
        _localCache.saveMessage(newMessage);
        notifyListeners();
        try {
          await _sendMessageUseCase.execute(_currentRoomId, newMessage);
          // 메시지 전송 성공 후 상태를 sent로 업데이트
          final successMessages = state.messages
              .map(
                (m) => m.id == newMessage.id
                    ? m.copyWith(status: const MessageStatus.sent())
                    : m,
              )
              .toList();
          _state = state.copyWith(messages: successMessages);
          _localCache.updateMessageStatus(
            newMessage.id,
            const MessageStatus.sent(),
          );
          notifyListeners();
        } catch (e) {
          _eventController.add(const ChatEvent.showSnackbar('메시지 전송 실패'));
          final errorMessages = state.messages
              .map(
                (m) => m.id == newMessage.id
                    ? m.copyWith(status: const MessageStatus.failed())
                    : m,
              )
              .toList();
          _state = state.copyWith(messages: errorMessages);
          _localCache.updateMessageStatus(
            newMessage.id,
            const MessageStatus.failed(),
          );
          notifyListeners();
        }
    }
  }

  @override
  void dispose() {
    closeChatRoom();
    _eventController.close();
    super.dispose();
  }
}

// DI 설정 함수
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

// 라우터 설정
final _router = GoRouter(
  initialLocation: '/chat/1',
  routes: [
    GoRoute(
      path: '/chat/:roomId',
      builder: (context, state) =>
          ChatScreenRoot(roomId: state.pathParameters['roomId']!),
    ),
  ],
);
// App Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!isMockMode) {
    // 실제 Firebase 사용 시에만 초기화
    // await Firebase.initializeApp();
  }
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      );
}

// --- 뷰 계층 ---
class ChatScreenRoot extends StatefulWidget {
  final String roomId;
  const ChatScreenRoot({super.key, required this.roomId});
  @override
  State<ChatScreenRoot> createState() => _ChatScreenRootState();
}

class _ChatScreenRootState extends State<ChatScreenRoot> {
  late final ChatViewModel viewModel;
  StreamSubscription<ChatEvent>? _eventSubscription;
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    viewModel = getIt<ChatViewModel>();
    viewModel.openChatRoom(widget.roomId);
    _eventSubscription = viewModel.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case ShowSnackbar(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
        }
      }
    });
    viewModel.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    viewModel.removeListener(_scrollToBottom);
    viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return ChatScreen(
          state: viewModel.state,
          onAction: viewModel.onAction,
          scrollController: _scrollController,
        );
      },
    );
  }
}

class ChatScreen extends StatelessWidget {
  final ChatState state;
  final void Function(ChatAction action) onAction;
  final ScrollController scrollController;
  const ChatScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.scrollController,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMyMessage = (message) => message.senderId == state.currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    itemCount: state.messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMine = isMyMessage(message);
                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMine
                                ? theme.primaryColor.withOpacity(0.8)
                                : theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMine
                                  ? const Radius.circular(16)
                                  : const Radius.circular(4),
                              bottomRight: isMine
                                  ? const Radius.circular(4)
                                  : const Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  message.content,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isMine ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              if (isMine) ...[
                                const SizedBox(width: 8),
                                if (message.status is Sending)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else if (message.status is Error)
                                  const Icon(
                                    Icons.error_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _MessageInput(
            onSendMessage: (content) {
              onAction(ChatAction.sendMessage(content));
            },
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final void Function(String content) onSendMessage;
  const _MessageInput({required this.onSendMessage});
  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final TextEditingController _controller = TextEditingController();
  void _handleSendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
