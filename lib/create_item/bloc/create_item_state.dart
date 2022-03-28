part of 'create_item_cubit.dart';

abstract class CreateItemState extends Equatable {
  String name = '';
  String category = '';
  File image = File('');

  @override
  List<Object> get props => [name, category, image];
}

class CreateItemInitial extends CreateItemState {}

class xd extends CreateItemState {}

class ChangeField extends CreateItemState {
  ChangeField({name = String, category = String, image = File}) {
    this.name = name;
    this.category = category;
    this.image = image;
  }
}

class NameError extends CreateItemState {
  final String nameError;
  @override
  List<Object> get props => [nameError, name, category];
  NameError(
      {required this.nameError,
      name = String,
      category = String,
      image = File}) {
    this.name = name;
    this.category = category;
    this.image = image;
  }
}

class CategoryError extends CreateItemState {
  final String categoryError;
  @override
  List<Object> get props => [categoryError, name, category];

  CategoryError(
      {required this.categoryError,
      name = String,
      category = String,
      image = File}) {
    this.name = name;
    this.category = category;
    this.image = image;
  }
}

class CreateItemError extends CreateItemState {
  final String error;

  @override
  List<Object> get props => [error, name, category];
  CreateItemError(
      {required this.error, name = String, category = String, image = File}) {
    this.name = name;
    this.category = category;
    this.image = image;
  }
}

class CreateItemLoading extends CreateItemState {
  CreateItemLoading({name = String, category = String, image = File}) {
    this.name = name;
    this.category = category;
    this.image = image;
  }
}

class CreateItemLoaded extends CreateItemState {
  CreateItemLoaded({category = String}) {
    name = '';
    this.category = category;
    image = File('');
  }
}
