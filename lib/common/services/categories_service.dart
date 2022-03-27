import 'package:cloud_firestore/cloud_firestore.dart';
import '../../create_category/exceptions/already_exists_category_exception.dart';
import '../models/category.dart';

class CategoriesService {

  Future<void> createCategory(String name, int color) async {
    CollectionReference categoryCollection =
    FirebaseFirestore.instance.collection('category').withConverter<Category>(
      fromFirestore: (snapshot, _) =>
          Category.fromSnapshot(snapshot.data()!),
      toFirestore: (category, _) => category.toJson(),
    );

    final categoryDoc = await categoryCollection
        .where('name', isEqualTo: name)
        .get()
        .then((snapshot) => snapshot.docs);

    if (categoryDoc.isEmpty) {
      await categoryCollection
          .add(Category(name: name, color: color));
    }else{
      throw const AlreadyExistsCategoryException();
    }
  }

  Future<List<Category>> getAllCategories() async {
    final categoryCollection =
    FirebaseFirestore.instance.collection('category')
        .withConverter<Category>(
      fromFirestore: (snapshot, _) =>
          Category.fromSnapshot(snapshot.data()!),
      toFirestore: (category, _) => category.toJson(),
    );

    List<QueryDocumentSnapshot<Category>> documentSnapshots = await categoryCollection.get().then((snapshot) => snapshot.docs);

    List<Category> categories = documentSnapshots.map((doc) => doc.data()).toList();

    return categories;
  }
}