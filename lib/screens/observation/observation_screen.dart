import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/providers/observation_provider.dart';
import 'package:hiking_app_one/screens/observation/add_observation_screen.dart';
import 'package:intl/intl.dart';

class ObservationScreen extends ConsumerWidget {
  final String hikingHistoryId;

  const ObservationScreen({super.key, required this.hikingHistoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observationsAsyncValue = ref.watch(observationsProvider(hikingHistoryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: observationsAsyncValue.when(
          data: (observations) {
            if (observations.isEmpty) {
              return const Center(child: Text('No observations yet.'));
            }
            return ListView.builder(
              itemCount: observations.length,
              itemBuilder: (context, index) {
                final obs = observations[index];

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
                        // fallback: try decode as base64
                        final bytes = base64Decode(data);
                        imageWidget = Image.memory(bytes, height: 160, fit: BoxFit.cover, width: double.infinity);
                      }
                    }
                  } catch (_) {
                    imageWidget = const Icon(Icons.broken_image, size: 64);
                  }
                }

                // Safely compute a human-friendly date string; fall back to createdAt or a placeholder if needed
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
                  child: ListTile(
                    // leading removed
                    leading: null,
                    // show image (if any) as the top block by using title Column
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageWidget != null) ...[
                            ClipRRect(borderRadius: BorderRadius.circular(8.0), child: imageWidget),
                            const SizedBox(height: 8),
                          ],
                          // ensure date is visible across themes
                          Text(
                            dateStr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700) ??
                                TextStyle(color: Colors.grey.shade700),
                          ),
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
                    // action menu stays as before
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (v) async {
                        if (v == 'edit') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddObservationScreen(hikingHistoryId: hikingHistoryId, existing: obs)));
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
                            await ref.read(observationsProvider(hikingHistoryId).notifier).deleteObservation(obs.id, hikingHistoryId);
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
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddObservationScreen(hikingHistoryId: hikingHistoryId)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
