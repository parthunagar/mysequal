class AppSettings {
  String appDirection;

  Map<String, dynamic> toJson() => {
        'appDirection': appDirection,
      };

  AppSettings.fromJson(Map<String, dynamic> json)
      : appDirection = json['appDirection'];
}
