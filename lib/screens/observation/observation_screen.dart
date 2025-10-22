import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/providers/observation_provider.dart';
import 'package:hiking_app_one/screens/observation/add_observation_screen.dart';

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
                Widget content;

                if (obs.observationType.toLowerCase() == 'image' && (obs.observation.isNotEmpty ?? false)) {
                  final data = obs.observation;
                  try {
                    // If looks like base64 (no path separators and long), decode and show
                    if (data.length > 100 && !data.contains('/') && !data.startsWith('http')) {
                      final bytes = base64Decode(data);
                      content = Image.memory(bytes, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                    } else if (kIsWeb && data.startsWith('http')) {
                      content = Image.network(data, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                    } else {
                      final file = File(data);
                      if (file.existsSync()) {
                        content = Image.file(file, height: 80, fit: BoxFit.cover);
                      } else if (data.startsWith(RegExp(r'https?://'))) {
                        content = Image.network(data, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                      } else {
                        // fallback: maybe it's base64 but short; try decode
                        final bytes = base64Decode(data);
                        content = Image.memory(bytes, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
                      }
                    }
                  } catch (_) {
                    content = const Icon(Icons.broken_image);
                  }
                } else {
                  content = Text(obs.observation.isNotEmpty ? obs.observation : '(no text)', maxLines: 3, overflow: TextOverflow.ellipsis);
                }

                return Card(
                  child: ListTile(
                    // title shows image or text; subtitle shows date and additional comments (no type label for non-image)
                    title: content,
                    isThreeLine: obs.additionalComments.isNotEmpty,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${obs.observationDate.toLocal()}'.split(' ')[0]),
                        if (obs.additionalComments.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(obs.additionalComments, style: const TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
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
