import 'package:equatable/equatable.dart';

import 'item.dart';

class CategoryWithItem extends Equatable {
  final String name;
  final int? color;
  late List<Item>? items;

  CategoryWithItem({required this.name, this.color, this.items});

  Map<String, dynamic> toJson() => {'name': name, 'color': color};

  static CategoryWithItem fromSnapshot(Map<String, dynamic> snapshot) {
    return CategoryWithItem(name: snapshot['name'], color: snapshot['color']);
  }

  @override
  List<Object?> get props => [name, color, items];
}
