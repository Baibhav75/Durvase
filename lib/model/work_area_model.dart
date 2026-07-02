// work_area_model.dart
class WorkAreaModel {
  final String block;
  final String district;
  final String state;

  WorkAreaModel({
    required this.block,
    required this.district,
    required this.state,
  });

  factory WorkAreaModel.fromJson(Map<String, dynamic> json) {
    // Handle null values and convert to string
    String getStringValue(dynamic value) {
      if (value == null) return 'N/A';
      final str = value.toString();
      return str.isEmpty ? 'N/A' : str;
    }

    // Extract values with multiple possible key names
    String block = 'N/A';
    String district = 'N/A';
    String state = 'N/A';

    // Try to find block value
    for (var key in ['BlockName', 'blockName', 'Block', 'block', 'BLOCK']) {
      if (json.containsKey(key) && json[key] != null) {
        block = getStringValue(json[key]);
        break;
      }
    }

    // Try to find district value
    for (var key in ['District', 'district', 'DISTRICT']) {
      if (json.containsKey(key) && json[key] != null) {
        district = getStringValue(json[key]);
        break;
      }
    }

    // Try to find state value
    for (var key in ['State', 'state', 'STATE']) {
      if (json.containsKey(key) && json[key] != null) {
        state = getStringValue(json[key]);
        break;
      }
    }

    return WorkAreaModel(block: block, district: district, state: state);
  }

  Map<String, dynamic> toJson() {
    return {'Block': block, 'District': district, 'State': state};
  }

  @override
  String toString() {
    return 'WorkAreaModel(Block: $block, District: $district, State: $state)';
  }
}
