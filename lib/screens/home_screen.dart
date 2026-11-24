import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/kos_card.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KosProvider>().fetchKosList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: widget.onAboutTap,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Akun Pemilik',
            onPressed: widget.onAuthTap,
          ),
        ],
      ),
      body: Consumer<KosProvider>(
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
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
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
                  onTap: () => widget.onKosTap?.call(kos.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
