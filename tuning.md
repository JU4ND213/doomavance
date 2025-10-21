# Doom Avance - Tuning Recommendations

This document contains suggested tuning parameters for gameplay balance. Use these as starting points and iterate with playtesting.

General notes
- Target session length: ~3-8 minutes per run for early players.
- Gradual difficulty increase per wave; avoid sudden spikes.

Wave configuration
- Base rows: 2
- Base cols: 4
- Rows growth: +1 every 3 waves
- Cols growth: +1 every 2 waves
- Capturer chance: start 5% -> increase by +1% per wave, clamp 3%..25%

Enemy speeds
- Base dive speed: 160 px/s
- Capturer dive speed: 120 px/s (slower so capture feels threatening)
- Dive speed growth: +10 px/s every 2 waves

Player
- Base speed: 220 px/s (responsive)
- Shoot cooldown: 0.22s (allows ~4.5 shots/sec)
- Double-ship duration: permanent once rescued (or you can make it timed, e.g. 12s)

Projectiles
- Speed: 520 px/s
- Size: 6x12

Timers and pacing
- Time between waves: 2s (add a 3..2..1 countdown for player clarity)
- Dive interval base: 3s; reduce by 150ms per wave, min 0.8s

Visual & Audio
- Explosion: short (~300ms) particle burst + sound SFX (short "boom")
- Shot SFX: light pew
- Capture SFX: distinct rising alarm

Playtest checklist
1. Run with default parameters and play 5-10 waves. Check difficulty curve.
2. Adjust spawn counts if screen feels overwhelmed.
3. If capturers are too punishing, reduce initial chance and/or increase rescue probability.

Notes
- Values are suggestions. Use the HUD to show `waveNumber`, `lives`, and consider adding `difficulty` sliders for live tuning.
