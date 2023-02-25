import 'package:wear/wear.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin<MapScreen> {

  late CameraPosition initialCamera;

  //the blue pin showing the users location
  Marker userMarker = Marker(
    flat: true,
    markerId: userMarkerId,
    icon: userMarkerIcon,
    position: const LatLng(
      29.649784,
      -82.348671,
    ),
  );
  static const MarkerId userMarkerId = MarkerId("userLocation");
  static BitmapDescriptor userMarkerIcon = BitmapDescriptor
      .defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  //TODO: we can use something like this for the circles of the peers
  //each peer has an ID and map the id to their circle
  //Map<int, Marker> peerCircles = <int, Marker>{};

  @override
  void initState() {
    super.initState();

    initialCamera = const CameraPosition(
        target: LatLng(
          //initialLatitude,
          //initialLongitude,
          29.649784,
          -82.348671,
        ),
        zoom: 10.0
    );
  }

  _MapScreenState();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: WatchShape(
        builder: (context, shape, widget) {
          return Center(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: initialCamera,
              markers: <Marker>{userMarker},
              scrollGesturesEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
            )
          );
        }
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}