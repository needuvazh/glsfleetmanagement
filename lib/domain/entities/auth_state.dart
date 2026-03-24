import 'user.dart';

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    required this.error,
  });

  final bool isAuthenticated;
  final User? user;
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? error;

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      user: null,
      token: null,
      refreshToken: null,
      expiresAt: null,
      error: null,
    );
  }

  factory AuthState.authenticated({
    required User user,
    required String token,
    required String refreshToken,
    required DateTime expiresAt,
  }) {
    return AuthState(
      isAuthenticated: true,
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      error: null,
    );
  }

  factory AuthState.error(String message) {
    return AuthState(
      isAuthenticated: false,
      user: null,
      token: null,
      refreshToken: null,
      expiresAt: null,
      error: message,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      error: error ?? this.error,
    );
  }

  bool get isTokenExpired {
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt!);
  }
}
