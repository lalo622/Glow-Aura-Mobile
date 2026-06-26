import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/safe_call.dart';
import '../models/user_profile_model.dart';

class UserService {
  final Dio _dio = ApiClient.instance.dio;

  Future<SafeResult<UserProfileModel>> getMyProfile() =>
      safeCall(() async {
        final response = await _dio.get(ApiEndpoints.myProfile);
        return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
      });

  Future<SafeResult<UserProfileModel>> updateMyProfile(UpdateProfileRequest request) =>
      safeCall(() async {
        final response = await _dio.put(
          ApiEndpoints.myProfile,
          data: request.toJson(),
        );
        return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
      });
}