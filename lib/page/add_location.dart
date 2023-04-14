import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/model/location_spot_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocation extends StatefulWidget {
  final LatLng selectedPosition;
  final LocationSpotModel? initialData;
  const AddLocation({super.key, required this.selectedPosition, this.initialData});

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<CategoryModel> categories = [
    CategoryModel(id: 'kecelakaan', name: 'Kecelakaan', icon: 'car-accident.png'),
    CategoryModel(id: 'penutupan_jalan', name: 'Penutupan Jalan', icon: 'traffic-barrier.png'),
    CategoryModel(id: 'kemacetan', name: 'Kemacetan', icon: 'traffic-jam.png'),
    CategoryModel(id: 'rawan_kecelakaan', name: 'Rawan Kecelakaan', icon: 'warning.png'),
  ];
  CollectionReference locationSpot = FirebaseFirestore.instance.collection('location_spot');
  bool loadingSubmit = false;
  String description = '';
  CategoryModel? selectedCategory;

  handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final bool isAdmin = prefs.getBool('isAdmin') ?? false;

    if (description.isEmpty) {
      return ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(
        const SnackBar(
          content: Text('Deskripsi harus diisi'),
          behavior: SnackBarBehavior.floating,
        )
      );
    }

    setState(() {
      loadingSubmit = true;
    });

    if (widget.initialData != null) {
      // update the thing
      locationSpot.doc(widget.initialData!.id).update({
        'category': selectedCategory!.id,
        'description': description,
      }).then((value) {
        setState(() {
          loadingSubmit = false;
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil update detail lokasi!'),
            behavior: SnackBarBehavior.floating,
          )
        );
      }).catchError((err) {
        setState(() {
          loadingSubmit = false;
        });
      });
    } else {
      locationSpot.add({
        'category': selectedCategory!.id,
        'created_at': FieldValue.serverTimestamp(),
        'created_by': userId,
        'description': description,
        'location': GeoPoint(widget.selectedPosition.latitude, widget.selectedPosition.longitude),
        'from_admin': isAdmin
      }).then((value) {
        setState(() {
          loadingSubmit = false;
        });

        Navigator.of(context).pop();
      }).catchError((err) {
        setState(() {
          loadingSubmit = false;
        });
      });
    }
  }

  @override
  void initState() {
    selectedCategory = categories.first;

    LocationSpotModel? data = widget.initialData;
    if (data != null) {
      setState(() {
        selectedCategory = categories.firstWhere((element) => element.id == data.category?.id);
        description = data.description;
      });
    } 

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Scaffold(
        key: scaffoldKey,
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Lokasi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  childAspectRatio: (1 / .6),
                  physics: const NeverScrollableScrollPhysics(),
                  children: categories.map((item) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = item;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: selectedCategory == item ? 2.0 : 0.5,
                          color: selectedCategory == item ? Colors.blue : Colors.grey
                        ),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/${item.icon}',
                            height: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
                TextFormField(
                  maxLines: 3,
                  minLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    hintText: 'Deskripsi...',
                  ),
                  initialValue: description,
                  onChanged: (value) {
                    description = value;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => handleSubmit(),
                    child: !loadingSubmit ? const Text('Submit') : const Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}