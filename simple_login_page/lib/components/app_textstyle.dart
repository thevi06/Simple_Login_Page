import 'package:flutter/material.dart';
import '../components/app_color.dart';

class AppTextStyle {
  static AppTextStyle instance = AppTextStyle();

  TextStyle displayLarge = TextStyle(
    color: AppColor.blackGrey,
    fontSize: 57,
    fontWeight: FontWeight.bold,
  );
  TextStyle displayMedium = TextStyle(
    color: AppColor.blackGrey,
    fontSize: 45,
    fontWeight: FontWeight.bold,
  );