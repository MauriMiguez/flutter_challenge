import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/create_item/exceptions/upload_file_exception.dart';
import '../../common/services/items_service.dart';
import '../exceptions/already_exists_item_exception.dart';
import '../services/images_service.dart';

part 'create_item_state.dart';

class CreateItemCubit extends Cubit<CreateItemState> {
  final ItemsService itemsService;
  final ImagesStorage imagesStorage;

  CreateItemCubit(this.itemsService, this.imagesStorage)
      : super(CreateItemInitial());

  void onChangeName(String name) {
    emit(ChangeField(name: name, category: state.category, image: state.image));
  }

  void onChangeCategory(String category) {
    emit(ChangeField(name: state.name, category: category, image: state.image));
  }

  void onChangeImage(File image) {
    emit(ChangeField(name: state.name, category: state.category, image: image));
  }

  void createItem() async {
    if (state.name.isEmpty) {
      emit(NameError(
          nameError: 'Name is empty',
          name: state.name,
          category: state.category,
          image: state.image));
      return;
    }

    if (state.category.isEmpty) {
      emit(CategoryError(
          categoryError: 'Category not selected',
          name: state.name,
          category: state.category,
          image: state.image));
      return;
    }

    emit(CreateItemLoading(
        name: state.name, category: state.category, image: state.image));
    String? imageUrl = null;
    if (state.image.path != '') {
      try {
        imageUrl = await imagesStorage.uploadImage(state.image);
      } on UploadFileException catch (e) {
        emit(CreateItemError(
            error: e.message != null ? e.message! : "Error uploading image",
            name: state.name,
            category: state.category,
            image: state.image));
        return;
      }
    }

    try {
      await itemsService.createItem(state.name, imageUrl, state.category);
      emit(CreateItemLoaded(category: state.category));
    } on AlreadyExistsItemException catch (e) {
      emit(CreateItemError(
          error: e.message,
          name: state.name,
          category: state.category,
          image: state.image));
    }
  }
}
