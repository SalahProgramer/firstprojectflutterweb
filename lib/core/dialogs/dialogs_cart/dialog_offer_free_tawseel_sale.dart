import 'package:flutter/material.dart';

import '../../utilities/global/app_global.dart';

Future<void> dialogSale({void Function()? onPressed}) {
  return showDialog(
    context: NavigatorApp.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("مبروك ,لقد حصلت على خصم التوصيل"),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: Text("حسنا"),
          ),
        ],
      );
    },
  );
}
