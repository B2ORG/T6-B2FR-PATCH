- Ready to use patches can be found in [releases](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/releases) section.
- Development thread on my Discord https://discord.gg/fDY4VR6rNE

# Launchers

First Room Fix is compatibile with all modern Pluto versions. At this point in time i don't provide release versions for other launchers.
That being said, a special version for Redacted is present in the repository,
you may download the script file and use it as is, Redacted does not require compiled scripts. After compilation Redacted script also works with older offline Plutonium versions.

# Pluto Versions
Compatibility ragarding legitimacy of the game while playing for records

| Version | V3 | V4 | V5 | V5.2+ | Redacted |
| --- | --- | --- | --- | --- | --- |
| Others | - | - | - | - | v |
| R2905 (solo) | x | v | v | v | x |
| R2905 (coop) | v | x | x | v | x |
| R3000+ (solo) | v | v | v | v | x |
| R3000+ (coop) | v | x | x | v | x |

# Features:

Table of features lists all the basic functions the patch does. This is not absolutely everything it can do, there are a lot of small details but this more or less sums it up. Check column presence to know whether a feature is in the script by default. Value `Default` means, the feature is there and cannot be disabled (HUD elements are off if Vanilla version is used even if they're listed as Default). If value is `Enabled`, means a version of the patch can be requested with that option disabled, and value `Disabled` means the version with that option enabled can be produced. Special cases are Game and Round timers, where the toggle is between the timer being on the screen at all times or only at the end of each round.

| Feature | Platform | Implementation | Presence | Dsc |
| --- | --- | --- | --- | --- |
| Backspeed depatch | All | V1 | Default | Puts back Strafespeedscale and Backspeedscale to Steam values |
| Game Timer | All | V1 | Default | Displays game timer, optionally it can be only showing game time after each round for few seconds |
| Fix to hostmigration | Pluto | V2 | Default | Changes `sv_endGameIfISuck` dvar to prevent host migration issues |
| Nuketown Mannequins | All | V2 | Disabled | Removes certain mannequins from the map to prevent restarts for First Room and Yellow House |
| Target Assist removal | Pluto | V3 | Default | Disables Target Assist |
| Reddot Reticle | Pluto | V3 | Default | Sets reticle to always be a reddot in PaPed guns | 
| Nuketown Blue Eyes | All | V3 | Disabled | Changes zombies eyes to blue, and announcer voice accordingly |
| Anticheat | All | V4 | Default | Scans most basic game values players could attempt to change to cheat a game |
| Round Timer | All | V4 | Default | Displays round time. By default it's showing up for a few seconds after each round, but optionally it can be enabled to display at all times |
| Prepatch recoil removal | Pluto | V4 | Default | Puts back some recoil values back to Steam version |
| Tickrate Fix | Pluto | V4 | Default | Sets tickrate back to steam values. This function has been fixed in version 5.2, as original implementation wasn't correct |
| Origins blood override | All | V4 | Disabled | Overrides the reward to always be zombie blood, required for having blood at all in older pluto versions |
| Permaperks | All | V4 | Enabled | Gives permaperks |
| Console debug / info prints | Pluto | V5.0 | Default | Various info printed out to plutonium console | 
| Velocity Meter | All | V5.0 | Default | Displays current velocity of the player |
| Round splits | All | V5.0 | Default | Displays round splits every 5 rounds after round 10 |
| Horde size | All | V5.0 | Enabled | Displays the amount of hordes for the round after round 20 on each round |
| First Box | All | V5.1 | Disabled | Allows for overriding guns in the box (and is very vocal about it) |
| Semtex prenades | All | V5.1 | Enabled | Shows the amount of prenades on Semtex for rounds 22-50 |
| Fridge and Bank set | All | V5.1 | Disabled | Sets full bank and fridge weapon |

## Permaperks

Permaperks have been more or less broken in versions before 5.6, some perks would not go away even tho the conditions for them to go away have been met. Version 5.6 introduces a fix to that, and also there is a special treatment to Metal Boards, as this perk was particulary difficult to work with, it's been made into separate gsc script, put that script alongside First Room Fix in your scripts folder. What it'll do, is it'll award metal boards and then end the game, in that case either fast restart, or just launch into the map again (no need to remove the script), and metal boards will work correctly. The script will always end the game after awarding metal boards, and it'll only award if one (or more) player don't have them.

Awarded permaperks:

| Perk | Map | Restriction |
| --- | --- | --- |
| Jug | All | Must be below round 15 |
| Revive | All | - |
| Deadshot | All | - |
| Tombstone | All | - |
| Metal Boards | All | Only with plugin (check in releases) |
| Flopper | Buried | - |
| Nube (RayGun) | Tranzit & Buried | Must be below round 10 |

Removed permaperks:

| Perk | Map | Reason |
| --- | --- | --- |
| Better Box | Tranzit & Die Rise | Perk actually decreases the chances of getting MK2 on those maps. |
| Nube (RayGun) | Die Rise | Could be kinda hard to get to 10 without Ray. If there is a demand, optional plugin will be made to reverse that |

## First Box

First Box module in this patch works differently than any first box you've encountered before. What happens, is even if you have that module enabled in your version of the patch (default versions in release comes with disabled for less butt hurt), the box will remain unaffected. A change in box have to specifically invoked using commands. To do so, simply put in game chat 
```
fb <gun>
```
or
```
/fb <gun>
```
and replace `<gun>` with any of the keys below. By game chat, i mean game chat, the one that's invoked by a key `t` (by default), not the console. It can however, be done via console too, simply insert following command
```
say fb <gun>
```
in the console.
Once those commands are used, a weapon in the box will be overridden by weapon selected via the command and it'll remain that way until box is hit round 11 is achieved. Round 11 will stop First Box module from working, so the weapons can no longer be overridden.
If First Box is used, a watermark will be generated on the screen, this ensures the first box usage cannot be hidden.

| Weapon | Key | Green Run | Nuketown | Die Rise | Mob | Buried | Origins |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Ballistic Knife | bk | v | v | v | x | v | x |
| Blundergat | blunder | x | x | x | v | x | x |
| EMP | emp | v | x | x | x | x | x |
| Monkeys | monk | v | v | v | x | v | v |
| Paralyzer | paralyzer | x | x | x | x | v | x |
| RayGun | mk1 | v | v | v | v | v | v |
| RayGun MK2 | mk2 | v | v | v | v | v | v |
| Sliquifier | sliq | x | x | v | x | x | x |
| Time Bomb | time | x | x | x | x | v | x |
| AK47 | ak47 | x | x | x | v | x | x |
| B23R | b23 | x | x | x | x | x | v |
| Chicom CQB | chic | v | v | v | x | x | v |
| Death Machine | dm | x | x | x | v | x | x |
| DSR50 | dsr | v | v | v | v | v | v |
| Executioner | exe | v | v | v | v | v | x |
| Fal | fal | v | v | v | v | v | v |
| Five-Seven | 57 | v | v | v | v | v | x |
| Five-Seven DW | 257 | v | v | v | v | v | v |
| Galil | galil | v | v | v | v | v | v |
| HAMR | hamr | v | v | v | x | v | v |
| KAP-40 | kap | v | v | v | v | v | v |
| KSG | ksg | x | x | x | x | x | v |
| LSAT | lsat | x | v | x | v | x | x |
| M1216 | m1216 | v | v | v | x | v | v |
| M1927 | tommy | x | x | x | v | x | x |
| M27 | m27 | x | v | x | x | x | x |
| M82A1 Barret | barret | v | v | v | v | v | x |
| M8A1 | m8 | v | v | v | x | x | x |
| MG08 | mg | x | x | x | x | x | v |
| MP40 | mp40 | x | x | x | x | x | v |
| MTAR | mtar | v | v | v | v | v | x |
| PDW57 | pdw | x | x | x | v | x | v |
| Python | pyt | v | v | v | x | x | v |
| RNMA | rnma | x | x | x | x | v | x |
| RPD | rpd | v | v | v | x | x | x |
| RPG | rpg | v | v | v | v | v | x |
| Saiga | s12 | v | v | v | v | v | x |
| Scar | scar | x | x | x | x | x | v |
| Skorpion EVO | evo | x | x | x | x | x | v |
| Type 25 | type | v | v | v | x | x | v |
| War Machine | wm | v | v | v | x | v | v |

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
| Permaperks Tracker | x | x | x |

# Tech
- All versions below 5.4 were Compiled using irony.dll
- 5.4 onwards normal version is compiled using xensiks [gsc-tool](https://github.com/xensik/gsc-tool)

# Thanks to
- [JezuzLizard](https://github.com/JezuzLizard)
- [5and5](https://github.com/5and5)
- [Txchno](https://github.com/mbahgatTech)