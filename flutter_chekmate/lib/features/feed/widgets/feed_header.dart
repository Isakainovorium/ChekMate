import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// FeedHeader - Header component for content feeds with filters and actions
class FeedHeader extends StatefulWidget {
  const FeedHeader({
    super.key,
    this.title = 'Feed',
    this.subtitle,
    this.showSearch = true,
    this.showFilters = true,
    this.showSort = true,
    this.showViewToggle = true,
    this.onSearch,
    this.onFilterChanged,
    this.onSortChanged,
    this.onViewModeChanged,
    this.filterOptions = const [],
    this.sortOptions = const [],
    this.currentFilter,
    this.currentSort,
    this.currentViewMode = FeedViewMode.list,
    this.actions = const [],
    this.showNotifications = true,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  final String title;
  final String? subtitle;
  final bool showSearch;
  final bool showFilters;
  final bool showSort;
  final bool showViewToggle;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String?>? onFilterChanged;
  final ValueChanged<String?>? onSortChanged;
  final ValueChanged<FeedViewMode>? onViewModeChanged;
  final List<FilterOption> filterOptions;
  final List<SortOption> sortOptions;
  final String? currentFilter;
  final String? currentSort;
  final FeedViewMode currentViewMode;
  final List<Widget> actions;
  final bool showNotifications;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  @override
  State<FeedHeader> createState() => _FeedHeaderState();
}

class _FeedHeaderState extends State<FeedHeader> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        widget.onSearch?.call('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Main header row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Title and subtitle
                  if (!_isSearchExpanded) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.subtitle!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Search field (when expanded)
                  if (_isSearchExpanded) ...[
                    Expanded(
                      child: AppInput(
                        controller: _searchController,
                        hint: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _toggleSearch,
                        ),
                        onChanged: widget.onSearch,
                        autofocus: true,
                      ),
                    ),
                  ],

                  // Action buttons
                  if (!_isSearchExpanded) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search button
                        if (widget.showSearch)
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _toggleSearch,
                          ),

                        // Notifications
                        if (widget.showNotifications)
                          _NotificationButton(
                            count: widget.notificationCount,
                            onTap: widget.onNotificationTap,
                          ),

                        // Custom actions
                        ...widget.actions,
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Filter and sort row
            if (widget.showFilters || widget.showSort || widget.showViewToggle) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Filters
                    if (widget.showFilters && widget.filterOptions.isNotEmpty) ...[
                      _FilterDropdown(
                        options: widget.filterOptions,
                        currentValue: widget.currentFilter,
                        onChanged: widget.onFilterChanged,
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],

                    // Sort
                    if (widget.showSort && widget.sortOptions.isNotEmpty) ...[
                      _SortDropdown(
                        options: widget.sortOptions,
                        currentValue: widget.currentSort,
                        onChanged: widget.onSortChanged,
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],

                    const Spacer(),

                    // View mode toggle
                    if (widget.showViewToggle)
                      _ViewModeToggle(
                        currentMode: widget.currentViewMode,
                        onChanged: widget.onViewModeChanged,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.options,
    required this.currentValue,
    required this.onChanged,
  });

  final List<FilterOption> options;
  final String? currentValue;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: currentValue,
        hint: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Filter',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        items: [
          DropdownMenuItem<String>(
            child: Text(
              'All',
              style: theme.textTheme.bodySmall,
            ),
          ),
          ...options.map((option) => DropdownMenuItem<String>(
            value: option.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  option.label,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),),
        ],
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
        isDense: true,
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.options,
    required this.currentValue,
    required this.onChanged,
  });

  final List<SortOption> options;
  final String? currentValue;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: currentValue,
        hint: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Sort',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        items: options.map((option) => DropdownMenuItem<String>(
          value: option.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 16),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                option.label,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),).toList(),
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
        isDense: true,
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.currentMode,
    required this.onChanged,
  });

  final FeedViewMode currentMode;
  final ValueChanged<FeedViewMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSegmentedControl<FeedViewMode>(
      options: const [
        AppToggleOption(
          value: FeedViewMode.list,
          icon: Icons.view_list,
        ),
        AppToggleOption(
          value: FeedViewMode.grid,
          icon: Icons.grid_view,
        ),
        AppToggleOption(
          value: FeedViewMode.card,
          icon: Icons.view_agenda,
        ),
      ],
      selectedValue: currentMode,
      onSelectionChanged: onChanged,
    );
  }
}

/// FeedViewMode - Different view modes for the feed
enum FeedViewMode {
  list,
  grid,
  card,
}

/// FilterOption - Option for feed filtering
class FilterOption {
  const FilterOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;
}

/// SortOption - Option for feed sorting
class SortOption {
  const SortOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;
}

/// FeedHeaderController - Controller for managing feed header state
class FeedHeaderController extends ChangeNotifier {
  FeedHeaderController({
    FeedViewMode initialViewMode = FeedViewMode.list,
  }) : _viewMode = initialViewMode;

  FeedViewMode _viewMode;
  String? _currentFilter;
  String? _currentSort;
  String _searchQuery = '';

  FeedViewMode get viewMode => _viewMode;
  String? get currentFilter => _currentFilter;
  String? get currentSort => _currentSort;
  String get searchQuery => _searchQuery;

  void setViewMode(FeedViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setFilter(String? filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSort(String? sort) {
    _currentSort = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _currentFilter = null;
    _currentSort = null;
    _searchQuery = '';
    notifyListeners();
  }
}
