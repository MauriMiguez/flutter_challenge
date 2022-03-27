
class Category {
  final String name;
  final int? color;

  const Category({
    required this.name,
     this.color
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color
  };

  static Category fromSnapshot(Map<String, dynamic> snapshot) {
    return Category(
      name: snapshot['name'],
      color: snapshot['color']
    );
  }
}
