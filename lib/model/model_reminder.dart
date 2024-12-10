// The model class to represent any reminder

class Reminder{

  String id;
  String name;
  DateTime when;

  Reminder(this.name, this.when): id = 'REM${when.toString()}';

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'name' : name,
      'when' : when.toString(),
    };
  }
}
