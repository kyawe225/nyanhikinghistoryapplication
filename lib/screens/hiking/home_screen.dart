import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/providers/hike_provider.dart';
import 'package:hiking_app_one/screens/hiking/add_edit_hike_screen.dart';
import 'package:hiking_app_one/screens/hiking/hike_detail_screen.dart';
import 'package:hiking_app_one/screens/favourite/favourite_screen.dart';
import 'package:hiking_app_one/providers/theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 200)) {
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        ref.read(hikesProvider.notifier).loadMore().whenComplete(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hikesAsync = ref.watch(hikesProvider);
    final currentTheme = ref.watch(themeTypeProvider);

    // Map labels for menu (no if statements used when applying)
    const Map<ThemeType, String> themeLabels = {
      ThemeType.material: 'Material',
      ThemeType.cupertino: 'Cupertino',
      ThemeType.ios26Liquid: 'iOS26 Liquid',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          // Theme selector: updates provider by map lookup (no conditional styling here)
          PopupMenuButton<ThemeType>(
            icon: const Icon(Icons.palette),
            initialValue: currentTheme,
            onSelected: (t) => ref.read(themeTypeProvider.notifier).state = t,
            itemBuilder: (context) => ThemeType.values.map((tt) {
              return PopupMenuItem<ThemeType>(
                value: tt,
                child: Row(
                  children: [
                    (tt == currentTheme) ? const Icon(Icons.check, size: 18) : const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(themeLabels[tt] ?? tt.toString()),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favourites',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavouriteScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reset Database'),
                content: const Text('Are you sure you want to delete all hikes?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(onPressed: () { ref.read(hikesProvider.notifier).resetHikes(); Navigator.pop(context); }, child: const Text('Reset')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: hikesAsync.when(
        data: (hikes) {
          if (hikes.isEmpty) {
            return const Center(child: Text('No hikes yet.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: hikes.length,
                  itemBuilder: (context, index) {
                    final hike = hikes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(hike.name.isNotEmpty ? hike.name[0] : 'H')),
                        title: Text(hike.name),
                        subtitle: Text('${hike.location} • ${hike.hikedDate.toLocal()}'.split(' ')[0]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                hike.isFavourite ? Icons.favorite : Icons.favorite_border,
                                color: hike.isFavourite ? Colors.red : null,
                              ),
                              onPressed: () {
                                ref.read(hikesProvider.notifier).toggleFavourite(hike.id, !hike.isFavourite);
                              },
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditHikeScreen(hike: hike)));
                                } else if (value == 'delete') {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Hike'),
                                      content: const Text('Are you sure you want to delete this hike?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await ref.read(hikesProvider.notifier).deleteHike(hike.id);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hike deleted')));
                                  }
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HikeDetailScreen(hike: hike)));
                        },
                      ),
                    );
                  },
                ),
              ),
              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading hikes: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditHikeScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
