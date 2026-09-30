/// UserModel — represents the authenticated user.
///
/// DATA FLOW:
///   POST /auth/login → JSON response → UserModel.fromJson()
///   → stored in Hive session box → AuthBloc state → widgets
///
/// API FIELD MAPPINGS (from /auth/login response):
///   "id"          → id
///   "firstName"   → firstName
///   "lastName"    → lastName
///   "email"       → email
///   "username"    → username
///   "accessToken"       → token  (JWT — used for authenticated requests)
///
/// NOTE: DummyJSON tokens are for demo purposes only.
/// This model is used to personalise the UI (show name, etc.).
class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.token,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String token; // JWT from DummyJSON — required for authenticated endpoints

  /// Full display name composed from first + last name.
  String get fullName => '$firstName $lastName';

  /// Builds a UserModel from the DummyJSON /auth/login JSON response.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      token: json['accessToken'] as String,
    );
  }

  /// Converts to Map for Hive session storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'token': token,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, username: $username)';
}
