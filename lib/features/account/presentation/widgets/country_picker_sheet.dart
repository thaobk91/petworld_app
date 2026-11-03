import 'package:flutter/material.dart';
import 'package:petworld_app/features/account/presentation/widgets/countries.dart';

/// Mở danh sách quốc gia để chọn mã vùng. Trả về null nếu người dùng đóng
/// mà không chọn.
Future<Country?> showCountryPicker(
  BuildContext context, {
  required Country selected,
}) => showModalBottomSheet<Country>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => _CountryPickerSheet(selected: selected),
);

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.selected});

  final Country selected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countries = allCountries.where((c) => c.matches(_query)).toList();

    // Chừa chỗ cho bàn phím để ô tìm kiếm và kết quả không bị che.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Chọn quốc gia', style: theme.textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Tìm tên nước hoặc mã vùng',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: countries.isEmpty
                  ? Center(
                      child: Text(
                        'Không tìm thấy quốc gia nào',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        final country = countries[index];
                        return _CountryTile(
                          country: country,
                          selected: country.isoCode == widget.selected.isoCode,
                          onTap: () => Navigator.pop(context, country),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.selected,
    required this.onTap,
  });

  final Country country;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      selected: selected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.35),
      onTap: onTap,
      leading: Text(country.flag, style: const TextStyle(fontSize: 26)),
      title: Text(country.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            country.dialCode,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: colors.primary, size: 20),
          ],
        ],
      ),
    );
  }
}
