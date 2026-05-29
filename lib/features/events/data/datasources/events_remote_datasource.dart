import 'package:dio/dio.dart';

import '../../domain/entities/event.dart';
import '../../../../core/utils/constants.dart';
import '../models/event_model.dart';

abstract class EventsRemoteDataSource {
  Future<List<Event>> getPastEvents();
  Future<List<Event>> getUpcomingEvents();
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final Dio _dio;

  EventsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Event>> getPastEvents() async {
    try {
      final response = await _dio.get(ApiConstants.pastEvents);
      return EventModel.fromJsonList(response.data);
    } on DioException catch (e) {
      print('=== DIO EXCEPTION (pastEvents) ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Base URL: ${_dio.options.baseUrl}');
      print('Endpoint: ${ApiConstants.pastEvents}');
      print('Stack Trace: ${e.stackTrace}');
      print('===================================');
      rethrow;
    }
  }

  @override
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final response = await _dio.get(ApiConstants.upcomingEvents);
      return EventModel.fromJsonList(response.data, isUpcoming: true);
    } on DioException catch (e) {
      print('=== DIO EXCEPTION (upcomingEvents) ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Base URL: ${_dio.options.baseUrl}');
      print('Endpoint: ${ApiConstants.upcomingEvents}');
      print('Stack Trace: ${e.stackTrace}');
      print('======================================');
      rethrow;
    }
  }
}
