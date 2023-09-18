import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;

  const MyButton({Key? key, required this.onTap}) : super(key: key);

  _showSuccessDialog(BuildContext context) {
    // Delayed navigation to the second page after showing the dialog
    // Future.delayed(const Duration(seconds: 2), () {
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(
    //     builder: (context) => const SecondPage(),
    //   ));
    // });

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Login Successful',
      desc: 'Here We Go!!!',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SecondPage(),
        ));
      },
    ).show();
  }
