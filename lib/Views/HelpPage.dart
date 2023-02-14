import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text('Súgó'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi ez az alkalmazás?',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                'Az alkalmazás lehetővé teszi a felhasználóknak, hogy a térképen (helyalapú) teendőket mentsenek el és, amikor közel érnek, az elmentett teendő helyéhez, értesítést kapjanak a teendőről.\n',
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).primaryColor),
              ),
              Text(
                'Gombosűk elhelyezése',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                'A gombosűk elhelyezése nagyon egyszerű: navigáljon a térképen a helyhez, ahova teendőt szeretne elmenteni, és nyomjon rá a térképen a kiválaszott helyre.\nHa ez megvan, egy menü fog megjelenni, ahol megadhat egy címet a teendőnek, illetve egy rövidebb leírást. Ha ezeket megadta, nyomja meg a Mentés gombot, és a teendő el lesz mentve a térképen. \n',
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).primaryColor),
              ),
              Text(
                'Mikor kapok értesítést a teendőimről?',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                'Ha az elmentett teendő helyének 100 méteres körzetébe ér, egy értesítést fog kapni a teendjéről. \n',
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).primaryColor),
              ),
              Text(
                'Teendők törlése',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                'Ha ki szeretné törölni egy vagy akár több teendőjét, akkor kattintson rá a térképen elmentett teendő gombostűjére. Egy menü fog megjelenni a képernyő tetején. Válassza ki a "Törlés/kész" gombot és nyomjon rá! \n',
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
