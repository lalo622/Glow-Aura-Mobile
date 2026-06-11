class UserProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String role;
  final String vipLevel;
  final String? skinType;
  final int? age;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    required this.vipLevel,
    this.skinType,
    this.age,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        phoneNumber: json['phoneNumber'] as String?,
        role: json['role'] as String,
        vipLevel: json['vipLevel'] as String,
        skinType: json['skinType'] as String?,
        age: json['age'] as int?,
      );
}

class UpdateProfileRequest {
  final String fullName;
  final String? phoneNumber;
  final String? skinType;
  final int? age;

  const UpdateProfileRequest({
    required this.fullName,
    this.phoneNumber,
    this.skinType,
    this.age,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (skinType != null) 'skinType': skinType,
        if (age != null) 'age': age,
      };
}