import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_challenge/create_category/bloc/create_category_cubit.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import '../common/services/categories_service.dart';

class CreateCategory extends StatelessWidget {
  const CreateCategory({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CreateCategoryCubit(CategoriesService()),
      child: Builder(builder: (context) {
        final createCategoryCubit =
            BlocProvider.of<CreateCategoryCubit>(context);
        return SafeArea(
          child: BlocListener<CreateCategoryCubit, CreateCategoryState>(
            listener: (context, state) {
              if (state is CreateCategoryLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Category successfully created!"),
                  duration: Duration(seconds: 2),
                ));
              }
              if (state is CreateCategoryError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  duration: const Duration(seconds: 2),
                ));
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _nameTextField(createCategoryCubit),
                  const SizedBox(height: 16),
                  _colorSelectedContainer(createCategoryCubit),
                  const SizedBox(height: 16),
                  _colorPickBtn(createCategoryCubit),
                  const SizedBox(height: 16),
                  _createCategoryBtn(createCategoryCubit),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _nameTextField(CreateCategoryCubit createCategoryCubit) {
    return BlocBuilder<CreateCategoryCubit, CreateCategoryState>(
        builder: (context, state) {
      return TextField(
        enabled: state is! CreateCategoryLoading,
        onChanged: (value) => createCategoryCubit.onChangeName(value),
        decoration: InputDecoration(
          labelText: 'Name',
          errorText: state is NameError ? state.nameError : null,
        ),
      );
    });
  }

  Widget _colorSelectedContainer(CreateCategoryCubit createCategoryCubit) {
    return BlocBuilder<CreateCategoryCubit, CreateCategoryState>(
        builder: (context, state) {
      return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: createCategoryCubit.state.color),
        width: 120,
        height: 120,
      );
    });
  }

  Widget _colorPickBtn(CreateCategoryCubit createCategoryCubit) {
    return BlocBuilder<CreateCategoryCubit, CreateCategoryState>(
        builder: (context, state) {
      return ElevatedButton(
        onPressed: state is CreateCategoryLoading
            ? null
            : () => _pickColor(context, createCategoryCubit),
        child: const Text('Pick color'),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24)),
      );
    });
  }

  Widget _createCategoryBtn(CreateCategoryCubit createCategoryCubit) {
    return BlocBuilder<CreateCategoryCubit, CreateCategoryState>(
        builder: (context, state) {
      return state is CreateCategoryLoading
          ? CircularProgressIndicator()
          : ElevatedButton(
              onPressed: createCategoryCubit.CreateCategory,
              child: const Text('Create category'),
            );
    });
  }

  void _pickColor(
          BuildContext context, CreateCategoryCubit createCategoryCubit) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Pick a color'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorPicker(createCategoryCubit),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ));

  Widget _buildColorPicker(CreateCategoryCubit createCategoryCubit) {
    return ColorPicker(
      pickerColor: createCategoryCubit.state.color,
      onColorChanged: (color) => {
        createCategoryCubit.onChangeColor(color),
      },
    );
  }
}
