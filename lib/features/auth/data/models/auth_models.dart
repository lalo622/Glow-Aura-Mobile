// ─── Request Models ──────────────────────────────────────────────────────────

class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final String phoneNumber;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
      };
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };
}

// ─── Response Models ─────────────────────────────────────────────────────────

class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String accessTokenExpiry;
  final String refreshTokenExpiry;

  const TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        accessTokenExpiry: json['accessTokenExpiry'] as String,
        refreshTokenExpiry: json['refreshTokenExpiry'] as String,
      );
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String vipLevel;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.vipLevel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String,
        vipLevel: json['vipLevel'] as String,
      );
}

class AuthResponse {
  final bool isSuccess;
  final String message;
  final TokenModel? token;
  final UserModel? user;

  const AuthResponse({
    required this.isSuccess,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        isSuccess: json['isSuccess'] as bool,
        message: json['message'] as String,
        token: json['token'] != null
            ? TokenModel.fromJson(json['token'] as Map<String, dynamic>)
            : null,
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}
class GoogleLoginRequest {
  final String idToken;
  const GoogleLoginRequest({required this.idToken});
  Map<String, dynamic> toJson() => {'idToken': idToken};
}