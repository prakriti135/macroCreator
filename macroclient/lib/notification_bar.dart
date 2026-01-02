import 'package:flutter/material.dart';
import 'package:macroclient/structures.dart';

class NotificationBar extends InheritedWidget {
  final MacroNotification notification;
  final Function(String, NotificationType, bool?) updateNotification;

  const NotificationBar({
    super.key,
    required this.notification,
    required this.updateNotification,
    required super.child,
  });

  static NotificationBar? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NotificationBar>();
  }

  @override
  bool updateShouldNotify(NotificationBar old) {
    bool changed = false;
    changed =
        (notification.value != old.notification.value) ||
        (notification.notificationType != old.notification.notificationType) ||
        (notification.serverConnected != old.notification.serverConnected);
    return changed;
  }
}
