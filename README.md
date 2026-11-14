#<p align="center">
  <img src="logo.png" alt="Multimail_logo" width="100">
</p>

<h1 align="center">Clocked</h1>

<br>

A tiny macOS menu bar app that tracks how much time you spend on different projects. 

No accounts. No streaks. No notifications. No "productivity tips." Just pick a project, hit start, and it counts.

## Preview

![Clocked Screenshot](media/Screenshot1.png)
![Clocked Screenshot](media/Screenshot2.png)

## Download

Grab the latest [Clocked.dmg](https://github.com/izzyflestado/Clocked/releases/download/V1.0.0/Clocked.dmg) from the [Releases page](https://github.com/izzyflestado/Clocked/releases).

## What it does

- Lives in your menu bar. Click it, get a popover.
- **Timer tab** — pick/create/rename/delete projects, big readout, Start/Pause/Stop.
- **Stats tab** — pie chart + list of totals per project, each with its own customizeable color.
- Menu bar icon shows the live time while a timer's running. Logo shows when it's paused or stopped.
- Settings:
  - Customize background and text color.
  - Quit app.

## Roadmap
 
1. [ ] Add menu bar popup for automatic start to select project
2. [ ] Add feature: Automatic app detection
3. [ ] Automatic start a timer on project
4. [ ] Add github like contrib graph
5. [ ] Add restore to default button on settings
6. [ ] Add dedicated settings
7. [ ] Add shortcut keybind
8. [ ] Add blocking for active apps/websites to pause time or automatically unpause when not active)

## Running it

```bash
swift build
swift run
```

Requires macOS 14+.
