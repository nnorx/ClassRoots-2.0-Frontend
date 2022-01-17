class UniversityModel {
  bool deleted;
  String id;
  String name;
  String code;
  String address;
  String city;
  String state;
  String country;
  String postalCode;
  String createdBy;
  DateTime updated;
  DateTime created;

  UniversityModel.fromJson(Map data) {
    this.deleted = data['deleted'];
    this.id = data['_id'];
    this.name = data['name'];
    this.code = data['code'];
    this.address = data['address'];
    this.city = data['city'];
    this.state = data['state'];
    this.country = data['country'];
    this.postalCode = data['postalCode'];
    this.createdBy = data['createdBy'];
    this.updated = DateTime.fromMillisecondsSinceEpoch(data['updated']);
    this.created = DateTime.fromMillisecondsSinceEpoch(data['created']);
  }
}
