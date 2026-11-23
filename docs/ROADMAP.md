# SLIDE CULT — Roadmap

## Milestone 0.1 — Playable foundation
- [x] Godot 4 project scaffold
- [x] Keyboard-only controls
- [x] Third-person chase camera
- [x] Basic arcade drift controller
- [x] Drift score and combo HUD
- [x] Parking, city, and touge greybox layouts
- [ ] Test in Godot and tune handling from real play feedback

## Milestone 0.2 — Driving feel
- [ ] Wheel steering and rotation animation
- [ ] Better traction, counter-steer, braking, and handbrake behavior
- [ ] Tire smoke and skid marks
- [ ] Engine, tire, and surface audio
- [ ] Collision feedback and reliable reset points

## Milestone 0.3 — Garage and cars
- [ ] Garage scene and car selection
- [ ] Multiple distinct cars with different handling
- [ ] Paint and wheel customization
- [ ] Basic performance tuning

## Milestone 0.4 — Progression
- [ ] Credits and event rewards
- [ ] Local personal-best records
- [ ] Unlockable cars and maps
- [ ] Save/load profile

## Milestone 1.0 — Presentation
- [ ] Replace greybox layouts with designed environments
- [ ] Optimized vehicle and environment assets
- [ ] Lighting, post-processing, and menus
- [ ] Settings and accessibility options

## Technical principles
- Keyboard-first: all core driving and menu actions must work without a mouse.
- Performance-aware: target stable play on modest laptop hardware.
- Build in tested increments; do not mark a feature complete until it has been run in Godot.
- Keep the prototype dependency-light and use Godot-native systems where practical.
