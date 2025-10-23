import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/icons/app_icons.dart';
import 'package:flutter_chekmate/shared/ui/icons/svg_icon.dart';

/// SVG Icon Examples
///
/// Demonstrates all SVG icon components and usage patterns.
class SvgIconExamples extends StatefulWidget {
  const SvgIconExamples({super.key});

  @override
  State<SvgIconExamples> createState() => _SvgIconExamplesState();
}

class _SvgIconExamplesState extends State<SvgIconExamples> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _notificationCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Icons'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Basic SVG Icons',
            [
              _buildExample(
                'Simple Icons',
                const Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SvgIcon(AppIcons.home),
                    SvgIcon(AppIcons.explore),
                    SvgIcon(AppIcons.messages),
                    SvgIcon(AppIcons.profile),
                    SvgIcon(AppIcons.notifications),
                  ],
                ),
              ),
              _buildExample(
                'Colored Icons',
                const Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SvgIcon(
                      AppIcons.like,
                      color: Colors.red,
                    ),
                    SvgIcon(
                      AppIcons.comment,
                      color: Colors.blue,
                    ),
                    SvgIcon(
                      AppIcons.share,
                      color: Colors.green,
                    ),
                    SvgIcon(
                      AppIcons.bookmark,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              _buildExample(
                'Different Sizes',
                const Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SvgIcon(AppIcons.camera, size: 16),
                    SvgIcon(AppIcons.camera),
                    SvgIcon(AppIcons.camera, size: 32),
                    SvgIcon(AppIcons.camera, size: 48),
                    SvgIcon(AppIcons.camera, size: 64),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Themed Icons',
            [
              _buildExample(
                'Auto Theme Color',
                const Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ThemedSvgIcon(AppIcons.settings),
                    ThemedSvgIcon(AppIcons.search),
                    ThemedSvgIcon(AppIcons.filter),
                    ThemedSvgIcon(AppIcons.edit),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Icon Buttons',
            [
              _buildExample(
                'Action Buttons',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SvgIconButton(
                      assetPath: _isLiked ? AppIcons.likeFilled : AppIcons.like,
                      onPressed: () {
                        setState(() => _isLiked = !_isLiked);
                      },
                      color: _isLiked ? Colors.red : null,
                      tooltip: 'Like',
                    ),
                    SvgIconButton(
                      assetPath: AppIcons.comment,
                      onPressed: () {},
                      tooltip: 'Comment',
                    ),
                    SvgIconButton(
                      assetPath: AppIcons.share,
                      onPressed: () {},
                      tooltip: 'Share',
                    ),
                    SvgIconButton(
                      assetPath: _isBookmarked
                          ? AppIcons.bookmarkFilled
                          : AppIcons.bookmark,
                      onPressed: () {
                        setState(() => _isBookmarked = !_isBookmarked);
                      },
                      color: _isBookmarked ? Colors.orange : null,
                      tooltip: 'Bookmark',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Icons with Badges',
            [
              _buildExample(
                'Notification Badges',
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    SvgIconWithBadge(
                      assetPath: AppIcons.notifications,
                      badgeCount: _notificationCount,
                      showBadge: _notificationCount > 0,
                    ),
                    const SvgIconWithBadge(
                      assetPath: AppIcons.messages,
                      badgeCount: 3,
                      showBadge: true,
                      badgeColor: Colors.blue,
                    ),
                    const SvgIconWithBadge(
                      assetPath: AppIcons.notifications,
                      badgeCount: 99,
                      showBadge: true,
                    ),
                    const SvgIconWithBadge(
                      assetPath: AppIcons.notifications,
                      badgeCount: 150,
                      showBadge: true,
                    ),
                  ],
                ),
              ),
              _buildExample(
                'Badge Controls',
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_notificationCount > 0) {
                                _notificationCount--;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$_notificationCount notifications',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            setState(() => _notificationCount++);
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Animated Icons',
            [
              _buildExample(
                'Tap to Animate',
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    AnimatedSvgIcon(
                      AppIcons.like,
                      size: 32,
                      color: Colors.red,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Liked!'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      },
                    ),
                    AnimatedSvgIcon(
                      AppIcons.bookmark,
                      size: 32,
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bookmarked!'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      },
                    ),
                    AnimatedSvgIcon(
                      AppIcons.star,
                      size: 32,
                      color: Colors.amber,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Starred!'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSection(
            'Icon Categories',
            [
              _buildExample(
                'Navigation Icons',
                _buildIconGrid([
                  AppIcons.home,
                  AppIcons.explore,
                  AppIcons.messages,
                  AppIcons.profile,
                  AppIcons.notifications,
                ]),
              ),
              _buildExample(
                'Action Icons',
                _buildIconGrid([
                  AppIcons.like,
                  AppIcons.comment,
                  AppIcons.share,
                  AppIcons.bookmark,
                  AppIcons.send,
                  AppIcons.add,
                  AppIcons.search,
                  AppIcons.filter,
                ]),
              ),
              _buildExample(
                'Media Icons',
                _buildIconGrid([
                  AppIcons.camera,
                  AppIcons.gallery,
                  AppIcons.video,
                  AppIcons.microphone,
                  AppIcons.play,
                  AppIcons.pause,
                  AppIcons.volume,
                  AppIcons.mute,
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...examples,
      ],
    );
  }

  Widget _buildExample(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: child,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildIconGrid(List<String> iconPaths) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: iconPaths
          .map((path) => SvgIcon(path))
          .toList(),
    );
  }
}

