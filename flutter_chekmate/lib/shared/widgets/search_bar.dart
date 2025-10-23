import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// SearchBar - Advanced search component with suggestions and filters
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.onSearch,
    this.onSuggestionTap,
    this.onFilterChanged,
    this.suggestions = const [],
    this.filters = const [],
    this.placeholder = 'Search...',
    this.showFilters = false,
    this.showSuggestions = true,
    this.showClearButton = true,
    this.showSearchButton = false,
    this.debounceMs = 300,
    this.maxSuggestions = 5,
    this.enabled = true,
    this.autofocus = false,
    this.controller,
  });

  final ValueChanged<String>? onSearch;
  final ValueChanged<SearchSuggestion>? onSuggestionTap;
  final ValueChanged<List<String>>? onFilterChanged;
  final List<SearchSuggestion> suggestions;
  final List<SearchFilter> filters;
  final String placeholder;
  final bool showFilters;
  final bool showSuggestions;
  final bool showClearButton;
  final bool showSearchButton;
  final int debounceMs;
  final int maxSuggestions;
  final bool enabled;
  final bool autofocus;
  final TextEditingController? controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final List<String> _selectedFilters = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.showSuggestions && widget.suggestions.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onSearchChanged(String query) {
    widget.onSearch?.call(query);
    
    if (widget.showSuggestions && query.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();
    
    if (widget.suggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.size?.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: _SuggestionsPanel(
              suggestions: widget.suggestions.take(widget.maxSuggestions).toList(),
              onTap: (suggestion) {
                _controller.text = suggestion.text;
                widget.onSuggestionTap?.call(suggestion);
                _removeOverlay();
                _focusNode.unfocus();
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch?.call('');
    _removeOverlay();
  }

  void _onFilterToggle(String filterId, bool selected) {
    setState(() {
      if (selected) {
        _selectedFilters.add(filterId);
      } else {
        _selectedFilters.remove(filterId);
      }
    });
    widget.onFilterChanged?.call(_selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              boxShadow: _focusNode.hasFocus ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                widget.onSearch?.call(value);
                _removeOverlay();
              },
              decoration: InputDecoration(
                hintText: widget.placeholder,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showClearButton && _controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                    if (widget.showSearchButton)
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          widget.onSearch?.call(_controller.text);
                          _removeOverlay();
                          _focusNode.unfocus();
                        },
                      ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ),

        // Filters
        if (widget.showFilters && widget.filters.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _FiltersPanel(
            filters: widget.filters,
            selectedFilters: _selectedFilters,
            onFilterToggle: _onFilterToggle,
          ),
        ],
      ],
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.suggestions,
    required this.onTap,
  });

  final List<SearchSuggestion> suggestions;
  final ValueChanged<SearchSuggestion> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: true,
            leading: Icon(
              suggestion.icon ?? Icons.search,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              suggestion.text,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: suggestion.subtitle != null
                ? Text(
                    suggestion.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
            trailing: suggestion.type != null
                ? AppBadge(
                    label: suggestion.type!,
                    variant: AppBadgeVariant.secondary,
                  )
                : null,
            onTap: () => onTap(suggestion),
          );
        },
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.filters,
    required this.selectedFilters,
    required this.onFilterToggle,
  });

  final List<SearchFilter> filters;
  final List<String> selectedFilters;
  final void Function(String, bool) onFilterToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: filters.map((filter) {
        final isSelected = selectedFilters.contains(filter.id);
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filter.icon != null) ...[
                Icon(filter.icon, size: 16),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(filter.label),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) => onFilterToggle(filter.id, selected),
        );
      }).toList(),
    );
  }
}

/// SearchSuggestion - Data structure for search suggestions
class SearchSuggestion {
  const SearchSuggestion({
    required this.text,
    this.subtitle,
    this.icon,
    this.type,
    this.data,
  });

  final String text;
  final String? subtitle;
  final IconData? icon;
  final String? type;
  final Map<String, dynamic>? data;
}

/// SearchFilter - Data structure for search filters
class SearchFilter {
  const SearchFilter({
    required this.id,
    required this.label,
    this.icon,
    this.count,
  });

  final String id;
  final String label;
  final IconData? icon;
  final int? count;
}

/// SearchBarController - Controller for managing search bar state
class SearchBarController extends ChangeNotifier {
  SearchBarController({
    String initialQuery = '',
    List<String> initialFilters = const [],
  }) : _query = initialQuery,
       _selectedFilters = List<String>.from(initialFilters);

  String _query;
  List<String> _selectedFilters;
  List<SearchSuggestion> _suggestions = [];
  bool _isLoading = false;

  String get query => _query;
  List<String> get selectedFilters => List.unmodifiable(_selectedFilters);
  List<SearchSuggestion> get suggestions => List.unmodifiable(_suggestions);
  bool get isLoading => _isLoading;

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  void setFilters(List<String> filters) {
    _selectedFilters = List.from(filters);
    notifyListeners();
  }

  void addFilter(String filter) {
    if (!_selectedFilters.contains(filter)) {
      _selectedFilters.add(filter);
      notifyListeners();
    }
  }

  void removeFilter(String filter) {
    _selectedFilters.remove(filter);
    notifyListeners();
  }

  void setSuggestions(List<SearchSuggestion> suggestions) {
    _suggestions = List.from(suggestions);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clear() {
    _query = '';
    _selectedFilters.clear();
    _suggestions.clear();
    notifyListeners();
  }
}

/// SearchHistory - Manages search history
class SearchHistory {
  static const int _maxHistoryItems = 10;

  final List<String> _history = [];

  List<String> get history => List.unmodifiable(_history);

  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    
    _history.remove(query); // Remove if exists
    _history.insert(0, query); // Add to beginning
    
    // Keep only max items
    if (_history.length > _maxHistoryItems) {
      _history.removeRange(_maxHistoryItems, _history.length);
    }
    
    _saveToStorage();
  }

  void removeSearch(String query) {
    _history.remove(query);
    _saveToStorage();
  }

  void clearHistory() {
    _history.clear();
    _saveToStorage();
  }

  void _saveToStorage() {
    // Implement storage logic here (SharedPreferences, etc.)
  }

}
