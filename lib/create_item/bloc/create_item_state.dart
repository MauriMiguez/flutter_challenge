part of 'create_item_cubit.dart';

abstract class CreateItemState {
  String category = '';
  String name = '';
  File? image;
}

class CreateItemInitial extends CreateItemState {}

class ChangeField extends CreateItemState {
  ChangeField({name = String, category = String, image = File}) {
    this.name = name;
    this.category = category;
    this.image = image;
  }
}

class NameError extends CreateItemState {
  final String nameError;

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
    image = null;
  }
}
