import 'package:cloud_firestore/cloud_firestore.dart';

import '../../create_item/exceptions/already_exists_item_exception.dart';
import '../models/item.dart';

class ItemsService {
  Future<void> createItem(
      String name, String? imageUrl, String category) async {
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
      await itemCollection.add(Item(
          name: name,
          imageUrl: imageUrl,
          category: category,
          isFav: false,
          favDate: DateTime.now()));
    } else {
      throw const AlreadyExistsItemException();
    }
  }

  Future<List<Item>> getItemsFromCategory(String category) async {
    final itemCollection =
        FirebaseFirestore.instance.collection('items').withConverter<Item>(
              fromFirestore: (snapshot, _) =>
                  Item.fromSnapshot(snapshot.id, snapshot.data()!),
              toFirestore: (item, _) => item.toJson(),
            );

    List<QueryDocumentSnapshot<Item>> documentSnapshots = await itemCollection
        .where('category', isEqualTo: category)
        .get()
        .then((snapshot) => snapshot.docs);

    List<Item> items = documentSnapshots.map((doc) => doc.data()).toList();
    return items;
  }

  Future<void> favItem(String name) async {
    final itemCollection =
        FirebaseFirestore.instance.collection('items').withConverter<Item>(
              fromFirestore: (snapshot, _) =>
                  Item.fromSnapshot(snapshot.id, snapshot.data()!),
              toFirestore: (item, _) => item.toJson(),
            );
    final querySnapshot =
        await itemCollection.where('name', isEqualTo: name).get();

    if (querySnapshot.docs.first.exists) {
      String itemId = querySnapshot.docs.first.id;

      await itemCollection
          .doc(itemId)
          .update({'isFav': true, 'favDate': DateTime.now()});
    }
  }

  Future<void> deleteItem(String name) async {
    final itemCollection =
        FirebaseFirestore.instance.collection('items').withConverter<Item>(
              fromFirestore: (snapshot, _) =>
                  Item.fromSnapshot(snapshot.id, snapshot.data()!),
              toFirestore: (item, _) => item.toJson(),
            );

    final querySnapshot =
        await itemCollection.where('name', isEqualTo: name).get();
    if (querySnapshot.docs.first.exists) {
      String itemId = querySnapshot.docs.first.id;

      await itemCollection.doc(itemId).delete();
    }
  }

  Future<void> deleteAllCategoryItems(String name) async {
    final itemCollection =
        FirebaseFirestore.instance.collection('items').withConverter<Item>(
              fromFirestore: (snapshot, _) =>
                  Item.fromSnapshot(snapshot.id, snapshot.data()!),
              toFirestore: (item, _) => item.toJson(),
            );

    WriteBatch batch = FirebaseFirestore.instance.batch();

    var allCategoryItemsSnapshots =
        await itemCollection.where('category', isEqualTo: name).get();
    allCategoryItemsSnapshots.docs.forEach((document) {
      batch.delete(document.reference);
    });

    return await batch.commit();
  }
}
