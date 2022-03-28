part of 'favorite_list_cubit.dart';

abstract class FavoriteListState extends Equatable {
  List<CategoryWithItem> favoriteList = List.empty();

  @override
  List<Object?> get props => [favoriteList];
}

class RemovedItemFromFavorite extends FavoriteListState {
  final String item;

  RemovedItemFromFavorite(
      {required this.item, favoriteList = List<CategoryWithItem>}) {
    this.favoriteList = favoriteList;
  }

  @override
  List<Object?> get props => [item, favoriteList];
}

class FavoriteListInitial extends FavoriteListState {
  FavoriteListInitial() {}
}

class FavoriteListReorder extends FavoriteListState {
  FavoriteListReorder(List<CategoryWithItem> favoriteList) {
    this.favoriteList = favoriteList;
  }
}

class FavoriteListLoading extends FavoriteListState {
  FavoriteListLoading(List<CategoryWithItem> favoriteList) {
    this.favoriteList = favoriteList;
  }
}

class FavoriteListLoaded extends FavoriteListState {
  FavoriteListLoaded(List<CategoryWithItem> favoriteList) {
    this.favoriteList = favoriteList;
  }
}
