import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: LayoutExamples(),
          ),
        ),
      ),
    );
  }
}

class LayoutExamples extends StatelessWidget {
  const LayoutExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutCase1(),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutCase2(),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutCase3(),
        ),
      ],
    );
  }
}

// 각 영역을 시각적으로 구분하기 위한 헬퍼 위젯
class ColoredArea extends StatelessWidget {
  final Color color;
  final String name;

  const ColoredArea({
    Key? key,
    required this.color,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// 케이스 1: 3단 수평 분할 (Row)
class LayoutCase1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ColoredArea(color: Colors.blue, name: '영역 A (1/3)'),
        ),
        Expanded(
          flex: 1,
          child: ColoredArea(color: Colors.green, name: '영역 B (1/3)'),
        ),
        Expanded(
          flex: 1,
          child: ColoredArea(color: Colors.red, name: '영역 C (1/3)'),
        ),
      ],
    );
  }
}

// 케이스 2: 2x2 그리드 레이아웃
class LayoutCase2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ColoredArea(color: Colors.purple, name: '영역 D'),
              ),
              Expanded(
                child: ColoredArea(color: Colors.orange, name: '영역 E'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ColoredArea(color: Colors.teal, name: '영역 F'),
              ),
              Expanded(
                child: ColoredArea(color: Colors.indigo, name: '영역 G'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 케이스 3: 수직/수평 비대칭 분할
class LayoutCase3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ColoredArea(color: Colors.brown, name: '영역 H (큰 영역)'),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: ColoredArea(color: Colors.pink, name: '영역 I (위)'),
              ),
              Row(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ColoredArea(color: Colors.pink, name: 'Evenly'),
                  ColoredArea(color: Colors.pink, name: 'Evenly'),
                  ColoredArea(color: Colors.pink, name: 'Evenly'),
                ],
              ),
              Row(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ColoredArea(color: Colors.pink, name: 'Around'),
                  ColoredArea(color: Colors.pink, name: 'Around'),
                  ColoredArea(color: Colors.pink, name: 'Around'),
                ],
              ),
              Row(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ColoredArea(color: Colors.pink, name: 'Between'),
                  ColoredArea(color: Colors.pink, name: 'Between'),
                  ColoredArea(color: Colors.pink, name: 'Between'),
                ],
              ),
              Container(
                //width: 50,
                //height: 40,
                alignment: Alignment.centerRight,
                color: Colors.greenAccent,
                child: Text(
                  'askjdhfjkasdfsdsahfjkjljkljkljljlkjlkjlj;lkkjljl;kjl;kjl;kjlkjl;kjlkjlkjlk;jkljl;kdklj',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
