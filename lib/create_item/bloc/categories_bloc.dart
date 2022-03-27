import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/services/categories_service.dart';
import '../../common/models/category.dart';

part 'categories_state.dart';

class CategoriesBloc extends Cubit<CategoriesState>{
  final CategoriesService _categoriesService;

  CategoriesBloc(this._categoriesService) : super(CategoriesInitial()) ;


  Future<void> getCategories() async {
    emit(CategoriesLoading());
    List<Category> categories = await _categoriesService.getAllCategories();

    emit(CategoriesLoaded(categories));
  }
}
