part of 'shopping_list_cubit.dart';

abstract class ShoppingListState {
  List<CategoryWithItem> shoppingList = List.empty();
}

class ChangeShoppingList extends ShoppingListState {
  ChangeShoppingList(List<CategoryWithItem> shoppingList){
    this.shoppingList = shoppingList;
  }
}

class ItemSavedAsFavorite extends ShoppingListState {
  final String item;
  ItemSavedAsFavorite({required this.item, shoppingList = List<CategoryWithItem>}){
    this.shoppingList = shoppingList;
  }
}

class ShoppingListInitial extends ShoppingListState {
  ShoppingListInitial(){}
}

class ShoppingListLoading extends ShoppingListState {
  ShoppingListLoading(List<CategoryWithItem> shoppingList){
    this.shoppingList = shoppingList;
  }
}

class ShoppingListLoaded extends ShoppingListState {
  ShoppingListLoaded(List<CategoryWithItem> shoppingList){
    this.shoppingList = shoppingList;
  }
}