class MemeModel {
  final String url, name;
  final int id, width, height, boxCount;

  MemeModel({
    this.id,
    this.name,
    this.url,
    this.width,
    this.height,
    this.boxCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'name': name,
      'width': width,
      'height': height,
      'box_count': boxCount,
    };
  }
}
