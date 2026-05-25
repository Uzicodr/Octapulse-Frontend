import 'package:dio/dio.dart';

import '../../domain/entities/fighter_log.dart';
import '../../../../core/utils/constants.dart';
import '../models/fighter_log_model.dart';

abstract class FighterLogsRemoteDataSource {
  Future<List<FighterLog>> getFighterLogs({String? search});
}

class FighterLogsRemoteDataSourceImpl implements FighterLogsRemoteDataSource {
  final Dio _dio;

  FighterLogsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<FighterLog>> getFighterLogs({String? search}) async {
    try {
      final response = await _dio.get(
        ApiConstants.fighterLogs,
        queryParameters:
            search != null && search.isNotEmpty ? {'search': search} : null,
      );
      return FighterLogModel.fromJsonList(response.data);
    } on DioException catch (e) {
      print('=== DIO EXCEPTION (fighterLogs) ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Base URL: ${_dio.options.baseUrl}');
      print('Endpoint: ${ApiConstants.fighterLogs}');
      print('Stack Trace: ${e.stackTrace}');
      print('===================================');
      rethrow;
    }
  }
}
