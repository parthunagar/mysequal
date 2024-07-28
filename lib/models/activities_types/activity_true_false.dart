class ActivityTrueFalse {

  final bool defaultVal;
  bool answer;
  final String title;
  final String relatedGoal;
  final String iconName;

  ActivityTrueFalse(
      {
      this.defaultVal,
      this.answer,
      this.title,
      this.relatedGoal,
      this.iconName});

  factory ActivityTrueFalse.fromJson(Map<String, dynamic> parsedJson) {
    return ActivityTrueFalse(

      defaultVal: parsedJson['default_value'],
      answer: parsedJson['answer'],
      title: parsedJson['title'],
      relatedGoal: parsedJson['related_goal'],
      iconName: parsedJson['icon_name'],
    );
  }
}
