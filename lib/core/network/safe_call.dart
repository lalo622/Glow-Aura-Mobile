
import 'package:dio/dio.dart';
import 'app_exception.dart';


typedef SafeResult<T> = ({T? data, AppException? error});

Future<SafeResult<T>> safeCall<T>(Future<T> Function() call) async {
  try {
    final data = await call();
    return (data: data, error: null);
  } on DioException catch (e) {
    return (data: null, error: AppException.fromDio(e));
  } on AppException catch (e) {
    return (data: null, error: e);
  } catch (e) {
    return (
      data: null,
      error: AppException(
        type: AppErrorType.unknown,
        message: e.toString(),
      ),
    );
  }
}