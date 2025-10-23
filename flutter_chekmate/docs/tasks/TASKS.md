# Work Mode: UI polish plan

This checklist drives full-polish UI implementation to match Figma. Use it in order. Mark items as completed as we land PRs.

## 0) Foundation (tokens, review, tools)
- [ ] Verify theme tokens mapping to Figma in `lib/core/theme/` (colors, spacing, radii, typography, shadows)
- [ ] Add Widgetbook stories for new shared components
- [ ] Set up golden (image) tests for key components

## 1) Shared UI primitives (shared/ui)
- [ ] AppButton (variants: primary, secondary, outline, text; sizes: sm, md, lg; loading)
- [ ] AppCard (standard radius, elevation, padding)
- [ ] AppDialog (title/content/actions, helper `AppDialog.show`)
- [ ] AppSheet (modal bottom sheet wrapper, full-height option)
- [ ] AppPopover and AppTooltip (overlay positioning and theming)
- [ ] AppDropdownMenu / AppSelect (list, searchable variant later)
- [ ] AppTabs (underline/mute styles, with scroll)
- [ ] AppMenuBar / NavigationMenu (desktop/tablet parity)
- [ ] AppForm primitives: Input, Textarea, Checkbox, RadioGroup, Switch, Slider, OTP
- [ ] AppSkeleton and AppProgress
- [ ] AppTable and AppPagination
- [ ] AppAvatar, AppBadge
- [ ] AppCarousel
- [ ] Chart wrapper (choose: fl_chart or charts_flutter)

## 2) Group polish passes
Follow `Orders/GROUPS.md`. For each group:
- [ ] Replace in-page custom widgets with shared/ui primitives
- [ ] Ensure empty/loading/error states
- [ ] Align paddings, radii, elevations to tokens
- [ ] Verify a11y: contrast, touch targets, semantics
- [ ] Add critical golden tests and Widgetbook entries

### [1] Navigation Shell
- [ ] Bottom nav interactions and badges
- [ ] Header search, actions, overflow menus

### [2] Home Feed & Stories
- [ ] Stories viewer (progress, gestures, dismiss)
- [ ] Post card: media, actions, menus, share

### [3] Explore & Location
- [ ] Search UI with filters/sorting (selects, chips)
- [ ] Location picker and permissions flow

### [4] Create Post & Media
- [ ] Create modal/sheet flow
- [ ] Media pickers, preview, progress

### [5] Messaging & Chat
- [ ] Conversation list skeletons, swipe actions
- [ ] Chat bubble styles, typing indicators

### [6] Notifications
- [ ] Grouped list, read/unread states, actions

### [7] Profile, Settings & Subscription
- [ ] Profile header, stats, edit profile forms
- [ ] Subscription/Paywall UI

### [8] Live & Video
- [ ] Live tile states, join UX, viewers list
- [ ] Video playback controls

### [9] Rate Your Date
- [ ] Rating interactions, constraints, submit UX

## 3) Routing & overlays
- [ ] Ensure overlays hide bottom nav (stories, chat, rate-date)
- [ ] Replace any remaining Navigator.push with GoRouter

## 4) Assets & icons
- [ ] Bring in Figma icons/assets (SVG/PNG) with correct theming

## 5) Performance & QA
- [ ] Profile UI jank on low-end device (impeller on iOS)
- [ ] Image caching, list virtualization
- [ ] Final visual audit vs Figma

---

Owner: UI Working Group
Status: Active
