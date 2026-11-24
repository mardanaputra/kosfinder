import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos_model.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import 'kos_form_screen.dart';

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

  void _showDeleteConfirmationDialog(BuildContext context, KosModel kos) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${kos.name}" secara permanen? Data yang dihapus tidak dapat dipulihkan.',
          ),
          actions: [
            TextButton(
              key: const Key('cancel_delete_button'),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              key: const Key('confirm_delete_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final success =
                    await context.read<KosProvider>().deleteKos(kos.id);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kos berhasil dihapus permanen!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal menghapus kos.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ya, Hapus'),
            ),
          ],
        );
      },
    );
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
        onPressed: () {
          if (onAddTap != null) {
            onAddTap!();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KosFormScreen()),
            );
          }
        },
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
                      onPressed: () {
                        if (onAddTap != null) {
                          onAddTap!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const KosFormScreen()),
                          );
                        }
                      },
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
                        const SizedBox(height: 6),
                        // Quick Availability Stepper Control (Slice 5 Bonus)
                        Row(
                          children: [
                            const Text(
                              'Kamar Kosong:',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              key: Key('decrement_rooms_${kos.id}'),
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: kos.availableRooms > 0
                                  ? () {
                                      final newRooms = kos.availableRooms - 1;
                                      context.read<KosProvider>().updateKos(
                                            kos.copyWith(
                                                availableRooms: newRooms),
                                          );
                                    }
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '${kos.availableRooms}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            IconButton(
                              key: Key('increment_rooms_${kos.id}'),
                              icon:
                                  const Icon(Icons.add_circle_outline, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                final newRooms = kos.availableRooms + 1;
                                context.read<KosProvider>().updateKos(
                                      kos.copyWith(availableRooms: newRooms),
                                    );
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                if (onEditTap != null) {
                                  onEditTap!(kos);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => KosFormScreen(kos: kos),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Ubah'),
                            ),
                            TextButton.icon(
                              key: Key('delete_button_${kos.id}'),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              onPressed: () {
                                if (onDeleteTap != null) {
                                  onDeleteTap!(kos);
                                } else {
                                  _showDeleteConfirmationDialog(context, kos);
                                }
                              },
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
