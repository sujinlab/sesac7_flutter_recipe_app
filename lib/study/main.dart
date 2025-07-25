import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main.freezed.dart';

part 'main.g.dart';

final getIt = GetIt.instance;

// --- 유틸리티 ---
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success;

  const factory Result.error(Exception e) = Error;
}

// [새로 추가됨] 앱의 모든 경로를 중앙에서 관리하는 클래스
abstract class Routes {
  static const String items = '/items';
  static const String settings = '/settings';
  static const String detail = '/detail/:id';
  static const String reviews = 'reviews'; // 자식 경로는 '/'로 시작하지 않음

  static String itemDetailPath(int id) => '/detail/$id';

  static String itemReviewsPath(String id) => '/detail/$id/reviews';
}

// --- 데이터 계층 ---
@JsonSerializable()
class ItemDto {
  final int? id;
  final String? title;

  ItemDto({this.id, this.title});

  factory ItemDto.fromJson(Map<String, dynamic> json) =>
      _$ItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ItemDtoToJson(this);
}

class ItemDataSource {
  Future<List<ItemDto>> getDtos() async {
    await Future.delayed(const Duration(seconds: 1));
    final jsonString =
        '[${List.generate(10, (i) => '{"id": ${i + 1}, "title": "아이템 ${i + 1}"}').join(',')}]';
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => ItemDto.fromJson(json)).toList();
  }
}

// --- 도메인 계층 ---
class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});
}

class ItemMapper {
  static Item fromDto(ItemDto dto) =>
      Item(id: dto.id ?? 0, name: dto.title ?? '이름 없음');
}

class ItemRepository {
  final ItemDataSource _dataSource;

  ItemRepository(this._dataSource);

  Future<Result<List<Item>>> getItems() async {
    try {
      final dtos = await _dataSource.getDtos();
      return Result.success(
        dtos.map((dto) => ItemMapper.fromDto(dto)).toList(),
      );
    } catch (e) {
      return Result.error(Exception('데이터 로드 실패: $e'));
    }
  }
}

class GetItemsUseCase {
  final ItemRepository _repository;

  GetItemsUseCase(this._repository);

  Future<Result<List<Item>>> execute() => _repository.getItems();
}

// --- 프레젠테이션 계층 ---

// 사용자의 상호작용을 정의하는 Action
@freezed
sealed class ItemsAction with _$ItemsAction {
  const factory ItemsAction.clickItem(Item item) = ClickItem;

  const factory ItemsAction.dragItem(Item item) = DragItem;
}

