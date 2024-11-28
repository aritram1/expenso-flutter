// ignore_for_file: constant_identifier_names
import 'package:expenso/helper/salesforce_query_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AccountUtil {

  static Logger log = Logger();
  static bool debug = bool.parse(dotenv.env['debug'] ?? 'false');
  static bool detaildebug = bool.parse(dotenv.env['detaildebug'] ?? 'false');
  
  // A function to get the list of tasks
  static Future<List<Map<String, dynamic>>> getAllAccountsData() async {
    List<Map<String, dynamic>> allAccounts = [];

    Map<String, dynamic> response = await SalesforceQueryController.queryFromSalesforce(
      objAPIName: 'FinPlan__Bank_Account__c',
      fieldList: ['Id', 'FinPlan__CC_Last_Paid_Amount__c', 'FinPlan__Account_Code__c', 'Name', 'FinPlan__CC_Billing_Cycle_Date__c', 'FinPlan__CC_Last_Bill_Paid_Date__c', 'FinPlan__Last_Balance__c', 'FinPlan__CC_Available_Limit__c', 'FinPlan__CC_Max_Limit__c','FinPlan__Bill_Due_Date__c', 'LastModifiedDate'], 
      whereClause: 'FinPlan__Active__c = true',
      orderByClause: 'LastModifiedDate desc',
      //count : 120
      );
    dynamic error = response['error'];
    dynamic data = response['data'];

    if(debug) log.d('Error inside generatedDataForExpenseScreen2v2 : ${error.toString()}');
    if(debug) log.d('Datainside generatedDataForExpenseScreen2v2: ${data.toString()}');
    
    if(error != null && error.isNotEmpty){
      if(debug) log.d('Error occurred while querying inside getAllAccountsData : ${response['error']}');
      //return null;
    }
    else if (data != null && data.isNotEmpty) {
      try{
        dynamic records = data['data'];
        if(detaildebug) log.d('Inside getAllAccountsData Records=> $records');
        if(records != null && records.isNotEmpty){
          for (var record in records) {
            Map<String, dynamic> recordMap = Map.castFrom(record);
            allAccounts.add(recordMap);
          }
        }
      }
      catch(error){
        if(debug) log.e('Error Inside getAllAccountsData : $error');
      }
    }
    if(debug) log.d('Inside getAllAccountsData=>$allAccounts');
    return allAccounts;
  }

}