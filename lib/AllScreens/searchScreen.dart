import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/Models/placePredictions.dart';
import 'package:rider_app/configMaps.dart';
import 'package:rider_app/widgets/Divider.dart';
import 'package:rider_app/widgets/progressDialog.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePrediction> placePredictionList = [];


  void findPlace(String placeName) async {
    if(placeName.length > 1)
      {
        String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:ke";

        var response = await RequestAssistant.getRequest(autoCompleteUrl);

        if(response == "Failed")
          {
            return;
          }

        if(response["status"] == "OK")
          {
            var predictions = response["predictions"];

            var placesList = (predictions as List).map((e) => PlacePrediction.fromJson(e)).toList();

            setState(() {
              placePredictionList = placesList;
            });
          }
      }
  }

  @override
  Widget build(BuildContext context) {

    String placeAddress = Provider.of<AppData>(context).pickUpLocation != null
        ? Provider.of<AppData>(context).pickUpLocation.placeName : "";
    pickUpTextEditingController.text = placeAddress;

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 215.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  )
                ]
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 25.0, top: 20.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: 5.0,),
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        Center(
                          child: Text("Set drop off", style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),),
                        )
                      ],
                    ),

                    SizedBox(height: 16.0,),
                    Row(
                      children: [
                        Image.asset("images/pickicon.png", height: 16.0, width: 16.0,),
                        SizedBox(width: 18.0,),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickUpTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "PickUp Location",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: 10.0,),
                    Row(
                      children: [
                        Image.asset("images/desticon.png", height: 16.0, width: 16.0,),
                        SizedBox(width: 18.0,),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.0),
                              child: TextField(
                                onChanged: (val) {
                                  findPlace(val);
                                },
                                controller: dropOffTextEditingController,
                                decoration: InputDecoration(
                                  hintText: "Where to?",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            placePredictionList.length > 0
                ? Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return PredictionTile(placePrediction: placePredictionList[index],);
                },
                separatorBuilder: (BuildContext context, int index) => DividerWidget(),
                itemCount: placePredictionList.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }
}

class PredictionTile extends StatelessWidget {

  final PlacePrediction placePrediction;
  PredictionTile({Key key, this.placePrediction}) : super(key: key);

  void getPlaceAddressDetails(String placeId, context) async {

    showDialog(
      context: context,
      builder: (BuildContext context)=> ProgressDialog(message: "Setting DropOff, Please wait...")
    );

    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var res = await RequestAssistant.getRequest(placeDetailsUrl);

    Navigator.pop(context);

    if(res == "Failed")
      {
        return;
      }

    if(res["status"] == "OK")
      {
        Address address = Address(
          placeName: res["result"]["name"],
          placeId: placeId,
          longitude: res["result"]["geometry"]["location"]["lng"],
          latitude: res["result"]["geometry"]["location"]["lat"],
        );

        Provider.of<AppData>(context, listen: false).updateDropOffLocationAddress(address);

        print("================" + address.placeName + "=============");

        Navigator.pop(context, "obtainDirection");

      }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        getPlaceAddressDetails(placePrediction.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 10.0,),
            Row(
              children: [
                Icon(Icons.add_location_alt_outlined),
                SizedBox(width: 14.0,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(placePrediction.main_text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0),),
                      SizedBox(height: 3.0,),
                      Text(placePrediction.secondary_text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, color: Colors.grey),)
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10.0,),
          ],
        ),
      ),
    );
  }
}

