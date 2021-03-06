import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/Models/directionDetails.dart';
import 'package:rider_app/configMaps.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if(response != "Failed")
      {
        placeAddress = response["results"][0]["formatted_address"];
        // st1 = response["results"][0]["address_components"][3]["long_name"];
        // st2 = response["results"][0]["address_components"][4]["long_name"];
        // st3 = response["results"][0]["address_components"][5]["long_name"];
        // st4 = response["results"][0]["address_components"][6]["long_name"];
        //
        // placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

        Address userPickUpAddress = Address();
        userPickUpAddress.longitude = position.longitude;
        userPickUpAddress.latitude = position.latitude;
        userPickUpAddress.placeName = placeAddress;

        Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
      }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(directionUrl);

    if(response == "Failed")
      {
        return null;
      }

    DirectionDetails directionDetails = DirectionDetails(
      encodedPoints: response["routes"][0]["overview_polyline"]["points"],
      distanceText: response["routes"][0]["legs"][0]["distance"]["text"],
      distanceValue: response["routes"][0]["legs"][0]["distance"]["value"],
      durationText: response["routes"][0]["legs"][0]["duration"]["text"],
      durationValue: response["routes"][0]["legs"][0]["duration"]["value"],
    );

    return directionDetails;

  }

}