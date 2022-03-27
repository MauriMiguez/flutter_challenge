import 'package:cloud_firestore/cloud_firestore.dart';
import '../../create_category/exceptions/already_exists_category_exception.dart';
import '../models/category.dart';
import '../models/category_with_items.dart';
import 'items_service.dart';

class CategoriesService {
  Future<void> createCategory(String name, int color) async {
    CollectionReference categoryCollection = FirebaseFirestore.instance
        .collection('category')
        .withConverter<Category>(
          fromFirestore: (snapshot, _) =>
              Category.fromSnapshot(snapshot.data()!),
          toFirestore: (category, _) => category.toJson(),
        );

    final categoryDoc = await categoryCollection
        .where('name', isEqualTo: name)
        .get()
        .then((snapshot) => snapshot.docs);

    if (categoryDoc.isEmpty) {
      await categoryCollection.add(Category(name: name, color: color));
    } else {
      throw const AlreadyExistsCategoryException();
    }
  }

  Future<List<Category>> getAllCategories() async {
    final categoryCollection = FirebaseFirestore.instance
        .collection('category')
        .withConverter<Category>(
          fromFirestore: (snapshot, _) =>
              Category.fromSnapshot(snapshot.data()!),
          toFirestore: (category, _) => category.toJson(),
        );

    List<QueryDocumentSnapshot<Category>> documentSnapshots =
        await categoryCollection.get().then((snapshot) => snapshot.docs);

    List<Category> categories =
        documentSnapshots.map((doc) => doc.data()).toList();

    return categories;
  }

  Future<List<CategoryWithItem>> getCategoriesWithItems() async {
    final categoryCollection = FirebaseFirestore.instance
        .collection('category')
        .withConverter<CategoryWithItem>(
          fromFirestore: (snapshot, _) =>
              CategoryWithItem.fromSnapshot(snapshot.data()!),
          toFirestore: (category, _) => category.toJson(),
        );

    List<QueryDocumentSnapshot<CategoryWithItem>> documentSnapshots =
        await categoryCollection.get().then((snapshot) => snapshot.docs);

    List<CategoryWithItem> categories =
        documentSnapshots.map((doc) => doc.data()).toList();

    List<CategoryWithItem> categoriesWithItems = List.empty(growable: true);
    for (var element in categories) {
      var items = await ItemsService().getItemsFromCategory(element.name);
      var newCategory = CategoryWithItem(
          name: element.name, color: element.color, items: items);
      categoriesWithItems.add(newCategory);
    }

    return categoriesWithItems;
  }

  Future<void> deleteCategory(String name) async {
    await ItemsService().deleteAllCategoryItems(name);

    final categoryCollection = FirebaseFirestore.instance
        .collection('category')
        .withConverter<CategoryWithItem>(
          fromFirestore: (snapshot, _) =>
              CategoryWithItem.fromSnapshot(snapshot.data()!),
          toFirestore: (category, _) => category.toJson(),
        );

    final querySnapshot =
        await categoryCollection.where('name', isEqualTo: name).get();
    if (querySnapshot.docs.first.exists) {
      String categoryId = querySnapshot.docs.first.id;

      await categoryCollection.doc(categoryId).delete();
    }
  }

  Future<List<CategoryWithItem>> getCategoriesWithFavoriteItems() async {
    final categoryCollection = FirebaseFirestore.instance
        .collection('category')
        .withConverter<CategoryWithItem>(
      fromFirestore: (snapshot, _) =>
          CategoryWithItem.fromSnapshot(snapshot.data()!),
      toFirestore: (category, _) => category.toJson(),
    );

    List<QueryDocumentSnapshot<CategoryWithItem>> documentSnapshots =
    await categoryCollection.get().then((snapshot) => snapshot.docs);

    List<CategoryWithItem> categories =
    documentSnapshots.map((doc) => doc.data()).toList();

    List<CategoryWithItem> categoriesWithItems = List.empty(growable: true);
    for (var element in categories) {
      var items = await ItemsService().getFavoriteItemsFromCategory(element.name);
      if(items.isNotEmpty){
        var newCategory = CategoryWithItem(
            name: element.name, color: element.color, items: items);
        categoriesWithItems.add(newCategory);
      }
    }

    return categoriesWithItems;
  }

}
