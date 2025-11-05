# main_projects — a curated collection of small iOS apps and experiments

Hi — I’m Arihant Marwaha. This repository is my developer sketchbook: a set of small apps, learning ports, and prototypes I built while practicing Swift, SwiftUI, and experimenting with small AI integrations and device features. These are not production apps; they are practical experiments and examples I returned to often while learning. I’ve refined this README to explain what each folder contains, how to run projects locally, where to look for key files, and how you can reuse or contribute.

Why I keep this repo
- It’s my lab for trying ideas quickly: small apps, UI experiments, HomeKit and AI prototypes.
- Each project captures a specific learning goal—often the best way to teach others is to show working code.
- If something here helps you build faster or learn a concept, I’m glad it’s useful.

How this repo is organized
- Each project has its own top-level folder. Typical folder names: Study Buddy, GUGU, DSAM, Landmarks, Moodsync, Notes app, Blank, Juornal port.
- Look for a README inside a project folder for project-specific notes, screenshots, or special run steps.
- If a project uses CocoaPods, you’ll find a Podfile—run `pod install` and open the generated .xcworkspace.
- If a project uses Swift Package Manager, Xcode will resolve packages on open.

Quick environment notes
- Recommended Xcode: 13–15 (projects were created over several Xcode versions). If a project fails to compile, try updating the build settings or Swift language version in Xcode.
- Signing: Set your own development team in Xcode (Signing & Capabilities) to run on a real device.
- Device integrations: HomeKit/HomePod features require real hardware; the simulator can exercise UI flows only.
- No API keys committed: If a feature needs a third‑party API key, search for files named `Config.swift`, `Secrets.swift.example`, or `*.example`—fill local configs and keep keys out of Git.

What’s in each project (practical guide)

1) Study Buddy — AI study helper (NOTES, PROGRESS, MIND MAP)
- Short description: A focused study assistant that combines quick note capture, session tracking, and a node-based mind map view to visualize connections between ideas.
- Why I built it: I wanted an app that helps me summarize notes, track study streaks, and visually link concepts when preparing for exams or projects.
- Notable files: look for an App entry (AppDelegate/Scene), NotesView / NotesModel, MindMapView, and a file named `AIService` or `SummaryProvider` for early AI integration hooks.
- How to run:
  1. Open the Study Buddy folder in Finder.
  2. If there is a Podfile: run `pod install` and open the `.xcworkspace`.
  3. Open the project in Xcode (14+ recommended) and run on simulator or device.
  4. For AI features, provide an API key locally where the code documents it.
- Status: active prototype — useful logic, WIP UI polish and persistence hardening.
- Where to contribute: node export/import, offline-first sync, and unit tests.

2) GUGU — SSC competition app
- Short description: My polished entry for an SSC competition. The app focuses on a small user problem and a clean UX.
- Why I built it: to practice designing a tight, user-focused flow and to ship something competition-ready.
- How to run: open GUGU in Xcode. Run `pod install` if a Podfile is present.
- Status: polished for the contest; a good example of layout and accessibility practices.

3) DSAM — Daily productivity manager
- Short description: A lightweight task/habit manager with daily focus and simple analytics.
- Why I built it: to practice state management and local persistence while solving my own daily planning needs.
- How to run: open DSAM in Xcode and install dependencies if present.
- Status: useful as a learning reference. Tests and UX polish welcome.

4) Landmarks — Apple sample port
- Short description: My port/learning copy of Apple’s Landmarks sample project to practice SwiftUI, maps, and data flow.
- How to run: open in Xcode, no external deps expected.
- Status: educational.

5) Moodsync — mood tracker + ambient control
- Short description: Experimental mood tracker that connects mood logs to ambient device control (ideas for lighting and HomePod adjustments).
- Why I built it: to explore whether changing the environment can support mood regulation and to learn HomeKit patterns.
- How to run: open in Xcode; UI works in simulator but HomeKit/HomePod features need real devices and Home setup.
- Status: proof-of-concept; HomeKit code is experimental.

6) Notes app
- Short description: A compact notes app to practice persistence, editing, and search.
- How to run: open Notes app in Xcode and run.
- Status: straightforward example for text persistence.

7) Blank
- Short description: A minimal Swift sandbox — intentionally small so I can prototype quickly.
- How to run: open Blank in Xcode.

8) Juornal port (note folder name)
- Short description: A journal app port or small journal prototype (folder name intentionally preserved as `Juornal port`).
- How to run: open in Xcode. Expect minor name/refactor cleanups may be necessary.

Troubleshooting tips
- Missing modules or dependency errors: ensure you opened the `.xcworkspace` if CocoaPods was used, or let Xcode resolve Swift packages for SwiftPM projects.
- Signing errors: set your development team in the project’s Signing & Capabilities settings.
- Apple framework/API changes: if a project errors due to API changes, check the project’s Swift version and consider migrating code in Xcode.
- API keys: add local config files and keep them gitignored. Look for `*.example` files for patterns I left in the repo.

Contributing — practical pointers
- I welcome focused PRs: bug fixes, README improvements in individual project folders, small refactors, and tests.
- When opening a PR:
  1. Keep changes scoped to one project or a clear cross-project utility.
  2. Explain the change and how to verify it in the PR description.
  3. Don’t add credentials or large binaries.
- When opening issues, include Xcode version, iOS version (device vs simulator), and reproduction steps.

Development notes and style
- You’ll see a mix of UIKit and SwiftUI across folders—projects span my learning timeline.
- Early prototypes may have quick, pragmatic code. If you clean code, tests or a small refactor are appreciated.

License & reuse
- Unless a project has its own LICENSE file, treat code here as intended for learning and reference. If you want to use code in a product, please open an issue so we can discuss licensing and attribution.

Contact
- GitHub: @ArihantMarwaha — open an issue or PR to start a conversation.

Thanks for looking through my sketchbook. If you’d like, I can:
- Add screenshots to each project README
- Create per-project run scripts or sample data
- Add a CONTRIBUTING.md with a checklist for PRs

(If you want me to commit screenshots or per-project READMEs next, tell me which project to prioritize and I’ll prepare the files.)