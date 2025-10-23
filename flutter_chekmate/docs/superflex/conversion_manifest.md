# React → Flutter Conversion Manifest

## Summary
- **React Components**: 35 page/feature components + 48 UI primitives = **83 total**
- **Target**: Convert all to Flutter equivalents
- **Strategy**: UI primitives → `lib/shared/ui/`, Feature components → `lib/features/`

---

## A) UI Primitives (48 components)
**Source**: `ChekMate (Copy)/src/components/ui/`  
**Target**: `flutter_chekmate/lib/shared/ui/components/`

| React File | Flutter Target | Priority | Notes |
|------------|----------------|----------|-------|
| `button.tsx` | `app_button.dart` | ✅ DONE | Variants, sizes, loading |
| `card.tsx` | `app_card.dart` | ✅ DONE | Standard surface |
| `dialog.tsx` | `app_dialog.dart` | ✅ DONE | Modal with actions |
| `sheet.tsx` | `app_sheet.dart` | HIGH | Bottom sheet wrapper |
| `popover.tsx` | `app_popover.dart` | HIGH | Overlay positioning |
| `tooltip.tsx` | `app_tooltip.dart` | HIGH | Hover/long-press hints |
| `select.tsx` | `app_select.dart` | HIGH | Dropdown selection |
| `dropdown-menu.tsx` | `app_dropdown_menu.dart` | HIGH | Context menus |
| `tabs.tsx` | `app_tabs.dart` | HIGH | Tab navigation |
| `input.tsx` | `app_input.dart` | HIGH | Text field |
| `textarea.tsx` | `app_textarea.dart` | HIGH | Multi-line input |
| `checkbox.tsx` | `app_checkbox.dart` | MEDIUM | Boolean input |
| `radio-group.tsx` | `app_radio_group.dart` | MEDIUM | Single selection |
| `switch.tsx` | `app_switch.dart` | MEDIUM | Toggle control |
| `slider.tsx` | `app_slider.dart` | MEDIUM | Range input |
| `input-otp.tsx` | `app_input_otp.dart` | MEDIUM | OTP code entry |
| `form.tsx` | `app_form.dart` | MEDIUM | Form wrapper |
| `label.tsx` | `app_label.dart` | MEDIUM | Field labels |
| `avatar.tsx` | `app_avatar.dart` | MEDIUM | User pictures |
| `badge.tsx` | `app_badge.dart` | MEDIUM | Status indicators |
| `skeleton.tsx` | `app_skeleton.dart` | MEDIUM | Loading placeholders |
| `progress.tsx` | `app_progress.dart` | MEDIUM | Progress indicators |
| `table.tsx` | `app_table.dart` | MEDIUM | Data tables |
| `pagination.tsx` | `app_pagination.dart` | MEDIUM | Page navigation |
| `carousel.tsx` | `app_carousel.dart` | MEDIUM | Image/content slider |
| `chart.tsx` | `app_chart.dart` | MEDIUM | Data visualization |
| `accordion.tsx` | `app_accordion.dart` | LOW | Collapsible sections |
| `alert.tsx` | `app_alert.dart` | LOW | Inline notifications |
| `alert-dialog.tsx` | `app_alert_dialog.dart` | LOW | Confirmation dialogs |
| `aspect-ratio.tsx` | `app_aspect_ratio.dart` | LOW | Responsive containers |
| `breadcrumb.tsx` | `app_breadcrumb.dart` | LOW | Navigation trail |
| `calendar.tsx` | `app_calendar.dart` | LOW | Date picker |
| `collapsible.tsx` | `app_collapsible.dart` | LOW | Expand/collapse |
| `command.tsx` | `app_command.dart` | LOW | Command palette |
| `context-menu.tsx` | `app_context_menu.dart` | LOW | Right-click menus |
| `drawer.tsx` | `app_drawer.dart` | LOW | Side navigation |
| `hover-card.tsx` | `app_hover_card.dart` | LOW | Hover previews |
| `menubar.tsx` | `app_menubar.dart` | LOW | Top menu bar |
| `navigation-menu.tsx` | `app_navigation_menu.dart` | LOW | Nav dropdowns |
| `resizable.tsx` | `app_resizable.dart` | LOW | Resizable panels |
| `scroll-area.tsx` | `app_scroll_area.dart` | LOW | Custom scrollbars |
| `separator.tsx` | `app_separator.dart` | LOW | Visual dividers |
| `sidebar.tsx` | `app_sidebar.dart` | LOW | Side panel |
| `sonner.tsx` | `app_toast.dart` | LOW | Toast notifications |
| `toggle.tsx` | `app_toggle.dart` | LOW | Toggle buttons |
| `toggle-group.tsx` | `app_toggle_group.dart` | LOW | Toggle groups |
| `use-mobile.ts` | `responsive_utils.dart` | LOW | Screen size utils |
| `utils.ts` | `ui_utils.dart` | LOW | Helper functions |

---

## B) Feature Components (35 components)
**Source**: `ChekMate (Copy)/src/components/`  
**Target**: `flutter_chekmate/lib/features/*/`

