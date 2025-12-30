import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';

void showConfirmationDialog({
  required BuildContext context,
  required String message,
  required String confirmText,
  required Function() onConfirm,
  String? cancelText,
  Function()? onCancel,
  preventDismissal = false
}) {
  showDialog(
    context: context,
    barrierDismissible: !preventDismissal, // ✅ استخدمه هنا
    builder: (BuildContext context) {
      return StatefulBuilder(

        builder: (BuildContext context, setState) {

          return Dialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // إظهار زر الإلغاء فقط إذا كان cancelText ليس فارغًا
                      if (cancelText != null && cancelText.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            if (onCancel != null) {
                              onCancel();
                            }
                            Navigator.of(context).pop(); // إغلاق الـ Dialog بعد الضغط على إلغاء
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      if (cancelText != null && cancelText.isNotEmpty)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                      ElevatedButton(
                        onPressed: () {
                          onConfirm();
                          Navigator.of(context).pop(); // إغلاق الـ Dialog بعد الضغط على "تحديث الآن"
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

