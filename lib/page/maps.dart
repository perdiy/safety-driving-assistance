import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:safe/model/location_spot_model.dart';
import 'package:safe/page/add_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  List<LocationSpotModel> spots = [];
  List<LocationSpotModel> spotsFromAdmin = [];
  List<Marker> markers = [];

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController mapController;
  late LocationPermission permission;
  CollectionReference locationSpot = FirebaseFirestore.instance.collection('location_spot');
  Stream<QuerySnapshot> locationStream = FirebaseFirestore.instance.collection('location_spot').orderBy('created_at').snapshots();
  PolylinePoints polylinePoints = PolylinePoints();

  LatLng userPosition = const LatLng(0, 0);
  LatLng selectedPosition = const LatLng(0, 0);
  List<LatLng> polylineCoordinates = <LatLng>[];
  Map<PolylineId, Polyline> polylines = {};
  LocationSpotModel? currentDetail;
  bool loading = false;
  String currentUser = '';

  // custom marker
  BitmapDescriptor kecelakaanMarker = BitmapDescriptor.defaultMarker;
  BitmapDescriptor kemacetanMarker = BitmapDescriptor.defaultMarker;
  BitmapDescriptor rawanKecelakaanMarker = BitmapDescriptor.defaultMarker;
  BitmapDescriptor penutupanJalanMarker = BitmapDescriptor.defaultMarker;

  // 0: default, 1: pick location
  int formStep = 0;

  // last time notification
  DateTime? lastNotificationTime;

  checkNearestSpot() async {
    // prevent show notification if the last notification time is less than 2 minutes ago
    if (lastNotificationTime != null && DateTime.now().difference(lastNotificationTime!).inMinutes <= 2) {
      return;
    }

    List<LocationSpotModel> nearestSpot = [
      ...spotsFromAdmin.where((element) => element.distance != null && element.distance! <= 0.4).toList(),
      ...spots.where((element) => element.distance != null && element.distance! <= 0.4).toList(),
    ];

    nearestSpot.sort((a, b) {
      if (a.distance == null) {
        return 0;
      }

      return a.distance!.compareTo(b.distance!);
    });

    if (nearestSpot.isNotEmpty) {
      String? category = nearestSpot.first.category?.name;
      int distance = nearestSpot.first.distance != null ? ((nearestSpot.first.distance! * 1000).round() == 0 ? 1 : (nearestSpot.first.distance! * 1000).round()) : 0;
      String message = 'Hati hati dalam $distance meter, ada titik $category.';

      if (category != null) {
        lastNotificationTime = DateTime.now();

        FlutterTts flutterTts = FlutterTts();
        await flutterTts.setLanguage('id-ID');

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          )
        );

        await flutterTts.speak(message);
      }
    }
  }

  updateSpotDistance({ bool fromStream = false }) {
    spots = spots.map((e) {
      LocationSpotModel currentSpot = e;

      num distanceBetweenPoints = mp.SphericalUtil.computeDistanceBetween(
        mp.LatLng(userPosition.latitude, userPosition.longitude),
        mp.LatLng(currentSpot.location.latitude, currentSpot.location.longitude)
      );

      currentSpot.distance = distanceBetweenPoints / 1000;

      return currentSpot;
    }).toList();

    spotsFromAdmin = spotsFromAdmin.map((e) {
      LocationSpotModel currentSpot = e;

      num distanceBetweenPoints = mp.SphericalUtil.computeDistanceBetween(
        mp.LatLng(userPosition.latitude, userPosition.longitude),
        mp.LatLng(currentSpot.location.latitude, currentSpot.location.longitude)
      );

      currentSpot.distance = distanceBetweenPoints / 1000;

      return currentSpot;
    }).toList();

    spotsFromAdmin.sort((a, b) {
      if (a.distance == null) {
        return 0;
      }

      return a.distance!.compareTo(b.distance!);
    });

    spots.sort((a, b) {
      if (a.distance == null) {
        return 0;
      }

      return a.distance!.compareTo(b.distance!);
    });

    if (!fromStream) {
      setState(() {});
    }
  }

  handleInitialPosition() async {
    // set current user id
    final prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString('userId') ?? '';

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      setState(() {});
    }

    // real time location update
    Geolocator.getPositionStream().listen( (Position? position) {
      if (position != null) {
        setState(() {
          // animate camera only if user position havent updated
          // if already set, then dont animate camera
          if (userPosition.latitude == 0) {
            mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 12));
          }

          userPosition = LatLng(position.latitude, position.longitude);

          // update spot distance
          updateSpotDistance();

          // check for nearest spot
          checkNearestSpot();
        });
      }
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<BitmapDescriptor> customMarker(String path) async {
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset(path, 110)
    );

    return icon;
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double x0 = 0;
    double x1 = 0;
    double y1 = 0;
    double y0 = 0;
    for (LatLng latLng in list) {
      if (x0 == 0) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  updatePolyline() {
    PolylineId id = const PolylineId('route');
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      color: polylineCoordinates.isEmpty ? Colors.transparent : Colors.blue,
      width: 5
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  openDetail(LocationSpotModel spot) async {
    setState(() {
      currentDetail = spot;
    });

    if (userPosition.latitude != 0) {
      // finding polyline from two location
      // 1st: current user location
      // 2nd: destination location
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDr1FkdGTNvnySoBYdm7zZttr6ixPMYbZ8',
        PointLatLng(userPosition.latitude, userPosition.longitude),
        PointLatLng(currentDetail!.location.latitude, currentDetail!.location.longitude),
        avoidFerries: true,
        avoidHighways: true,
        avoidTolls: true
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();

        // adding to polyline list
        polylineCoordinates = result.points.map((point) =>  LatLng(point.latitude, point.longitude)).toList();

        updatePolyline();

        // animate google map camera between polyline
        mapController.animateCamera(CameraUpdate.newLatLngBounds(
          boundsFromLatLngList(polylineCoordinates), 36
        ));
      }
    } else {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(spot.location.latitude, spot.location.longitude), 14)
      );
    }
  }

  deleteSpot(LocationSpotModel spot) async {
    final OkCancelResult result = await showOkCancelAlertDialog(
      title: 'Hapus lokasi?',
      message: 'Konfirmasi jika kamu ingin menghapus lokasi ini.',
      context: context,
    );

    if (result == OkCancelResult.ok) {
      setState(() {
        loading = true;
      });

      locationSpot.doc(spot.id).delete().then((value) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menghapus lokasi!'),
            behavior: SnackBarBehavior.floating,
          )
        );
      }).catchError((err) {
        setState(() {
          loading = false;
        });
      });
    }
  }

  loadMarker() async {
    kecelakaanMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 1, size: Size(16, 16)), "assets/images/car-accident-32x32.png");
    kemacetanMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 1, size: Size(16, 16)), "assets/images/traffic-jam-32x32.png");
    rawanKecelakaanMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 1, size: Size(16, 16)), "assets/images/warning-32x32.png");
    penutupanJalanMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(devicePixelRatio: 1, size: Size(16, 16)), "assets/images/traffic-barrier-32x32.png");
  }

  BitmapDescriptor resolveMarker(String id) {
    if (id == 'penutupan_jalan') {
      return penutupanJalanMarker;
    }

    if (id == 'kemacetan') { 
      return kemacetanMarker;
    }

    if (id == 'rawan_kecelakaan') {
      return rawanKecelakaanMarker;
    }

    return kecelakaanMarker;
  }

  @override
  void initState() {
    loadMarker();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: locationStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          // admin spot
          spotsFromAdmin = snapshot.data!.docs.where((element) {
            final data = element.data() as Map<String, dynamic>;

            return data['from_admin'] == true;
          }).map((doc) => LocationSpotModel.fromSnapshot(doc)).toList();

          // user spot
          spots = snapshot.data!.docs.where((element) {
            final data = element.data() as Map<String, dynamic>;

            return data['from_admin'] == null || data['from_admin'] == false;
          }).map((doc) => LocationSpotModel.fromSnapshot(doc)).toList();

          updateSpotDistance(fromStream: true);

          // work around updating current detail
          if (currentDetail != null) {
            currentDetail = [...spots, ...spotsFromAdmin].cast<LocationSpotModel?>().firstWhere(
              (element) => element?.id == currentDetail!.id,
              orElse: () => null
            );
          }

          markers = [
            ...spotsFromAdmin.map((spot) {
              return Marker(
                markerId: MarkerId(spot.id),
                position: LatLng(spot.location.latitude, spot.location.longitude),
                onTap: () => openDetail(spot),
                consumeTapEvents: true,
                icon: resolveMarker(spot.category?.id ?? '')
              );
            }).toList(),
            ...spots.map((spot) {
              return Marker(
                markerId: MarkerId(spot.id),
                position: LatLng(spot.location.latitude, spot.location.longitude),
                onTap: () => openDetail(spot),
                consumeTapEvents: true,
                icon: resolveMarker(spot.category?.id ?? '')
              );
            }).toList()
          ];
        }

        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: const Text('Maps '),
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Lokasi Rawan Kecelakaan Data Polres Kota Bogor',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 24),
                      spotsFromAdmin.isEmpty ? const Text(
                        'Belum ada lokasi',
                        style: TextStyle(
                          color: Colors.grey
                        ),
                      ) : const SizedBox(),
                      ...spotsFromAdmin.map((item) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          openDetail(item);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.5, color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.category?.name ?? '',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                              ),
                              const SizedBox(height: 8),
                              item.distance != null ? Row(
                                children: [
                                  const Icon(Icons.location_pin, size: 16),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.distance!.toStringAsFixed(2)} Km',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ) : const SizedBox()
                            ],
                          ),
                        ),
                      )).toList(),
                      const SizedBox(height: 24),
                      const Text(
                        'List Lokasi Rawan Kecelakaan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...spots.map((item) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          openDetail(item);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(width: 0.5, color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.category?.name ?? '',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('dd MMMM y · HH.mm', 'id_ID').format(
                                      DateTime.parse(item.createdAt.toDate().toString())
                                    ),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13
                                    ),
                                  ),
                                  const Spacer(),
                                  item.distance != null ? Row(
                                    children: [
                                      const Icon(Icons.location_pin, size: 16),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.distance!.toStringAsFixed(2)} Km',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ) : const SizedBox()
                                ],
                              )
                            ],
                          ),
                        ),
                      )).toList()
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(child: GoogleMap(
                onMapCreated: (GoogleMapController controller) async {
                  mapController = controller;
                  await handleInitialPosition();
                },
                initialCameraPosition: CameraPosition(target: userPosition),
                myLocationEnabled: true,
                markers: formStep == 0 ? Set<Marker>.of(markers) : const <Marker>{},
                polylines: Set<Polyline>.of(polylines.values),
                padding: const EdgeInsets.only(bottom: 16),
                onCameraMove: (position) {
                  selectedPosition = position.target;
                },
              )),
              formStep == 0 ? Positioned(
                top: 32,
                child: Container(
                  color: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_right_outlined, size: 32),
                    onPressed: () => scaffoldKey.currentState!.openDrawer(),
                  ),
                ),
              ) : const SizedBox(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formStep == 0) {
                        setState(() {                        
                          formStep = 1;

                          mapController.animateCamera(CameraUpdate.zoomIn());
                        });
                      } else if (formStep == 1) {
                        showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          enableDrag: false,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return AddLocation(
                              selectedPosition: selectedPosition,
                            );
                          }
                        );

                        setState(() {
                          formStep = 0;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      formStep == 0 ? 'Tambah Lokasi' : 'Pilih Lokasi',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  )
                ),
              ),
              formStep == 1 ? const Center(
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 28,
                ),
              ) : const SizedBox(),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                bottom: currentDetail != null ? 16 : -100,
                left: 0,
                curve: Curves.easeIn,
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: currentDetail == null ? const SizedBox() : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detail',
                            style: TextStyle(
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                currentDetail = null;
                                polylineCoordinates.clear();
                                updatePolyline();
                              });
                            },
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Text(
                        currentDetail?.category?.name ?? '',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentDetail!.description,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            DateFormat('dd MMMM y · HH.mm', 'id_ID').format(
                              DateTime.parse(currentDetail!.createdAt.toDate().toString())
                            ),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13
                            ),
                          ),
                          const Spacer(),
                          currentDetail?.distance != null ? Row(
                            children: [
                              const Icon(Icons.location_pin, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                '${currentDetail!.distance!.toStringAsFixed(2)} Km',
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ) : const SizedBox()
                        ],
                      ),
                      currentUser == currentDetail!.createdBy ? const Divider(height: 24) : const SizedBox(),
                      currentUser == currentDetail!.createdBy ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isDismissible: false,
                                enableDrag: false,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return AddLocation(
                                    selectedPosition: selectedPosition,
                                    initialData: currentDetail,
                                  );
                                }
                              );
                            },
                            child: const Text('Ubah')
                          ),
                          TextButton(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => deleteSpot(currentDetail!),
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                color: Colors.red
                              ),
                            )
                          )
                        ],
                      ) : const SizedBox()
                    ],
                  ),
                ),
              ),
              loading ? Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator())
              ) : const SizedBox()
            ],
          )
        );
      }
    );
  }
}
