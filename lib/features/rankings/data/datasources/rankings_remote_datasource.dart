import 'package:dio/dio.dart';

import '../../domain/entities/rankings.dart';
import '../../../../core/utils/constants.dart';
import '../models/ranking_model.dart';

abstract class RankingsRemoteDataSource {
  Future<List<Ranking>> getRankings({String? division});
}

class RankingsRemoteDataSourceImpl implements RankingsRemoteDataSource {
  final Dio _dio;

  RankingsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Ranking>> getRankings({String? division}) async {
    try {
      final response = await _dio.get(ApiConstants.rankings);
      return RankingModel.fromJsonList(response.data);
    } on DioException catch (e) {
      print('=== DIO EXCEPTION (getRankings) ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Base URL: ${_dio.options.baseUrl}');
      print('Endpoint: ${ApiConstants.rankings}');
      print('Stack Trace: ${e.stackTrace}');
      print('====================================');
      rethrow;
    }
  }
}
