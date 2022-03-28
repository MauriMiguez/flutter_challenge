import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_challenge/common/models/category.dart';
import 'package:flutter_challenge/common/services/categories_service.dart';
import 'package:flutter_challenge/create_item/bloc/categories_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCategoriesRepository extends Mock
    implements CategoriesService {}


void main() {
  group('Get categories cubit testing', ()
  {
    MockCategoriesRepository? mockCategoriesRepository;
    CategoriesCubit? categoriesCubit;

    List<Category> categories = [Category(name: 'category1', color: 1), Category(name: 'category2', color: 2)];

    setUp(() {
      mockCategoriesRepository = MockCategoriesRepository();
      categoriesCubit = CategoriesCubit(mockCategoriesRepository!);
    });

    tearDown(() {
      categoriesCubit?.close();
    });

    blocTest<CategoriesCubit, CategoriesState>(
      'Create item, error already registered item',
      build: () => categoriesCubit!,
      setUp: () =>
          when(() => mockCategoriesRepository!.getAllCategories()).thenAnswer((invocation) => Future.value(categories)),
      act: (cubit) {
        cubit.getCategories();
      },
      expect: () => [
        CategoriesLoading(),
        CategoriesLoaded(categories)
      ],
    );
  });
}