import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos_model.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';

class KosFormScreen extends StatefulWidget {
  final KosModel? kos;

  const KosFormScreen({super.key, this.kos});

  static const List<String> availableFacilities = [
    'Wi-Fi',
    'AC',
    'Kamar Mandi Dalam',
    'Kasur',
    'Lemari',
    'Parkir Motor',
  ];

  static const List<String> availableTypes = [
    'Putra',
    'Putri',
    'Campur',
  ];

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _priceController;
  late TextEditingController _roomsController;
  late TextEditingController _contactController;

  late String _selectedType;
  late List<String> _selectedFacilities;
  bool _isSubmitting = false;

  bool get isEditMode => widget.kos != null;

  @override
  void initState() {
    super.initState();
    final k = widget.kos;
    _nameController = TextEditingController(text: k?.name ?? '');
    _areaController = TextEditingController(text: k?.area ?? '');
    _priceController =
        TextEditingController(text: k != null ? k.pricePerMonth.toString() : '');
    _roomsController =
        TextEditingController(text: k != null ? k.availableRooms.toString() : '1');
    _contactController =
        TextEditingController(text: k?.contactNumber ?? '');

    _selectedType = k?.type ?? 'Campur';
    _selectedFacilities = k != null ? List.from(k.facilities) : ['Wi-Fi'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi telah berakhir. Silakan login kembali.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final kosProvider = context.read<KosProvider>();
    final price = int.parse(_priceController.text.trim());
    final rooms = int.parse(_roomsController.text.trim());

    if (isEditMode) {
      final updatedKos = widget.kos!.copyWith(
        name: _nameController.text.trim(),
        area: _areaController.text.trim(),
        type: _selectedType,
        pricePerMonth: price,
        availableRooms: rooms,
        facilities: _selectedFacilities,
        contactNumber: _contactController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await kosProvider.updateKos(updatedKos);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data kos berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kosProvider.errorMessage ?? 'Gagal memperbarui kos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      final newKos = KosModel(
        id: '', // Will be assigned by database
        ownerId: auth.currentUserId!,
        name: _nameController.text.trim(),
        area: _areaController.text.trim(),
        type: _selectedType,
        pricePerMonth: price,
        availableRooms: rooms,
        facilities: _selectedFacilities,
        contactNumber: _contactController.text.trim(),
      );

      final success = await kosProvider.addKos(newKos);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kos berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kosProvider.errorMessage ?? 'Gagal menambahkan kos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Ubah Data Kos' : 'Tambah Kos Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Kos
              TextFormField(
                key: const Key('name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kos *',
                  hintText: 'Contoh: Kos Bunga Melati',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama kos wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Area
              TextFormField(
                key: const Key('area_field'),
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / Wilayah *',
                  hintText: 'Contoh: Singaraja Barat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Area kos wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipe Kos
              const Text('Tipe Kos *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Row(
                children: KosFormScreen.availableTypes.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: _selectedType == t,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = t);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Harga Sewa Bulanan
              TextFormField(
                key: const Key('price_field'),
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga Sewa per Bulan (Rp) *',
                  hintText: 'Contoh: 850000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Harga sewa wajib diisi';
                  }
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Harga harus berupa angka lebih besar dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sisa Kamar
              TextFormField(
                key: const Key('rooms_field'),
                controller: _roomsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Sisa Kamar Tersedia *',
                  hintText: '0 jika penuh, atau jumlah kamar kosong',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Jumlah sisa kamar wajib diisi';
                  }
                  final parsed = int.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Jumlah kamar tidak boleh negatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kontak Nomor Pemilik
              TextFormField(
                key: const Key('contact_field'),
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp / Telepon Pemilik *',
                  hintText: 'Contoh: 081234567890',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nomor kontak wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fasilitas
              const Text('Fasilitas Kos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: KosFormScreen.availableFacilities.map((f) {
                  final isChecked = _selectedFacilities.contains(f);
                  return FilterChip(
                    label: Text(f),
                    selected: isChecked,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFacilities.add(f);
                        } else {
                          _selectedFacilities.remove(f);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton(
                key: const Key('save_button'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isEditMode ? 'Simpan Perubahan' : 'Simpan Kos',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
