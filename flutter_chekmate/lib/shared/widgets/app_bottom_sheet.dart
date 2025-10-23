import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// AppBottomSheet - Enhanced modal bottom sheet with animations and gestures
class AppBottomSheet extends StatefulWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.isFullHeight = false,
    this.isDismissible = true,
    this.showDragHandle = true,
    this.enableDrag = true,
    this.backgroundColor,
    this.shape,
    this.elevation = 8,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool isFullHeight;
  final bool isDismissible;
  final bool showDragHandle;
  final bool enableDrag;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final double elevation;
  final Clip clipBehavior;

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    bool isFullHeight = false,
    bool isDismissible = true,
    bool showDragHandle = true,
    bool enableDrag = true,
    Color? backgroundColor,
    ShapeBorder? shape,
    double elevation = 8,
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      useRootNavigator: useRootNavigator,
      builder: (context) => AppBottomSheet(
        title: title,
        content: content,
        actions: actions,
        isFullHeight: isFullHeight,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
        shape: shape,
        elevation: elevation,
      ),
    );
  }

  @override
  State<AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends State<AppBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(
            top: widget.isFullHeight ? 0 : screenHeight * 0.1,
          ),
          child: Transform.translate(
            offset: Offset(0, (1 - _animation.value) * 100),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: widget.isFullHeight 
                      ? screenHeight 
                      : screenHeight * 0.9,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? theme.colorScheme.surface,
                  borderRadius: widget.shape != null 
                      ? null 
                      : const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: widget.elevation,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                clipBehavior: widget.clipBehavior,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    if (widget.showDragHandle) _buildDragHandle(theme),

                    // Title
                    if (widget.title != null) _buildTitle(theme),

                    // Content
                    if (widget.content != null)
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: AppSpacing.lg,
                            right: AppSpacing.lg,
                            bottom: bottomPadding + AppSpacing.lg,
                          ),
                          child: widget.content!,
                        ),
                      ),

                    // Actions
                    if (widget.actions != null) _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        widget.showDragHandle ? 0 : AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: DefaultTextStyle.merge(
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        child: widget.title!,
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.actions!.map((action) {
          final index = widget.actions!.indexOf(action);
          return Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? AppSpacing.md : 0,
            ),
            child: action,
          );
        }).toList(),
      ),
    );
  }
}

/// AppDraggableBottomSheet - Bottom sheet with draggable resize functionality
class AppDraggableBottomSheet extends StatefulWidget {
  const AppDraggableBottomSheet({
    required this.builder, super.key,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.9,
    this.expand = true,
    this.snap = false,
    this.snapSizes,
  });

  final Widget Function(BuildContext, ScrollController) builder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool expand;
  final bool snap;
  final List<double>? snapSizes;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext, ScrollController) builder,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
    bool expand = true,
    bool snap = false,
    List<double>? snapSizes,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppDraggableBottomSheet(
        builder: builder,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: expand,
        snap: snap,
        snapSizes: snapSizes,
      ),
    );
  }

  @override
  State<AppDraggableBottomSheet> createState() => _AppDraggableBottomSheetState();
}

class _AppDraggableBottomSheetState extends State<AppDraggableBottomSheet> {
  late DraggableScrollableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: widget.expand,
      snap: widget.snap,
      snapSizes: widget.snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: widget.builder(context, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// AppListBottomSheet - Bottom sheet optimized for lists
class AppListBottomSheet<T> extends StatelessWidget {
  const AppListBottomSheet({
    required this.items, required this.itemBuilder, super.key,
    this.title,
    this.onItemTap,
    this.searchable = false,
    this.searchHint = 'Search...',
    this.emptyBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final String? title;
  final ValueChanged<T>? onItemTap;
  final bool searchable;
  final String searchHint;
  final Widget Function(BuildContext)? emptyBuilder;

  static Future<T?> show<T>({
    required BuildContext context,
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    String? title,
    ValueChanged<T>? onItemTap,
    bool searchable = false,
    String searchHint = 'Search...',
    Widget Function(BuildContext)? emptyBuilder,
  }) {
    return AppBottomSheet.show<T>(
      context: context,
      title: title != null ? Text(title) : null,
      content: AppListBottomSheet<T>(
        items: items,
        itemBuilder: itemBuilder,
        onItemTap: onItemTap,
        searchable: searchable,
        searchHint: searchHint,
        emptyBuilder: emptyBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ListBottomSheetContent<T>(
      items: items,
      itemBuilder: itemBuilder,
      onItemTap: onItemTap,
      searchable: searchable,
      searchHint: searchHint,
      emptyBuilder: emptyBuilder,
    );
  }
}

class _ListBottomSheetContent<T> extends StatefulWidget {
  const _ListBottomSheetContent({
    required this.items,
    required this.itemBuilder,
    this.onItemTap,
    this.searchable = false,
    this.searchHint = 'Search...',
    this.emptyBuilder,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final ValueChanged<T>? onItemTap;
  final bool searchable;
  final String searchHint;
  final Widget Function(BuildContext)? emptyBuilder;

  @override
  State<_ListBottomSheetContent<T>> createState() => _ListBottomSheetContentState<T>();
}

class _ListBottomSheetContentState<T> extends State<_ListBottomSheetContent<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return item.toString().toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        if (widget.searchable) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppInput(
              controller: _searchController,
              hint: widget.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ],

        // Items list
        if (_filteredItems.isEmpty)
          widget.emptyBuilder?.call(context) ??
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No items found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return InkWell(
                onTap: () {
                  widget.onItemTap?.call(item);
                  Navigator.of(context).pop(item);
                },
                child: widget.itemBuilder(context, item, index),
              );
            },
          ),
      ],
    );
  }
}

/// AppActionBottomSheet - Bottom sheet with action buttons
class AppActionBottomSheet extends StatelessWidget {
  const AppActionBottomSheet({
    required this.actions, super.key,
    this.title,
    this.subtitle,
    this.showCancel = true,
    this.cancelText = 'Cancel',
  });

  final List<AppBottomSheetAction> actions;
  final String? title;
  final String? subtitle;
  final bool showCancel;
  final String cancelText;

  static Future<String?> show({
    required BuildContext context,
    required List<AppBottomSheetAction> actions,
    String? title,
    String? subtitle,
    bool showCancel = true,
    String cancelText = 'Cancel',
  }) {
    return AppBottomSheet.show<String>(
      context: context,
      title: title != null ? Text(title) : null,
      content: AppActionBottomSheet(
        actions: actions,
        subtitle: subtitle,
        showCancel: false, // Handle cancel separately
      ),
      actions: showCancel ? [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
      ] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (subtitle != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final action = actions[index];
            return ListTile(
              leading: action.icon != null
                  ? Icon(
                      action.icon,
                      color: action.isDestructive 
                          ? theme.colorScheme.error 
                          : null,
                    )
                  : null,
              title: Text(
                action.title,
                style: TextStyle(
                  color: action.isDestructive 
                      ? theme.colorScheme.error 
                      : null,
                ),
              ),
              subtitle: action.subtitle != null
                  ? Text(action.subtitle!)
                  : null,
              onTap: () {
                Navigator.of(context).pop(action.id);
                action.onTap?.call();
              },
            );
          },
        ),
      ],
    );
  }
}

/// AppBottomSheetAction - Action item for action bottom sheet
class AppBottomSheetAction {
  const AppBottomSheetAction({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.isDestructive = false,
    this.onTap,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback? onTap;
}
