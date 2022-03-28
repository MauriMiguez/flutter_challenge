part of 'create_category_cubit.dart';

abstract class CreateCategoryState extends Equatable {
  Color color = Colors.red;
  String name = '';

  @override
  List<Object> get props => [name, color];
}

class CreateCategoryInitial extends CreateCategoryState {}

class ChangeField extends CreateCategoryState {

  ChangeField({name = String, color = Color}){
    this.name = name;
    this.color = color;
  }
}

class NameError extends CreateCategoryState {
  final String nameError;

  @override
  List<Object> get props => [nameError, name, color];
  NameError({required this.nameError, name = String, color = Color} ){
    this.name = name;
    this.color = color;
  }
}


class CreateCategoryError extends CreateCategoryState {
  final String error;

  @override
  List<Object> get props => [error, name, color];
  CreateCategoryError({required this.error, name = String, color = Color}){
    this.name = name;
    this.color = color;
  }
}

class CreateCategoryLoading extends CreateCategoryState {
  CreateCategoryLoading({name = String, color = Color}){
    this.name = name;
    this.color = color;
  }
}

class CreateCategoryLoaded extends CreateCategoryState {}


