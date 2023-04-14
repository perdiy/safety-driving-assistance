import 'package:cloud_firestore/cloud_firestore.dart';

class LocationSpotModel {
  String id;
  CategoryModel? category;
  String description;
  String createdBy;
  GeoPoint location;
  Timestamp createdAt;
  double? distance;

  LocationSpotModel({
    required this.id,
    required this.description,
    required this.location,
    required this.createdAt,
    required this.createdBy,
    this.category,
    this.distance
  });


  factory LocationSpotModel.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    CategoryModel findCategory(String id) {
      if (id == 'penutupan_jalan') {
        return CategoryModel(id: 'penutupan_jalan', name: 'Penutupan Jalan', icon: 'traffic-barrier.png');
      }

      if (id == 'kemacetan') {
        return CategoryModel(id: 'kemacetan', name: 'Kemacetan', icon: 'traffic-jam.png');
      }

      if (id == 'rawan_kecelakaan') {
        return CategoryModel(id: 'rawan_kecelakaan', name: 'Rawan Kecelakaan', icon: 'warning.png');
      }

      return CategoryModel(id: 'kecelakaan', name: 'Kecelakaan', icon: 'car-accident.png');
    }

    return LocationSpotModel(
      id: snapshot.id,
      category: data['category'] != null ? findCategory(data['category']) : null,
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      createdAt: data['created_at'] ?? Timestamp(0, 0),
      createdBy: data['created_by'] ?? '',
      distance: null
    );
  }
}

class CategoryModel {
  String id;
  String name;
  String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });
}
