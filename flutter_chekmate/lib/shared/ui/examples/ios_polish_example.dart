import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/core/theme/cupertino_theme.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// iOS Polish Example Page
///
/// Demonstrates iOS-native styling using Cupertino widgets and design patterns.
class IOSPolishExamplePage extends StatefulWidget {
  const IOSPolishExamplePage({super.key});

  @override
  State<IOSPolishExamplePage> createState() => _IOSPolishExamplePageState();
}

class _IOSPolishExamplePageState extends State<IOSPolishExamplePage> {
  bool _switchValue = false;
  double _sliderValue = 0.5;
  DateTime _selectedDate = DateTime.now();
  String _selectedOption = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS Polish Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSectionHeader('Cupertino Buttons'),
          const SizedBox(height: AppSpacing.sm),
          _buildCupertinoButtons(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Cupertino Form Controls'),
          const SizedBox(height: AppSpacing.sm),
          _buildCupertinoFormControls(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Cupertino Dialogs'),
          const SizedBox(height: AppSpacing.sm),
          _buildCupertinoDialogs(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Cupertino Lists'),
          const SizedBox(height: AppSpacing.sm),
          _buildCupertinoLists(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Cupertino Navigation'),
          const SizedBox(height: AppSpacing.sm),
          _buildCupertinoNavigation(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCupertinoButtons() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filled Button
          CupertinoButton.filled(
            onPressed: () {},
            child: const Text('Filled Button'),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Regular Button
          CupertinoButton(
            color: AppColors.primary,
            onPressed: () {},
            child: const Text('Regular Button'),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Text Button
          CupertinoButton(
            onPressed: () {},
            child: const Text('Text Button'),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoFormControls() {
    return AppCard(
      child: Column(
        children: [
          // Switch
          CupertinoListTile(
            title: const Text('Enable Notifications'),
            trailing: CupertinoSwitch(
              value: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                });
              },
            ),
          ),
          const Divider(height: 1),

          // Slider
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Volume'),
                CupertinoSlider(
                  value: _sliderValue,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Text Field
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: CupertinoTextField(
              placeholder: 'Enter your name',
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppCupertinoTheme.systemGray6,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoDialogs() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Alert Dialog
          CupertinoButton(
            onPressed: () {
              CupertinoHelpers.showAlertDialog<void>(
                context: context,
                title: 'Delete Post?',
                message: 'This action cannot be undone.',
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
            child: const Text('Show Alert Dialog'),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Action Sheet
          CupertinoButton(
            onPressed: () {
              CupertinoHelpers.showActionSheet<void>(
                context: context,
                title: 'Choose an action',
                message: 'What would you like to do?',
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Share'),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Save'),
                  ),
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
            child: const Text('Show Action Sheet'),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Date Picker
          CupertinoButton(
            onPressed: () async {
              final date = await CupertinoHelpers.showDatePicker(
                context: context,
                initialDate: _selectedDate,
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child:
                Text('Select Date: ${_selectedDate.toString().split(' ')[0]}'),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Picker
          CupertinoButton(
            onPressed: () async {
              final option = await CupertinoHelpers.showPicker<String>(
                context: context,
                items: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
                itemBuilder: (item) => item,
                initialItem: _selectedOption,
              );
              if (option != null) {
                setState(() {
                  _selectedOption = option;
                });
              }
            },
            child: Text('Select Option: $_selectedOption'),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoLists() {
    return AppCard(
      child: Column(
        children: [
          CupertinoListTile(
            leading: const Icon(CupertinoIcons.person),
            title: const Text('Profile'),
            trailing: const CupertinoListTileChevron(),
            onTap: () {},
          ),
          const Divider(height: 1),
          CupertinoListTile(
            leading: const Icon(CupertinoIcons.settings),
            title: const Text('Settings'),
            trailing: const CupertinoListTileChevron(),
            onTap: () {},
          ),
          const Divider(height: 1),
          CupertinoListTile(
            leading: const Icon(CupertinoIcons.bell),
            title: const Text('Notifications'),
            trailing: const CupertinoListTileChevron(),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoNavigation() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => const _CupertinoDetailPage(),
                ),
              );
            },
            child: const Text('Open Cupertino Page'),
          ),
        ],
      ),
    );
  }
}

/// Cupertino Detail Page Example
class _CupertinoDetailPage extends StatelessWidget {
  const _CupertinoDetailPage();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Detail Page'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const Text(
              'This is a Cupertino-style page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Notice the iOS-native navigation bar, smooth transitions, and Cupertino widgets.',
            ),
            const SizedBox(height: AppSpacing.lg),
            CupertinoButton.filled(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cupertino Icons Showcase
class CupertinoIconsShowcase extends StatelessWidget {
  const CupertinoIconsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = [
      {'icon': CupertinoIcons.home, 'name': 'home'},
      {'icon': CupertinoIcons.search, 'name': 'search'},
      {'icon': CupertinoIcons.heart, 'name': 'heart'},
      {'icon': CupertinoIcons.heart_fill, 'name': 'heart_fill'},
      {'icon': CupertinoIcons.person, 'name': 'person'},
      {'icon': CupertinoIcons.person_fill, 'name': 'person_fill'},
      {'icon': CupertinoIcons.bell, 'name': 'bell'},
      {'icon': CupertinoIcons.bell_fill, 'name': 'bell_fill'},
      {'icon': CupertinoIcons.chat_bubble, 'name': 'chat_bubble'},
      {'icon': CupertinoIcons.chat_bubble_fill, 'name': 'chat_bubble_fill'},
      {'icon': CupertinoIcons.camera, 'name': 'camera'},
      {'icon': CupertinoIcons.camera_fill, 'name': 'camera_fill'},
      {'icon': CupertinoIcons.photo, 'name': 'photo'},
      {'icon': CupertinoIcons.photo_fill, 'name': 'photo_fill'},
      {'icon': CupertinoIcons.settings, 'name': 'settings'},
      {'icon': CupertinoIcons.share, 'name': 'share'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cupertino Icons'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final iconData = icons[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData['icon'] as IconData,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                iconData['name'] as String,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
