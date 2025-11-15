import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcuts service for power users
/// Provides keyboard navigation and shortcuts throughout the app
class KeyboardShortcutsService {
  // Singleton pattern
  static final KeyboardShortcutsService _instance = KeyboardShortcutsService._internal();
  factory KeyboardShortcutsService() => _instance;
  KeyboardShortcutsService._internal();

  // Callbacks for different shortcuts
  final Map<String, VoidCallback> _shortcuts = {};

  /// Register a keyboard shortcut
  void registerShortcut(String key, VoidCallback callback) {
    _shortcuts[key] = callback;
  }

  /// Unregister a keyboard shortcut
  void unregisterShortcut(String key) {
    _shortcuts.remove(key);
  }

  /// Handle keyboard event
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    // Build shortcut key
    String shortcutKey = '';
    if (isCtrl) shortcutKey += 'ctrl+';
    if (isShift) shortcutKey += 'shift+';
    if (isAlt) shortcutKey += 'alt+';
    shortcutKey += key.keyLabel.toLowerCase();

    // Execute callback if registered
    if (_shortcuts.containsKey(shortcutKey)) {
      _shortcuts[shortcutKey]?.call();
      return true;
    }

    return false;
  }

  /// Clear all shortcuts
  void clearAll() {
    _shortcuts.clear();
  }
}

/// Keyboard shortcuts widget wrapper
class KeyboardShortcuts extends StatefulWidget {
  const KeyboardShortcuts({
    required this.child,
    required this.shortcuts,
    super.key,
  });

  final Widget child;
  final Map<ShortcutActivator, VoidCallback> shortcuts;

  @override
  State<KeyboardShortcuts> createState() => _KeyboardShortcutsState();
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      child: Shortcuts(
        shortcuts: widget.shortcuts.map(
          (key, value) => MapEntry(key, CallbackIntent(value)),
        ),
        child: Actions(
          actions: {
            CallbackIntent: CallbackAction<CallbackIntent>(
              onInvoke: (intent) => intent.callback(),
            ),
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Callback intent for shortcuts
class CallbackIntent extends Intent {
  const CallbackIntent(this.callback);
  final VoidCallback callback;
}

/// Common keyboard shortcuts for ChekMate
class ChekMateShortcuts {
  // Navigation shortcuts
  static const home = SingleActivator(LogicalKeyboardKey.keyH, control: true);
  static const explore = SingleActivator(LogicalKeyboardKey.keyE, control: true);
  static const profile = SingleActivator(LogicalKeyboardKey.keyP, control: true);
  static const search = SingleActivator(LogicalKeyboardKey.keyK, control: true);
  
  // Action shortcuts
  static const like = SingleActivator(LogicalKeyboardKey.keyL);
  static const comment = SingleActivator(LogicalKeyboardKey.keyC);
  static const share = SingleActivator(LogicalKeyboardKey.keyS);
  static const bookmark = SingleActivator(LogicalKeyboardKey.keyB);
  
  // Feed navigation
  static const nextPost = SingleActivator(LogicalKeyboardKey.keyJ);
  static const previousPost = SingleActivator(LogicalKeyboardKey.keyK);
  static const scrollDown = SingleActivator(LogicalKeyboardKey.arrowDown);
  static const scrollUp = SingleActivator(LogicalKeyboardKey.arrowUp);
  
  // Tab navigation
  static const nextTab = SingleActivator(LogicalKeyboardKey.tab);
  static const previousTab = SingleActivator(LogicalKeyboardKey.tab, shift: true);
  
  // Modal shortcuts
  static const closeModal = SingleActivator(LogicalKeyboardKey.escape);
  static const submit = SingleActivator(LogicalKeyboardKey.enter, control: true);
  
  // Utility shortcuts
  static const refresh = SingleActivator(LogicalKeyboardKey.keyR, control: true);
  static const help = SingleActivator(LogicalKeyboardKey.slash, shift: true);
  static const newPost = SingleActivator(LogicalKeyboardKey.keyN, control: true);
}

/// Keyboard shortcuts help dialog
class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Keyboard Shortcuts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildSection('Navigation', [
                    _buildShortcut('Ctrl + H', 'Go to Home'),
                    _buildShortcut('Ctrl + E', 'Go to Explore'),
                    _buildShortcut('Ctrl + P', 'Go to Profile'),
                    _buildShortcut('Ctrl + K', 'Search'),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Actions', [
                    _buildShortcut('L', 'Like post'),
                    _buildShortcut('C', 'Comment on post'),
                    _buildShortcut('S', 'Share post'),
                    _buildShortcut('B', 'Bookmark post'),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Feed Navigation', [
                    _buildShortcut('J', 'Next post'),
                    _buildShortcut('K', 'Previous post'),
                    _buildShortcut('↓', 'Scroll down'),
                    _buildShortcut('↑', 'Scroll up'),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Tabs', [
                    _buildShortcut('Tab', 'Next tab'),
                    _buildShortcut('Shift + Tab', 'Previous tab'),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Other', [
                    _buildShortcut('Ctrl + R', 'Refresh feed'),
                    _buildShortcut('Ctrl + N', 'New post'),
                    _buildShortcut('Esc', 'Close modal'),
                    _buildShortcut('?', 'Show this help'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...shortcuts,
      ],
    );
  }

  Widget _buildShortcut(String keys, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

