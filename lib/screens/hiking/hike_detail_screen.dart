import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
                    final bool isImage = obs.observationType.toLowerCase() == 'image';
                    Widget? imageWidget;
                    if (isImage && obs.observation.isNotEmpty) {
                      final data = obs.observation;
                      try {
                        if (data.length > 100 && !data.contains('/') && !data.startsWith('http')) {
                          final bytes = base64Decode(data);
                          imageWidget = Image.memory(bytes, height: 160, fit: BoxFit.cover, width: double.infinity);
                        } else if (data.startsWith(RegExp(r'https?://'))) {
                          imageWidget = Image.network(data, height: 160, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                        } else {
                          final file = File(data);
                          if (file.existsSync()) {
                            imageWidget = Image.file(file, height: 160, fit: BoxFit.cover, width: double.infinity);
                          } else {
                            final bytes = base64Decode(data);
                            imageWidget = Image.memory(bytes, height: 160, fit: BoxFit.cover, width: double.infinity);
                          }
                        }
                      } catch (_) {
                        imageWidget = const Icon(Icons.broken_image, size: 64);
                      }
                    }

                    String dateStr;
                    try {
                      final dt = (obs.observationDate != null) ? obs.observationDate.toLocal() : obs.createdAt.toLocal();
                      dateStr = DateFormat.yMd().add_jm().format(dt);
                    } catch (_) {
                      try {
                        dateStr = DateFormat.yMd().add_jm().format(obs.createdAt.toLocal());
                      } catch (_) {
                        dateStr = 'Unknown date';
                      }
                    }

                    final String observationText = (!isImage && obs.observation.isNotEmpty) ? obs.observation : '';
                    final String comments = obs.additionalComments.isNotEmpty ? obs.additionalComments : '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      child: ListTile(
                        leading: null,
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageWidget != null) ...[
                                ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
                                const SizedBox(height: 8),
                              ],
                              Text(dateStr, style: TextStyle(color: Colors.grey.shade700)),
                              if (observationText.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text('Observation', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(observationText),
                              ],
                              if (comments.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Text('Additional comments', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(comments),
                              ],
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (v) async {
                            if (v == 'edit') {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AddObservationScreen(hikingHistoryId: _hike.id, existing: obs)));
                            } else if (v == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Observation'),
                                  content: const Text('Delete this observation?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await ref.read(observationsProvider(_hike.id).notifier).deleteObservation(obs.id, _hike.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Observation deleted')));
                              }
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
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