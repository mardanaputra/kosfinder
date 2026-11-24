import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/kos_card.dart';
import 'about_screen.dart';
import 'auth_screen.dart';
import 'detail_screen.dart';
import 'my_kos_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onAboutTap;
  final VoidCallback? onAuthTap;
  final void Function(String kosId)? onKosTap;

  const HomeScreen({
    super.key,
    this.onAboutTap,
    this.onAuthTap,
    this.onKosTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KosProvider>().fetchKosList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<KosProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filter Kos',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const FilterBottomSheet(),
                        );
                      },
                    ),
                    if (provider.hasActiveFilter)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              if (widget.onAboutTap != null) {
                widget.onAboutTap!();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: Builder(
              builder: (context) {
                final auth = Provider.of<AuthProvider?>(context);
                final isAuth = auth?.isAuthenticated ?? false;
                return Icon(
                  isAuth
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                  color: isAuth ? Colors.green : null,
                );
              },
            ),
            tooltip: 'Akun Pemilik',
            onPressed: () {
              if (widget.onAuthTap != null) {
                widget.onAuthTap!();
              } else {
                final auth = Provider.of<AuthProvider?>(context, listen: false);
                if (auth?.isAuthenticated == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyKosScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan area (misal: Singaraja)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<KosProvider>().searchByArea('');
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                context.read<KosProvider>().searchByArea(val);
                setState(() {});
              },
            ),
          ),
          // Content
          Expanded(
            child: Consumer<KosProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchKosList(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.kosList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            provider.searchArea.isNotEmpty
                                ? 'Kos di area tersebut tidak ditemukan'
                                : 'Belum ada data kos yang tersedia',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchKosList(),
                  child: ListView.builder(
                    itemCount: provider.kosList.length,
                    itemBuilder: (context, index) {
                      final kos = provider.kosList[index];
                      return KosCard(
                        kos: kos,
                        onTap: () {
                          if (widget.onKosTap != null) {
                            widget.onKosTap!(kos.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(kos: kos),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
