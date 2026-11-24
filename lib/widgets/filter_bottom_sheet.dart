import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kos_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

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
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? _maxPrice;
  String? _selectedType;
  late List<String> _selectedFacilities;

  @override
  void initState() {
    super.initState();
    final provider = context.read<KosProvider>();
    _maxPrice = provider.maxPrice;
    _selectedType = provider.selectedType;
    _selectedFacilities = List.from(provider.selectedFacilities);
  }

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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Pencarian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _maxPrice = null;
                      _selectedType = null;
                      _selectedFacilities.clear();
                    });
                    context.read<KosProvider>().resetFilter();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset Filter'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Tipe Kos
            const Text(
              'Tipe Kos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: FilterBottomSheet.availableTypes.map((type) {
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? type : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Harga Maksimal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Batas Harga Sewa',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  _maxPrice != null
                      ? _formatCurrency(_maxPrice!)
                      : 'Semua Harga',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            Slider(
              value: (_maxPrice ?? 3000000).toDouble(),
              min: 300000,
              max: 3000000,
              divisions: 27,
              label: _maxPrice != null ? _formatCurrency(_maxPrice!) : 'Semua',
              onChanged: (val) {
                setState(() {
                  _maxPrice = val.toInt();
                });
              },
            ),
            Wrap(
              spacing: 6,
              children: [500000, 1000000, 1500000, 2000000].map((price) {
                return ActionChip(
                  label: Text('Maks ${_formatCurrency(price)}',
                      style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    setState(() {
                      _maxPrice = price;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Fasilitas Checklist
            const Text(
              'Fasilitas',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: FilterBottomSheet.availableFacilities.map((facility) {
                final isChecked = _selectedFacilities.contains(facility);
                return FilterChip(
                  label: Text(facility),
                  selected: isChecked,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFacilities.add(facility);
                      } else {
                        _selectedFacilities.remove(facility);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  context.read<KosProvider>().setFilter(
                        maxPrice: _maxPrice,
                        selectedType: _selectedType,
                        selectedFacilities: _selectedFacilities,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Terapkan',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
