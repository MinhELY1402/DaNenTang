// File cấu hình Firebase Options chính thức từ Firebase Console của bạn
// Project ID: danentang-b5b16 (Bản Free Spark Plan)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  // Cấu hình Firebase Web chính thức từ Project của bạn
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCg0bqZSLPSLlokm6QuQZgv1wREjDmEt7o',
    appId: '1:297994799764:web:eb397a95927032e3144281',
    messagingSenderId: '297994799764',
    projectId: 'danentang-b5b16',
    authDomain: 'danentang-b5b16.firebaseapp.com',
    storageBucket: 'danentang-b5b16.firebasestorage.app',
    measurementId: 'G-L3BQ5PWRP1',
  );

  // Cấu hình Firebase Android kết nối cùng Project danentang-b5b16
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCg0bqZSLPSLlokm6QuQZgv1wREjDmEt7o',
    appId: '1:297994799764:android:eb397a95927032e3144281',
    messagingSenderId: '297994799764',
    projectId: 'danentang-b5b16',
    storageBucket: 'danentang-b5b16.firebasestorage.app',
  );
}
