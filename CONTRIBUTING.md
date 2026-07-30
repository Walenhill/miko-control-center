# Contributing

Both Russian and English issues are welcome.

Before sending a change:

1. keep system logic in a `*Controller.qml`;
2. reuse or extend `Miko*` primitives;
3. pass dependencies explicitly with `required property`;
4. gate optional commands through `Capabilities`;
5. never run destructive operations during component initialization;
6. update both language versions of user-facing documentation;
7. run `./scripts/check.sh`.

Keep pull requests focused. Include the tested distribution, compositor,
Quickshell version and relevant optional integrations.
