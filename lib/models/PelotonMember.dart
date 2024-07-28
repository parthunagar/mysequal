class PelotonMember {
  
  final String name;
  final String imageUrl;

  PelotonMember({
    
    this.name,
    this.imageUrl,
  });

  factory PelotonMember.fromJson(Map<String, dynamic> parsedJson) {
    return PelotonMember(
      
      name: parsedJson != null ? parsedJson['name'] : '',
      imageUrl: parsedJson != null ?  parsedJson['profile_image'] : '',
    );
  }
}
