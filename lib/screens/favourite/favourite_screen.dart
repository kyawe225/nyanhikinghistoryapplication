import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/providers/hike_provider.dart';
import 'package:hiking_app_one/screens/hiking/hike_detail_screen.dart';
import 'package:hiking_app_one/database/entities.dart';

class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen> {
  bool _selectionMode = false;
  final Map<String, bool> _selected = {};

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selected.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _toggleSelect(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selected[id] = true;
      } else {
        _selected.remove(id);
      }
    });
  }

  Future<void> _saveAllUnfavourite() async {
    final ids = _selected.entries.where((e) => e.value).map((e) => e.key).toList();
    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No items selected')));
      return;
    }
    for (final id in ids) {
      await ref.read(hikesProvider.notifier).toggleFavourite(id, false);
    }
    _exitSelectionMode();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed favourites for selected hikes')));
  }

  @override
  Widget build(BuildContext context) {
    final hikesAsync = ref.watch(hikesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          if (_selectionMode) ...[
            TextButton(
              onPressed: _saveAllUnfavourite,
              child: const Text('Save All', style: TextStyle(color: Colors.white)),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitSelectionMode,
              tooltip: 'Cancel',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _enterSelectionMode,
              tooltip: 'Select',
            ),
          ],
        ],
      ),
      body: hikesAsync.when(
        data: (hikes) {
          final favourites = hikes.where((h) => h.isFavourite).toList();
          if (favourites.isEmpty) {
            return const Center(child: Text('No favourite hikes yet.'));
          }
          return ListView.builder(
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final Hikehistory hike = favourites[index];
              final isSelected = _selected[hike.id] == true;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: ListTile(
                  leading: _selectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (v) => _toggleSelect(hike.id, v),
                        )
                      : CircleAvatar(child: Text(hike.name.isNotEmpty ? hike.name[0] : 'H')),
                  title: Text(hike.name),
                  subtitle: Text('${hike.location} • ${hike.hikedDate.toLocal()}'.split(' ')[0]),
                  trailing: _selectionMode
                      ? null
                      : IconButton(
                          icon: Icon(hike.isFavourite ? Icons.favorite : Icons.favorite_border,
                              color: hike.isFavourite ? Colors.red : null),
                          onPressed: () {
                            ref.read(hikesProvider.notifier).toggleFavourite(hike.id, !hike.isFavourite);
                          },
                        ),
                  onTap: () {
                    if (_selectionMode) {
                      _toggleSelect(hike.id, !isSelected);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HikeDetailScreen(hike: hike)),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading hikes: $e')),
      ),
    );
  }
}