@freezed
abstract class ItemsState with _$ItemsState {
  const factory ItemsState({
    @Default([]) List<Item> items,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ItemsState;
}

class ItemsViewModel with ChangeNotifier {
  final GetItemsUseCase _getItemsUseCase;

  ItemsViewModel(this._getItemsUseCase);

  ItemsState _state = const ItemsState();

  ItemsState get state => _state;

  Future<void> fetchItems() async {
    if (state.items.isNotEmpty || state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _getItemsUseCase.execute();
    switch (result) {
      case Success<List<Item>>(:final data):
        _state = state.copyWith(isLoading: false, items: data);
      case Error(:final e):
        _state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
    notifyListeners();
  }

  void onAction(ItemsAction action) {
    switch (action) {
      case ClickItem(:final item):
        print('Item clicked in ViewModel: ${item.name}');
      case DragItem(:final item):
        final updatedItems = List<Item>.from(state.items)
          ..removeWhere((i) => i.id == item.id);
        _state = state.copyWith(items: updatedItems);
        notifyListeners();
        print('Item dragged to delete in ViewModel: ${item.name}');
    }
  }
}

// DI 설정 함수
void setupDependencies() {
  getIt.registerSingleton<ItemDataSource>(ItemDataSource());
  getIt.registerSingleton<ItemRepository>(
    ItemRepository(getIt<ItemDataSource>()),
  );
  getIt.registerSingleton<GetItemsUseCase>(
    GetItemsUseCase(getIt<ItemRepository>()),
  );
  getIt.registerFactory<ItemsViewModel>(
    () => ItemsViewModel(getIt<GetItemsUseCase>()),
  );
}

// 라우터 설정
final _router = GoRouter(
  initialLocation: Routes.items,
  routes: [
    GoRoute(
      path: Routes.detail,
      builder: (context, state) =>
          ItemDetailScreen(id: state.pathParameters['id']!),
      routes: [
        GoRoute(
          path: Routes.reviews,
          builder: (context, state) =>
              ItemReviewScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScreen(shell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.items,
              builder: (context, state) {
                return ItemsScreenRoot(viewModel: getIt<ItemsViewModel>());
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);

// App Entry Point
void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router);
}

// --- 뷰 계층 ---
class MainScreen extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainScreen({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: '아이템'),
          NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}

// ViewModel을 생성자에서 주입받고, 생명주기와 Action 처리를 담당
class ItemsScreenRoot extends StatefulWidget {
  final ItemsViewModel viewModel;

  const ItemsScreenRoot({super.key, required this.viewModel});

  @override
  State<ItemsScreenRoot> createState() => _ItemsScreenRootState();
}

class _ItemsScreenRootState extends State<ItemsScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return ItemsScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            widget.viewModel.onAction(action);

            switch (action) {
              case ClickItem(:final item):
                context.push(Routes.itemDetailPath(item.id));
              case DragItem():
              // UI 로직 없음
            }
          },
        );
      },
    );
  }
}

// 순수하게 UI 렌더링과 Action 전달만 담당
class ItemsScreen extends StatelessWidget {
  final ItemsState state;
  final void Function(ItemsAction action) onAction;

  const ItemsScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 목록')),
      body: Builder(
        builder: (context) {
          if (state.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (state.errorMessage != null)
            return Center(child: Text(state.errorMessage!));

          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  onAction(ItemsAction.dragItem(item));
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(item.name),
                  onTap: () {
                    onAction(ItemsAction.clickItem(item));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ItemDetailScreen extends StatelessWidget {
  final String id;

  const ItemDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 상세')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('선택된 아이템 ID: $id'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.push(Routes.itemReviewsPath(id));
              },
              child: const Text('리뷰 보기'),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemReviewScreen extends StatelessWidget {
  final String id;

  const ItemReviewScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리뷰 목록')),
      body: Center(child: Text('ID: $id의 리뷰 화면')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: const Center(
        child: Text('설정 화면입니다.'),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('에러')),
      body: Center(
        child: Text(error?.toString() ?? '페이지를 찾을 수 없습니다.'),
      ),
    );
  }
}

/*
--- pubspec.yaml 파일 내용 ---

name: flutter_architecture_skeleton
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

#==============================================================================
# Dependencies: 앱 실행에 직접 필요한 패키지들
#==============================================================================
dependencies:
  flutter:
    sdk: flutter

  # --- 상태 관리 및 아키텍처 ---
  get_it: ^7.7.0 # 의존성 주입(DI)을 쉽게 관리하기 위해 사용

  # --- 라우팅 ---
  go_router: ^14.2.0 # 화면 간의 이동(네비게이션)을 관리

  # --- 네트워크 통신 ---
  http: ^1.2.1 # 서버와 HTTP 통신(API 호출)을 위해 사용

  # --- 코드 생성 (Annotation) ---
  # build_runner가 코드를 생성할 때 참고하는 어노테이션
  freezed_annotation: ^2.4.1 # 불변(immutable) 클래스와 sealed class를 쉽게 만들기 위해 사용
  json_annotation: ^4.9.0 # JSON 직렬화/역직렬화를 위한 어노테이션

  # --- UI 및 유틸리티 ---
  cupertino_icons: ^1.0.8 # iOS 스타일 아이콘

#==============================================================================
# Dev Dependencies: 개발 과정에서만 필요한 패키지들
#==============================================================================
dev_dependencies:
  flutter_test:
    sdk: flutter

  # --- 코드 생성 (Generator) ---
  # 터미널에서 `flutter pub run build_runner build` 명령으로 코드를 자동 생성
  build_runner: ^2.4.11 # 파일 감지 및 코드 생성을 실행하는 도구
  freezed: ^2.5.2 # freezed_annotation을 기반으로 실제 코드를 생성
  json_serializable: ^6.8.0 # json_serializable을 기반으로 fromJson/toJson 코드를 생성

  # --- 코드 분석 및 테스트 ---
  flutter_lints: ^4.0.0 # 코드 스타일과 잠재적 오류를 검사하는 규칙 모음

#==============================================================================
# Flutter 관련 설정
#==============================================================================
flutter:
  uses-material-design: true

#==============================================================================
# 터미널에 복사 & 붙여넣기 하여 모든 패키지를 한 번에 추가할 수 있습니다.
#==============================================================================
# flutter pub add get_it go_router http freezed_annotation json_annotation cupertino_icons
# flutter pub add dev:build_runner dev:freezed dev:json_serializable dev:flutter_lints

*/
