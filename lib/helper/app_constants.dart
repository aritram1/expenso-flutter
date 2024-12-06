// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AppConstants{
  static const String SPLASH_PAGE_TITLE = 'Splash Page';
  static const String HOME_PAGE_TITLE = 'Home Page';
  static const int TOKEN_TIMEOUT_MINUTES = 120;
  static const String DATABASE_NAME = 'expenso.db';
  static const String APP_NAME = 'Expenso'; // This name is shown in `Recent Items` in android
  static const String IN_DATE_FORMAT = 'yyyy-MM-dd';
  static const String INVALID_SESSION_ID = 'INVALID_SESSION_ID';
  static const String INSERT = 'insert';
  static const String UPDATE = 'update';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  
  static const String LOGIN = 'login';
  static const String SYNC = 'sync';
  static const String GET = 'GET';
  static const String POST = 'POST';

  static const bool DETAIL_DEBUG = true;
  static const bool SPECIAL_DEBUG = true;
  static const bool DEBUG = true;
  
  static const String LOGIN_VIA_OTP_ENDPOINT = 'www.google.com';

  static const String DELETE_MESSAGES = 'delete_messages';
  static const String DELETE_TRANSACTIONS = 'delete_transactions';
  static const String APPROVE_MESSAGES = 'approve_messages';
  static const int CREDIT_CARD_GRACE_PERIOD = 10;
  static const List<String> DAYS_OF_WEEK_WITH_SINGLE_LETTER = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const String TASK_STATUS_NORMAL = 'Normal';

  static const List<String> VALID_DATE_RANGES = ['All', 'Today', 'Yesterday', 'Last 7 days', 'Last 30 days', 'Last 6 months', 'Last 12 months', 'Custom'];
  static const List<String> FAVORITE_DATE_RANGES = ['All', 'Today', 'Yesterday', 'Last 7 days', 'Last 30 days'];

  static const String LOGIN_PAGE_DEFAULT_MESSAGE = 'You are not logged in yet!'; // show this messsage when user is logging in for the first time
  static const String LOGIN_PAGE_OVERRIDDEN_MESSAGE = 'You have logged out successfully! You may close the app!'; // show this message when user is coming after logging out

  static const String LOGIN_PAGE_BUTTON_LOGIN_WITH_SALESFORCE = 'Login With Salesforce';
  static const String LOGIN_PAGE_BUTTON_LOGIN_WITH_GOOGLE = 'Login With Google';
  static const String LOGIN_PAGE_BUTTON_LOGIN_WITH_OTP = 'Login With OTP';
  static const String LOGIN_PAGE_IMAGE_URL = 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg';

  static const int STATUS_CODE_OK = 200;
  static const int STATUS_CODE_NOT_OK = 400;

  static const int NUMBER_OF_MESSAGES_TO_RETRIEVE = 10; //testing

  // static const String OAUTH2_CLIENT_ID = '3MVG9wt4IL4O5wvIBCa0yrhLb82rC8GGk03G2F26xbcntt9nq1JXS75mWYnnuS2rxwlghyQczUFgX4whptQeT';
  // static const String OAUTH2_CLIENT_SECRET = '3E0A6C0002E99716BD15C7C35F005FFFB716B8AA2DE28FBD49220EC238B2FFC7';
  
  static const String OAUTH2_CLIENT_ID_EXPENSO = '3MVG9k02hQhyUgQAH_sdqt1SK.UP_KJVv9NytGFYs80P8fNz8sdqnag.zaC3dDd_98BlhPqj07oielhVpx51U';
  static const String OAUTH2_CLIENT_SECRET_EXPENSO = '9217258B3C870B6DEF1CD180B59F5161400691A0896CCE60BF79C2FB34650677';

  static const String QUERY_URL = '/services/data/v59.0/query?q=';

  static const String OAUTH2_TOKEN_ENDPOINT = 'https://login.salesforce.com/services/oauth2/token';
  static const String OAUTH2_AUTH_ENDPOINT = 'https://login.salesforce.com/services/oauth2/authorize';
  static const String OAUTH2_REVOKE_ACCESS_ENDPOINT = 'https://login.salesforce.com/services/oauth2/revoke';

  // CUSTOM REST ENDPOINTS (Not Configurable)
  static const String CUSTOM_ENDPOINT_FOR_SYNC_MESSAGES = '/services/apexrest/FinPlan/api/sms/sync/*';
  static const String CUSTOM_ENDPOINT_FOR_APPROVE_MESSAGES = '/services/apexrest/FinPlan/api/sms/approve/*';
  static const String CUSTOM_ENDPOINT_FOR_DELETE_ALL_MESSAGES_AND_TRANSACTIONS = '/services/apexrest/FinPlan/api/delete/*';

  static const String CUSTOM_ENDPOINT_FOR_SMS_PE = '/services/data/v59.0/sobjects/SMS_Platform_Event__e';

  // STANDARD REST ENDPOINTS (Not Configurable)
  static const String COMPOSITE_URL_FOR_INSERT = '/services/data/v59.0/composite/tree/';
  static const String COMPOSITE_URL_FOR_UPDATE = '/services/data/v59.0/composite/sobjects/';
  static const String COMPOSITE_URL_FOR_DELETE = '/services/data/v59.0/composite/sobjects?ids=';

  // CUSTOM REST ENDPOINTS (Not Configurable)
  static const String ENDPOINT_SYNC_MESSAGES = '/services/apexrest/FinPlan/api/sms/sync/*';
  static const String ENDPOINT_APPROVE_MESSAGES = '/services/apexrest/FinPlan/api/sms/approve/*';
  static const String ENDPOINT_DEL_MESSAGES_AND_TRANSACTIONS = '/services/apexrest/FinPlan/api/delete/*';

  static const Map<String, List<dynamic>> ICON_LABEL_DATA = {
    'Aquarium' : ['Aquarium', Icons.water],
    'Bills' : ['Bills', Icons.receipt],
    'ATM Withdrawal' : ['ATM Withdrawal', Icons.auto_awesome_sharp],
    'Broker' : ['Broker', Icons.inventory_sharp],
    'Dress' : ['Dress', Icons.rotate_90_degrees_cw_sharp],
    'Entertainment' : ['Entertainment', Icons.movie_creation_outlined],
    'Food and Drinks' : ['Food and Drinks', Icons.restaurant],
    'Fuel' : ['Fuel', Icons.oil_barrel_outlined],
    'Grocery' : ['Grocery', Icons.local_grocery_store],
    'Investment' : ['Investment', Icons.inventory_2_outlined],
    'Medicine' : ['Medicine', Icons.medication_liquid],
    'Other' : ['Other', Icons.devices_other],
    'OTT' : ['OTT', Icons.tv],
    'Salary' : ['Salary', Icons.attach_money],
    'Shopping' : ['Shopping', Icons.shopping_bag_outlined],
    'Transfer' : ['Transfer', Icons.bookmark_rounded],
    'Travel' : ['Travel', Icons.travel_explore],
    'Credit' : ['Credit', Icons.arrow_downward_sharp],
    'Debit' : ['Debit', Icons.arrow_outward_outlined],
    'All' : ['All', Icons.done_all_sharp]
  };

}