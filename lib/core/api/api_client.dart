import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._(this._dio, this._cookieJar);

  final Dio _dio;
  final PersistCookieJar _cookieJar;

  Future<Response<dynamic>>? _refreshCall;

  static Future<ApiClient> create() async {
    final dir = await getApplicationSupportDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/cookies'),
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    final client = ApiClient._(dio, cookieJar);
    dio.interceptors.add(
      InterceptorsWrapper(onError: client._onError),
    );
    return client;
  }

  static const _authFlowPaths = [
    '/api/auth/refresh',
    '/api/auth/login',
    '/api/auth/register',
  ];

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final status = error.response?.statusCode;
    final path = error.requestOptions.path;
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    if (status == 401 &&
        !alreadyRetried &&
        !_authFlowPaths.any(path.contains)) {
      try {
        _refreshCall ??= _dio
            .post('/api/auth/refresh')
            .whenComplete(() => _refreshCall = null);
        await _refreshCall;

        final options = error.requestOptions..extra['retried'] = true;
        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } catch (_) {
        // Refresh failed; fall through with the original 401.
      }
    }

    handler.next(error);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _request(() => _dio.post(path, data: body));

  Future<dynamic> patch(String path, {Object? body}) =>
      _request(() => _dio.patch(path, data: body));

  Future<dynamic> delete(String path) => _request(() => _dio.delete(path));

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> clearCookies() => _cookieJar.deleteAll();
}
