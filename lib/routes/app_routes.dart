import 'package:flutter/material.dart';
import 'package:trashwisecollector/views/accepted_request_view.dart';
import 'package:trashwisecollector/views/login_view.dart';
import 'package:trashwisecollector/views/main_view.dart';
import 'package:trashwisecollector/views/register_view.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const register = '/register';
  static const mainView = "/main-view";
  static const accepted_requests = "/accepted_requests";




  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginView(),
    register: (_) =>  const RegisterView(),
    mainView: (_) => const MainView(),
    accepted_requests: (_)=> const AcceptedRequestsView()
  };
}
