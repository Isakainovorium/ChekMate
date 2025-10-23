import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_theme.dart';
import 'package:flutter_chekmate/shared/widgets/app_avatar.dart';
import 'package:flutter_chekmate/shared/widgets/app_button.dart';
import 'package:flutter_chekmate/shared/widgets/app_card.dart';
import 'package:flutter_chekmate/shared/widgets/app_text_field.dart';
import 'package:flutter_chekmate/shared/widgets/error_view.dart';
import 'package:flutter_chekmate/shared/widgets/loading_indicator.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Widgets',
          children: [
            WidgetbookFolder(
              name: 'Buttons',
              children: [
                WidgetbookComponent(
                  name: 'AppButton',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Primary',
                      builder: (context) => Center(
                        child: AppButton(
                          text: 'Primary Button',
                          onPressed: () {},
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'Secondary',
                      builder: (context) => Center(
                        child: AppButton(
                          text: 'Secondary Button',
                          onPressed: () {},
                          variant: ButtonVariant.secondary,
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'Outline',
                      builder: (context) => Center(
                        child: AppButton(
                          text: 'Outline Button',
                          onPressed: () {},
                          variant: ButtonVariant.outline,
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'Loading',
                      builder: (context) => Center(
                        child: AppButton(
                          text: 'Loading Button',
                          onPressed: () {},
                          isLoading: true,
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'With Icon',
                      builder: (context) => Center(
                        child: AppButton(
                          text: 'Button with Icon',
                          onPressed: () {},
                          icon: Icons.favorite,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookFolder(
              name: 'Inputs',
              children: [
                WidgetbookComponent(
                  name: 'AppTextField',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Default',
                      builder: (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: AppTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'With Icon',
                      builder: (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: AppTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: true,
                          prefixIcon: Icon(Icons.lock_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookFolder(
              name: 'Cards',
              children: [
                WidgetbookComponent(
                  name: 'AppCard',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Default',
                      builder: (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: AppCard(
                          child: Text('This is a card'),
                        ),
                      ),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'PostCard',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'With Image',
                      builder: (context) => PostCard(
                        authorName: 'John Doe',
                        authorAvatar: 'https://i.pravatar.cc/150?img=1',
                        timeAgo: '2h ago',
                        content: 'This is a sample post with an image!',
                        imageUrl: 'https://picsum.photos/400/300',
                        likes: 42,
                        comments: 12,
                        shares: 5,
                        onLike: () {},
                        onComment: () {},
                        onShare: () {},
                        onBookmark: () {},
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'Text Only',
                      builder: (context) => PostCard(
                        authorName: 'Jane Smith',
                        authorAvatar: 'https://i.pravatar.cc/150?img=2',
                        timeAgo: '5h ago',
                        content: 'This is a text-only post without any images.',
                        likes: 128,
                        comments: 34,
                        shares: 12,
                        isLiked: true,
                        onLike: () {},
                        onComment: () {},
                        onShare: () {},
                        onBookmark: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookFolder(
              name: 'Avatars',
              children: [
                WidgetbookComponent(
                  name: 'AppAvatar',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Small',
                      builder: (context) => const Center(
                        child: AppAvatar(
                          imageUrl: 'https://i.pravatar.cc/150?img=3',
                          size: AvatarSize.small,
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'Medium',
                      builder: (context) => const Center(
                        child: AppAvatar(
                          imageUrl: 'https://i.pravatar.cc/150?img=4',
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'Large',
                      builder: (context) => const Center(
                        child: AppAvatar(
                          imageUrl: 'https://i.pravatar.cc/150?img=5',
                          size: AvatarSize.large,
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'With Badge',
                      builder: (context) => const Center(
                        child: AppAvatar(
                          imageUrl: 'https://i.pravatar.cc/150?img=6',
                          size: AvatarSize.large,
                          showBadge: true,
                        ),
                      ),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'StoryAvatar',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Unviewed Story',
                      builder: (context) => const Center(
                        child: StoryAvatar(
                          imageUrl: 'https://i.pravatar.cc/150?img=7',
                          name: 'John',
                          hasStory: true,
                        ),
                      ),
                    ),
                    WidgetbookUseCase(
                      name: 'Viewed Story',
                      builder: (context) => const Center(
                        child: StoryAvatar(
                          imageUrl: 'https://i.pravatar.cc/150?img=8',
                          name: 'Jane',
                          hasStory: true,
                          isViewed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            WidgetbookFolder(
              name: 'Loading & Errors',
              children: [
                WidgetbookComponent(
                  name: 'LoadingIndicator',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'Default',
                      builder: (context) => const Center(
                        child: LoadingIndicator(),
                      ),
                    ),
                  ],
                ),
                WidgetbookComponent(
                  name: 'ErrorView',
                  useCases: [
                    WidgetbookUseCase(
                      name: 'With Retry',
                      builder: (context) => ErrorView(
                        message: 'Something went wrong. Please try again.',
                        onRetry: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: AppTheme.lightTheme,
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: AppTheme.darkTheme,
            ),
          ],
        ),
        // ViewportAddon replaced DeviceFrameAddon - configure as needed
        // ViewportAddon(),
      ],
    );
  }
}
