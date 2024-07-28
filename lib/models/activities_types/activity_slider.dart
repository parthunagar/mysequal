class ActivitySlider {
  final double minVal;
  final double maxVal;
  final double defaultVal;
  double answer;
  final String title;
  final String relatedGoal;
  final String iconName;

  ActivitySlider(
      {this.minVal,
      this.maxVal,
      this.defaultVal,
      this.answer,
      this.title,
      this.relatedGoal,
      this.iconName});

  factory ActivitySlider.fromJson(Map<String, dynamic> parsedJson) {
    return ActivitySlider(
      minVal: parsedJson['min_value'],
      maxVal: parsedJson['max_value'],
      defaultVal: parsedJson['default_value'],
      answer: parsedJson['answer'],
      title: parsedJson['title'],
      relatedGoal: parsedJson['related_goal'],
      iconName: parsedJson['icon_name'],
    );
  }
}
