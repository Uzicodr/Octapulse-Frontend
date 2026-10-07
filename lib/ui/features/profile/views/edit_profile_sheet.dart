import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/social.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../community/view_models/community_view_models.dart';

Future<void> showEditProfileSheet(BuildContext context, Me me) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _EditProfileSheet(me: me),
  );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.me});

  final Me me;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _form = GlobalKey<FormState>();
  late final _username = TextEditingController(text: widget.me.username);
  late final _displayName = TextEditingController(text: widget.me.displayName ?? '');
  late final _avatarUrl = TextEditingController(text: widget.me.avatarUrl ?? '');
  late final _bio = TextEditingController(text: widget.me.bio ?? '');
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_username, _displayName, _avatarUrl, _bio]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final me = widget.me;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    String? changed(String value, String? old) => value.trim() == (old ?? '') ? null : value.trim();
    try {
      await ref.read(meProvider.notifier).save(
            username: changed(_username.text, me.username),
            displayName: changed(_displayName.text, me.displayName),
            avatarUrl: changed(_avatarUrl.text, me.avatarUrl),
            bio: changed(_bio.text, me.bio),
          );
      ref.invalidate(userProfileProvider(me.id));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit profile', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(labelText: 'Username', prefixText: '@'),
                  validator: (v) => RegExp(r'^[A-Za-z0-9_]{3,32}$').hasMatch(v?.trim() ?? '')
                      ? null
                      : '3–32 letters, digits or underscores',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _displayName,
                  maxLength: 50,
                  decoration: const InputDecoration(labelText: 'Display name', counterText: ''),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _avatarUrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(labelText: 'Avatar URL (https://)'),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    return value.isEmpty || value.startsWith('https://') ? null : 'Must start with https://';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bio,
                  maxLength: 280,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                const SizedBox(height: 16),
                PillButton(label: 'Save', filled: true, loading: _saving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
