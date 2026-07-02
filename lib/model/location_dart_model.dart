class LocationDataModel {
  List<LocationItem>? states;
  String? message;

  LocationDataModel({this.states, this.message});

  LocationDataModel.fromJson(Map<String, dynamic> json) {
    if (json['states'] != null) {
      states = <LocationItem>[];
      json['states'].forEach((v) {
        states!.add(LocationItem.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (states != null) {
      data['states'] = states!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class LocationItem {
  int? id;
  String? name;
  List<LocationItem>? districts;
  List<LocationItem>? blocks;

  LocationItem({this.id, this.name, this.districts, this.blocks});

  LocationItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['districts'] != null) {
      districts = <LocationItem>[];
      json['districts'].forEach((v) {
        districts!.add(LocationItem.fromJson(v));
      });
    }
    if (json['blocks'] != null) {
      blocks = <LocationItem>[];
      json['blocks'].forEach((v) {
        blocks!.add(LocationItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (districts != null) {
      data['districts'] = districts!.map((v) => v.toJson()).toList();
    }
    if (blocks != null) {
      data['blocks'] = blocks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