### Navigation & Shell (4 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `BottomNavigation.tsx` | `lib/features/navigation/widgets/bottom_nav_widget.dart` | 1 | ✅ EXISTS |
| `Header.tsx` | `lib/features/navigation/widgets/header_widget.dart` | 1 | ✅ EXISTS |
| `NavigationTabs.tsx` | `lib/features/navigation/widgets/nav_tabs_widget.dart` | 1 | ✅ EXISTS |
| `NavigationWidget.tsx` | `lib/features/navigation/widgets/navigation_widget.dart` | 1 | ✅ EXISTS |

### Home, Feed & Stories (6 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `Stories.tsx` | `lib/features/stories/widgets/stories_widget.dart` | 2 | PARTIAL |
| `StoryViewer.tsx` | `lib/features/stories/widgets/story_viewer.dart` | 2 | PARTIAL |
| `Post.tsx` | `lib/features/feed/widgets/post_widget.dart` | 2 | PARTIAL |
| `PostCreationModal.tsx` | `lib/features/feed/widgets/post_creation_modal.dart` | 2 | PARTIAL |
| `PostDetailModal.tsx` | `lib/features/feed/widgets/post_detail_modal.dart` | 2 | PARTIAL |
| `PostInputBar.tsx` | `lib/features/feed/widgets/post_input_widget.dart` | 2 | PARTIAL |

### Explore & Location (2 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `Explore.tsx` | `lib/features/explore/pages/explore_page.dart` | 3 | PARTIAL |
| `LocationSelector.tsx` | `lib/features/location/widgets/location_selector.dart` | 3 | PARTIAL |

### Create Post & Media (3 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `VideoCard.tsx` | `lib/features/video/widgets/video_card_widget.dart` | 4 | MISSING |
| `VideoPlayer.tsx` | `lib/features/video/widgets/video_player_widget.dart` | 4 | PARTIAL |
| `ShareModal.tsx` | `lib/features/feed/widgets/share_modal.dart` | 4 | MISSING |

### Messaging & Chat (3 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `MessagesPage.tsx` | `lib/features/messaging/pages/messages_page.dart` | 5 | PARTIAL |
| `MessagingInterface.tsx` | `lib/features/messaging/pages/messaging_interface.dart` | 5 | PARTIAL |
| `ConversationInputBar.tsx` | `lib/features/messaging/widgets/conversation_input_widget.dart` | 5 | PARTIAL |

### Notifications (3 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `Notifications.tsx` | `lib/features/notifications/pages/notifications_page.dart` | 6 | PARTIAL |
| `NotificationItem.tsx` | `lib/features/notifications/widgets/notification_item_widget.dart` | 6 | PARTIAL |
| `NotificationsHeader.tsx` | `lib/features/notifications/widgets/notifications_header_widget.dart` | 6 | MISSING |

### Profile, Settings & Subscription (9 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `MyProfile.tsx` | `lib/features/profile/pages/my_profile_page.dart` | 7 | PARTIAL |
| `UserProfile.tsx` | `lib/features/profile/pages/user_profile_page.dart` | 7 | PARTIAL |
| `EditProfile.tsx` | `lib/features/profile/pages/edit_profile_page.dart` | 7 | PARTIAL |
| `ProfileCard.tsx` | `lib/features/profile/widgets/profile_card_widget.dart` | 7 | PARTIAL |
| `ProfileHeader.tsx` | `lib/features/profile/widgets/profile_header_widget.dart` | 7 | PARTIAL |
| `ProfileStats.tsx` | `lib/features/profile/widgets/profile_stats_widget.dart` | 7 | MISSING |
| `FlippableProfileCard.tsx` | `lib/features/profile/widgets/flippable_profile_card.dart` | 7 | PARTIAL |
| `ProfilePictureChanger.tsx` | `lib/features/profile/widgets/profile_picture_changer.dart` | 7 | PARTIAL |
| `ShareProfile.tsx` | `lib/features/profile/widgets/share_profile_widget.dart` | 7 | PARTIAL |
| `SettingsPage.tsx` | `lib/features/profile/pages/settings_page.dart` | 7 | MISSING |
| `Subscribe.tsx` | `lib/features/subscription/pages/subscribe_page.dart` | 7 | PARTIAL |

### Live & Video (2 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `Live.tsx` | `lib/features/live/pages/live_page.dart` | 8 | PARTIAL |
| `Following.tsx` | `lib/features/feed/pages/following_page.dart` | 8 | PARTIAL |

### Rate Your Date (2 components)
| React File | Flutter Target | Group | Status |
|------------|----------------|-------|--------|
| `RateYourDate.tsx` | `lib/features/rate_date/pages/rate_your_date_page.dart` | 9 | PARTIAL |
| `RateYourDateHeader.tsx` | `lib/features/rate_date/widgets/rate_your_date_header_widget.dart` | 9 | MISSING |

---

## Status Legend
- ✅ **DONE**: Complete implementation
- **PARTIAL**: Exists but needs polish/completion
- **MISSING**: Needs to be created

## Next Actions
1. Complete HIGH priority UI primitives (Sheet, Popover, Tooltip, Select, Tabs)
2. Convert MISSING feature components
3. Polish PARTIAL implementations
4. Test and integrate all components
