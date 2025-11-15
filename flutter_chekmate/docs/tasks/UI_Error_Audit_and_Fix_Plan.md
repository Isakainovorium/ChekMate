# UI Error Audit and Fix Plan

Scope scanned (read-only):
- `flutter_chekmate/lib/features/`
- `flutter_chekmate/lib/features/rate_date/`
- `flutter_chekmate/lib/features/stories/`
- Note: `flutter_chekmate/lib/widgets/` does not exist. Using `flutter_chekmate/lib/shared/widgets/` in practice; Navigator/overlay usage found there too.

Methodology (static grep):
- TODO/FIXME markers
- print/debugPrint usage
- Navigator API usage (migrate to GoRouter)
- setState occurrences (assess Riverpod migration)
- Unimplemented stubs (UnimplementedError/throw)
- Lint disables (ignore_for_file)

---

## High-level findings

- **[React UI parity gap]** The Flutter app lacks a full shared UI primitives set compared to React `ui/`. We created `lib/shared/ui/` to begin closing this gap, but many primitives remain to build.
- **[Navigation consistency]** Several screens still use `Navigator.*`; must standardize on `GoRouter` (`context.go/context.push`) and ensure overlays hide bottom nav.
- **[Debug prints]** Multiple `print()` usages across features need removal or replacement with a logger (and `kDebugMode`).
- **[setState overuse]** Common in pages/forms. Keep for trivial local UI toggles; move longer-lived state to Riverpod providers.
- **[TODO/FIXME hotspots]** Concentrated in `home_page.dart`, `home_page_new.dart`, `create_post/*`, `auth/*`, `messages/*`.
- **[Unimplemented stubs]** Found in `rate_date/pages/rate_your_date_page.dart` and `stories/widgets/story_viewer.dart` (usage gaps/partials).

---

## Directory-by-directory summary

### 1) `lib/features/` (global)
- **[TODO/FIXME]**
  - `features/home/presentation/pages/home_page.dart` (9)
  - `features/auth/presentation/pages/login_page.dart` (5)
  - `features/create_post/pages/video_editor_page.dart` (4)
  - `features/home/presentation/pages/home_page_new.dart` (4)
  - `features/create_post/pages/camera_page.dart` (3)
  - `features/create_post/widgets/post_options_panel.dart` (2)
  - `features/home/pages/home_feed_page.dart` (2)
  - `features/messages/presentation/pages/messages_page.dart` (2)
  - `features/auth/presentation/pages/signup_page.dart` (1)
  - `features/subscription/pages/subscribe_page.dart` (1)
- **[print/debugPrint]**
  - `features/home/presentation/pages/home_page_new.dart` (7)
  - `features/explore/pages/explore_page.dart` (6)
  - `features/profile/pages/my_profile_page.dart` (6)
  - `features/messaging/widgets/conversation_input_widget.dart` (4)
  - `features/messaging/pages/messages_page.dart` (2)
  - `features/messaging/pages/messaging_interface.dart` (2)
  - `features/profile/pages/user_profile_page.dart` (2)
  - `features/profile/widgets/profile_header_widget.dart` (2)
  - `features/feed/widgets/post_creation_modal.dart` (1)
  - `features/feed/widgets/post_input_widget.dart` (1)
  - `features/live/pages/live_page.dart` (1)
- **[Navigator.*]** (partial list)
  - `features/create_post/pages/create_post_page.dart` (6)
  - `features/create_post/pages/camera_page.dart` (4)
  - `features/create_post/pages/video_editor_page.dart` (4)
  - `features/create_post/widgets/post_options_panel.dart` (4)
  - `features/location/widgets/location_selector.dart` (3)
  - `features/profile/pages/edit_profile_page.dart` (5)
  - `features/live/pages/live_feed_page.dart` (2)
  - `features/profile/pages/profile_page.dart` (2)
  - `features/profile/widgets/profile_picture_changer.dart` (2)
  - `features/stories/widgets/story_viewer.dart` (2)
  - …and others (see grep summary).
- **[setState]** Common across many pages (create_post, stories, video, profile, auth). Keep only for ephemeral UI toggles; move core data flow to Riverpod.

### 2) `lib/features/rate_date/`
- **[TODO/Unimplemented]** `pages/rate_your_date_page.dart` (1)
- **[setState]** Present; consider provider for rating state, validation, and submission flow.
- **[Plan]** Needs polished UI (gestures, constraints, submit UX) and nav behavior (hide bottom nav) aligned with Figma.

### 3) `lib/features/stories/`
- **[Navigator/print]** `widgets/story_viewer.dart` has navigator usage and prints.
- **[setState]** Used for viewer state; move view-state (isViewingStories) to `navStateProvider` (already available) and consolidate progress/gesture handling.
- **[Plan]** Implement full-screen story viewer overlay: progress bars, tap/hold/drag gestures, preload, and proper dismissal with nav bar restore.

