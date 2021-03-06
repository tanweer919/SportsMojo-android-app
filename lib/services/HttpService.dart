import 'package:dio/dio.dart';
import 'RemoteConfigService.dart';
import 'GetItLocator.dart';

class HttpService {
  static Dio getApiClient() {
    final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();
    BaseOptions options = new BaseOptions(headers: {
      'x-rapidapi-host': _remoteConfigService.getString(key: 'xRapidapiHost'),
      'x-rapidapi-key': _remoteConfigService.getString(key: 'scoreApiKey')
    }, baseUrl: _remoteConfigService.getString(key: 'scoreUrl'));
    final _dio = new Dio(options);
    return _dio;
  }
}