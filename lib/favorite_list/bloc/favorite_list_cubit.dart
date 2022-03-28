import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/common/services/categories_service.dart';
import 'package:flutter_challenge/common/services/items_service.dart';

import '../../common/models/category_with_items.dart';
import '../../common/models/item.dart';

part 'favorite_list_state.dart';

class FavoriteListCubit extends Cubit<FavoriteListState> {
  final CategoriesService _categoriesService;
  final ItemsService _itemsService;

  FavoriteListCubit(this._categoriesService, this._itemsService) : super(FavoriteListInitial());

  Future<void> getFavoriteList() async {
    emit(FavoriteListLoading(state.favoriteList));
    List<CategoryWithItem> favoriteList = await _categoriesService.getCategoriesWithFavoriteItems();
    emit(FavoriteListLoaded(favoriteList));
  }

  Future<void> unFavItem(int categoryIndex, int itemIndex) async {
    List<CategoryWithItem> favoriteList = state.favoriteList;
    var category = favoriteList[categoryIndex];
    Item item = category.items!.removeAt(itemIndex);
    if(category.items!.isEmpty){
      favoriteList.removeAt(categoryIndex);
    }
    await _itemsService.unFavItem(item.name);
    emit(RemovedItemFromFavorite(favoriteList: favoriteList, item: item.name));
  }

  void reorderItem(CategoryWithItem category, int categoryIndex, int itemOldIndex, int itemNewIndex) {
    final index = itemNewIndex > itemOldIndex ? itemNewIndex - 1 : itemNewIndex;
    final item = category.items!.removeAt(itemOldIndex);
    category.items!.insert(index, item);

    List<CategoryWithItem> favoriteList = state.favoriteList;
    favoriteList.replaceRange(categoryIndex,categoryIndex+1,[category]);

    emit(FavoriteListReorder(favoriteList));

  }
}