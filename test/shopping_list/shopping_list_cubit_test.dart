import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_challenge/common/models/category_with_items.dart';
import 'package:flutter_challenge/common/models/item.dart';
import 'package:flutter_challenge/common/services/categories_service.dart';
import 'package:flutter_challenge/common/services/items_service.dart';
import 'package:flutter_challenge/shopping_list/bloc/shopping_list_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCategoriesRepository extends Mock implements CategoriesService {}

class MockItemsRepository extends Mock implements ItemsService {}

void main() {
  group('Shopping list tests', () {
    MockCategoriesRepository? mockCategoriesRepository;
    MockItemsRepository? mockItemsRepository;
    ShoppingListCubit? shoppingListCubit;

    Item? item1;
    Item? item2;
    List<Item>? catOneItems;

    CategoryWithItem? oneCategory;
    CategoryWithItem? twoCategory;
    List<CategoryWithItem>? categoriesWithItems;

    setUp(() {
      item1 = Item(
          name: 'item1',
          category: 'category1',
          isFav: false,
          favDate: DateTime.now());
      item2 = Item(
          name: 'item2',
          category: 'category1',
          isFav: false,
          favDate: DateTime.now());
      catOneItems = List.of([item1!, item2!], growable: true);
      oneCategory =
          CategoryWithItem(name: 'category1', color: 1, items: catOneItems);
      twoCategory = CategoryWithItem(name: 'category2', color: 2);

      categoriesWithItems =
          List.of([oneCategory!, twoCategory!], growable: true);
      mockCategoriesRepository = MockCategoriesRepository();
      mockItemsRepository = MockItemsRepository();
      shoppingListCubit =
          ShoppingListCubit(mockCategoriesRepository!, mockItemsRepository!);
    });

    tearDown(() {
      shoppingListCubit?.close();
    });

    blocTest<ShoppingListCubit, ShoppingListState>(
      'Get Shopping List',
      setUp: () {
        when(() => mockCategoriesRepository!.getCategoriesWithItems())
            .thenAnswer((invocation) => Future.value(categoriesWithItems));
      },
      build: () => shoppingListCubit!,
      act: (cubit) {
        cubit.getShoppingList();
      },
      expect: () => [
        ShoppingListLoading(List.empty()),
        ShoppingListLoaded(categoriesWithItems!),
      ],
    );

    List<CategoryWithItem>? expectedCategoriesWithItems;
    blocTest<ShoppingListCubit, ShoppingListState>(
      'Reorder item',
      setUp: () {
        List<Item> expectedItemList = List.of([item2!, item1!], growable: true);
        CategoryWithItem copyCategory = CategoryWithItem(
            name: oneCategory!.name,
            color: oneCategory!.color,
            items: expectedItemList);
        expectedCategoriesWithItems =
            List.of([copyCategory, twoCategory!], growable: true);
      },
      build: () => shoppingListCubit!,
      seed: () => ShoppingListLoaded(categoriesWithItems!),
      act: (cubit) {
        cubit.reorderItem(oneCategory!, 0, 1, 0);
      },
      expect: () => [
        ChangeShoppingList(expectedCategoriesWithItems!),
      ],
    );

    List<CategoryWithItem>? categoryListWithCategoryOneMissingItem;
    blocTest<ShoppingListCubit, ShoppingListState>(
      'Delete item',
      build: () => shoppingListCubit!,
      setUp: () {
        List<Item> removedItemList = List.of([item1!], growable: true);
        CategoryWithItem categoryWithOneLessItem = CategoryWithItem(
            name: oneCategory!.name,
            color: oneCategory!.color,
            items: removedItemList);
        categoryListWithCategoryOneMissingItem =
            List.of([categoryWithOneLessItem, twoCategory!], growable: true);
        when(() => mockItemsRepository!.deleteItem(item2!.name))
            .thenAnswer((invocation) => Future.value());
      },
      seed: () => ShoppingListLoaded(categoriesWithItems!),
      act: (cubit) {
        cubit.deleteItem(0, 1);
      },
      expect: () => [
        ChangeShoppingList(categoryListWithCategoryOneMissingItem!),
      ],
    );

  });
}
