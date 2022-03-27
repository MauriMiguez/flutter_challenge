import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/common/services/categories_service.dart';
import 'package:flutter_challenge/common/services/items_service.dart';
import '../common/models/category_with_items.dart';
import '../common/models/item.dart';
import 'bloc/favorite_list_cubit.dart';
import 'package:intl/intl.dart';

class FavoriteList extends StatelessWidget {
  const FavoriteList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            FavoriteListCubit(CategoriesService(), ItemsService())
              ..getFavoriteList(),
        child: Builder(builder: (context) {
          return BlocConsumer<FavoriteListCubit, FavoriteListState>(
              listener: (context, state) {
            if (state is RemovedItemFromFavorite) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.item + " item removed from favorites!"),
                duration: const Duration(seconds: 2),
              ));
            }
          }, builder: (context, state) {
            final favoriteListCubit =
                BlocProvider.of<FavoriteListCubit>(context);
            if (state is FavoriteListInitial) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is FavoriteListLoading) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is FavoriteListLoaded ||
                state is RemovedItemFromFavorite ||
                state is FavoriteListReorder) {
              if (state.favoriteList.isEmpty) {
                return _emptyScreenText();
              } else {
                return _buildCategoriesAndItems(
                    state.favoriteList, favoriteListCubit);
              }
            }
            return Container();
          });
        }));
  }

  Widget _buildCategoriesAndItems(List<CategoryWithItem> categoriesAndItems,
      FavoriteListCubit favoriteListCubit) {
    return Column(
      children: [
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            //physics: BouncingScrollPhysics(),
            itemCount: categoriesAndItems.length,
            itemBuilder: (context, index) {
              final categoryAndItem = categoriesAndItems[index];
              return _buildItemsList(categoryAndItem, index, favoriteListCubit);
            }),
      ],
    );
  }

  Widget _buildItemsList(CategoryWithItem category, int categoryIndex,
      FavoriteListCubit favoriteListCubit) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Colors.grey[200],
        ),
        child: _categoryExpandablePanel(
            category, categoryIndex, favoriteListCubit));
  }

  Widget _categoryExpandablePanel(CategoryWithItem category, int categoryIndex,
      FavoriteListCubit favoriteListCubit) {
    return ExpandablePanel(
      theme: const ExpandableThemeData(
        headerAlignment: ExpandablePanelHeaderAlignment.center,
        tapBodyToCollapse: true,
      ),
      collapsed: SizedBox(height: 0),
      header: _headerCategory(category),
      expanded: _expandedList(category, categoryIndex, favoriteListCubit),
      builder: (_, collapsed, expanded) {
        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Expandable(
            collapsed: collapsed,
            expanded: expanded,
          ),
        );
      },
    );
  }

  Widget _headerCategory(CategoryWithItem category) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Text(category.name, style: TextStyle(fontSize: 20)),
          Divider(
            color: Color(category.color!),
            indent: 10,
            endIndent: 5,
            thickness: 4,
            height: 10,
          )
        ]));
  }

  Widget _expandedList(CategoryWithItem category, int categoryIndex,
      FavoriteListCubit favoriteListCubit) {
    return ReorderableListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: category.items != null ? category.items!.length : 0,
        onReorder: (oldIndex, newIndex) {
          favoriteListCubit.reorderItem(
              category, categoryIndex, oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final item = category.items![index];
          return _itemWidget(item, favoriteListCubit, categoryIndex, index);
        });
  }

  Widget _itemWidget(Item item, FavoriteListCubit favoriteListCubit,
      int categoryIndex, int itemIndex) {
    return Dismissible(
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection dismissDirection) {
          _dismissItem(favoriteListCubit, categoryIndex, itemIndex);
        },
        key: ValueKey(item.name),
        background: dismissFavoriteBackground(),
        child: ListTile(
          leading: CircleAvatar(
              radius: 25,
              backgroundImage:
                  item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? NetworkImage(item.imageUrl!)
                      : AssetImage('assets/image_placeholder.png')
                          as ImageProvider),
          title: Text(item.name),
          subtitle:
              Text(DateFormat('MM/dd kk:mm').format(item.favDate.toLocal())),
          trailing: IconButton(
            icon: Icon(
              Icons.thumb_up,
              color: item.isFav ? Colors.blueAccent : Colors.black,
            ),
            onPressed: () {
              favoriteListCubit.unFavItem(categoryIndex, itemIndex);
            },
          ),
        ));
  }

  void _dismissItem(
      FavoriteListCubit favoriteListCubit, int categoryIndex, int itemIndex) {
    favoriteListCubit.unFavItem(categoryIndex, itemIndex);
  }

  Widget dismissFavoriteBackground() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Colors.blueAccent,
        child: Icon(
          Icons.thumb_down,
          color: Colors.white,
          size: 30,
        ));
  }

  Widget _emptyScreenText() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Text(
            'Ups! Looks like you haven\'t favorite any item yet!',
            style: TextStyle(fontSize: 22, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
