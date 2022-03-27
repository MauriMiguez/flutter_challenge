import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../create_category_service.dart';
import '../exceptions/already_exists_category_exception.dart';

part 'create_category_state.dart';

class CreateCategoryCubit extends Cubit<CreateCategoryState>{

  final CategoriesService categoriesService;

  CreateCategoryCubit({required this.categoriesService}): super (CreateCategoryInitial());


  void onChangeName(String name){
    emit(ChangeField(name: name, color: state.color));
  }

  void onChangeColor(Color color){
    emit(ChangeField(name: state.name, color: color));
  }


  void CreateCategory() async{
    if(state.name.isEmpty){
      emit(NameError(nameError: 'Name is empty', name: state.name, color: state.color));
      return;
    }

    emit(CreateCategoryLoading(name: state.name, color: state.color));
    try{
      await categoriesService.createCategory(state.name, state.color.value);
      emit(CreateCategoryLoaded());
    } on AlreadyExistsCategoryException catch (e) {
      emit(CreateCategoryError(error:e.message, name: state.name, color: state.color));
    }
  }

}