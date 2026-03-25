import '../domain/user_model.dart';

abstract class UserMockDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel?> getUserById(String userId);
  Future<List<UserModel>> addUser(UserModel user);
  Future<List<UserModel>> updateUser(UserModel user);
}

class UserMockDataSourceImpl implements UserMockDataSource {
  UserMockDataSourceImpl() : _users = _seedUsers();

  final List<UserModel> _users;
  int _sequence = 7;

  @override
  Future<List<UserModel>> getUsers() async {
    return _users.map((user) => user.copyWith()).toList();
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    for (final user in _users) {
      if (user.userId == userId) {
        return user.copyWith();
      }
    }
    return null;
  }

  @override
  Future<List<UserModel>> addUser(UserModel user) async {
    final now = DateTime.now();
    final next = user.copyWith(
      userId: user.userId.trim().isEmpty ? _nextUserId() : user.userId,
      createdAt: now,
      updatedAt: now,
    );
    _users.add(next);
    return getUsers();
  }

  @override
  Future<List<UserModel>> updateUser(UserModel user) async {
    final index = _users.indexWhere((entry) => entry.userId == user.userId);
    if (index == -1) {
      return getUsers();
    }

    final existing = _users[index];
    _users[index] = user.copyWith(
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return getUsers();
  }

  String _nextUserId() {
    final id = 'USR-${_sequence.toString().padLeft(3, '0')}';
    _sequence += 1;
    return id;
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
