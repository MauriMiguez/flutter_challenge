
class Item {
  final String name;
  final String? imageUrl;
  final String category;
  bool isFav;
  DateTime favDate;

  Item({
    required this.name,
    this.imageUrl,
    required this.category,
    required this.isFav,
    required this.favDate
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'imageUrl': imageUrl,
    'category': category,
    'isFav': isFav,
    'favDate': favDate
  };

  static Item fromSnapshot(String id, Map<String, dynamic> snapshot) => Item(
    name: snapshot['name'],
    imageUrl: snapshot['imageUrl'],
    category: snapshot['category'],
    isFav: snapshot['isFav'],
      favDate: snapshot['favDate'].toDate()
  );
}
