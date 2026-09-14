import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../address_provider.dart';
import '../data/models/address_models.dart';

class AddressPickerResult {
  final String detail;
  final Province province;
  final Ward ward;

  AddressPickerResult({required this.detail, required this.province, required this.ward});

  String get formatted => '$detail, ${ward.name}, ${province.name}';
}

Future<AddressPickerResult?> showAddressPickerSheet(BuildContext context) {
  return showModalBottomSheet<AddressPickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddressPickerSheet(),
  );
}

class _AddressPickerSheet extends ConsumerStatefulWidget {
  const _AddressPickerSheet();

  @override
  ConsumerState<_AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends ConsumerState<_AddressPickerSheet> {
  final _detailCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  List<Province> _provinces = [];
  List<Ward> _wards = [];
  Province? _selectedProvince;
  Ward? _selectedWard;

  bool _loadingProvinces = true;
  bool _loadingWards = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _loadingProvinces = true;
      _error = null;
    });

    final result = await ref.read(addressServiceProvider).getProvinces();

    if (!mounted) return;
    if (result.error != null) {
      setState(() {
        _error = result.error!.message;
        _loadingProvinces = false;
      });
      return;
    }

    setState(() {
      _provinces = result.data!;
      _loadingProvinces = false;
    });
  }

  Future<void> _onProvinceSelected(Province p) async {
    setState(() {
      _selectedProvince = p;
      _selectedWard = null;
      _wards = [];
      _loadingWards = true;
      _searchCtrl.clear();
      _error = null;
    });

    final result = await ref.read(addressServiceProvider).getWards(p.code);

    if (!mounted) return;
    if (result.error != null) {
      setState(() {
        _error = result.error!.message;
        _loadingWards = false;
      });
      return;
    }

    setState(() {
      _wards = result.data!;
      _loadingWards = false;
    });
  }

  void _confirm() {
    if (_selectedProvince == null || _selectedWard == null || _detailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ số nhà/đường và chọn Tỉnh/Thành, Phường/Xã')),
      );
      return;
    }
    Navigator.of(context).pop(AddressPickerResult(
      detail: _detailCtrl.text.trim(),
      province: _selectedProvince!,
      ward: _selectedWard!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final currentList = _selectedProvince == null ? _provinces : _wards;
    final filtered = query.isEmpty
        ? currentList
        : currentList.where((e) {
            final name = e is Province ? e.name : (e as Ward).name;
            return name.toLowerCase().contains(query);
          }).toList();

    final isLoading = (_loadingProvinces && _selectedProvince == null) ||
        (_loadingWards && _selectedProvince != null);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  if (_selectedProvince != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      onPressed: () => setState(() {
                        _selectedProvince = null;
                        _wards = [];
                        _selectedWard = null;
                        _searchCtrl.clear();
                      }),
                    ),
                  Expanded(
                    child: Text(
                      _selectedProvince == null ? 'Chọn Tỉnh/Thành phố' : 'Chọn Phường/Xã',
                      style: AppTextStyles.heading(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_error!, style: AppTextStyles.body(color: AppColors.error)),
                      ),
                      TextButton(
                        onPressed: _selectedProvince == null
                            ? _loadProvinces
                            : () => _onProvinceSelected(_selectedProvince!),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          final name = item is Province ? item.name : (item as Ward).name;
                          return ListTile(
                            title: Text(name, style: AppTextStyles.body()),
                            onTap: () {
                              if (item is Province) {
                                _onProvinceSelected(item);
                              } else {
                                setState(() => _selectedWard = item as Ward);
                              }
                            },
                            trailing: (item is Ward && _selectedWard?.code == item.code)
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                : null,
                          );
                        },
                      ),
              ),
              if (_selectedProvince != null && _selectedWard != null) ...[
                const Divider(),
                TextField(
                  controller: _detailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số nhà, tên đường *',
                    hintText: 'VD: 123 Nguyễn Huệ',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    child: const Text('Xác nhận địa chỉ'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}