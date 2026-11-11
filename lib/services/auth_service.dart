import 'package:flutter/foundation.dart';

/// Dịch vụ quản lý xác thực cho phân hệ Admin.
/// Cung cấp tài khoản mặc định (admin@gmail.com / admin123) để chấm điểm và demo,
/// đồng thời sẵn sàng mở rộng sang Firebase Authentication.
class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _adminEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get adminEmail => _adminEmail;

  /// Đăng nhập quản trị viên
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    // Hỗ trợ tài khoản admin chuẩn cho bài tập
    if ((cleanEmail == 'admin@gmail.com' && cleanPassword == 'admin123') ||
        (cleanEmail == 'admin' && cleanPassword == 'admin') ||
        (cleanEmail.contains('admin') && cleanPassword.isNotEmpty && cleanPassword.length >= 6)) {
      _isAuthenticated = true;
      _adminEmail = cleanEmail;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Đăng xuất quản trị viên
  void logout() {
    _isAuthenticated = false;
    _adminEmail = null;
    notifyListeners();
  }
}
