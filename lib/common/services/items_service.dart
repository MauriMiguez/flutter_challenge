import 'package:cloud_firestore/cloud_firestore.dart';

import '../../create_item/exceptions/already_exists_item_exception.dart';
import '../models/item.dart';

class ItemsService {

  Future<void> createItem(String name, String? imageUrl, String category) async {
    CollectionReference itemCollection =
    FirebaseFirestore.instance.collection('items').withConverter<Item>(
      fromFirestore: (snapshot, _) =>
          Item.fromSnapshot(snapshot.id, snapshot.data()!),
      toFirestore: (item, _) => item.toJson(),
    );

    final itemDoc = await itemCollection
        .where('name', isEqualTo: name)
        .get()
        .then((snapshot) => snapshot.docs);

    if (itemDoc.isEmpty) {
      await itemCollection
          .add(Item(name: name, imageUrl: imageUrl, category: category, isFav: false, favDate: DateTime.now()));
    }else{
      throw const AlreadyExistsItemException();
    }
  }
}