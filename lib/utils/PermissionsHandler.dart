import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  askForPermission({
    @required BuildContext context,
    @required List<PermissionGroup> permissions,
    @required String text,
  }) async {
    Map<PermissionGroup, PermissionStatus> permissionsMap =
        await PermissionHandler().requestPermissions(permissions);
    print('${permissionsMap[PermissionGroup.storage]}');

    for (PermissionGroup permissionGroup in permissions)
      if (permissionsMap[permissionGroup] != PermissionStatus.granted)
        showConfirmationDialog(context, permissions, text);
  }

  showConfirmationDialog(
      BuildContext context, List<PermissionGroup> permissions, String text) {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Text(text),
            title: Text("Warning !"),
            actions: <Widget>[
              FlatButton(
                child: Text("Decline"),
                onPressed: () {
                  Navigator.pop(context, false);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Accept"),
                onPressed: () {
                  Navigator.pop(context, true);
                  askForPermission(
                    context: context,
                    permissions: permissions,
                    text: text,
                  );
                },
              ),
            ],
          );
        });
  }
}
