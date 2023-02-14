import 'package:awesome_notifications/awesome_notifications.dart';

class PushNotificationUtil {
  void show(String title, String message, String path) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'todomaps_channel',
        title: title,
        body: message,
        payload: {'path': path},
        displayOnForeground: true,
        displayOnBackground: true,
      ),
    );
  }
}
