import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos_model.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';

class MyKosScreen extends StatelessWidget {
  final VoidCallback? onAddTap;
  final void Function(KosModel kos)? onEditTap;
  final void Function(KosModel kos)? onDeleteTap;

  const MyKosScreen({
    super.key,
    this.onAddTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final kosProvider = context.watch<KosProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kos Saya')),
        body: const Center(
          child: Text('Silakan masuk terlebih dahulu.'),
        ),
      );
    }

    // Filter only current user's kos
    final myKosList = kosProvider.allKos
        .where((k) => k.ownerId == auth.currentUserId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kos Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddTap,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kos'),
      ),
      body: myKosList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.holiday_village_outlined,
                        size: 72, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Anda belum memiliki properti kos yang terdaftar',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan properti kos Anda sekarang agar dapat ditemukan oleh pencari kos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: onAddTap,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Kos Sekarang'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: myKosList.length,
              itemBuilder: (context, index) {
                final kos = myKosList[index];
                final isAvailable = kos.isAvailable;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                kos.type,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isAvailable
                                    ? 'Sisa ${kos.availableRooms} Kamar'
                                    : 'Penuh',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: isAvailable
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          kos.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(kos.area,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatCurrency(kos.pricePerMonth)} / bulan',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => onEditTap?.call(kos),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Ubah'),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              onPressed: () => onDeleteTap?.call(kos),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Hapus'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
