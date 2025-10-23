import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:flutter_chekmate/core/services/location_service.dart';

/// LocationPickerWidget - Shared UI Component
///
/// A widget for picking a location using current location or search.
/// Displays location with icon and allows users to select/change location.
///
/// Features:
/// - Get current location
/// - Search for locations
/// - Display selected location
/// - Remove location
///
/// Usage:
/// ```dart
/// LocationPickerWidget(
///   selectedLocation: location,
///   onLocationSelected: (location) {
///     print('Selected: ${location.displayName}');
///   },
/// )
/// ```
class LocationPickerWidget extends StatefulWidget {
  const LocationPickerWidget({
    required this.onLocationSelected,
    super.key,
    this.selectedLocation,
    this.onLocationRemoved,
    this.label = 'Add Location',
    this.icon = Icons.location_on,
    this.showCurrentLocationButton = true,
    this.showSearchButton = true,
    this.showRemoveButton = true,
  });

  final LocationEntity? selectedLocation;
  final void Function(LocationEntity location) onLocationSelected;
  final VoidCallback? onLocationRemoved;
  final String label;
  final IconData icon;
  final bool showCurrentLocationButton;
  final bool showSearchButton;
  final bool showRemoveButton;

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final location = await LocationService.getCurrentLocation();
      widget.onLocationSelected(location);
    } on LocationServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => LocationService.openAppSettings(),
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchLocation() async {
    final result = await showDialog<LocationEntity>(
      context: context,
      builder: (context) => const LocationSearchDialog(),
    );

    if (result != null) {
      widget.onLocationSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.selectedLocation != null) {
      return Card(
        child: ListTile(
          leading: Icon(widget.icon, color: theme.primaryColor),
          title: Text(widget.selectedLocation!.displayName),
          subtitle: widget.selectedLocation!.address != null
              ? Text(
                  widget.selectedLocation!.address!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: widget.showRemoveButton
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onLocationRemoved,
                )
              : null,
          onTap: widget.showSearchButton ? _searchLocation : null,
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: Icon(widget.icon, color: theme.iconTheme.color),
        title: Text(widget.label),
        trailing: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showCurrentLocationButton)
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: _getCurrentLocation,
                      tooltip: 'Use current location',
                    ),
                  if (widget.showSearchButton)
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchLocation,
                      tooltip: 'Search location',
                    ),
                ],
              ),
      ),
    );
  }
}

/// LocationSearchDialog - Dialog for searching locations
class LocationSearchDialog extends StatefulWidget {
  const LocationSearchDialog({super.key});

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final _searchController = TextEditingController();
  List<LocationEntity> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await LocationService.getCoordinatesFromAddress(
        address: query,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } on LocationServiceException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isSearching = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Failed to search location: $e';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 16),
                  const Text(
                    'Search Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter city, address, or place',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _search,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _search(),
              ),
            ),

            // Results
            if (_isSearching)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Search for a location'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(location.displayName),
                      subtitle: location.address != null
                          ? Text(
                              location.address!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(location),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
