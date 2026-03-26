enum UserRoleType {
  admin('Admin'),
  driver('Driver'),
  dispatcher('Dispatcher');

  const UserRoleType(this.label);
  final String label;
}

enum UserStatusType {
  active('Active'),
  inactive('Inactive');

  const UserStatusType(this.label);
  final String label;
}

enum CountryCodeType {
  oman('+968'),
  uae('+971'),
  bahrain('+973'),
  qatar('+974'),
  kuwait('+965'),
  india('+91');

  const CountryCodeType(this.label);
  final String label;
}

enum DepartmentType {
  administration('Administration'),
  transport('Transport'),
  dispatch('Dispatch'),
  operations('Operations'),
  safety('Safety & Compliance');

  const DepartmentType(this.label);
  final String label;
}

class UserModel {
  const UserModel({
    required this.userId,
    required this.department,
    required this.employeeId,
    required this.joiningDate,
    required this.username,
    required this.password,
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
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final DepartmentType department;
  final String employeeId;
  final DateTime joiningDate;
  final String username;
  final String password;
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
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName'.trim();
  String get fullPhone => '${countryCode.label} $phoneNumber';
  String get joiningDateLabel => _formatDate(joiningDate);
  String get licenseExpiryDateLabel =>
      licenseExpiryDate == null ? '-' : _formatDate(licenseExpiryDate!);

  UserModel copyWith({
    String? userId,
    DepartmentType? department,
    String? employeeId,
    DateTime? joiningDate,
    String? username,
    String? password,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      joiningDate: joiningDate ?? this.joiningDate,
      username: username ?? this.username,
      password: password ?? this.password,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
