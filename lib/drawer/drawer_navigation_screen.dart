import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/shopping_list/shopping_list_screen.dart';
import '../create_item_and_category/create_item_and_category_screen.dart';
import 'bloc/drawer_navigation_cubit.dart';

class NavigationDrawerScreen extends StatelessWidget {
  const NavigationDrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => NavigationDrawerCubit(),
        child: BlocBuilder<NavigationDrawerCubit, NavigationDrawerState>(
            builder: (BuildContext context, state) {
          NavigationDrawerCubit navigationDrawerCubit =
              BlocProvider.of<NavigationDrawerCubit>(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(state.title),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _customListTile(Icons.shopping_cart, 'Shopping list', 0,
                      state.selectedDestination, navigationDrawerCubit),
                  _customListTile(Icons.add, 'Create', 1,
                      state.selectedDestination, navigationDrawerCubit),
                  _customListTile(Icons.thumb_up, 'Favorites', 2,
                      state.selectedDestination, navigationDrawerCubit),
                ],
              ),
            ),
            body: _showSelectedScreen(navigationDrawerCubit),
          );
        }));
  }

  Widget _customListTile(IconData icon, String name, int screenNumber,
      int selectedDestination, NavigationDrawerCubit navigationDrawerCubit) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      selected: selectedDestination == screenNumber,
      onTap: () => navigationDrawerCubit.changeSelectedScreen(screenNumber),
    );
  }

  Widget _showSelectedScreen(NavigationDrawerCubit navigationDrawerCubit) {
    switch (navigationDrawerCubit.state.selectedDestination) {
      case 0:
        return ShoppingList();
      case 1:
        return CreateItemAndCategory();
      case 2:
        return Container();
      default:
        return ShoppingList();
    }
  }
}
