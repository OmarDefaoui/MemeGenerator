class MemeModel {
  final String  url, name;
  final int id;

  MemeModel({
    this.id,
    this.name,
    this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'name': name,
    };
  }
}