### 4) `lib/shared/widgets/` (instead of non-existent `lib/widgets/`)
- **[Navigator usage]** `shared/widgets/app_dialog.dart` uses `showDialog` in multiple spots; ensure consistent AppDialog usage once shared/ui `AppDialog` is adopted.
- **[Plan]** Migrate callers to `lib/shared/ui/components/app_dialog.dart` for consistent styling and behavior.

---

## Concrete fix plan

### A) Remove debug prints and replace with logger
- **[Action]** Replace `print()`/`debugPrint()` with a central logger in `lib/core/utils/logger.dart` and/or guard with `kDebugMode`.
- **[Targets]** Files listed above under print/debugPrint.
- **[Done when]** No `print(` occurrences remain in features; only logger or no-op.

### B) Migrate all `Navigator.*` to GoRouter
- **[Action]** Use `context.go('/path')` or `context.push('/path')` consistently; pass params via path/query. Confirm hide/show bottom nav for overlays (stories/chat/rate-date).
- **[Targets]** Files listed above under Navigator usage.
- **[Done when]** grep for `Navigator.` returns 0 under `lib/features/` and `lib/shared/widgets/` (except internal dialog APIs where appropriate).

### C) Triage TODO/FIXME and unimplemented stubs
- **[Action]** Convert each TODO to a tracked task in Orders and address:
  - `home_page[_new].dart`: finish top tabs, replace prints with analytics/logs, polish header actions.
  - `create_post/*`: finish camera/video flows, permissions, progress, error UX.
  - `auth/*`: form validation, error surfaces, routing after auth.
  - `messages/*`: chat list polish, deep links to `/chat/:id`.
  - `rate_date`: rating interactions, constraints, submit UX, hide nav.
  - `stories`: full viewer overlay, gestures, preload, nav bar restore.
- **[Done when]** TODO/FIXME grep returns 0 in features folders.

### D) Rationalize setState vs Riverpod
- **[Action]**
  - Keep `setState` for trivial UI toggles (e.g., password visibility).
  - Move longer-lived state (filters, selections, async data, viewer states) to Riverpod providers.
  - Add tests for provider logic where critical.
- **[Targets]** create_post pages, story_viewer, video player, profile edit, signup/login flows.

### E) Adopt shared UI primitives and align visuals
- **[Action]** Use `lib/shared/ui/` primitives (AppButton, AppCard, AppDialog) now; add next primitives: AppSheet, AppSelect/Dropdown, AppPopover, AppTooltip, AppTabs.
- **[Done when]** feature pages replace local ad-hoc widgets with shared primitives; Widgetbook entries exist.

### F) Testing and verification
- **[Action]**
  - Widgetbook stories for key components and pages.
  - Golden tests for critical components (buttons, dialogs, sheets) and select screens.
  - `flutter analyze` clean; CI task to enforce.

---

## File-by-file task seeds (representative)

- **[home]** `home_page.dart`, `home_page_new.dart`, `home_feed_page.dart`:
  - Replace prints, complete TODOs, ensure top-tab state via provider, nav via GoRouter.
- **[create_post]** `camera_page.dart`, `video_editor_page.dart`, `create_post_page.dart`, `post_options_panel.dart`:
  - Migrate Navigator, add permission/async handling, progress states, shared AppSheet for modals.
- **[auth]** `login_page.dart`, `signup_page.dart`:
  - Strong validation, error surfaces, provider-driven auth flow, replace prints.
- **[messages/messaging]** `messages_page.dart`, `messaging_interface.dart`, `conversation_input_widget.dart`:
  - GoRouter to `/chat/:id`, typing indicators, skeletons, logger.
- **[profile]** `edit_profile_page.dart`, `profile_page.dart`, `profile_header_widget.dart`, `profile_picture_changer.dart`, `my_profile_page.dart`, `user_profile_page.dart`:
  - Shared UI adoption, Navigator migration, replace prints.
- **[stories]** `story_viewer.dart`:
  - Implement full viewer overlay with progress/gestures; provider for view state; restore nav on close.
- **[rate_date]** `rate_your_date_page.dart`:
  - Provider for rating, constraints, submit UX; nav hide.
- **[live]** `live_page.dart`, `live_feed_page.dart`:
  - Video control polish, error/loading states, Navigator migration.
- **[explore/location]** `explore_page.dart`, `location_selector.dart`:
  - Filters/selects via shared UI; provider flow; replace prints; Navigator migration.

---

## Success criteria
- **[No Navigator.* in features]** All routes via GoRouter; overlays hide nav correctly.
- **[Zero prints/TODOs]** Grep returns 0 for `print(` and `TODO|FIXME` across features.
- **[Consistent UI]** Shared UI primitives adopted in feature pages; visual parity with Figma.
- **[State clarity]** Riverpod providers own cross-screen state; `setState` limited to local UI toggles.
- **[Tests]** Widgetbook and golden tests in place; `flutter analyze` passes.

---

Generated by static scan (grep) across the target directories. If you want, I can start creating PR-sized edits per group (Orders/GROUPS.md) beginning with Navigation/Feed or Stories.
