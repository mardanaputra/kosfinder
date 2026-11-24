import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  final KosRepository repository;

  List<KosModel> _allKos = [];
  List<KosModel> _filteredKos = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchArea = '';
  int? _maxPrice;
  String? _selectedType;
  List<String> _selectedFacilities = [];

  KosProvider({required this.repository});

  List<KosModel> get kosList => _filteredKos;
  List<KosModel> get allKos => _allKos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchArea => _searchArea;
  int? get maxPrice => _maxPrice;
  String? get selectedType => _selectedType;
  List<String> get selectedFacilities => _selectedFacilities;

  bool get hasActiveFilter =>
      _maxPrice != null ||
      _selectedType != null ||
      _selectedFacilities.isNotEmpty ||
      _searchArea.isNotEmpty;

  Future<void> fetchKosList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allKos = await repository.getKosList();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda';
      _allKos = [];
      _filteredKos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchByArea(String areaQuery) {
    _searchArea = areaQuery.trim();
    _applyFilters();
    notifyListeners();
  }

  void setFilter({
    int? maxPrice,
    String? selectedType,
    List<String>? selectedFacilities,
  }) {
    _maxPrice = maxPrice;
    _selectedType = selectedType;
    if (selectedFacilities != null) {
      _selectedFacilities = List.from(selectedFacilities);
    }
    _applyFilters();
    notifyListeners();
  }

  void resetFilter() {
    _searchArea = '';
    _maxPrice = null;
    _selectedType = null;
    _selectedFacilities = [];
    _applyFilters();
    notifyListeners();
  }

  Future<bool> addKos(KosModel kos) async {
    try {
      final newKos = await repository.createKos(kos);
      _allKos.insert(0, newKos);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan kos: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateKos(KosModel kos) async {
    try {
      final updated = await repository.updateKos(kos);
      final index = _allKos.indexWhere((k) => k.id == updated.id);
      if (index != -1) {
        _allKos[index] = updated;
      }
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui kos: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteKos(String id) async {
    try {
      await repository.deleteKos(id);
      _allKos.removeWhere((k) => k.id == id);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus kos: $e';
      notifyListeners();
      return false;
    }
  }

  void _applyFilters() {
    _filteredKos = _allKos.where((kos) {
      // Filter Area (case-insensitive substring)
      if (_searchArea.isNotEmpty) {
        if (!kos.area.toLowerCase().contains(_searchArea.toLowerCase())) {
          return false;
        }
      }

      // Filter Tipe Kos (Putra/Putri/Campur)
      if (_selectedType != null && _selectedType!.isNotEmpty) {
        if (kos.type != _selectedType) {
          return false;
        }
      }

      // Filter Harga Maksimal
      if (_maxPrice != null && _maxPrice! > 0) {
        if (kos.pricePerMonth > _maxPrice!) {
          return false;
        }
      }

      // Filter Fasilitas (wajib memenuhi semua fasilitas yang dipilih)
      if (_selectedFacilities.isNotEmpty) {
        for (final facility in _selectedFacilities) {
          if (!kos.facilities.contains(facility)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }
}
