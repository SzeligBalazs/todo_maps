import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void requestPermission() async {
    final prefs = await SharedPreferences.getInstance();

    await AwesomeNotifications().isNotificationAllowed().then((value) {
      if (!value) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
            channelGroupKey: 'todomaps_channel_group',
            channelKey: 'todomaps_channel',
            channelName: "Todo Maps",
            channelDescription: "Todo Maps értesítések",
            defaultColor: Colors.black,
            ledColor: Colors.white)
      ],
      debug: kDebugMode,
    );
    Permission.location.request();
    Permission.locationAlways.request();
    prefs.setBool('firstRun', false);
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Todo Maps',
                style: Theme.of(context).textTheme.headline1,
              ),
              Text(
                "Az alkalmazás használatához engedélyezned kell a pontos helyszolgáltatást és az értesítéseket.\n\ \nErre azért van szükség, mert az alklamazás helymegahtározási funkciókat használ (a háttérben is)\n\nAz alkalmazás nem tárol semmilyen adatot, és nem küld semmilyen információt külső szerverekre.",
                textAlign: TextAlign.left,
              ),
              TextButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse(
                        'https://szeligbalazs.github.io/SzeligBalazs/todomaps-privacy-policy.html'));
                  },
                  child: Text(
                    'Adatvédelmi nyilatkozat',
                    style: TextStyle(color: Colors.black),
                  )),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  requestPermission();
                },
                child: Text('Engedélyezés és belépés'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
