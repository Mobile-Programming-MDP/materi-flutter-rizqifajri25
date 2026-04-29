import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/note_services.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteDialog extends StatefulWidget {
  final Note? note;

  const NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _imageFile;
  String? _base64Image;
  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _base64Image = widget.note!.imageBase64;
      _latitude = widget.note!.latitude;
      _longitude = widget.note!.longitude;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _base64Image = base64String;
        _imageFile = File(pickedFile.path);
      });
    } else {
      debugPrint("No image selected.");
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Layanan Lokasi Dinonaktifkan."),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Izin Lokasi Ditolak."),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Izin Lokasi Ditolak Permanen."),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lokasi berhasil diambil: $_latitude, $_longitude"),
        ),
      );
    } catch (e) {
      debugPrint("Failed to retrieve location: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Gagal Mengambil Lokasi."),
        ),
      );

      setState(() {
        _latitude = null;
        _longitude = null;
      });
    }
  }

  Future<void> openMap() async{
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_latitude}, ${_longitude}',
    );
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if(!mounted) return;
    if(!success){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("gagal Membuka Peta")),
        );
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title:'),
              TextField(controller: _titleController),

              const SizedBox(height: 20),
              const Text('Description:'),
              TextField(controller: _descriptionController),

              const SizedBox(height: 20),
              const Text('Image:'),

              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: _base64Image != null
                    ? Image.memory(
                        base64Decode(_base64Image!),
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),

              TextButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),

              TextButton(
                onPressed: _getLocation,
                child: const Text('Get Current Location'),
              ),

              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 10),
                Text('Latitude: $_latitude'),
                Text('Longitude: $_longitude'),
              ],
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.note == null) {
              NoteService.addNote(
                Note(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  imageBase64: _base64Image,
                  latitude: _latitude,
                  longitude: _longitude,
                ),
              ).whenComplete(() {
                Navigator.of(context).pop();
              });
            } else {
              NoteService.updateNote(
                Note(
                  id: widget.note!.id,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  createdAt: widget.note!.createdAt,
                  imageBase64: _base64Image,
                  latitude: _latitude,
                  longitude: _longitude,
                ),
              ).whenComplete(() {
                Navigator.of(context).pop();
              });
            }
          },
          child: Text(widget.note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}