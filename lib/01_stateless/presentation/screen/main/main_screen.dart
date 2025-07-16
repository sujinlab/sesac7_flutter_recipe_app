import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/01_stateless/presentation/component/small_button.dart';

import '../../../data/model/person.dart';
import '../../component/greeting.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key: Key('count'),
              '$count',
            ),
            SmallButton(
              key: Key('small_button'),
              text: 'button',
              onClick: () {
                setState(() {
                  count++;
                });
              },
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
