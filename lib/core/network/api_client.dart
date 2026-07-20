import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../utils/app_logger.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.info('${options.method} ${options.path}', tag: 'ApiClient');
          handler.next(options);
        },
        onError: (error, handler) {
          AppLogger.error(
            '${error.requestOptions.path} failed: ${error.response?.statusCode}',
            tag: 'ApiClient',
            error: error,
          );
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;

  // Maps a DioException into our typed exceptions with a clean message.
  Never handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw const NetworkException(
        message: 'Connection timed out. Please try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      throw const NetworkException(message: 'No internet connection.');
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;
    final serverMessage = _extractMessage(data);

    if (status == 401) {
      throw AuthException(message: serverMessage ?? 'Invalid credentials.');
    }
    if (status == 403) {
      // Authenticated but not allowed (e.g. wrong role, or an action the
      // account isn't permitted to perform). Surface the server's reason.
      throw ServerException(
        message: serverMessage ??
            "You don't have permission to perform this action.",
      );
    }
    throw ServerException(
      message: serverMessage ?? 'Something went wrong. Please try again.',
    );
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      // ASP.NET validation errors come under "errors"
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      final title = data['title'];
      if (title is String && title.isNotEmpty) return title;
    }
    return null;
  }

  // Every endpoint returns { success, message, data }. These helpers pull the
  // `data` payload out and surface a ServerException when success is false.
  Map<String, dynamic> unwrapObject(dynamic body) {
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    if (map['success'] == false) {
      throw ServerException(
        message: map['message']?.toString() ?? 'Request failed.',
      );
    }
    final data = map['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  List<dynamic> unwrapList(dynamic body) {
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    if (map['success'] == false) {
      throw ServerException(
        message: map['message']?.toString() ?? 'Request failed.',
      );
    }
    final data = map['data'];
    // Paged endpoints nest the list under data.items; raw-list endpoints put it at data.
    if (data is Map<String, dynamic> && data['items'] is List) {
      return data['items'] as List<dynamic>;
    }
    return data is List ? data : const <dynamic>[];
  }

  String unwrapMessage(dynamic body) {
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    if (map['success'] == false) {
      throw ServerException(
        message: map['message']?.toString() ?? 'Request failed.',
      );
    }
    return map['message']?.toString() ?? 'Success';
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(tokenStorageProvider));
});
