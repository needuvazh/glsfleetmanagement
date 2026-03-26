import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user_mock_datasource.dart';
import '../../data/user_repository.dart';
import '../../domain/user_model.dart';

class UserUiState {
  const UserUiState({
    required this.users,
    required this.searchQuery,
    required this.lastUpdated,
  });

  final List<UserModel> users;
  final String searchQuery;
  final DateTime lastUpdated;

  List<UserModel> get filteredUsers {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      final text = '${user.firstName} ${user.lastName} ${user.phoneNumber}'
          .toLowerCase();
      return text.contains(query);
    }).toList();
  }

  UserUiState copyWith({
    List<UserModel>? users,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return UserUiState(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final _userDataSourceProvider = Provider<UserMockDataSource>(
  (ref) => UserMockDataSourceImpl(),
);

final _userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    dataSource: ref.watch(_userDataSourceProvider),
  ),
);

final userViewModelProvider = AsyncNotifierProvider<UserViewModel, UserUiState>(
  UserViewModel.new,
);

class UserViewModel extends AsyncNotifier<UserUiState> {
  @override
  Future<UserUiState> build() async {
    final users = await ref.watch(_userRepositoryProvider).getUsers();
    return UserUiState(
      users: users,
      searchQuery: '',
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> getUsers() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final users = await ref.read(_userRepositoryProvider).getUsers();
    state = AsyncData(
      current.copyWith(users: users, lastUpdated: DateTime.now()),
    );
  }

  Future<UserModel?> getUserById(String userId) {
    return ref.read(_userRepositoryProvider).getUserById(userId);
  }

  Future<String> addUser(UserModel user) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'User state is not ready.';
    }

    final validation = _validateUser(user, current.users);
    if (validation != null) {
      return validation;
    }

    final users = await ref.read(_userRepositoryProvider).addUser(user);
    state = AsyncData(
      current.copyWith(users: users, lastUpdated: DateTime.now()),
    );
    return 'User created successfully.';
  }

  Future<String> updateUser(UserModel user) async {
    final current = state.valueOrNull;
    if (current == null) {
      return 'User state is not ready.';
    }

    final others =
        current.users.where((entry) => entry.userId != user.userId).toList();
    final validation = _validateUser(user, others);
    if (validation != null) {
      return validation;
    }

    final users = await ref.read(_userRepositoryProvider).updateUser(user);
    state = AsyncData(
      current.copyWith(users: users, lastUpdated: DateTime.now()),
    );
    return 'User updated successfully.';
  }

  void setSearchQuery(String value) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(searchQuery: value));
  }

  String? _validateUser(UserModel user, List<UserModel> existingUsers) {
    if (user.employeeId.trim().isEmpty) {
      return 'Employee ID is required.';
    }
    if (user.firstName.trim().isEmpty) {
      return 'First name is required.';
    }
    if (user.lastName.trim().isEmpty) {
      return 'Last name is required.';
    }
    if (user.username.trim().isEmpty) {
      return 'Username is required.';
    }
    if (user.phoneNumber.trim().isEmpty) {
      return 'Phone number is required.';
    }
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(user.phoneNumber.trim())) {
      return 'Phone number must be 7-15 digits.';
    }
    if (user.alternateNumber.trim().isNotEmpty &&
        !RegExp(r'^[0-9]{7,15}$').hasMatch(user.alternateNumber.trim())) {
      return 'Alternate number must be 7-15 digits.';
    }
    if (user.email.trim().isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(user.email.trim())) {
      return 'Enter a valid email address.';
    }

    final roleValidation = _validateRoleSpecificFields(user);
    if (roleValidation != null) {
      return roleValidation;
    }

    final duplicateEmail = existingUsers.any(
      (entry) =>
          user.email.trim().isNotEmpty &&
          entry.email.toLowerCase() == user.email.toLowerCase(),
    );
    if (duplicateEmail) {
      return 'Email already exists.';
    }

    final duplicateEmployeeId = existingUsers.any(
      (entry) =>
          entry.employeeId.toLowerCase() == user.employeeId.toLowerCase(),
    );
    if (duplicateEmployeeId) {
      return 'Employee ID already exists.';
    }

    final duplicateUsername = existingUsers.any(
      (entry) => entry.username.toLowerCase() == user.username.toLowerCase(),
    );
    if (duplicateUsername) {
      return 'Username already exists.';
    }

    final duplicatePhone = existingUsers.any(
      (entry) =>
          entry.countryCode == user.countryCode &&
          entry.phoneNumber == user.phoneNumber,
    );
    if (duplicatePhone) {
      return 'Phone number already exists.';
    }

    return null;
  }

  String? _validateRoleSpecificFields(UserModel user) {
    switch (user.role) {
      case UserRoleType.admin:
        if (user.email.trim().isEmpty) {
          return 'Email is required for Admin.';
        }
        if (user.address.trim().isEmpty) {
          return 'Address is required for Admin.';
        }
        return null;
      case UserRoleType.driver:
        if (user.licenseNumber.trim().isEmpty) {
          return 'License number is required for Driver.';
        }
        if (user.licenseExpiryDate == null) {
          return 'License expiry date is required for Driver.';
        }
        return null;
      case UserRoleType.dispatcher:
        if (user.email.trim().isEmpty) {
          return 'Email is required for Dispatcher.';
        }
        return null;
    }
  }
}

