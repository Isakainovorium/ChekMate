# Orders

Operational docs to drive the UI polish execution.

- `GROUPS.md`: the 9 feature groups and file mappings.
- `TASKS.md`: the ordered checklist ("work mode").

Suggested workflow:
- Work one group at a time, starting with shared/ui primitives required by that group.
- Use a branch per component or group (e.g., `feat/ui-button`, `feat/group-2-feed`).
- Add Widgetbook stories and golden tests before merging.
- Keep parity with React `src/components/ui/` where it makes sense.
