

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_challenge/common/models/category.dart';
import 'package:flutter_challenge/common/services/categories_service.dart';
import 'package:flutter_challenge/create_category/bloc/create_category_cubit.dart';
import 'package:flutter_challenge/create_category/exceptions/already_exists_category_exception.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCategoriesRepository extends Mock
    implements CategoriesService {}


void main() {
  group('Create category cubit testing', ()
  {
    MockCategoriesRepository? mockCategoriesRepository;
    CreateCategoryCubit? categoriesCubit;
    String name = 'Category';
    AlreadyExistsCategoryException exception = const AlreadyExistsCategoryException();

    setUp(() {
      mockCategoriesRepository = MockCategoriesRepository();
      categoriesCubit = CreateCategoryCubit(mockCategoriesRepository!);
    });

    tearDown(() {
      categoriesCubit?.close();
    });

    blocTest<CreateCategoryCubit, CreateCategoryState>(
      'Change name',
      build: () => categoriesCubit!,
      act: (cubit) => cubit.onChangeName(name),
      expect: () => [
        ChangeField(
            name: name,
            color: Colors.red),
      ],
    );


  });
}