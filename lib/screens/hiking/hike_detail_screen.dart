import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/database/entities.dart';
import 'package:hiking_app_one/providers/observation_provider.dart';
import 'package:hiking_app_one/providers/hike_provider.dart';
import 'package:hiking_app_one/screens/observation/add_observation_screen.dart';
import 'package:hiking_app_one/screens/observation/observation_screen.dart';

class HikeDetailScreen extends ConsumerStatefulWidget {
  final Hikehistory hike;

  const HikeDetailScreen({super.key, required this.hike});

  @override
  ConsumerState<HikeDetailScreen> createState() => _HikeDetailScreenState();
}

class _HikeDetailScreenState extends ConsumerState<HikeDetailScreen> {
  late Hikehistory _hike;
  late bool _isFavourite;

  @override
  void initState() {
    super.initState();
    _hike = widget.hike;
    _isFavourite = _hike.isFavourite;
  }

  Future<void> _toggleFavourite() async {
    setState(() {
      _isFavourite = !_isFavourite;
    });

    // Build updated Hikehistory preserving fields
    final updated = Hikehistory(
      id: _hike.id,
      name: _hike.name,
      location: _hike.location,
      hikedDate: _hike.hikedDate,
      parkingAvailable: _hike.parkingAvailable,
      lengthOfHike: _hike.lengthOfHike,
      difficultyLevel: _hike.difficultyLevel,
      description: _hike.description,
      freeParking: _hike.freeParking,
      isFavourite: _isFavourite,
    );
    // preserve createdAt if the class stores it as a mutable field
    try {
      updated.createdAt = _hike.createdAt;
    } catch (_) {}

    // Persist update
    await ref.read(hikesProvider.notifier).updateHike(updated);

    // update local copy for UI (subtitle etc)
    setState(() {
      _hike = updated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFavourite ? 'Marked favourite' : 'Removed favourite')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final observationsAsync = ref.watch(observationsProvider(_hike.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(_hike.name),
        actions: [
          IconButton(
            tooltip: _isFavourite ? 'Unmark favourite' : 'Mark as favourite',
            icon: Icon(_isFavourite ? Icons.favorite : Icons.favorite_border, color: _isFavourite ? Colors.red : null),
            onPressed: _toggleFavourite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Location'),
              subtitle: Text(_hike.location),
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${_hike.hikedDate.toLocal()}'.split(' ')[0]),
            ),
            ListTile(
              title: const Text('Length'),
              subtitle: Text('${_hike.lengthOfHike} km'),
            ),
            ListTile(
              title: const Text('Difficulty'),
              subtitle: Text(_hike.difficultyLevel),
            ),
            ListTile(
              title: const Text('Parking'),
              subtitle: Text(_hike.parkingAvailable ? 'Yes' : 'No'),
            ),
            ListTile(
              title: const Text('Free Parking'),
              subtitle: Text(_hike.freeParking ? 'Yes' : 'No'),
            ),
            ListTile(
              title: const Text('Favourite'),
              subtitle: Text(_hike.isFavourite ? 'Yes' : 'No'),
            ),
            if (_hike.description.isNotEmpty)
              ListTile(
                title: const Text('Description'),
                subtitle: Text(_hike.description),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddObservationScreen(hikingHistoryId: _hike.id),
                  ),
                );
              },
              child: const Text('Add Observation'),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Related Observations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            observationsAsync.when(
              data: (observations) {
                if (observations.isEmpty) {
                  return const Text('No observations yet for this hike.');
                }
                return Column(
                  children: observations.map((obs) {
                    // If observation is an image, attempt to render it as an image.
                    Widget contentWidget;
                    if (obs.observationType.toLowerCase() == 'image' && (obs.observation.isNotEmpty ?? false)) {
                      final data = obs.observation;
                      try {
                        // Heuristic: long strings without slashes are likely base64
                        if (data.length > 100 && !data.contains('/') && !data.startsWith('http')) {
                          final bytes = base64Decode(data);
                          contentWidget = Image.memory(bytes, height: 180, fit: BoxFit.cover);
                        } else if (data.startsWith(RegExp(r'https?://'))) {
                          contentWidget = Image.network(data, height: 180, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                        } else {
                          // try local file path
                          final file = File(data);
                          if (file.existsSync()) {
                            contentWidget = Image.file(file, height: 180, fit: BoxFit.cover);
                          } else {
                            // fallback: try decode as base64
                            final bytes = base64Decode(data);
                            contentWidget = Image.memory(bytes, height: 180, fit: BoxFit.cover);
                          }
                        }
                      } catch (_) {
                        contentWidget = const Icon(Icons.broken_image, size: 48);
                      }
                    } else {
                      // text observation
                      contentWidget = Text(obs.observation.isNotEmpty ? obs.observation : '(no text)');
                    }

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(obs.observationType.isNotEmpty ? obs.observationType[0] : 'O')),
                        title: contentWidget,
                        isThreeLine: obs.additionalComments.isNotEmpty,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${obs.observationType} • ${obs.observationDate.toLocal()}'.split(' ')[0]),
                            if (obs.additionalComments.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(obs.additionalComments, style: const TextStyle(fontSize: 13)),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => ref.read(observationsProvider(_hike.id).notifier).deleteObservation(obs.id, _hike.id),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading observations: $e'),
            ),
          ],
        ),
      ),
    );
  }
}