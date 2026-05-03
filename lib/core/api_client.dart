import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';

/// Centralized HTTP layer.
///
/// Two shared Dio instances live here. Infrastructure callsites should NEVER
/// instantiate a fresh `Dio()` — every per-call instantiation costs a TLS
/// handshake, prevents keep-alive reuse, and breaks HTTP connection pooling.
///
/// - [dio]      — short-timeout (15s) client for regular API calls.
/// - [downloadDio] — long-running client used by the chunked downloader.
///
/// Both share an underlying `HttpClient` configuration with a generous
/// per-host connection cap so several parallel calls (watch info +
/// SponsorBlock + thumbnails + comments) don't queue behind each other.
class ApiClient {
  static ApiClient? _instance;

  late final Dio _apiDio;
  late final Dio _downloadDio;

  ApiClient._() {
    _apiDio = _buildApiDio();
    _downloadDio = _buildDownloadDio();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Convenience static accessor for raw API client.
  static Dio get dio => instance._apiDio;

  /// Convenience static accessor for the download client.
  static Dio get downloadDio => instance._downloadDio;

  Dio _buildApiDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      followRedirects: false,
      // Handle all status codes manually so callers don't need try/catch
      // around routine 4xx/5xx.
      validateStatus: (status) => true,
    ));
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: _buildHttpClient,
    );
    return dio;
  }

  Dio _buildDownloadDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      // Bulk transfers — but never 30 minutes (which masks dead sockets).
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(seconds: 30),
      followRedirects: true,
      validateStatus: (status) => status != null && status < 500,
    ));
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: _buildHttpClient,
    );
    return dio;
  }

  HttpClient _buildHttpClient() {
    final client = HttpClient();
    // Default is 6 — far too low when we fan out to thumbnails + watch info +
    // related streams + sponsorblock concurrently.
    client.maxConnectionsPerHost = 32;
    client.idleTimeout = const Duration(seconds: 60);
    client.connectionTimeout = const Duration(seconds: 15);
    return client;
  }

  /// Perform a GET request with automatic error handling.
  ///
  /// Returns [Either<MainFailure, T>] where T is the parsed response.
  Future<Either<MainFailure, T>> get<T>({
    required String url,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? queryParameters,
    int maxAttempts = 1,
  }) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;

      try {
        final response = await _apiDio.get(
          url,
          queryParameters: queryParameters,
        );

        return _handleResponse(response, parser, url);
      } on DioException catch (e) {
        log('DioException on $url (attempt $attempts): ${e.type}');

        if (attempts < maxAttempts && _isRetriableError(e)) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }

        return Left(_mapDioException(e));
      } catch (e) {
        log('Unknown error on $url: $e');
        return Left(MainFailure.unknown(message: e.toString()));
      }
    }

    return const Left(MainFailure.unknown());
  }

  Either<MainFailure, T> _handleResponse<T>(
    Response response,
    T Function(dynamic data) parser,
    String url,
  ) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        return Right(parser(response.data));
      } catch (e) {
        log('Parse error on $url: $e');
        return Left(MainFailure.parseError(message: e.toString()));
      }
    } else if (statusCode == 404) {
      log('Not found: $url');
      return Left(MainFailure.notFound(resource: url));
    } else if (statusCode == 429) {
      final retryAfter = int.tryParse(
        response.headers.value('retry-after') ?? '',
      );
      log('Rate limited on $url');
      return Left(MainFailure.rateLimited(retryAfter: retryAfter));
    } else if (statusCode >= 500) {
      log('Server error on $url: $statusCode');
      return Left(MainFailure.serverError(
        statusCode: statusCode,
        message: 'Server error',
      ));
    } else {
      log('Error on $url: $statusCode');
      return Left(MainFailure.serverError(
        statusCode: statusCode,
        message: response.statusMessage,
      ));
    }
  }

  bool _isRetriableError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  MainFailure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return MainFailure.timeout(message: e.message);

      case DioExceptionType.connectionError:
        return MainFailure.networkError(message: e.message);

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const MainFailure.notFound();
        } else if (statusCode == 429) {
          return const MainFailure.rateLimited();
        }
        return MainFailure.serverError(
          statusCode: statusCode,
          message: e.message,
        );

      case DioExceptionType.cancel:
        return MainFailure.unknown(message: 'Request cancelled');

      case DioExceptionType.badCertificate:
        return MainFailure.networkError(message: 'Certificate error');

      case DioExceptionType.unknown:
        return MainFailure.unknown(message: e.message);
    }
  }

  /// Close the Dio client (call when app is disposed).
  void close() {
    _apiDio.close(force: true);
    _downloadDio.close(force: true);
    _instance = null;
  }
}

/// Extension to simplify API calls that return lists.
extension ApiClientListExtension on ApiClient {
  /// GET request that parses response as a list.
  Future<Either<MainFailure, List<T>>> getList<T>({
    required String url,
    required T Function(Map<String, dynamic> json) itemParser,
    Map<String, dynamic>? queryParameters,
    int maxAttempts = 1,
  }) {
    return get(
      url: url,
      queryParameters: queryParameters,
      maxAttempts: maxAttempts,
      parser: (data) {
        if (data is List) {
          return data.map((item) => itemParser(item as Map<String, dynamic>)).toList();
        }
        throw FormatException('Expected list but got ${data.runtimeType}');
      },
    );
  }
}
