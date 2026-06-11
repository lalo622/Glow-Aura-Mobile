import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/user_profile_model.dart';

class UserService {
  final Dio _dio = ApiClient.instance.dio;

  Future<UserProfileModel> getMyProfile() async {
    final response = await _dio.get(ApiEndpoints.myProfile);
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfileModel> updateMyProfile(UpdateProfileRequest request) async {
    final response = await _dio.put(
      ApiEndpoints.myProfile,
      data: request.toJson(),
    );
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}