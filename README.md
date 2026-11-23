# SLIDE CULT

**A keyboard-first 3D drift game prototype built with Godot 4.**

SLIDE CULT is an early-stage arcade drift project. The current milestone focuses on a responsive third-person driving loop, drift scoring, combo chaining, and three greybox environments. Art and vehicle handling are deliberately being iterated before expanding the garage and progression systems.

## Requirements

- Godot Engine 4.3 or newer (Godot 4.x)
- Windows, Linux, or macOS
- Keyboard; no mouse is required during driving

## Run locally

1. Clone or download this repository.
2. Open Godot Project Manager.
3. Select **Import** and choose the repository's `project.godot`.
4. Open the project and press **F6/F5** or the Play button.

## Controls

| Key | Action |
| --- | --- |
| Arrow keys / WASD | Steer and accelerate / brake |
| Shift / Space | Handbrake |
| R | Reset car |
| 1 | Parking lot |
| 2 | City block |
| 3 | Touge road |
| Esc | Pause / resume |

## Current prototype

- Third-person chase camera
- Keyboard-only driving controls
- Arcade vehicle controller with lateral slip and handbrake grip
- Drift angle, session score, combo multiplier, and speed HUD
- Three procedural greybox environments: parking lot, city block, and touge
- Reset and map switching

## Project structure

```
project.godot
scenes/
  Main.tscn
scripts/
  main.gd
  car_controller.gd
  follow_camera.gd
docs/
  ROADMAP.md
```

## Development status

This is **not a finished realistic simulator**. The car and environments are procedural placeholders. The immediate next steps are to tune the handling, improve collision/track geometry, add wheel animation and tire effects, and then build the garage and car selection flow.

See [docs/ROADMAP.md](docs/ROADMAP.md) for milestones.
