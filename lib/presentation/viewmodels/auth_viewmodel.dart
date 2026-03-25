import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<AuthState>>((ref) {
  return AuthViewModel();
});

class AuthViewModel extends StateNotifier<AsyncValue<AuthState>> {
  AuthViewModel() : super(AsyncValue.data(AuthState.initial()));

  /// Mock login method for demonstration
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock user data based on username
      final mockUsers = {
        'admin': User(
          userId: 'USR001',
          username: 'admin',
          email: 'admin@glslogistics.com',
          fullName: 'Admin User',
          phone: '+968 9123 4567',
          role: UserRole.admin,
          profilePicture: null,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          lastLogin: DateTime.now(),
        ),
        'dispatcher': User(
          userId: 'USR002',
          username: 'dispatcher',
          email: 'dispatcher@glslogistics.com',
          fullName: 'Ahmed Al Balushi',
          phone: '+968 9234 5678',
          role: UserRole.dispatcher,
          profilePicture: null,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
          lastLogin: DateTime.now(),
        ),
        'driver': User(
          userId: 'USR003',
          username: 'driver',
          email: 'driver@glslogistics.com',
          fullName: 'Mohammed Al Harthi',
          phone: '+968 9345 6789',
          role: UserRole.driver,
          profilePicture: null,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          lastLogin: DateTime.now(),
        ),
        'compliance': User(
          userId: 'USR004',
          username: 'compliance',
          email: 'compliance@glslogistics.com',
          fullName: 'Fatima Al Mazrouei',
          phone: '+968 9456 7890',
          role: UserRole.compliance,
          profilePicture: null,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 120)),
          lastLogin: DateTime.now(),
        ),
        'accountant': User(
          userId: 'USR005',
          username: 'accountant',
          email: 'accountant@glslogistics.com',
          fullName: 'Salim Al Kindi',
          phone: '+968 9567 8901',
          role: UserRole.accountant,
          profilePicture: null,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 150)),
          lastLogin: DateTime.now(),
        ),
      };

      final user = mockUsers[username];
      if (user == null) {
        state = AsyncValue.error(
            'Invalid username or password', StackTrace.current);
        return;
      }

      // Mock token generation
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      final refreshToken =
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
      final expiresAt = DateTime.now().add(const Duration(hours: 24));

      state = AsyncValue.data(
        AuthState.authenticated(
          user: user,
          token: token,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  /// Logout method
  void logout() {
    state = AsyncValue.data(AuthState.initial());
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    final authState = state.valueOrNull;
    return authState?.isAuthenticated ?? false;
  }

  /// Get current user
  User? get currentUser {
    return state.valueOrNull?.user;
  }

  /// Get current user role
  UserRole? get currentUserRole {
    return state.valueOrNull?.user?.role;
  }

  /// Check if token is expired
  bool get isTokenExpired {
    return state.valueOrNull?.isTokenExpired ?? true;
  }
}
