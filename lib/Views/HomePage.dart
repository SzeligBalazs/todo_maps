import 'dart:async';
import 'dart:isolate';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';

import 'package:todo_maps/utils/pushNotifications.dart';
import '../utils/DatabaseHelper.dart';
import '../utils/Model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

late LocationSettings locationSettings;
double latPoint = 0;
double longPoint = 0;
double latCurrent = 0;
double longCurrent = 0;
const String _isolateName = "LocatorIsolate";
ReceivePort port = ReceivePort();
bool showMenu = false;
bool showDetails = false;
bool executeWhenEnabled = true;
int selectedMarkerId = 0;
double selectedMarkerLat = 0;
double selectedMarkerLong = 0;
String selectedMarkerTitle = '';
String selectedMarkerDescription = '';
int duartion = 5;
bool isForegroundMode = true;
int partOfTheDay = 0;
int partOfTheDaySet = 0;
List ids = [];

late TextEditingController _titleController = TextEditingController();
late TextEditingController _descriptionController = TextEditingController();

MapController controller = MapController.withPosition(
  initPosition: GeoPoint(
    latitude: 47.1430034,
    longitude: 17.2622665,
  ),
);

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      getDataFromDB();
      checkLocation();
      placeMarker();

      setState(() {
        isForegroundMode = true;
        if (executeWhenEnabled == true) {
          if (DateTime.now().hour >= 0 && DateTime.now().hour < 8) {
            partOfTheDay = 0;
          } else if (DateTime.now().hour >= 8 && DateTime.now().hour <= 12) {
            partOfTheDay = 1;
          } else if (DateTime.now().hour > 12 && DateTime.now().hour <= 17) {
            partOfTheDay = 2;
          } else if (DateTime.now().hour > 17 && DateTime.now().hour <= 23) {
            partOfTheDay = 3;
          }
        } else {
          partOfTheDay = 4;
        }
      });
    });

    setState(() {
      if (executeWhenEnabled == true) {
        if (DateTime.now().hour >= 0 && DateTime.now().hour < 8) {
          partOfTheDaySet = 0;
        } else if (DateTime.now().hour >= 8 && DateTime.now().hour <= 12) {
          partOfTheDaySet = 1;
        } else if (DateTime.now().hour > 12 && DateTime.now().hour <= 17) {
          partOfTheDaySet = 2;
        } else if (DateTime.now().hour > 17 && DateTime.now().hour <= 23) {
          partOfTheDaySet = 3;
        }
      } else {
        partOfTheDaySet = 4;
      }
    });
    AwesomeNotifications().setListeners(onActionReceivedMethod: (action) async {
      setState(() {
        showDetails = true;
      });
    });
  }

  Future<Position> checkLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Futtatás a háttérben...",
          notificationTitle: "Todo Maps",
          enableWakeLock: true,
        ));

    if (kDebugMode) {
      print("latCurrent: $latCurrent");
      print("longCurrent: $longCurrent");
    }

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      latCurrent = position!.latitude;
      longCurrent = position.longitude;
    });

    await DBhelper.instance.getTodos().then((value) {
      for (var element in value) {
        setState(() {
          const ref = 0.00045045;

          if (ref > (latCurrent - element.latitude!).abs() ||
              ref > (longCurrent - element.longitude!).abs()) {
            if (!ids.contains(element.id) &&
                partOfTheDay == element.partOfTheDay) {
              PushNotificationUtil().show('Todo Maps',
                  'Közel van a(z) ${element.title} teendője helyéhez!', '/');

              ids.add(element.id);
              selectedMarkerId = element.id!;
              selectedMarkerTitle = element.title;
              selectedMarkerDescription = element.description;
            }

            if (!ids.contains(element.id) && element.partOfTheDay == 4) {
              PushNotificationUtil().show('Todo Maps',
                  'Közel van a(z) ${element.title} teendője helyéhez!', '/');
              ids.add(element.id);
              selectedMarkerId = element.id!;
              selectedMarkerTitle = element.title;
              selectedMarkerDescription = element.description;
            }
          }
        });
      }
    });

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return await Geolocator.getCurrentPosition();
  }

  void getDataFromDB() async {
    await DBhelper.instance.getTodos().then((value) {
      setState(() {
        value.forEach((element) {
          controller.addMarker(
              GeoPoint(
                latitude: element.latitude!,
                longitude: element.longitude!,
              ),
              markerIcon: MarkerIcon(
                icon: Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 100,
                ),
              ));
          controller.drawCircle(CircleOSM(
              key: element.id!.toString(),
              centerPoint: GeoPoint(
                  latitude: element.latitude!, longitude: element.longitude!),
              radius: 100,
              color: Colors.deepPurpleAccent,
              strokeWidth: 2));
        });
      });
    });
  }

  void delete(deletedId) {
    DBhelper.instance.getTodos().then((value) {
      value.forEach((element) {
        if (deletedId == element.id) {
          setState(() {
            controller.removeCircle(deletedId.toString());
            controller.removeMarker(
              GeoPoint(
                latitude: element.latitude!,
                longitude: element.longitude!,
              ),
            );
            controller.removeCircle(deletedId.toString());
            controller.removeMarker(
              GeoPoint(
                latitude: element.latitude!,
                longitude: element.longitude!,
              ),
            );
            DBhelper.instance.delete(deletedId);
          });
        }
      });
    });
  }

  void getSelectedMarkerData() async {
    await DBhelper.instance.getTodos().then((value) {
      setState(() {
        value.forEach((element) {
          if (element.latitude == selectedMarkerLat &&
              element.longitude == selectedMarkerLong) {
            selectedMarkerId = element.id!;
            selectedMarkerTitle = element.title;
            selectedMarkerDescription = element.description;
          }
        });
      });
    });
  }

  void placeMarker() {
    controller.listenerMapSingleTapping.addListener(() {
      if (controller.listenerMapSingleTapping.value != null) {
        setState(() {
          showMenu = true;
          latPoint = controller.listenerMapSingleTapping.value!.latitude;
          longPoint = controller.listenerMapSingleTapping.value!.longitude;
        });
      }
    });
  }

  void saveNote() async {
    await DBhelper.instance.add(
      NoteModel(
        title: _titleController.text,
        description: _descriptionController.text,
        latitude: latPoint,
        longitude: longPoint,
        partOfTheDay: partOfTheDaySet,
      ),
    );

    setState(() {
      showMenu = false;
      _titleController.clear();
      _descriptionController.clear();
      controller.addMarker(
        GeoPoint(
          latitude: latPoint,
          longitude: longPoint,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Todo Maps',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/help');
                },
                icon: Icon(Icons.help_outline_rounded)),
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            OSMFlutter(
              controller: controller,
              onGeoPointClicked: (p0) {
                setState(() {
                  showDetails = true;
                  selectedMarkerLat = p0.latitude;
                  selectedMarkerLong = p0.longitude;
                });
                getSelectedMarkerData();
              },
              trackMyPosition: true,
              initZoom: 15,
              minZoomLevel: 2,
              maxZoomLevel: 19,
              stepZoom: 1.0,
              mapIsLoading: Center(
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Center(
                    child: Text(
                      "Betöltés...",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.05),
                    ),
                  ),
                ),
              ),
              onMapIsReady: (p0) {
                placeMarker();
                checkLocation();
                getDataFromDB();
              },
              userLocationMarker: UserLocationMaker(
                personMarker: MarkerIcon(
                  icon: Icon(
                    Icons.location_history_rounded,
                    color: Color(0xFFff5f5f),
                    size: 48,
                  ),
                ),
                directionArrowMarker: MarkerIcon(
                  icon: Icon(
                    Icons.double_arrow,
                    size: 48,
                  ),
                ),
              ),
              roadConfiguration: RoadConfiguration(
                startIcon: MarkerIcon(
                  icon: Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.brown,
                  ),
                ),
                roadColor: Colors.yellowAccent,
              ),
              markerOption: MarkerOption(
                  defaultMarker: MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.transparent,
                  size: 56,
                ),
              )),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                    visible: showDetails,
                    child: Container(
                      width: width,
                      height: height / 2.25,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '"${selectedMarkerTitle}" teendő részletei',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28),
                            ),
                            Container(
                              width: width / 1.15,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .value ==
                                        4294967295
                                    ? Colors.grey[400]
                                    : Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                selectedMarkerDescription.split(" ").length > 20
                                    ? selectedMarkerDescription
                                            .split(" ")
                                            .sublist(0, 20)
                                            .join(" ") +
                                        "..."
                                    : selectedMarkerDescription,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: width / 4.5,
                                ),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        showDetails = false;
                                      });
                                    },
                                    child: Center(
                                        child: Text(
                                      "Becsukás",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ))),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        delete(selectedMarkerId);
                                        showDetails = false;
                                      });
                                    },
                                    child: Center(
                                        child: Text(
                                      "Törlés/kész",
                                      style: TextStyle(color: Colors.redAccent),
                                    ))),
                              ],
                            )
                          ],
                        ),
                      ),
                    )),
                Visibility(
                  visible: showMenu,
                  child: Container(
                    width: width,
                    height: height / 1.5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Új teendő",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 28),
                        ),
                        Container(
                          width: width / 1.15,
                          child: TextField(
                            controller: _titleController,
                            autofocus: true,
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            decoration: InputDecoration(
                              hintText: "Teendő címe",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: width / 1.15,
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            decoration: InputDecoration(
                              hintText: "Teendő leírása",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: Text(
                              "Végrehajtás ekkor",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Center(
                              child: Checkbox(
                                value: executeWhenEnabled,
                                checkColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                onChanged: (value) {
                                  setState(() {
                                    executeWhenEnabled = value!;
                                    if (executeWhenEnabled == false) {
                                      partOfTheDaySet = 4;
                                    }
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            )
                          ],
                        ),
                        Visibility(
                          visible: executeWhenEnabled,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    partOfTheDaySet = 0;
                                  });
                                },
                                child: Container(
                                  width: 64,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: partOfTheDaySet == 0
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Reggel",
                                      style: TextStyle(
                                          color: partOfTheDay == 0
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context).primaryColor,
                                          fontWeight: partOfTheDaySet == 0
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    partOfTheDaySet = 1;
                                  });
                                },
                                child: Container(
                                  width: 64,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: partOfTheDaySet == 1
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Délelőtt",
                                      style: TextStyle(
                                          color: partOfTheDaySet == 1
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context).primaryColor,
                                          fontWeight: partOfTheDaySet == 1
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    partOfTheDaySet = 2;
                                  });
                                },
                                child: Container(
                                  width: 64,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: partOfTheDaySet == 2
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Délután",
                                      style: TextStyle(
                                          color: partOfTheDaySet == 2
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context).primaryColor,
                                          fontWeight: partOfTheDaySet == 2
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    partOfTheDaySet = 3;
                                  });
                                },
                                child: Container(
                                  width: 64,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: partOfTheDaySet == 3
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Este",
                                      style: TextStyle(
                                          color: partOfTheDaySet == 3
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context).primaryColor,
                                          fontWeight: partOfTheDaySet == 3
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_titleController.text.isEmpty &&
                                _descriptionController.text.isEmpty) {
                              return;
                            } else {
                              saveNote();
                            }
                          },
                          child: Container(
                            width: width / 1.5,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                                child: Text(
                              "Mentés",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                showMenu = false;
                              });
                            },
                            child: Center(
                                child: Text(
                              "Mégse",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: Visibility(
          visible: showMenu ? false : true,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                controller.goToLocation(
                    GeoPoint(latitude: latCurrent, longitude: longCurrent));
                for (int i = 0; i < 4; i++) {
                  controller.zoomIn();
                }
              });
            },
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: Icon(
              Icons.place,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ));
  }
}
