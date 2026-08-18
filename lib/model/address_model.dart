class AddressModel {
  final String id;
  final String type;
  final String name;
  final String mobile;
  final String address;
  final String city;
  final String state;
  final String pincode;
  bool isSelected;

  AddressModel({
    required this.id,
    required this.type,
    required this.name,
    required this.mobile,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.isSelected = false,
  });
}