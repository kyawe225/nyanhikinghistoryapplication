
import 'package:flutter/material.dart';
import 'package:hiking_app_one/database/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/providers/hike_provider.dart';

class AddEditHikeScreen extends ConsumerStatefulWidget {
  final Hikehistory? hike;

  const AddEditHikeScreen({super.key, this.hike});

  @override
  ConsumerState<AddEditHikeScreen> createState() => _AddEditHikeScreenState();
}

class _AddEditHikeScreenState extends ConsumerState<AddEditHikeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _lengthController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _parkingAvailable = false;
  String _difficultyLevel = 'Easy';
  bool _freeParking = false;
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    if (widget.hike != null) {
      final hike = widget.hike!;
      _nameController.text = hike.name;
      _locationController.text = hike.location;
      _selectedDate = hike.hikedDate;
      _parkingAvailable = hike.parkingAvailable;
      _lengthController.text = hike.lengthOfHike.toString();
      _difficultyLevel = hike.difficultyLevel;
      _descriptionController.text = hike.description;
      _freeParking = hike.freeParking;
      _isFavourite = hike.isFavourite;
    }
  }

  Future<void> _saveHike() async {
    if (_formKey.currentState!.validate()) {
      final hike = Hikehistory(
        id: widget.hike?.id ?? const Uuid().v4(),
        name: _nameController.text,
        location: _locationController.text,
        hikedDate: _selectedDate,
        parkingAvailable: _parkingAvailable,
        lengthOfHike: double.parse(_lengthController.text),
        difficultyLevel: _difficultyLevel,
        description: _descriptionController.text,
        freeParking: _freeParking,
        isFavourite: _isFavourite,
      );

      if (widget.hike != null) {
        await ref.read(hikesProvider.notifier).updateHike(hike);
      } else {
        await ref.read(hikesProvider.notifier).addHike(hike);
      }

      // If this screen is part of a tab, we don't want to pop it.
      // We only pop if it was pushed as a route (e.g., from the FloatingActionButton on HomeScreen)
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Try reverse geocoding; if it fails (platform unsupported or runtime error),
      // fall back to showing "lat, lon".
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _locationController.text = "${place.locality ?? ''}${place.locality != null && place.country != null ? ', ' : ''}${place.country ?? ''}".trim().replaceAll(RegExp(r'^,|,$'), '');
          });
          return;
        }
        // If placemarks empty, fallback:
        setState(() {
          _locationController.text = "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
        });
      } catch (e) {
        // Reverse geocoding failed (common on some desktop setups) — fallback to coordinates.
        setState(() {
          _locationController.text = "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not resolve address, using coordinates instead.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hike != null ? 'Edit Hike' : 'Add Hike'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location *'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(labelText: 'Length (km) *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the length';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Date of Hike:'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                initialValue: _difficultyLevel,
                decoration: const InputDecoration(labelText: 'Difficulty Level'),
                items: ['Easy', 'Medium', 'Hard'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _difficultyLevel = newValue!;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Parking Available'),
                value: _parkingAvailable,
                onChanged: (value) {
                  setState(() {
                    _parkingAvailable = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Free Parking'),
                value: _freeParking,
                onChanged: (value) {
                  setState(() {
                    _freeParking = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Favourite'),
                value: _isFavourite,
                onChanged: (value) {
                  setState(() {
                    _isFavourite = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveHike,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}