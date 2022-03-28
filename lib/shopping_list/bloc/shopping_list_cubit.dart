import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/models/item.dart';
import '../../common/services/categories_service.dart';
import '../../common/services/items_service.dart';
import '../../common/models/category_with_items.dart';

part 'shopping_list_state.dart';

class ShoppingListCubit extends Cubit<ShoppingListState>{
  final CategoriesService _categoriesService;
  final ItemsService _itemsService;

  ShoppingListCubit(this._categoriesService, this._itemsService) : super(ShoppingListInitial()) ;

  Future<void> getShoppingList() async {
    emit(ShoppingListLoading(state.shoppingList));
    List<CategoryWithItem> shoppingList = await _categoriesService.getCategoriesWithItems();
    emit(ShoppingListLoaded(shoppingList));
  }

  void reorderItem(CategoryWithItem category, int categoryIndex, int itemOldIndex, int itemNewIndex) {
    final index = itemNewIndex > itemOldIndex ? itemNewIndex - 1 : itemNewIndex;
    final item = category.items!.removeAt(itemOldIndex);
    category.items!.insert(index, item);

    List<CategoryWithItem> shoppingList = state.shoppingList;
    shoppingList.replaceRange(categoryIndex,categoryIndex+1,[category]);

    emit(ChangeShoppingList(shoppingList));

  }

  Future<void> deleteItem(int categoryIndex, int itemIndex) async {
    List<CategoryWithItem> shoppingList = state.shoppingList;
    var category = shoppingList[categoryIndex];
    Item item = category.items!.removeAt(itemIndex);
    shoppingList.replaceRange(categoryIndex,categoryIndex+1,[category]);
    await _itemsService.deleteItem(item.name);
    emit(ChangeShoppingList(shoppingList));
  }

  Future<void> favItem(int categoryIndex, int itemIndex) async {
    List<CategoryWithItem> shoppingList = state.shoppingList;
    var category = shoppingList[categoryIndex];
    Item item = category.items![itemIndex];
    item.isFav = true;
    await _itemsService.favItem(item.name);
    emit(ItemSavedAsFavorite(shoppingList: shoppingList, item: item.name));
  }


  Future<void> deleteCategory(int categoryIndex) async {
    List<CategoryWithItem> shoppingList = state.shoppingList;
    var category = shoppingList.removeAt(categoryIndex);
    await _categoriesService.deleteCategory(category.name);
    emit(ChangeShoppingList(shoppingList));
  }

  Future<void> search(String searchText) async {
    List<CategoryWithItem> shoppingList = await _categoriesService.getCategoriesWithItems();
    String loweCaseSearch = searchText.toLowerCase();
    int i = 0;
    while(i < shoppingList.length){
      CategoryWithItem category = shoppingList[i];

      String lowerCaseCategoryName = category.name.toLowerCase();
      bool containsItemSearched = false;
      bool categoryMatch = lowerCaseCategoryName.contains(loweCaseSearch);

      if(!categoryMatch){
        if(category.items != null){
          int j = 0;
          while(j < category.items!.length){
            Item item = category.items![j];
            String lowerCaseItemName = item.name.toLowerCase();

            if(!lowerCaseItemName.contains(loweCaseSearch)) {
              category.items!.removeAt(j);
            }else{
              containsItemSearched = true;
              j++;
            }
          }
        }
      }
      if(!lowerCaseCategoryName.contains(loweCaseSearch) && !containsItemSearched){
        shoppingList.removeAt(i);
      }else{
        i++;
      }
    }

    emit(ChangeShoppingList(shoppingList));
  }

}