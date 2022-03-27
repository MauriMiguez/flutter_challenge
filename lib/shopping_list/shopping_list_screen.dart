import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../common/models/category_with_items.dart';
import '../common/models/item.dart';
import '../common/services/categories_service.dart';
import '../common/services/items_service.dart';
import '../widgets/searchbar.dart';
import 'bloc/shopping_list_cubit.dart';

class ShoppingList extends StatelessWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            ShoppingListCubit(CategoriesService(), ItemsService())
              ..getShoppingList(),
        child: Builder(builder: (buildContext) {
          return BlocConsumer<ShoppingListCubit, ShoppingListState>(
              listener: (listenerContext, state) {
            if (state is ItemSavedAsFavorite) {
              ScaffoldMessenger.of(listenerContext).showSnackBar(SnackBar(
                content: Text(state.item + " item added to favorites!"),
                duration: const Duration(seconds: 2),
              ));
            }
          }, builder: (buildContext, state) {
            final shoppingListCubit =
                BlocProvider.of<ShoppingListCubit>(buildContext);
            if (state is ShoppingListInitial) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is ShoppingListLoading) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is ShoppingListLoaded ||
                state is ChangeShoppingList ||
                state is ItemSavedAsFavorite) {
              if (state.shoppingList.isEmpty) {
                return _emptyScreenText();
              } else {
                return _buildCategoriesAndItems(
                    state.shoppingList, shoppingListCubit, context);
              }
            }
            return Container();
          });
        }));
  }

  Widget _buildCategoriesAndItems(List<CategoryWithItem> categoriesAndItems,
      ShoppingListCubit shoppingListCubit, buildContext) {
    return Column(
      children: [
        _buildSearchBar(shoppingListCubit),
        Expanded(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: categoriesAndItems.length,
              itemBuilder: (context, index) {
                final categoryAndItem = categoriesAndItems[index];
                return _buildItemsList(
                    categoryAndItem, index, shoppingListCubit, buildContext);
              }),
        )
      ],
    );
  }

  Widget _buildItemsList(CategoryWithItem category, int categoryIndex,
      ShoppingListCubit shoppingListCubit, buildContext) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Colors.grey[200],
        ),
        child: _dismissibleCategory(
            category, categoryIndex, shoppingListCubit, buildContext));
  }

  Widget _dismissibleCategory(CategoryWithItem category, int categoryIndex,
      ShoppingListCubit shoppingListCubit, buildContext) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection dismissDirection) {
        return _confirmDismissCategory(buildContext, category);
      },
      onDismissed: (DismissDirection dismissDirection) {
        _dismissCategory(shoppingListCubit, categoryIndex);
      },
      key: ValueKey(category.name),
      background: _dismissDeleteBackground(),
      child: _categoryWithExpandableItemsList(
          category, categoryIndex, shoppingListCubit, buildContext),
    );
  }

  Widget _categoryWithExpandableItemsList(CategoryWithItem category,
      int categoryIndex, ShoppingListCubit shoppingListCubit, buildContext) {
    return ExpandablePanel(
      theme: const ExpandableThemeData(
        headerAlignment: ExpandablePanelHeaderAlignment.center,
        tapBodyToCollapse: true,
      ),
      collapsed: const SizedBox(height: 0),
      header: _headerCategory(category),
      expanded: _reorderableItemsList(
          category, categoryIndex, shoppingListCubit, buildContext),
      builder: (_, collapsed, expanded) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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

  Widget _reorderableItemsList(CategoryWithItem category, int categoryIndex,
      ShoppingListCubit shoppingListCubit, buildContext) {
    return ReorderableListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: category.items != null ? category.items!.length : 0,
        onReorder: (oldIndex, newIndex) {
          shoppingListCubit.reorderItem(
              category, categoryIndex, oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final item = category.items![index];
          return _dismissibleItem(
              item, shoppingListCubit, categoryIndex, index, buildContext);
        });
  }

  Widget _dismissibleItem(Item item, ShoppingListCubit shoppingListCubit,
      int categoryIndex, int itemIndex, buildContext) {
    return Dismissible(
        confirmDismiss: (DismissDirection dismissDirection) {
          return _confirmDismissItem(dismissDirection, shoppingListCubit,
              categoryIndex, itemIndex, buildContext, item);
        },
        onDismissed: (DismissDirection dismissDirection) {
          _dismissItem(dismissDirection, shoppingListCubit, categoryIndex,
              itemIndex, buildContext, item);
        },
        key: ValueKey(item.name),
        background: _dismissFavoriteBackground(),
        secondaryBackground: _dismissDeleteBackground(),
        child: _itemTile(item, shoppingListCubit, categoryIndex, itemIndex));
  }

  Widget _itemTile(Item item, ShoppingListCubit shoppingListCubit,
      int categoryIndex, int itemIndex) {
    return ListTile(
      leading: CircleAvatar(
          radius: 25,
          backgroundImage: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? NetworkImage(item.imageUrl!)
              : AssetImage('assets/image_placeholder.png') as ImageProvider),
      title: Text(item.name),
      trailing: IconButton(
        icon: Icon(
          Icons.thumb_up,
          color: item.isFav ? Colors.blueAccent : Colors.grey,
        ),
        onPressed: () {
          if (!item.isFav) {
            shoppingListCubit.favItem(categoryIndex, itemIndex);
          }
        },
      ),
    );
  }

  void _dismissCategory(
      ShoppingListCubit shoppingListCubit, int categoryIndex) {
    shoppingListCubit.deleteCategory(categoryIndex);
  }

  Future<bool> _confirmDismissCategory(
      buildContext, CategoryWithItem categoryWithItem) async {
    var value = await showDialog<String>(
        context: buildContext,
        builder: (context) =>
            _deleteItemAlertDialog(context, categoryWithItem.name, "category"));
    if (value == 'Delete') {
      return true;
    } else {
      return false;
    }
  }

  void _dismissItem(
      DismissDirection dismissDirection,
      ShoppingListCubit shoppingListCubit,
      int categoryIndex,
      int itemIndex,
      buildContext,
      Item item) {
    if (DismissDirection.startToEnd == dismissDirection) {
      return;
    } else {
      shoppingListCubit.deleteItem(categoryIndex, itemIndex);
    }
  }

  Future<bool> _confirmDismissItem(
      DismissDirection dismissDirection,
      ShoppingListCubit shoppingListCubit,
      int categoryIndex,
      int itemIndex,
      buildContext,
      Item item) async {
    if (DismissDirection.startToEnd == dismissDirection) {
      if (item.isFav) {
        ScaffoldMessenger.of(buildContext).showSnackBar(const SnackBar(
          content: Text('Item already saved as favorite!'),
          duration: Duration(seconds: 2),
        ));
      } else {
        shoppingListCubit.favItem(categoryIndex, itemIndex);
      }
      return false;
    } else {
      var value = await showDialog<String>(
          context: buildContext,
          builder: (context) =>
              _deleteItemAlertDialog(context, item.name, "item"));
      if (value == 'Delete') {
        return true;
      } else {
        return false;
      }
    }
  }

  AlertDialog _deleteItemAlertDialog(
      BuildContext context, String name, String nameOfResourceToDelete) {
    return AlertDialog(
      title: Text("Confirm delete " + nameOfResourceToDelete),
      content: Text("Are you sure you want to delete " +
          name +
          " " +
          nameOfResourceToDelete +
          "?"),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.white24)),
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, 'Delete');
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _dismissDeleteBackground() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ));
  }

  Widget _dismissFavoriteBackground() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Colors.blueAccent,
        child: Icon(
          Icons.thumb_up,
          color: Colors.white,
          size: 40,
        ));
  }

  _buildSearchBar(ShoppingListCubit shoppingListCubit) {
    return SearchWidget(
        text: '',
        onChanged: shoppingListCubit.search,
        hintText: 'Category or item name');
  }

  Widget _emptyScreenText() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Text(
            'Ups! Looks like you haven\'t created categories or items yet!',
            style: TextStyle(fontSize: 22, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
