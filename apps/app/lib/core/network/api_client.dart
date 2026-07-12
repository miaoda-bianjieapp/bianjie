import 'package:dio/dio.dart';

import '../config/api_config.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 150),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  final Dio _dio;

  Dio get dio => _dio;
}
