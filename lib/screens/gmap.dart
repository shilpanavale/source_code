/*
import 'dart:async';
import 'package:webixes/other_config.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;



const kGoogleApiKey = "TOUR_API_KEY";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: OtherConfig.GOOGLE_MAP_API_KEY);



class MapViewDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapViewDemoState();
  }
}

class MapViewDemoState extends State<MapViewDemo> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  int _markerIdCounter = 1;
 // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  static  LatLng _initialcameraposition = const LatLng(45.521563, -122.677433);
  LatLng _lastMapPosition = _initialcameraposition;

  LocationManager.Location location = LocationManager.Location();
  LocationManager.LocationData _currentPosition;

  final Set<Marker> _markers = {};
  @override
  Widget build(BuildContext context) {
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: CircularProgressIndicator(value: null));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }

    return Scaffold(
        key: homeScaffoldKey,
        appBar: AppBar(
          title: const Text("PlaceZ"),
          actions: <Widget>[
            isLoading
                ? IconButton(
              icon: Icon(Icons.timer),
              onPressed: () {},
            )
                : IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                refresh();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _handlePressButton();
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: SizedBox(
                  height: 200.0,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    //markers:Set<Marker>.of(_markers.toSet()),
                    onMapCreated: _onMapCreated,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target:_initialcameraposition,
                      zoom: 14.4746,
                    ),
                      */
/*options: GoogleMapOptions(
                          myLocationEnabled: true,
                          cameraPosition:
                          const CameraPosition(target: LatLng(0.0, 0.0))),*//*

                    )),
            ),
            Expanded(child: expandedChild)
          ],
        ));
  }

  void refresh() async {
    final center = await getUserLocation();

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
    getNearbyPlaces(center);
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
   */
/* String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    mapController.setMapStyle(value);*//*

    refresh();
  }
  Future<LatLng> getUserLocation() async {
    bool _serviceEnabled;
    LocationManager.PermissionStatus _permissionGranted;
    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude, _currentPosition.longitude);
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return _initialcameraposition;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == LocationManager.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != LocationManager.PermissionStatus.granted) {
        return _initialcameraposition;
      }
    }

    _currentPosition = await location.getLocation();

    _initialcameraposition =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);

    location.onLocationChanged
        .listen((LocationManager.LocationData currentLocation) {
      print("${currentLocation.longitude} : ${currentLocation.longitude}");

    });
    return _initialcameraposition;
  }
  */
/*Future<LatLng> getUserLocation() async {
    var currentLocation = <String, double>{};
    final location = LocationManager.Location();
    try {
      //Location location = Location();
      final LocationManager.LocationData pos = await location.getLocation();
        setState(() {
          print(pos.runtimeType);
          _lastMapPosition = pos.longitude;
        });

      final lat = pos.latitude;
      final lng = pos.longitude;
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }*//*


  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(lat: center.latitude, lng:center.longitude,);
    final result = await _places.searchNearbyWithRadius(location, 2500);
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        result.results.forEach((f) {
       */
/*   _markers.add(Marker(
// This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId(_lastMapPosition.toString()),
            position: LatLng(
              f.geometry.location.lat,
              f.geometry.location.lng,
            ),
            infoWindow: InfoWindow(
                title: "${f.name}", snippet: "${f.types?.first}"
            ),
            icon: BitmapDescriptor.defaultMarker,
          ));*//*

        });
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.fullscreen,
          language: "en",
          location: center == null
              ? null
              : Location(lat:center.latitude, lng:center.longitude),
          radius: center == null ? null : 10000);

      showDetailPlace(p.placeId);
    } catch (e) {
      return;
    }
  }

  Future<Null> showDetailPlace(String placeId) async {
    */
/*if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
      );
    }*//*

  }

  ListView buildPlacesList() {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            f.name,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        )
      ];
      if (f.formattedAddress != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.formattedAddress,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ));
      }

      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.vicinity,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ));
      }

      if (f.types?.first != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.types.first,
            style: Theme.of(context).textTheme.caption,
          ),
        ));
      }

      return Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
        child: Card(
          child: InkWell(
            onTap: () {
              showDetailPlace(f.placeId);
            },
            highlightColor: Colors.lightBlueAccent,
            splashColor: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }
}*/
