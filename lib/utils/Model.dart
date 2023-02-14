import 'dart:typed_data';

class NoteModel {
  final int? id;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final int? partOfTheDay;

  NoteModel({
    this.id,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    this.partOfTheDay,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      partOfTheDay: map['partOfTheDay'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'partOfTheDay': partOfTheDay,
    };
  }
}
