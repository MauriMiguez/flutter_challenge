part of 'drawer_navigation_cubit.dart';

abstract class NavigationDrawerState {
  int selectedDestination = 0;
  String title = 'Shopping list';
}

class ChangeSelectedDestination extends NavigationDrawerState {
  ChangeSelectedDestination(int selectedDestination, String title){
    this.selectedDestination = selectedDestination;
    this.title = title;
  }
}

class InitialDestination extends NavigationDrawerState {
  InitialDestination(){
    selectedDestination = 0;
    title = 'Shopping list';
  }
}
