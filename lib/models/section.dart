class SectionModel {
  final String id;
  final String name;
  final int number;

  SectionModel.fromJson(Map data)
      : id = data['_id'],
        name = data['name'],
        number = data['number'];
}
