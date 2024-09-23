import 'package:flutter/material.dart';

class AppDialogs {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('حسناً',style: TextStyle(color: Colors.black),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
