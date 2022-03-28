part of 'shopping_list_cubit.dart';

abstract class ShoppingListState extends Equatable{
  List<CategoryWithItem> shoppingList = List.empty();

  @override
  List<Object?> get props => [shoppingList];
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
  @override
  List<Object?> get props => [shoppingList, item];
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