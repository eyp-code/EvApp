import 'package:flutter/material.dart';

import '../../../../core/backup/backup_service.dart';
import '../../../../core/backup/file_backup_gateway.dart';
import '../../../../shared/widgets/section_placeholder.dart';
import '../../../people/domain/models/person.dart';
import '../../../people/domain/repositories/person_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.personRepository,
    required this.backupService,
    required this.fileBackupGateway,
    required this.onDataImported,
  });

  final PersonRepository personRepository;
  final BackupService backupService;
  final FileBackupGateway fileBackupGateway;
  final VoidCallback onDataImported;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<List<Person>> _personsFuture;

  @override
  void initState() {
    super.initState();
    _reloadPersons();
  }

  void _reloadPersons() {
    _personsFuture = widget.personRepository.getPersons();
  }

  Future<void> _refreshPersons() async {
    setState(_reloadPersons);
    await _personsFuture;
  }

  Future<void> _addRoommate() async {
    final name = await _showPersonNameDialog(title: 'Ev arkadaşı ekle');

    if (name == null) {
      return;
    }

    await widget.personRepository.addPerson(Person.createRoommate(name: name));
    await _refreshPersons();
  }

  Future<void> _renamePerson(Person person) async {
    final name = await _showPersonNameDialog(
      title: 'Kişiyi düzenle',
      initialName: person.name,
    );

    if (name == null || name == person.name) {
      return;
    }

    await widget.personRepository.updatePerson(person.renamed(name));
    await _refreshPersons();
  }

  Future<void> _deletePerson(Person person) async {
    if (person.isMe) {
      return;
    }

    await widget.personRepository.deletePerson(person.id);
    await _refreshPersons();
  }

  Future<void> _exportBackup() async {
    try {
      final json = await widget.backupService.exportBackupJson();
      final path = await widget.fileBackupGateway.exportJson(json);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yedek oluşturuldu: $path')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yedek dışa aktarma başarısız: $error')),
      );
    }
  }

  Future<void> _importBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yedek içe aktar'),
        content: const Text(
          'Bu işlem mevcut verileri seçilen yedekle değiştirecek. Devam etmeden önce manuel yedek alman önerilir. Devam etmek istiyor musun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Devam et'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      final json = await widget.fileBackupGateway.pickBackupJson();
      if (json == null) {
        return;
      }

      await widget.backupService.importBackupJson(json);
      await _refreshPersons();
      widget.onDataImported();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yedek başarıyla içe aktarıldı.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yedek içe aktarma başarısız: $error')),
      );
    }
  }

  Future<String?> _showPersonNameDialog({
    required String title,
    String initialName = '',
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) =>
          _PersonNameDialog(title: title, initialName: initialName),
    );

    if (result == null || result.trim().isEmpty) {
      return null;
    }

    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _PageHeader(
          title: 'Ayarlar',
          subtitle:
              'Kişiler, yedekleme ve uygulama tercihleri burada yönetilir.',
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<Person>>(
          future: _personsFuture,
          builder: (context, snapshot) {
            return _PeopleSection(
              persons: snapshot.data ?? const [],
              isLoading: snapshot.connectionState != ConnectionState.done,
              onAddRoommate: _addRoommate,
              onRenamePerson: _renamePerson,
              onDeletePerson: _deletePerson,
            );
          },
        ),
        const SizedBox(height: 16),
        _BackupSection(
          onExportPressed: _exportBackup,
          onImportPressed: _importBackup,
        ),
        const SectionPlaceholder(
          title: 'Uygulama ayarları',
          description:
              'Bildirimler ve diğer uygulama tercihleri bu ekrana eklenecek.',
          icon: Icons.settings_outlined,
        ),
      ],
    );
  }
}

class _BackupSection extends StatelessWidget {
  const _BackupSection({
    required this.onExportPressed,
    required this.onImportPressed,
  });

  final VoidCallback onExportPressed;
  final VoidCallback onImportPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yedekleme',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Verilerini JSON olarak dışa aktar veya mevcut yedeği geri yükle.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onExportPressed,
                    icon: const Icon(Icons.ios_share_outlined),
                    label: const Text('Dışa aktar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onImportPressed,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('İçe aktar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonNameDialog extends StatefulWidget {
  const _PersonNameDialog({required this.title, required this.initialName});

  final String title;
  final String initialName;

  @override
  State<_PersonNameDialog> createState() => _PersonNameDialogState();
}

class _PersonNameDialogState extends State<_PersonNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'İsim'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Kaydet')),
      ],
    );
  }
}

class _PeopleSection extends StatelessWidget {
  const _PeopleSection({
    required this.persons,
    required this.isLoading,
    required this.onAddRoommate,
    required this.onRenamePerson,
    required this.onDeletePerson,
  });

  final List<Person> persons;
  final bool isLoading;
  final VoidCallback onAddRoommate;
  final ValueChanged<Person> onRenamePerson;
  final ValueChanged<Person> onDeletePerson;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evdeki kişiler',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Masraf paylaşımı için kullanılacak kişi listesi.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Ev arkadaşı ekle',
                  onPressed: onAddRoommate,
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const LinearProgressIndicator()
            else
              ...persons.map(
                (person) => _PersonTile(
                  person: person,
                  onRename: () => onRenamePerson(person),
                  onDelete: person.isMe ? null : () => onDeletePerson(person),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.onRename,
    required this.onDelete,
  });

  final Person person;
  final VoidCallback onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _parseColor(person.avatarColor, colorScheme.primary),
        child: Text(
          person.name.trim().isEmpty ? '?' : person.name.trim()[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text(person.name),
      subtitle: Text(person.isMe ? 'Ben' : 'Ev arkadaşı'),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Düzenle',
            onPressed: onRename,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Sil',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? value, Color fallback) {
    if (value == null || !value.startsWith('#') || value.length != 7) {
      return fallback;
    }

    return Color(int.parse('FF${value.substring(1)}', radix: 16));
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
