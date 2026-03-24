class User {
  const User({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.profilePicture,
    required this.isActive,
    required this.createdAt,
    required this.lastLogin,
  });

  final String userId;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? profilePicture;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User copyWith({
    String? userId,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? profilePicture,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

enum UserRole {
  admin('Admin', 'Full system access and user management'),
  operationsManager('Operations Manager', 'Manage orders, fleet, and drivers'),
  dispatcher('Dispatcher', 'Assign vehicles and drivers to orders'),
  driver('Driver', 'Execute trips and capture delivery evidence'),
  accountant('Accountant', 'Manage invoices and financial reports'),
  compliance('Compliance Officer', 'Monitor safety and compliance metrics'),
  viewer('Viewer', 'Read-only access to dashboards');

  const UserRole(this.displayName, this.description);

  final String displayName;
  final String description;
}
