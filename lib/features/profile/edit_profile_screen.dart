import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_exception.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late bool _showOnLeaderboard;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _showOnLeaderboard = user?.showOnLeaderboard ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await ref.read(authProvider.notifier).updateProfile(
            fullName: _nameCtrl.text.trim(),
            showOnLeaderboard: _showOnLeaderboard,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Full name',
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  prefixIcon:
                      const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.space5),
                SwitchListTile(
                  value: _showOnLeaderboard,
                  onChanged: (v) => setState(() => _showOnLeaderboard = v),
                  contentPadding: EdgeInsets.zero,
                  title: Text('Show me on leaderboards',
                      style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    'Your username and best scores appear on subject leaderboards.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: AppDimens.space6),
                AppButton(
                  label: 'Save Changes',
                  isFullWidth: true,
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
