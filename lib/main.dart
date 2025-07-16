import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/02_stateful/model/ingredient.dart';
import 'package:flutter_recipe_app/02_stateful/presentation/component/ingredient_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IngredientItem Test',
      theme: ThemeData(
        primarySwatch: Colors.blue, // 기본 테마 색상
        fontFamily: 'Poppins', // Poppins 폰트가 없다면, pubspec.yaml에 추가해야 합니다.
        // 테스트 목적으로는 시스템 기본 폰트로 표시됩니다.
      ),
      home: const TestScreen(), // 테스트 화면 지정
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 테스트용 Ingredient 객체 생성
    final Ingredient testIngredient = Ingredient(
      imgSrc: 'assets/images/tomato.png', // 실제 assets 폴더에 이미지가 있어야 합니다.
      // 없으면 에러가 나거나 빈 공간으로 표시됩니다.
      name: 'Tomatos000000',
      quantity: 150000,
    );

    final Ingredient testIngredient2 = Ingredient(
      imgSrc: 'assets/images/tomato.png', // 다른 이미지 경로
      name: 'Tomatos',
      quantity: 200,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('IngredientItem 테스트'),
      ),
      body: Center(
        // 화면 중앙에 배치
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 전체 패딩
          child: Column(
            mainAxisSize: MainAxisSize.min, // Column이 자식 크기만큼만 공간 차지
            children: [
              IngredientItem(
                name: testIngredient.name,
                quantity: testIngredient.quantity,
                ingredient: testIngredient,
              ),
              const SizedBox(height: 16.0), // 아이템 간 간격
              IngredientItem(
                name: testIngredient2.name,
                quantity: testIngredient2.quantity,
                ingredient: testIngredient2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
