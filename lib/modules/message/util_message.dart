// ignore_for_file: constant_identifier_names
import 'package:device_info/device_info.dart';
import 'package:finmind/helper/app_constants.dart';
import 'package:finmind/helper/app_sms_manager.dart';
import 'package:finmind/helper/salesforce_custom_rest_controller.dart';
import 'package:finmind/helper/salesforce_dml_controller.dart';
import 'package:finmind/helper/salesforce_query_controller.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MessagesUtil {

  static Logger log = Logger();
  static bool debug = AppConstants.DEBUG;
  static bool detaildebug = AppConstants.DETAIL_DEBUG;

  // A function to get the list of tasks
  static Future<List<Map<String, dynamic>>> getAllTransactionMessages({required DateTime startDate, required DateTime endDate}) async {
    
    if(debug) log.d('getAllTransactionMessages : StartDate is $startDate, endDate is $endDate');
    
    // Format the dates accordingly
    String formattedStartDateTime = DateFormat(AppConstants.IN_DATE_FORMAT).format(startDate);   // startDate.toUTC() is not required since startDate is already in UTC
    String formattedEndDateTime = DateFormat(AppConstants.IN_DATE_FORMAT).format(endDate);       // endDate.toUTC() is not required since endDate is already in UTC
    
    // Create the date clause to use in query later
    String dateClause = 'AND FinPlan__Transaction_Date__c >= $formattedStartDateTime AND FinPlan__Transaction_Date__c <= $formattedEndDateTime';
    if(debug) log.d('StartDate is $startDate, endDate is $endDate and dateClause is=> $dateClause');

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String deviceId = "'${androidInfo.model}'";
    
    List<Map<String, dynamic>> allTransactionMessages = [];
    Map<String, dynamic> response = await SalesforceQueryController.queryFromSalesforce(
      objAPIName: 'FinPlan__SMS_Message__c', 
      fieldList: ['Id', 'CreatedDate', 'FinPlan__Transaction_Date__c', 'FinPlan__Beneficiary__c', 
                  'FinPlan__Amount_Value__c', 'FinPlan__Beneficiary_Type__c', 'FinPlan__Device__c',
                  'FinPlan__Approved__c', 'FinPlan__Create_Transaction__c', 'FinPlan__Type__c'], 
      whereClause: 'FinPlan__Device__c = $deviceId AND FinPlan__Approved__c = false AND FinPlan__Create_Transaction__c = true $dateClause',
      orderByClause: 'FinPlan__Transaction_Date__c desc',
      //count : 120
    );
    dynamic error = response['error'];
    dynamic data = response['data'];

    if(debug) log.d('Error inside getAllTransactionMessages : ${error.toString()}');
    if(debug) log.d('Data inside getAllTransactionMessages : ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside getAllTransactionMessages : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        if(detaildebug) log.d('Inside getAllTransactionMessages Data where data is not empty');
        dynamic records = data['data'];
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            allTransactionMessages.add({
              'Paid To': recordMap['FinPlan__Beneficiary__c'] ?? 'Default Beneficiary',
              'Amount': double.parse(recordMap['FinPlan__Amount_Value__c'] ?? '0'),
              'Date': DateTime.parse(recordMap['FinPlan__Transaction_Date__c'] ?? DateTime.now().toString()),
              'Id': recordMap['Id'] ?? 'Default Id',
              'BeneficiaryType': recordMap['FinPlan__Beneficiary_Type__c'] ?? '',
              'Type' : recordMap['FinPlan__Type__c'] ?? 'noType'
            });
          }
        }
      }
      catch(error, stacktrace){
        if(debug) log.e('Error Inside generateTagenerateDataForExpenseScreen0b1Data : ${error.toString()}, stacktrace : ${stacktrace.toString()}');
      }
    }
    if(detaildebug) log.d('Inside generateDataForExpenseScreen0=>$allTransactionMessages');
    return Future.value(allTransactionMessages); 
  }

  // Method to sync messages
  static Future<Map<String, dynamic>> syncMessages() async{

    String deviceId = await getDeviceId();

    // Call the specific API to delete all messages and transactions
    String mesageAndTransactionsDeleteMessage = await hardDeleteMessagesAndTransactions(deviceId);
    if(detaildebug) log.d('mesageAndTransactionsDeleteMessage is -> $mesageAndTransactionsDeleteMessage');
    
    // Then retrieve, convert and call the insert API for inserting messages
    List<SmsMessage> txnMessages = await SMSManager.getTransactionalMessages(count : AppConstants.NUMBER_OF_MESSAGES_TO_RETRIEVE);
    List<Map<String, dynamic>> txnMessagesAsKeyValuePairs = await SMSManager.convertMessagesToMap(txnMessages);
    log.d('txnMessagesAsKeyValuePairs length=> ${txnMessagesAsKeyValuePairs.length}');
    log.d('txnMessagesAsKeyValuePairs=> $txnMessagesAsKeyValuePairs');
    Map<String, dynamic> createResponse = await SalesforceDMLController.dmlToSalesforce(
        opType: AppConstants.INSERT,
        objAPIName : 'FinPlan__SMS_Message__c', 
        fieldNameValuePairs : txnMessagesAsKeyValuePairs
    );

    if(detaildebug) log.d('syncMessages response Data => ${createResponse['data'].toString()}');
    if(detaildebug) log.d('syncMessages response Errors => ${createResponse['errors'].toString()}');

    return createResponse;
  }

  static Future<String> hardDeleteMessagesAndTransactions(String deviceId) async{
    // Call the specific API to delete all messages and transactions
    String mesageAndTransactionsDeleteMessage = await SalesforceCustomRestController.callSalesforceAPI(
        httpMethod: AppConstants.POST, 
        endpointUrl: AppConstants.ENDPOINT_DEL_MESSAGES_AND_TRANSACTIONS, 
        body: {'deviceId' : deviceId});
    if(detaildebug) log.d('mesageAndTransactionsDeleteMessage is -> $mesageAndTransactionsDeleteMessage');
    
    return mesageAndTransactionsDeleteMessage;
  }

  static Future<String> getDeviceId() async {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    String deviceId = androidInfo.model;
    return deviceId;
  }

}