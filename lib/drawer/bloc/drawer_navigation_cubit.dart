import 'package:flutter_bloc/flutter_bloc.dart';

part 'drawer_navigation_state.dart';

class NavigationDrawerCubit extends Cubit<NavigationDrawerState> {
  NavigationDrawerCubit() : super(InitialDestination());

  void changeSelectedScreen(int selectedScreen) {
    String title = '';
    switch (selectedScreen) {
      case 0:
        title = 'Shopping list';
        break;
      case 1:
        title = 'Create';
        break;
      case 2:
        title = 'Favorites';
        break;
    }
    emit(ChangeSelectedDestination(selectedScreen, title));
  }
}
