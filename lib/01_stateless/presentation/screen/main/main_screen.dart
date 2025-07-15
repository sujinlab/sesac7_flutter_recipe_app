import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/01_stateless/presentation/component/small_button.dart';

import '../../../data/model/person.dart';
import '../../component/greeting.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmallButton(
              text: 'button',
              onClick: () {},
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('button'),
            ),
            Greeting(
              name: '홍길동의 화면',
              person: const Person(name: '홍길동', age: 20),
              onTap: (Person person) {
                print(person);
              },
            ),
          ],
        ),
      ),
    );
  }
}
