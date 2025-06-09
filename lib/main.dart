import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/admin_dashboard_screen.dart';
import 'features/dashboard/student_dashboard_screen.dart';
import 'features/language/language_selection_screen.dart';
import 'services/language_service.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로그 레벨 설정
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) {
      print('🔍 DEBUG: $message');
    }
  };

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDDv2M2BNFQzj3m4I2N-i03H6W1B3YenPk",
        authDomain: "dormitory-project.firebaseapp.com",
        databaseURL: "https://dormitory-project-default-rtdb.firebaseio.com",
        projectId: "dormitory-project",
        storageBucket: "dormitory-project.firebasestorage.app",
        messagingSenderId: "795492950403",
        appId: "1:795492950403:web:20913b536e61e7b59856b6",
        measurementId: "G-HR0QRYXX6T",
      ),
    );
    print('✅ Firebase 앱 초기화 완료');

    // Firebase 서비스 초기화
    await FirebaseService.initializeFirebase();
    print('✅ Firebase 서비스 초기화 완료');

    // Firebase Auth 상태 확인
    final auth = FirebaseAuth.instance;
    print(
        '현재 Firebase Auth 상태: ${auth.currentUser != null ? '로그인됨' : '로그인되지 않음'}');

    runApp(const MyApp());
  } catch (e) {
    print('❌ Firebase 초기화 실패: $e');
    // 초기화 실패 시에도 앱은 실행
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _languageCode = AppConstants.defaultLanguage;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      // 테스트를 위한 더미 데이터 설정
      const languageCode = 'ko';

      // 로그인 상태를 테스트용으로 설정 (true로 설정하면 로그인된 상태로 시작)
      const bool isLoggedIn = false;
      const bool isAdmin = false;

      // 첫 실행 여부 (false로 설정하면 언어 선택 화면 건너뜀)
      const isFirstLaunch = false;

      setState(() {
        _languageCode = languageCode;
        _isLoggedIn = isLoggedIn;
        _isAdmin = isAdmin;
        _isFirstLaunch = isFirstLaunch;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setLanguage(String languageCode) {
    setState(() {
      _languageCode = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      locale: LanguageService.getLocaleFromLanguageCode(_languageCode),
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
        Locale('zh', 'CN'), // 중국어
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => _getInitialScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/student/dashboard': (context) => const StudentDashboardScreen(),
        '/language': (context) => LanguageSelectionScreen(
              onLanguageSelected: _setLanguage,
            ),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }

  Widget _getInitialScreen() {
    // 첫 실행 시 언어 선택 화면으로 이동
    if (_isFirstLaunch) {
      return LanguageSelectionScreen(
        onLanguageSelected: _setLanguage,
      );
    }

    // 로그인 상태에 따라 화면 분기
    if (_isLoggedIn) {
      // 관리자/학생 구분하여 대시보드 표시
      return _isAdmin
          ? const AdminDashboardScreen()
          : const StudentDashboardScreen();
    } else {
      // 로그인 화면으로 이동
      return const LoginScreen();
    }
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return FutureBuilder<String>(
            future: AuthService().getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (roleSnapshot.data == AppConstants.roleAdmin) {
                return const AdminDashboardScreen();
              } else {
                return const StudentDashboardScreen();
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
