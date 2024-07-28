class PelotonMessage {
  String id;
  String title;
  String description;
  String type;
  CallToAction callToAction;
  String url;
  NotificationSender sender;

  PelotonMessage({
    this.title,
    this.description,
    this.type,
    this.callToAction,
    this.url,
    this.sender
  });

  factory PelotonMessage.fromJson(Map<String, dynamic> parsedJson) {
    return PelotonMessage(
      title: parsedJson['title'],
      description: parsedJson['description'],
      type: parsedJson['type'],
      callToAction: parsedJson['call_to_action'] != null ? CallToAction.fromJson(parsedJson['call_to_action']) : null,
      url: parsedJson['url'],
      sender: NotificationSender.fromJson(parsedJson['sender']),
    );
  }
}
class CallToAction {
  String action;
  String actionId;

  CallToAction({
    this.action,
    this.actionId,
  });

  factory CallToAction.fromJson(Map<String, dynamic> parsedJson) {
    return CallToAction(
      action: parsedJson['action'],
      actionId: parsedJson['action_id'],
    );
  }
}
class NotificationSender {
  String name;
  List<dynamic> role;
  String profileImage;

  NotificationSender({
    this.name,
    this.role,
    this.profileImage,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> parsedJson) {
    return NotificationSender(
      name: parsedJson['name'],
      role: parsedJson['role'],
      profileImage: parsedJson['profile_image'],
    );
  }
}