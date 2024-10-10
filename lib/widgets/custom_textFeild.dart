// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFeildWidget extends StatelessWidget {
  final String? labelText;
  final double? width;
  final double? height;
  final bool? visible;
  final bool? readOnly;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool? enable;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final VoidCallback? showErrorCallback;
  final List<TextInputFormatter>? inputFormatters;
  void Function()? onEditingComplete;

   TextFeildWidget({
    Key? key,
    this.labelText,
    this.width,
    this.height,
    this.visible,
    this.readOnly = false,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.enable = true,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNode,
    this.hintText,
    this.controller,
    this.textInputAction,
    this.textInputType,
    this.showErrorCallback,
    this.inputFormatters,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 52,
      child: TextFormField( 
        inputFormatters: inputFormatters,
        readOnly: readOnly ?? false,
        textInputAction: textInputAction,
        keyboardType: textInputType,
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete ,
        validator: (value) {
          if (value!.isEmpty) {
            showErrorCallback?.call();
            return null;
          } else {
            return null;
          }
        },
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xffD9D9D9D9),
          hintText: hintText,
          floatingLabelStyle: const TextStyle(
            color: Color(0xffF05A28),
          ),
          label: Text(labelText ?? ""),
          labelStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xffF05A28),
              )),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
