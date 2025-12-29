  class ChannelModel{
    int id;
    String name;

    ChannelModel({
      required this.id,
      required this.name,
  });

    factory ChannelModel.fromJson(Map<String, dynamic> json){
      return ChannelModel(
          id: json["id"],
          name: json["name"],
      );
    }
  }