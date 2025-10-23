import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/domain/entities/location_entity.dart';
import 'package:flutter_chekmate/shared/ui/location/location_picker_widget.dart';
import 'package:flutter_chekmate/shared/ui/location/location_tag_widget.dart';

/// PostLocationExample - Example Widget
///
/// Demonstrates how to integrate location services with posts.
/// Shows location picker, location tag, and location display.
///
/// Features:
/// - Location picker for creating posts
/// - Location tag display on posts
/// - Location-based post filtering
///
/// Usage:
/// ```dart
/// PostLocationExample()
/// ```
class PostLocationExample extends StatefulWidget {
  const PostLocationExample({super.key});

  @override
  State<PostLocationExample> createState() => _PostLocationExampleState();
}

class _PostLocationExampleState extends State<PostLocationExample> {
  LocationEntity? _selectedLocation;
  LocationEntity? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Location Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Location Picker
          const Text(
            '1. Location Picker (for creating posts)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this widget when creating a post to allow users to add location.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          LocationPickerWidget(
            selectedLocation: _selectedLocation,
            onLocationSelected: (location) {
              setState(() => _selectedLocation = location);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${location.displayName}'),
                ),
              );
            },
            onLocationRemoved: () {
              setState(() => _selectedLocation = null);
            },
          ),
          const SizedBox(height: 32),

          // Section 2: Location Tag
          const Text(
            '2. Location Tag (for displaying on posts)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this widget to display location on posts, stories, etc.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_selectedLocation != null) ...[
            LocationTagWidget(
              location: _selectedLocation!,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped: ${_selectedLocation!.displayName}'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            LocationTagWidget(
              location: _selectedLocation!,
              showFullAddress: true,
              maxLines: 2,
              currentLocation: _currentLocation,
            ),
          ] else
            const Text(
              'Select a location above to see the tag',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 32),

          // Section 3: Location Header
          const Text(
            '3. Location Header (for post headers)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this widget in post headers to show location.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_selectedLocation != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LocationHeaderWidget(
                  location: _selectedLocation!,
                  showFullAddress: true,
                  currentLocation: _currentLocation,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Tapped: ${_selectedLocation!.displayName}'),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            const Text(
              'Select a location above to see the header',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 32),

          // Section 4: Location List Tile
          const Text(
            '4. Location List Tile (for location lists)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this widget in location search results or lists.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_selectedLocation != null)
            LocationListTile(
              location: _selectedLocation!,
              currentLocation: _currentLocation,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped: ${_selectedLocation!.displayName}'),
                  ),
                );
              },
            )
          else
            const Text(
              'Select a location above to see the list tile',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 32),

          // Section 5: Distance Display
          const Text(
            '5. Distance Display',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Show distance from current location to post location.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_selectedLocation != null && _currentLocation != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LocationDistanceWidget(
                  location: _selectedLocation!,
                  currentLocation: _currentLocation!,
                ),
              ),
            )
          else
            const Text(
              'Select a location and set current location to see distance',
              style: TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 32),

          // Section 6: Example Post Card
          const Text(
            '6. Example Post with Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete example of a post with location.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (_selectedLocation != null)
            _ExamplePostCard(
              location: _selectedLocation!,
              currentLocation: _currentLocation,
            )
          else
            const Text(
              'Select a location above to see the example post',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

/// Example post card with location
class _ExamplePostCard extends StatelessWidget {
  const _ExamplePostCard({
    required this.location,
    this.currentLocation,
  });

  final LocationEntity location;
  final LocationEntity? currentLocation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with location
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'John Doe',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      LocationHeaderWidget(
                        location: location,
                        iconSize: 16,
                        currentLocation: currentLocation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post image
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image, size: 64, color: Colors.grey),
            ),
          ),

          // Post content
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Amazing view from this location! 🌅',
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Location tag
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LocationTagWidget(
              location: location,
              currentLocation: currentLocation,
            ),
          ),

          // Post actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

