import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
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

    blocTest<CreateCategoryCubit, CreateCategoryState>(
      'Change color',
      build: () => categoriesCubit!,
      act: (cubit) => cubit.onChangeColor(Colors.blue),
      expect: () => [
        ChangeField(
            name: '',
            color: Colors.blue),
      ],
    );

    blocTest<CreateCategoryCubit, CreateCategoryState>(
      'Create category. Error empty name',
      build: () => categoriesCubit!,
      act: (cubit) => cubit.CreateCategory(),
      expect: () => [
        NameError(nameError: 'Name is empty', name: '', color: Colors.red)
      ],
    );

    blocTest<CreateCategoryCubit, CreateCategoryState>(
      'Create category. Successful',
      build: () => categoriesCubit!,
      setUp: () => when(() => mockCategoriesRepository!
          .createCategory(name, Colors.red.value))
          .thenAnswer((invocation) => Future.value(null)),
      seed: () => ChangeField(
          name: name,
          color: Colors.red),
      act: (cubit) => cubit.CreateCategory(),
      expect: () => [
        CreateCategoryLoading(name: name, color: Colors.red),
        CreateCategoryLoaded()
      ],
    );

    blocTest<CreateCategoryCubit, CreateCategoryState>(
      'Create category. Error already registered with name',
      build: () => categoriesCubit!,
      setUp: () => when(() => mockCategoriesRepository!
          .createCategory(name, Colors.red.value))
          .thenThrow(exception),
      seed: () => ChangeField(
          name: name,
          color: Colors.red),
      act: (cubit) => cubit.CreateCategory(),
      expect: () => [
        CreateCategoryLoading(name: name, color: Colors.red),
        CreateCategoryError(error:exception.message, name: name, color: Colors.red)
      ],
    );
  });
}