// The model class to represent an sms

class SMS{

  String id;
  String sender;
  String detail;
  DateTime when;

  SMS({
    required this.sender, 
    required this.detail,
    required this.when
  }): id = 'SMS${when.toString()}';

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'sender' : sender,
      'when' : when.toString(),
      'details' : detail,
    };
  }
}
