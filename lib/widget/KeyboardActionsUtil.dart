import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class KeyboardActionsUtil {
  /// Builds a standard [KeyboardActionsItem] with a "Done" (تم) button.
  static KeyboardActionsItem buildDoneItem(FocusNode focusNode) {
    return KeyboardActionsItem(
      focusNode: focusNode,
      toolbarButtons: [
        (node) => CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "تم",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Tajawal",
                ),
              ),
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  node.unfocus();
                });
              },
            ),
      ],
    );
  }

  /// Builds a [KeyboardActionsConfig] for a single focus node.
  static KeyboardActionsConfig buildConfig(BuildContext context, FocusNode focusNode) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        buildDoneItem(focusNode),
      ],
    );
  }
}
