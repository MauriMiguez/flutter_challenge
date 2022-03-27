import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_challenge/common/services/items_service.dart';
import 'package:flutter_challenge/create_item/bloc/create_item_cubit.dart';
import 'package:flutter_challenge/create_item/exceptions/already_exists_item_exception.dart';
import 'package:flutter_challenge/create_item/services/images_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockItemsRepository extends Mock
    implements ItemsService {}

class MockImagesRepository extends Mock
    implements ImagesStorage {}


void main() {
  group('Create item cubit testing', ()
  {
    MockItemsRepository? mockItemsRepository;
    MockImagesRepository? mockImagesRepository;
    CreateItemCubit? itemCubit;
    String name = 'Item';
    String category = 'Category';
    AlreadyExistsItemException exception = const AlreadyExistsItemException();

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
      expect: () => [
        ChangeField(name:name, category: '', image: null),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'Change category',
      build: () => itemCubit!,
      act: (cubit) => cubit.onChangeCategory(category),
      expect: () => [
        ChangeField(name:'', category: category, image: null),
      ],
    );
  });
}