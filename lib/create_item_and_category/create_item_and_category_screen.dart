import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../create_category/create_category_screen.dart';

class CreateItemAndCategory extends StatelessWidget {

  const CreateItemAndCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child: Center(
                child: Column(
                  children: [
                    _buildProfileInfoTabBar(context),
                    _buildProfileInfoTabBarView(context)
                  ],
                )));
  }

  Widget _buildProfileInfoTabBar(BuildContext context) {
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
      ],
    );
  }

  Widget _buildProfileInfoTabBarView(BuildContext context) {
    return const Expanded(
      child: TabBarView(
        children: [CreateCategory()],
      ),
    );
  }
}