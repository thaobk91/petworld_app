import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petworld_app/features/account/presentation/widgets/countries.dart';
import 'package:petworld_app/features/account/presentation/widgets/country_picker_sheet.dart';

/// Ô nhập số điện thoại, bên trái có nút chọn quốc gia (cờ + mã vùng).
/// Chỉ nhận chữ số và khoảng trắng. Mã vùng lấy từ quốc gia đang chọn.
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final Country country;
  final ValueChanged<Country> onCountryChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;

  Future<void> _pickCountry(BuildContext context) async {
    final picked = await showCountryPicker(context, selected: country);
    if (picked != null) onCountryChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final example = country.exampleMobile;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
        LengthLimitingTextInputFormatter(20),
      ],
      validator: validator,
      decoration: InputDecoration(
        labelText: 'Số điện thoại',
        hintText: example.isEmpty ? null : 'vd: $example',
        prefixIcon: _CountryButton(
          country: country,
          onPressed: () => _pickCountry(context),
        ),
      ),
    );
  }
}

class _CountryButton extends StatelessWidget {
  const _CountryButton({required this.country, required this.onPressed});

  final Country country;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Chọn quốc gia, đang chọn ${country.name} ${country.dialCode}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country.flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Text(
                country.dialCode,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.only(left: 4),
                color: theme.colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
