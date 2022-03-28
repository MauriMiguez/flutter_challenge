import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_challenge/common/services/items_service.dart';
import 'package:flutter_challenge/create_item/bloc/create_item_cubit.dart';
import 'package:flutter_challenge/create_item/exceptions/already_exists_item_exception.dart';
import 'package:flutter_challenge/create_item/exceptions/upload_file_exception.dart';
import 'package:flutter_challenge/create_item/services/images_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:io';

class MockItemsRepository extends Mock implements ItemsService {}

class MockImagesRepository extends Mock implements ImagesStorage {}

void main() {
  group('Create item cubit testing', () {
    MockItemsRepository? mockItemsRepository;
    MockImagesRepository? mockImagesRepository;
    CreateItemCubit? itemCubit;
    String name = 'Item';
    String category = 'Category';
    AlreadyExistsItemException exception = const AlreadyExistsItemException();
    UploadFileException emptyUploadFileException =
        UploadFileException(message: null);
    UploadFileException messageUploadFileException =
        UploadFileException(message: 'Upload error');
    File emptyFile = File('');
    File file = File('imageUrl');

    setUp(() {
      mockItemsRepository = MockItemsRepository();
      mockImagesRepository = MockImagesRepository();
      itemCubit = CreateItemCubit(mockItemsRepository!, mockImagesRepository!);
    });

    tearDown(() {
      itemCubit?.close();
    });

    blocTest<CreateItemCubit, CreateItemState>(
      'Change name',
      build: () => itemCubit!,
      act: (cubit) => cubit.onChangeName(name),
      seed: () => ChangeField(name: '', category: '', image: emptyFile),
      expect: () => [
        ChangeField(name: name, category: '', image: emptyFile),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Change category',
      build: () => itemCubit!,
      seed: () => ChangeField(name: '', category: '', image: emptyFile),
      act: (cubit) => cubit.onChangeCategory(category),
      expect: () => [
        ChangeField(name: '', category: category, image: emptyFile),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Create item, error name is empty',
      build: () => itemCubit!,
      seed: () => ChangeField(name: '', category: '', image: emptyFile),
      act: (cubit) => cubit.createItem(),
      expect: () => [
        NameError(
            nameError: 'Name is empty', name: '', category: '', image: emptyFile),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Create item, category empty',
      build: () => itemCubit!,
      seed: () => ChangeField(name: name, category: '', image: emptyFile),
      act: (cubit) => cubit.createItem(),
      expect: () => [
        CategoryError(
            categoryError: 'Category not selected',
            name: name,
            category: '',
            image: emptyFile),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Create item, error uploading image',
      build: () => itemCubit!,
      setUp: () => when(() => mockImagesRepository!.uploadImage(file))
          .thenThrow(emptyUploadFileException),
      seed: () => ChangeField(name: name, category: category, image: file),
      act: (cubit) => cubit.createItem(),
      expect: () => [
        CreateItemLoading(name: name, category: category, image: file),
        CreateItemError(
            error: 'Error uploading image',
            name: name,
            category: category,
            image: file),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Create item, error upload image with message ',
      build: () => itemCubit!,
      setUp: () => when(() => mockImagesRepository!.uploadImage(file))
          .thenThrow(messageUploadFileException),
      seed: () => ChangeField(name: name, category: category, image: file),
      act: (cubit) => cubit.createItem(),
      expect: () => [
        CreateItemLoading(name: name, category: category, image: file),
        CreateItemError(
            error: messageUploadFileException.message!,
            name: name,
            category: category,
            image: file),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Create item, error already registered item',
      build: () => itemCubit!,
      setUp: () {
        when(() => mockImagesRepository!.uploadImage(file))
            .thenAnswer((invocation) => Future.value(file.path));
        when(() => mockItemsRepository!.createItem(name, file.path, category))
            .thenThrow(exception);
      },
      seed: () => ChangeField(name: name, category: category, image: file),
      act: (cubit) {
        cubit.createItem();
      },
      expect: () => [
        CreateItemLoading(name: name, category: category, image: file),
        CreateItemError(
            error: exception.message,
            name: name,
            category: category,
            image: file)
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Create item',
      build: () => itemCubit!,
      seed: () => ChangeField(name: name, category: category, image: file),
      setUp: () {
        when(() => mockImagesRepository!.uploadImage(file))
            .thenAnswer((invocation) => Future.value(file.path));
        when(() => mockItemsRepository!.createItem(name, file.path, category))
            .thenAnswer((invocation) => Future.value());
      },
      act: (cubit) => cubit.createItem(),
      expect: () => [
        CreateItemLoading(name: name, category: category, image: file),
        isA<CreateItemLoaded>()
      ],
    );
  });
}