class UserFormState {
  const UserFormState({
    required this.initialized,
    required this.originalUserId,
    required this.department,
    required this.employeeId,
    required this.joiningDate,
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.countryCode,
    required this.phoneNumber,
    required this.alternateNumber,
    required this.email,
    required this.address,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.status,
  });

  final bool initialized;
  final String? originalUserId;
  final DepartmentType department;
  final String employeeId;
  final DateTime? joiningDate;
  final String username;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;
  final UserRoleType role;
  final CountryCodeType countryCode;
  final String phoneNumber;
  final String alternateNumber;
  final String email;
  final String address;
  final String licenseNumber;
  final DateTime? licenseExpiryDate;
  final UserStatusType status;

  bool get isEditMode => originalUserId != null;
  UserRoleType get selectedRole => role;

  UserModel toUserModel() {
    return UserModel(
      userId: originalUserId ?? '',
      department: department,
      employeeId: employeeId.trim(),
      joiningDate: joiningDate ?? DateTime.now(),
      username: username.trim(),
      password: password,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      role: role,
      countryCode: countryCode,
      phoneNumber: phoneNumber.trim(),
      alternateNumber: alternateNumber.trim(),
      email: email.trim(),
      address: address.trim(),
      licenseNumber: licenseNumber.trim(),
      licenseExpiryDate: licenseExpiryDate,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  UserFormState copyWith({
    bool? initialized,
    String? originalUserId,
    bool clearOriginalUserId = false,
    DepartmentType? department,
    String? employeeId,
    DateTime? joiningDate,
    bool clearJoiningDate = false,
    String? username,
    String? password,
    String? confirmPassword,
    String? firstName,
    String? lastName,
    UserRoleType? role,
    CountryCodeType? countryCode,
    String? phoneNumber,
    String? alternateNumber,
    String? email,
    String? address,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    bool clearLicenseExpiryDate = false,
    UserStatusType? status,
  }) {
    return UserFormState(
      initialized: initialized ?? this.initialized,
      originalUserId:
          clearOriginalUserId ? null : (originalUserId ?? this.originalUserId),
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      joiningDate: clearJoiningDate ? null : (joiningDate ?? this.joiningDate),
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: clearLicenseExpiryDate
          ? null
          : (licenseExpiryDate ?? this.licenseExpiryDate),
      status: status ?? this.status,
    );
  }
}

final userFormProvider =
    AutoDisposeNotifierProvider<UserFormNotifier, UserFormState>(
  UserFormNotifier.new,
);

class UserFormNotifier extends AutoDisposeNotifier<UserFormState> {
  @override
  UserFormState build() {
    return const UserFormState(
      initialized: false,
      originalUserId: null,
      department: DepartmentType.operations,
      employeeId: '',
      joiningDate: null,
      username: '',
      password: '',
      confirmPassword: '',
      firstName: '',
      lastName: '',
      role: UserRoleType.dispatcher,
      countryCode: CountryCodeType.oman,
      phoneNumber: '',
      alternateNumber: '',
      email: '',
      address: '',
      licenseNumber: '',
      licenseExpiryDate: null,
      status: UserStatusType.active,
    );
  }

  void initialize(UserModel? user) {
    if (state.initialized) {
      return;
    }

    if (user == null) {
      state = state.copyWith(initialized: true, clearOriginalUserId: true);
      return;
    }

    state = UserFormState(
      initialized: true,
      originalUserId: user.userId,
      department: user.department,
      employeeId: user.employeeId,
      joiningDate: user.joiningDate,
      username: user.username,
      password: user.password,
      confirmPassword: user.password,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      countryCode: user.countryCode,
      phoneNumber: user.phoneNumber,
      alternateNumber: user.alternateNumber,
      email: user.email,
      address: user.address,
      licenseNumber: user.licenseNumber,
      licenseExpiryDate: user.licenseExpiryDate,
      status: user.status,
    );
  }

  void setDepartment(DepartmentType value) =>
      state = state.copyWith(department: value);
  void setEmployeeId(String value) => state = state.copyWith(employeeId: value);
  void setJoiningDate(DateTime value) =>
      state = state.copyWith(joiningDate: value);
  void setUsername(String value) => state = state.copyWith(username: value);
  void setPassword(String value) => state = state.copyWith(password: value);
  void setConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value);
  void setFirstName(String value) => state = state.copyWith(firstName: value);
  void setLastName(String value) => state = state.copyWith(lastName: value);
  void setRole(UserRoleType value) => state = state.copyWith(role: value);
  void setCountryCode(CountryCodeType value) =>
      state = state.copyWith(countryCode: value);
  void setPhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value);
  void setAlternateNumber(String value) =>
      state = state.copyWith(alternateNumber: value);
  void setEmail(String value) => state = state.copyWith(email: value);
  void setAddress(String value) => state = state.copyWith(address: value);
  void setLicenseNumber(String value) =>
      state = state.copyWith(licenseNumber: value);
  void setLicenseExpiryDate(DateTime value) =>
      state = state.copyWith(licenseExpiryDate: value);
  void setStatus(UserStatusType value) => state = state.copyWith(status: value);
}
