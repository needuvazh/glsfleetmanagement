import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user_model.dart';

abstract class UserMockDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel?> getUserById(String userId);
  Future<List<UserModel>> addUser(UserModel user);
  Future<List<UserModel>> updateUser(UserModel user);
}

class UserMockDataSourceImpl implements UserMockDataSource {
  UserMockDataSourceImpl();

  static const _cacheKey = 'user_master_records_v2';
  List<UserModel>? _users;
  int _sequence = 7;

  Future<void> _ensureInitialized() async {
    if (_users != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _users = decoded
            .map((entry) => _userFromMap(Map<String, dynamic>.from(entry)))
            .toList();
      } catch (_) {
        _users = _seedUsers();
      }
    } else {
      _users = _seedUsers();
    }

    _sequence = _nextSequence(_users!);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _users!.map(_userToMap).toList();
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  @override
  Future<List<UserModel>> getUsers() async {
    await _ensureInitialized();
    return _users!.map((user) => user.copyWith()).toList();
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    await _ensureInitialized();
    for (final user in _users!) {
      if (user.userId == userId) {
        return user.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<UserModel>> addUser(UserModel user) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final next = user.copyWith(
      userId: user.userId.trim().isEmpty ? _nextUserId() : user.userId,
      createdAt: now,
      updatedAt: now,
    );
    _users!.add(next);
    await _persist();
    return getUsers();
  }

  @override
  Future<List<UserModel>> updateUser(UserModel user) async {
    await _ensureInitialized();
    final index = _users!.indexWhere((entry) => entry.userId == user.userId);
    if (index == -1) {
      return getUsers();
    }

    final existing = _users![index];
    _users![index] = user.copyWith(
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    await _persist();
    return getUsers();
  }

  String _nextUserId() {
    final id = 'USR-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
  }

  int _nextSequence(List<UserModel> users) {
    var maxValue = 0;
    for (final user in users) {
      final parts = user.userId.split('-');
      if (parts.length < 2) {
        continue;
      }
      final parsed = int.tryParse(parts.last) ?? 0;
      if (parsed > maxValue) {
        maxValue = parsed;
      }
    }
    return maxValue + 1;
  }

  UserModel _userFromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String? ?? '',
      department: _departmentFromName(map['department'] as String?),
      employeeId: map['employeeId'] as String? ?? '',
      joiningDate: DateTime.tryParse(map['joiningDate'] as String? ?? '') ??
          DateTime.now(),
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      role: _userRoleFromName(map['role'] as String?),
      countryCode: _countryCodeFromName(map['countryCode'] as String?),
      phoneNumber: map['phoneNumber'] as String? ?? '',
      alternateNumber: map['alternateNumber'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      licenseNumber: map['licenseNumber'] as String? ?? '',
      licenseExpiryDate:
          DateTime.tryParse(map['licenseExpiryDate'] as String? ?? ''),
      status: _userStatusFromName(map['status'] as String?),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> _userToMap(UserModel user) {
    return {
      'userId': user.userId,
      'department': user.department.name,
      'employeeId': user.employeeId,
      'joiningDate': user.joiningDate.toIso8601String(),
      'username': user.username,
      'password': user.password,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'role': user.role.name,
      'countryCode': user.countryCode.name,
      'phoneNumber': user.phoneNumber,
      'alternateNumber': user.alternateNumber,
      'email': user.email,
      'address': user.address,
      'licenseNumber': user.licenseNumber,
      'licenseExpiryDate': user.licenseExpiryDate?.toIso8601String(),
      'status': user.status.name,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };
  }

  DepartmentType _departmentFromName(String? value) {
    for (final item in DepartmentType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return DepartmentType.operations;
  }

  UserRoleType _userRoleFromName(String? value) {
    for (final item in UserRoleType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return UserRoleType.dispatcher;
  }

  CountryCodeType _countryCodeFromName(String? value) {
    for (final item in CountryCodeType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return CountryCodeType.oman;
  }

  UserStatusType _userStatusFromName(String? value) {
    for (final item in UserStatusType.values) {
      if (item.name == value) {
        return item;
      }
    }
    return UserStatusType.active;
  }
}

List<UserModel> _seedUsers() {
  final now = DateTime.now();
  return [
    UserModel(
      userId: 'USR-001',
      department: DepartmentType.administration,
      employeeId: 'EMP-1001',
      joiningDate: DateTime(2023, 1, 10),
      username: 'haris.admin',
      password: 'Admin@123',
      firstName: 'Haris',
      lastName: 'Khan',
      role: UserRoleType.admin,
      countryCode: CountryCodeType.oman,
      phoneNumber: '91000001',
      alternateNumber: '92000001',
      email: 'haris.khan@greenfield.com',
      address: 'Muscat HQ, Oman',
      licenseNumber: '',
      licenseExpiryDate: null,
      status: UserStatusType.active,
      createdAt: now,
      updatedAt: now,
    ),
    UserModel(
      userId: 'USR-002',
      department: DepartmentType.dispatch,
      employeeId: 'EMP-1002',
      joiningDate: DateTime(2023, 3, 4),
      username: 'amina.dispatch',
      password: 'Dispatch@123',
      firstName: 'Amina',
      lastName: 'Rahman',
      role: UserRoleType.dispatcher,
      countryCode: CountryCodeType.oman,
      phoneNumber: '91000002',
      alternateNumber: '',
      email: 'amina.rahman@greenfield.com',
      address: 'Operations Desk, Muscat',
      licenseNumber: '',
      licenseExpiryDate: null,
      status: UserStatusType.active,
      createdAt: now,
      updatedAt: now,
    ),
    UserModel(
      userId: 'USR-003',
      department: DepartmentType.transport,
      employeeId: 'EMP-1003',
      joiningDate: DateTime(2022, 11, 18),
      username: 'ravi.driver',
      password: 'Driver@123',
      firstName: 'Ravi',
      lastName: 'Menon',
      role: UserRoleType.driver,
      countryCode: CountryCodeType.india,
      phoneNumber: '9876543210',
      alternateNumber: '9876543211',
      email: '',
      address: '',
      licenseNumber: 'DRV-OM-7781',
      licenseExpiryDate: DateTime(2027, 4, 30),
      status: UserStatusType.active,
      createdAt: now,
      updatedAt: now,
    ),
    UserModel(
      userId: 'USR-004',
      department: DepartmentType.dispatch,
      employeeId: 'EMP-1004',
      joiningDate: DateTime(2024, 2, 12),
      username: 'fatima.dispatch',
      password: 'Dispatch@456',
      firstName: 'Fatima',
      lastName: 'Ali',
      role: UserRoleType.dispatcher,
      countryCode: CountryCodeType.uae,
      phoneNumber: '501234567',
      alternateNumber: '501234568',
      email: 'fatima.ali@greenfield.com',
      address: 'Regional Dispatch Hub, Dubai',
      licenseNumber: '',
      licenseExpiryDate: null,
      status: UserStatusType.inactive,
      createdAt: now,
      updatedAt: now,
    ),
    UserModel(
      userId: 'USR-005',
      department: DepartmentType.transport,
      employeeId: 'EMP-1005',
      joiningDate: DateTime(2021, 8, 7),
      username: 'suresh.driver',
      password: 'Driver@456',
      firstName: 'Suresh',
      lastName: 'Nair',
      role: UserRoleType.driver,
      countryCode: CountryCodeType.oman,
      phoneNumber: '91000005',
      alternateNumber: '92000005',
      email: '',
      address: '',
      licenseNumber: 'DRV-OM-8120',
      licenseExpiryDate: DateTime(2026, 12, 15),
      status: UserStatusType.active,
      createdAt: now,
      updatedAt: now,
    ),
    UserModel(
      userId: 'USR-006',
      department: DepartmentType.operations,
      employeeId: 'EMP-1006',
      joiningDate: DateTime(2022, 5, 20),
      username: 'noor.admin',
      password: 'Admin@456',
      firstName: 'Noor',
      lastName: 'Hassan',
      role: UserRoleType.admin,
      countryCode: CountryCodeType.qatar,
      phoneNumber: '33000006',
      alternateNumber: '',
      email: 'noor.hassan@greenfield.com',
      address: 'Admin Support Office, Doha',
      licenseNumber: '',
      licenseExpiryDate: null,
      status: UserStatusType.active,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
