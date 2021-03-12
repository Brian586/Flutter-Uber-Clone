import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllScreens/searchScreen.dart';
import 'package:rider_app/Assistants/assistantMethods.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/widgets/Divider.dart';
import 'package:rider_app/widgets/progressDialog.dart';


class MainScreen extends StatefulWidget {

  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;


    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));


    String address = await AssistantMethods.searchCoordinateAddress(position, context);
    print("Your address :: " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> getPlaceDirection() async {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLang = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLang = LatLng(finalPos.latitude, finalPos.longitude);


    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...")
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLang, dropOffLatLang);

    Navigator.pop(context);

    print("This is Encoded points :: ");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolilinePointResult = polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if(decodedPolilinePointResult.isNotEmpty)
      {
        decodedPolilinePointResult.forEach((PointLatLng pointLatLng) {
          pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });
      }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if(pickUpLatLang.latitude > dropOffLatLang.latitude && pickUpLatLang.longitude > dropOffLatLang.longitude)
      {
        latLngBounds = LatLngBounds(southwest: dropOffLatLang, northeast: pickUpLatLang);
      }
    else if(pickUpLatLang.longitude > dropOffLatLang.longitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLang.latitude, dropOffLatLang.longitude), northeast: LatLng(dropOffLatLang.latitude, pickUpLatLang.longitude));
    }
    else if(pickUpLatLang.latitude > dropOffLatLang.latitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLang.latitude, pickUpLatLang.longitude), northeast: LatLng(pickUpLatLang.latitude, dropOffLatLang.longitude));
    }
    else
      {
        latLngBounds = LatLngBounds(southwest: pickUpLatLang, northeast: dropOffLatLang);
      }

    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickUpLatLang,
      markerId: MarkerId("pickUpId")
    );

    Marker dropOffLocationMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
        position: dropOffLatLang,
        markerId: MarkerId("dropOffId")
    );

    setState(() {
      markersSet.add(pickUpLocationMarker);
      markersSet.add(dropOffLocationMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLang,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId")
    );

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.purple,
        center: dropOffLatLang,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.purple,
        circleId: CircleId("dropOffId")
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Main Screen", style: TextStyle(fontFamily: "Brand Bold"),),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png", height: 65.0, width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name", style: TextStyle(fontSize: 16.0, fontFamily: "Brand Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Visit Profile"),
                        ],
                      )
                    ]
                  ),
                ),
              ),

              DividerWidget(),
              SizedBox(height: 12.0,),

              //Drawer body contents
              ListTile(
                leading: Icon(Icons.history),
                title: Text("Ride History", style: TextStyle(fontSize: 15.0),),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Visit Profile", style: TextStyle(fontSize: 15.0),),
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("About", style: TextStyle(fontSize: 15.0),),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            markers: markersSet,
            circles: circlesSet,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });

              locatePosition();
            },
          ),
          //DRAWER
          Positioned(
            top: 45.0,
            left: 22.0,
            child: InkWell(
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.menu, color: Colors.black,),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7)
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0,),
                    Text("Hey There", style: TextStyle(fontSize: 12.0),),
                    Text("Where to?", style: TextStyle(fontSize: 20.0, fontFamily: "Brand Bold"),),
                    SizedBox(height: 20.0,),

                    InkWell(
                      onTap: () async {
                        var res = await Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen()));

                        if(res == "obtainDirection")
                          {
                            await getPlaceDirection();
                          }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7)
                              )
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.blueAccent,),
                              SizedBox(width: 10.0,),
                              Text("Search Drop Off")
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      children: [
                        Icon(Icons.home, color: Colors.grey,),
                        SizedBox(width: 12.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                            Provider.of<AppData>(context).pickUpLocation != null
                                ? Provider.of<AppData>(context).pickUpLocation.placeName
                                : "Add Home",
                            ),
                            SizedBox(height: 4.0,),
                            Text("Your living Home Address", style: TextStyle(color: Colors.black54, fontSize: 12.0),)
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),

                    DividerWidget(),

                    SizedBox(
                      height: 16.0,
                    ),

                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.grey,),
                        SizedBox(width: 12.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add Work", ),
                            SizedBox(height: 4.0,),
                            Text("Your Office Address", style: TextStyle(color: Colors.black54, fontSize: 12.0),)
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
