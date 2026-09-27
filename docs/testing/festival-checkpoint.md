# Festival checkpoint

Preserved before switching to a recreation of Colossal Cave Adventure, at the user's request.

Implemented: native desktop window with enlarged 18-point text, 19 locations, seven main puzzles, five treasures, lantern fuel, fatal pump/flood hazards, progressive hints, and versioned save/load.

Verification: full headless suite passed 89 checks on the installed full PureBasic 6.41 macOS x64 compiler. The main-story route used 42 turns and retained 40 fuel. An all-five-treasure route and a different branch order passed. The desktop app compiled and launched; its opening screen was visually inspected.

Outstanding: Windows and native macOS arm64 builds, independent code review, fresh-player playtesting, and manual desktop interaction checks. macOS denied accessibility access to the attempted UI automation. This checkpoint is not a fully verified release.

Development is preserved on `feat/festival`. The original-game recreation starts on `feat/colossal-cave-original`.
