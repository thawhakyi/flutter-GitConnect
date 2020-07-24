import 'package:dio/dio.dart';
import 'package:flutter_github_connect/bloc/User/User_model.dart';
import 'package:flutter_github_connect/bloc/notification/index.dart';
import 'package:flutter_github_connect/bloc/repo/repo_model.dart';
import 'package:flutter_github_connect/helper/config.dart';
import 'package:flutter_github_connect/resources/dio_client.dart';
import 'package:flutter_github_connect/resources/graphql_client.dart';
import 'package:flutter_github_connect/resources/provider/api_gatway.dart';
import 'package:flutter_github_connect/resources/service/session_servoce.dart';

class ApiGatwayImpl implements ApiGateway {
  final DioClient _dioClient;
  final SessionService _sessionService;
  ApiGatwayImpl(this._dioClient, this._sessionService);

  @override
  Future<UserModel> fetchUserProfile() async {
    try {
      var accesstoken = await _sessionService.loadSession();
      initClient(accesstoken);
      final result = await getUser("TheAlphamerc");
      if (result.hasException) {
        print(result.exception.toString());
        return null;
      }

      final userMap = result.data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      return user;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<RepositoryModel>> fetchRepositories() async {
    try {
      var accesstoken = await _sessionService.loadSession();
      var response = await _dioClient.get(
        Config.repos,
        options: Options(
          headers: {
            'Authorization': 'token $accesstoken',
            'Accept': 'application/vnd.github.v3+json'
          },
        ),
      );
      final list = _dioClient
          .getJsonBodyList(response)
          .map((e) => RepositoryModel.fromJson(e))
          .toList();
      return list;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<NotificationModel>> fetchNotificationList() async {
    try {
      var accesstoken = await _sessionService.loadSession();
      var response = await _dioClient.get(
        Config.notificationsList,
        options: Options(
          headers: {
            'Authorization': 'token $accesstoken'
          },
        ),
      );
      List<NotificationModel> list = [];
    //  await _dioClient
    //       .getJsonBodyList(response)
    //       .map((model){
    //          list.add(NotificationModel.fromJson(_dioClient.getJsonBody(model)));
    //       });
        list = _dioClient.getJsonBodyList(response).map((value) {
          return NotificationModel.fromJson(value);
        }).toList();
      print(list.length);
      return list;
    } catch (error) {
      throw error;
    }
  }
}