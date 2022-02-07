import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/pick/pickBottomSheetWidget.dart';

class PickBottomSheet {
  static Future<dynamic> showPickBottomSheet({
    required BuildContext context,
    required Member member,
    String? oldContent,
  }) async {
    String? content;
    var result = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return PickBottomSheetWidget(
          member: member,
          oldContent: oldContent,
          onTextChanged: (inputContent) => content = inputContent,
        );
      },
    );
    // when there has text, show hint
    if (result != true && content != null && content!.trim().isNotEmpty) {
      Widget dialogTitle = const Text(
        '確定要刪除留言？',
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      );
      Widget dialogContent = const Text(
        '系統將不會儲存您剛剛輸入的內容',
        style: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      );
      List<Widget> dialogActions = [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '刪除留言',
            style: TextStyle(
              color: Colors.red,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            content = await showPickBottomSheet(
              context: context,
              member: member,
              oldContent: content,
            );
          },
          child: const Text(
            '繼續輸入',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ];
      if (!Platform.isIOS) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: dialogTitle,
            content: dialogContent,
            buttonPadding: const EdgeInsets.only(left: 32, right: 8),
            actions: dialogActions,
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: dialogTitle,
            content: dialogContent,
            actions: dialogActions,
          ),
        );
      }
    } else if (result == true) {
      // return content when not empty or only space
      if (content != null && content!.trim().isNotEmpty) {
        return content;
      } else {
        return true;
      }
    }
    return false;
  }
}