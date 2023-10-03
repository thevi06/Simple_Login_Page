import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:simple_login_page/pages/second_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        onPressed: () {
          _showSuccessDialog(context); // Show the success dialog
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 25),
          primary: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Container(
          width: double.infinity, // Stretch the button width
          child: const Center(
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
