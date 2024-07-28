
class GoalJournalActivity {
  final String id;
  final int defaultVal;
  final String iconUrl;
  final int maxValue;
  final int minValue;
  final String name;
  final String type;
  List<Map<String,dynamic>> relatedGoals;
  int value;

  GoalJournalActivity(

      {
        this.id,
        this.defaultVal,
      this.iconUrl,
      this.maxValue,
      this.minValue,
      this.name,
      this.type,
      this.value
      });

  factory GoalJournalActivity.fromJson(Map<String, dynamic> parsedJson) {
    return GoalJournalActivity(
      defaultVal: parsedJson['defaultValue'],
      iconUrl: parsedJson['iconUrl'],
      maxValue: parsedJson['maxValue'],
      minValue: parsedJson['minValue'],
      name: parsedJson['name'],
      type: parsedJson['type'],
      value: parsedJson['value'],
      id: parsedJson['id'] ,
    );
  }
    Map<String, dynamic> toJson() =>
    {
      'defaultValue': defaultVal,
      'iconUrl': iconUrl,
      'maxValue': maxValue,
      'minValue': minValue,
      'name': name,
      'type': type,
      'value': value,
    };

}