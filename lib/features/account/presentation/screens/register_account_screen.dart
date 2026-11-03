import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petworld_app/core/error/failures.dart';
import 'package:petworld_app/features/account/domain/services/password_policy.dart';
import 'package:petworld_app/features/account/domain/services/phone_number_rules.dart';
import 'package:petworld_app/features/account/presentation/state/account_providers.dart';
import 'package:petworld_app/features/account/presentation/widgets/countries.dart';
import 'package:petworld_app/features/account/presentation/widgets/phone_number_field.dart';
import 'package:petworld_app/shared/widgets/note_card.dart';
import 'package:petworld_app/shared/widgets/welcome_hero.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class RegisterAccountScreen extends ConsumerStatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  ConsumerState<RegisterAccountScreen> createState() =>
      _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends ConsumerState<RegisterAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  Country _country = Country(IsoCode.VN);
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _saving = false;
  // Chưa bấm "Tạo tài khoản" thì chưa báo lỗi, để không mắng người dùng
  // khi họ mới gõ được vài ký tự. Bấm rồi thì báo ngay khi sửa.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Ô nhập dùng chung quy tắc với use case RegisterAccount (cùng các hàm ở
  // domain), nên lỗi hiện ngay dưới từng ô. Use case vẫn kiểm tra lại.
  // Đăng ký xong thì AppGate tự chuyển sang màn hình đăng ký nhà.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(myAccountProvider.notifier)
          .register(
            country: _country.isoCode,
            phoneNumber: _phoneController.text,
            password: _passwordController.text,
            confirmPassword: _confirmController.text,
          );
    } on ValidationFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: AutofillGroup(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const WelcomeHero(
                emoji: '🐾',
                title: 'Tạo tài khoản PetWorld',
                message:
                    'Đăng ký bằng số điện thoại để bắt đầu khoe các bé thú '
                    'cưng với những người bạn quanh đây.',
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PhoneNumberField(
                              controller: _phoneController,
                              country: _country,
                              onCountryChanged: (country) =>
                                  setState(() => _country = country),
                              textInputAction: TextInputAction.next,
                              validator: (value) => PhoneNumberRules.validate(
                                value ?? '',
                                _country.isoCode,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              // Cập nhật danh sách yêu cầu bên dưới khi gõ.
                              onChanged: (_) => setState(() {}),
                              validator: (value) =>
                                  PasswordPolicy.validate(value ?? ''),
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: _VisibilityToggle(
                                  visible: _showPassword,
                                  onPressed: () => setState(
                                    () => _showPassword = !_showPassword,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _PasswordChecklist(
                              password: _passwordController.text,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: !_showConfirm,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) =>
                                  PasswordPolicy.validateConfirmation(
                                    _passwordController.text,
                                    value ?? '',
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Nhập lại mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: _VisibilityToggle(
                                  visible: _showConfirm,
                                  onPressed: () => setState(
                                    () => _showConfirm = !_showConfirm,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const NoteCard(
                      emoji: '🔒',
                      title: 'Mật khẩu được giữ kín',
                      message:
                          'Mật khẩu được mã hoá một chiều trước khi lưu, '
                          'không ai đọc lại được, kể cả PetWorld.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Text('Tạo tài khoản'),
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: visible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu',
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}

/// Các yêu cầu của mật khẩu, mục nào đạt thì đánh dấu tích ngay khi gõ.
class _PasswordChecklist extends StatelessWidget {
  const _PasswordChecklist({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        for (final requirement in PasswordRequirement.values)
          Builder(
            builder: (context) {
              final met = requirement.isMetBy(password);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    met ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: met ? colors.primary : colors.outline,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      requirement.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: met ? colors.onSurface : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
