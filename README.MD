- Ready to use patches can be found in [releases](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/releases) section.
- Development thread on my Discord https://discord.gg/fDY4VR6rNE

# Launchers

| Launcher | Compatibile versions |
| --- | --- |
| Redacted Lan | First Room Fix Redacted |
| Redacted Nightly | First Room Fix Redacted |
| Ancient Pluto | First Room Fix Redacted |
| New Pluto | First Room Fix, First Room Fix Vanilla |

# Pluto Versions
Compatibility ragarding legitimacy of the game while playing for records

| Version | V3 | V4 | V5 | V5.2+ | Redacted |
| --- | --- | --- | --- | --- | --- |
| Ancient | - | - | - | - | v |
| R2905 (solo) | x | v | v | v | x |
| R2905 (coop) | v | x | x | v | x |
| R3000+ (solo) | v | v | v | v | x |
| R3000+ (coop) | v | x | x | v | x |

# Gameplay:
Default features:
- Anticheat (dvars & gameplay).
- Fix for Strafe & Backspeed scale.
- Fix for host migration issue in private matches (pluto only).
- Fix for Target Assist in zombies (pluto only).
- Fix for pre-patch recoil (pluto only).
- Fix for Tickrate (pluto only).
- Red dot reticle for scopes (pluto only).
- Info and debug prints to console (pluto only).

Optional features:
- Set Zombie Blood as a challenge box reward on Origins.
- Nuketown blue eyes for the entire game
- Nuketown mannequins set for yellow house & first room
- Set weapon in the fridge & full bank
- Give permaperks
    - Jug
    - Flopper
    - Revive
    - Deadshot
    - Tombstone
    - Metal boards
    - Raygun (Tranzit & Buried)
- First Box module (pluto only)
    * First box module will be active until round 11
    * Not setting the dvar will result in box behaving normally
    * If weapon is set the game will show First Box warning
    * Select next box weapon using `fbgun` dvar
        + `mk1` - RayGun
        + `mk2` - RayGun Mark II
        + `monk` - Monkey Bomb
        + `emp` - EMP Grenades
        + `barret` - M82 Barret
        + `dsr` - DSR50
        + `57` - FiveSeven
        + `257` - Five Seven X2
        + `fal` - FN FAL
        + `galil` - Galil
        + `mtar` - MTAR
        + `hamr` - HAMR
        + `exe` - Excecutioner
        + `kap` - KAP40
        + `bk` - Ballistic Knife
        + `wm` - War Machine
        + `pyt` - Python
        + `type` - Type95
        + `rpd` - RPD
        + `s12` - Saiga 12
        + `m1216` - M1216
        + `chic` - Chicom CQB
        + `rpg` - RPG
        + `M8A1` - M8A1

# HUD 
Default features:
- Print network frame at the beginning of the game (tickrate).
- Game and round time display after each round (if static timers are disabled).
- Velocity meter.
    * Use `velocity_size` dvar to change the size of the Velocity meter (1.0 - 5.0)
- Round splits displayed every 5 rounds after 10.

Optional features:
- Static timer / static round timer
- Amount of hordes displayed for each round on round 20 onwards.
- Semtex prenades

# Optional features
Let me know which of the optional features you want enabled while requesting the patch. If you like the default settings (table below), use version from releases

Default settings of First Room Fix
| Function | Main | Vanilla | Redacted |
| --- | --- | --- | --- |
| Timer | v | x | v |
| Round Timer | x | x | x |
| Horde count | v | x | v |
| Semtex Prenades | v | x | v |
| Origins Zombie Blood override | x | x | x |
| Permaperks | v | v | v |
| Fridge weapon | x | x | x |
| Nuketown Mannequinns | x | x | x |
| Nuketown Blue Eyes | x | x | x |
| First Box Module | x | x | - |
| Timer coop pause | - | - | - |

# Tech
- All versions below 5.4 were Compiled using irony.dll
- 5.4 onwards is compiled using xensiks [gsc-tool](https://github.com/xensik/gsc-tool)

# Thanks to
- [JezuzLizard](https://github.com/JezuzLizard)
- [5and5](https://github.com/5and5)
- [Txchno](https://github.com/mbahgatTech)