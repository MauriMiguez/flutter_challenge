import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import '../common/models/category.dart';
import '../common/services/categories_service.dart';
import '../create_item_and_category/create_item_and_category_screen.dart';
import 'bloc/categories_cubit.dart';
import 'bloc/create_item_cubit.dart';
import '../common/services/items_service.dart';
import 'services/images_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateItem extends StatefulWidget {
  const CreateItem({Key? key}) : super(key: key);

  @override
  _CreateItemState createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateItemCubit(
          itemsService: ItemsService(), imagesStorage: ImagesStorage()),
      child: Builder(builder: (context) {
        final createItemCubit = BlocProvider.of<CreateItemCubit>(context);
        return SafeArea(
          child: BlocListener<CreateItemCubit, CreateItemState>(
            listener: (context, state) {
              if (state is CreateItemLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Item successfully created!"),
                  duration: Duration(seconds: 2),
                ));
              }
              if (state is CreateItemError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  duration: const Duration(seconds: 2),
                ));
              }
            },
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  _imageSelector(createItemCubit),
                  _nameTextField(createItemCubit),
                  const SizedBox(height: 16),
                  _categoryDropdown(createItemCubit),
                  const SizedBox(height: 16),
                  _createCategoryBtn(createItemCubit),
                ],
              ),
            )),
          ),
        );
      }),
    );
  }

  Widget _imageSelector(CreateItemCubit createItemCubit) {
    return BlocBuilder<CreateItemCubit, CreateItemState>(
        builder: (context, state) {
      return GestureDetector(
          onTap: state is! CreateItemLoading &&
                  createItemCubit.state.category.isNotEmpty
              ? () async {
                  await pickImage(createItemCubit);
                }
              : null,
          child: Container(
              child: ClipOval(
            child: createItemCubit.state.image != null
                ? Image.file(createItemCubit.state.image!,
                    width: 100, height: 100, fit: BoxFit.cover)
                : Image(
                    image: AssetImage('assets/image_placeholder.png'),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover),
          )));
    });
  }

  Widget _nameTextField(CreateItemCubit createItemCubit) {
    return BlocBuilder<CreateItemCubit, CreateItemState>(
        builder: (context, state) {
      return TextField(
        enabled: state is! CreateItemLoading &&
            createItemCubit.state.category.isNotEmpty,
        onChanged: (value) => createItemCubit.onChangeName(value),
        decoration: InputDecoration(
          labelText: 'Name',
          errorText: state is NameError ? state.nameError : null,
        ),
      );
    });
  }

  Widget _categoryDropdown(CreateItemCubit createItemCubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Select category:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 26),
        _categoryList(createItemCubit),
      ],
    );
  }

  Widget _createCategoryBtn(CreateItemCubit createItemCubit) {
    return BlocBuilder<CreateItemCubit, CreateItemState>(
        builder: (context, state) {
      return state is CreateItemLoading
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: createItemCubit.state.category.isEmpty
                  ? null
                  : createItemCubit.CreateItem,
              child: const Text('Create item'),
            );
    });
  }

  Future pickImage(CreateItemCubit createItemCubit) async {
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      createItemCubit.onChangeImage(imageTemporary);
    } on PlatformException catch (e) {}
  }

  Widget _categoryList(CreateItemCubit createItemCubit) {
    return BlocProvider(
      create: (context) => CategoriesCubit(CategoriesService())..getCategories(),
      child: Builder(builder: (context) {
        return BlocConsumer<CategoriesCubit, CategoriesState>(
            listener: (context, state) {
          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              showDialog<void>(
                  context: context,
                  builder: (context) => _missingCategoryAlertDialog(context));
            }
          }
        }, builder: (context, state) {
          if (state is CategoriesInitial) {
            return CircularProgressIndicator();
          }
          if (state is CategoriesLoading) {
            return CircularProgressIndicator();
          }
          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              _emptyDropdown();
            } else {
              return _categoryDropdownWihItems(
                  state.categories, createItemCubit);
            }
          }
          return _emptyDropdown();
        });
      }),
    );
  }

  Widget _emptyDropdown() {
    return DropdownButton<String>(
      items: [],
      value: '',
      onChanged: (Object? value) {},
    );
  }

  Widget _categoryDropdownWihItems(
      List<Category> categories, CreateItemCubit createItemCubit) {
    var categoriesNames = categories
        .map((category) =>
            DropdownMenuItem(child: Text(category.name), value: category.name))
        .toList();
    if (createItemCubit.state.category == '') {
      createItemCubit.onChangeCategory(categoriesNames[0].value!);
    }
    return BlocBuilder<CreateItemCubit, CreateItemState>(
        builder: (context, state) {
      return DropdownButton(
        items: categoriesNames,
        onChanged: (value) => _dropDownCallBack(value, createItemCubit),
        value: createItemCubit.state.category,
      );
    });
  }

  void _dropDownCallBack(selectedValue, CreateItemCubit createItemCubit) {
    createItemCubit.onChangeCategory(selectedValue);
  }

  AlertDialog _missingCategoryAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Missing Category'),
      content: Text("Beafore creating an item"
          " you need to create a category."),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'OK');
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
