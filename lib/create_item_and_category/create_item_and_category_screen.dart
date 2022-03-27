import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_challenge/create_item/create_item_screen.dart';

import '../create_category/create_category_screen.dart';

class CreateItemAndCategory extends StatelessWidget {
  const CreateItemAndCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Center(
            child: Column(
          children: [_buildTabBar(context), _buildTabBarView(context)],
        )));
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Theme.of(context).backgroundColor,
      indicatorColor: Theme.of(context).colorScheme.secondary,
      tabs: const [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: FittedBox(
            child: Text(
              'Category',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Item',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    return const Expanded(
      child: TabBarView(
        children: [CreateCategory(), CreateItem()],
      ),
    );
  }
}
