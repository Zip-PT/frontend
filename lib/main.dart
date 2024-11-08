import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zippt/colors.dart';
import 'package:zippt/pages/home_screen.dart';
import 'package:zippt/pages/profile_page.dart';
import 'checklist_screen.dart';
import 'widgets/custom_bottom_navigation_bar.dart';

void main() {
  // Flutter 앱의 시작점
  runApp(const MyApp()); // 위젯 트리를 루트부터 렌더링하도록 지시하는 함수
  // MyApp 클래스를 루트 위젯으로 설정하여 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // MyApp 클래스는 Flutter에서 앱을 초기화하는 기본 위젯
  // StatelessWidget을 상속받아 상태가 없는 위젯으로 정의되었으며, 빌드할 때 화면의 변동이 없는 구조
  @override
  Widget build(BuildContext context) {
    // Flutter의 UI는 build 메서드를 통해 그려짐
    // 이 메서드는 Flutter 프레임워크가 UI를 렌더링할 때 호출하며
    // MaterialApp 위젯을 반환하여 앱의 구조를 정의
    return MaterialApp(
      // Flutter 앱의 근간이 되는 위젯. 전체 앱의 테마와 홈 화면, 네비게이션 등을 관리
      title: 'Flutter Bottom Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.main,
        fontFamily: 'GowunBatang',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const MyHomePage()), // HomeScreen 대신 MyHomePage로 이동
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png'), // 기존 로고 이미지
            const SizedBox(height: 16), // 이미지와 텍스트 사이의 간격
            Text(
              "나의 집보기 동반자",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const Text(
              "집피티",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  //상태를 가질 수 있는 StatefulWidget을 상속받음.
  //사용자가 상호작용 해서 상태가 변경될 때, UI를 다시 빌드해 화면에 반영 가능
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //MyHomePage의 상태를 관리하는 클래스
  //State<MyHomePage>를 상속받아 MyHomePage와 연결됨
  int _selectedIndex = 0; //현재 선택된 하단 내비게이션 항목의 인덱스 저장하는 변수

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const ChecklistScreen(),
    const Center(child: Text('Add')),
    const ExampleWidget(),
  ];

  void _onItemTapped(int index) {
    //이 함수는 하단 내비게이션 바의 항목을 눌렀을 때 호출됨
    setState(() {
      _selectedIndex =
          index; //index를 받아 _selectedIndex를 업데이트하고, setState로 상태 갱신하여 화면 다시 그림
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.main,
        elevation: 0,
        title: null,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        backgroundColor: AppColors.mainBlue, // 기존 색상 유지
      ),
    );
  }
}
