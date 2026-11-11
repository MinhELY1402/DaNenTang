// File cấu hình Firebase Options cho ứng dụng Admin Quản Lý Sản Phẩm
// Hỗ trợ cả nền tảng Web và Android (Bản Free Spark Plan)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Cấu hình mặc định cho Firebase.
/// Bạn có thể thay đổi các thông số này theo Project Firebase trên https://console.firebase.google.com
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

  // Cấu hình Firebase Web (Free Spark Plan)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_DEMO_API_KEY_WEB_GIUA_KY_2024',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'admin-product-manager-free',
    authDomain: 'admin-product-manager-free.firebaseapp.com',
    storageBucket: 'admin-product-manager-free.appspot.com',
  );

  // Cấu hình Firebase Android (Free Spark Plan)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_DEMO_API_KEY_ANDROID_GIUA_KY',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'admin-product-manager-free',
    storageBucket: 'admin-product-manager-free.appspot.com',
  );
}
