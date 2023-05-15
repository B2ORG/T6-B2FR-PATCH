Ready to use patches can be found in [releases](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/releases) section.

Development thread on my Discord https://discord.gg/fDY4VR6rNE

This doc will be updated when i know what else needs clarification

# Categories

This patch is meant to be used during First Room games. Below you can see alternatives for other categories

| Category| Patch | Creator | Link |
| --- | --- | --- | --- |
| Highrounds / Round Speedruns | B2OP | Zi0 | [GitHub](https://github.com/Zi0MIX/T6-B2OP-PATCH) |
| EE Speedrun | Easter Egg GSC Timer | HuthTV | [GitHub](https://github.com/HuthTV/BO2-Easter-Egg-GSC-timer) |
| Song Speedruns | Song Auto-Timer | Zi0 | [GitHub](https://github.com/Zi0MIX/T6-SONG-TIMER-PATCH) |

# Launchers

First Room Fix is mainly meant for modern Plutonium versions, as most of the actual fixes are required for those.

## Modern (R2905 & R3000+)

Download the main script from [releases](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/releases) section, and put it Plutonium script folder

```C:\Users\{your username}\AppData\Local\Plutonium\storage\t6\scripts\zm```

## Ancient (r353 and similar) and Redacted Nightly

Download the `_clientids.gsc` script from [releases](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/releases) section, and inject it to the game [Video tutorial](https://youtu.be/Qhmful3ZVkE). This script is preprocessed, as there is one particular compatibility issue between main version of the patch and version for Ancient.

## Redacted LAN

Download the raw [.gsc file](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/blob/main/first_room_fix_v6.gsc) containing the code (make sure it's downloaded from `main` branch), and insert it in Redacted scripts folder

```{path to your redacted}\data\scripts```

# Versions

In the past it's been tricky to determine which release of which version was legit to play after some time (due to dynamic period of discoveries that rendered some of the versions unlegit for certain types of games, for instance a set of versions was not legit for coop, but was perfectly fine for solo). Head to [this](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/blob/main/LEGIT.MD) document, where all of those things are explained, and if anything new pops up, it'll also be added there.

With version 6, it becomes easier, even tho there are 3 separate files for 3 launchers, all of those files contain the exact same code (almost, head to [preprocessing](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/blob/main/README.MD#preprocessing) section for details). Besides that, it is exactly the same code for each of the 3 options, main patch is compiled with new compiler, Ancient Pluto version is compiled with old compiler, and for Redacted you just use uncompiled code.

# First Room Fix changes:

List of changes in First Room Fix V6. Detailed information about each of the features can be found further down the file (if it is required)

## Fixes

- Backspeed & Strafespeed scale
- Host migration (Pluto)
- Target Assist (Pluto)
- Prepatch Recoil (Pluto)
- Network Frame (Pluto)
- Custom Games

## HUD

- Game timer
- Round timer
- Velocity meter
- Splits
- Round size (hordes)
- Semtex prenades

## Features

- Nuketown Mannequins
- Nuketown eyes & announcer
- Red dot reticle (Pluto)
- Anticheat
- Info prints (Pluto)
- First Box module
- Permaperks module
- Bank balance
- Fridge

# First Box module

First Box module, aside from being able to make players obtain certain weapons from the box, is also making sure that use of First Box (even if it's source is another patch) does not go unnoticed. If tempering with box is detected, a red watermark is generated on player screen.

## First Box functionality

This part can be disabled entirely, and in fact is disabled by default. To obtain version with this enabled, you need to [request customized patch](https://github.com/Zi0MIX/T6-FIRST-ROOM-FIX/blob/main/README.MD#customized-patch).

Once you have patch with this functionality enabled, that doesn't mean you always play with first box. Until it's explicitely invoked, it'll leave your box alone. Here is how to do it:

### New Plutonium

Send following message in the game chat (by default press `t` on your keyboard)

```fb <key>```

### Ancient Plutonium & Redacted

Set following dvar in the game console (by default press `~` on your keyboard)

```fb <key>```

Where key would be the representation of the weapon you want to obtain from the box. Now at this point, the game is considered as played with First Box. Next weapon that'll come out of the box will be the one that's been specified. Any player can specify a weapon, and whoever hits the box, will get said weapon. This does not prevent teddybears from appearing.

First Box is automatically disabled at the end of round 10. Setting box weapon can no longer be triggered, and if there is a weapon set currently, it'll be cancelled.

## First Box weapon keys

Use following keys for setting box weapon. Passing actual weapon code will also work.

| Weapon | Key |
| --- | --- |
| Ballistic Knife | bk |
| Blundergat | blunder |
| EMP | emp |
| Monkeys | monk |
| Paralyzer | paralyzer |
| RayGun | mk1 |
| RayGun MK2 | mk2 |
| Sliquifier | sliq |
| Time Bomb | time |
| AK47 | ak47 |
| B23R | b23re |
| Chicom CQB | chic |
| Death Machine | dm |
| DSR50 | dsr |
| Executioner | exe |
| Fal | fal |
| Five-Seven | 57 |
| Five-Seven DW | 257 |
| Galil | galil |
| HAMR | hamr |
| KAP-40 | kap |
| KSG | ksg |
| LSAT | lsat |
| M1216 | m1216 |
| M1927 | tommy |
| M27 | m27 |
| M82A1 Barret | barret |
| M8A1 | m8 |
| MG08 | mg |
| MP40 | mp40 |
| MTAR | mtar |
| PDW57 | pdw |
| Python | pyt |
| RNMA | rnma |
| RPD | rpd |
| RPG | rpg |
| Saiga | s12 |
| Scar | scar |
| Skorpion EVO | evo |
| Type 25 | type |
| War Machine | wm |

# Fridge

Fridge system works similarly to First Box. 

## Activation

Here is how to operate it:

### New Plutonium

Send either of the following messages in the game chat (by default press `t` on your keyboard)

```fridge all <key>```

```fridge <key>```

First of the commands can only be used by host player. It will set all players fridge weapon to gun specified in key. Second command can be used by anyone, and it sets that players weapon to what is specified in key.

### Ancient Plutonium & Redacted

Set following dvar in the game console (by default press `~` on your keyboard)

```fridge <key>```

In this case `fridge` sets that weapon for every player. It is because off host players cannot set dvars.

## Weapon keys

Keys only differ from First Box module by the fact that some of the weapons cannot be put in fridge, and also wall weapons are now available.

Another change is that in order to put upgraded weapon in the fridge, player has to add a `+` sign in front of the key, so message to give all players upgraded mp5 would look like

``` fridge all +mp5```

| WEAPON | KEY |
| --- | --- |
| AK74u | ak74 |
| AN94 | an94
| B23R | b23r |
| Chicom CQB | chic |
| DSR50 | dsr |
| Executioner | exe |
| Fal | fal |
| Five-Seven | 57 |
| Five-Seven DW | 257 |
| Galil | galil |
| HAMR | hamr |
| KAP-40 | kap |
| LSAT | lsat |
| M1216 | m1216 |
| M14 | m14 |
| M82A1 Barret | barret |
| M8A1 | m8 |
| MP5 | mp5 |
| MTAR | mtar |
| Olympia | oly |
| PDW57 | pdw |
| Python | pyt |
| Remington 870 | remington |
| RNMA | rnma |
| RPD | rpd |
| RPG | rpg |
| Saiga | s12 |
| Scar | scar |
| SVU | svu |
| Type 25 | type |
| War Machine | wm |

# Permaperks

Permaperks system is present in the First Room Fix since version 4, and since then there were problems with it. Finally at the long last, i can say that they have been resolved (or at least i hope so).

Each player will be awarded permaperks he's missing from the predefined list of permaperks. If all the players in game have their permaperks, the process is skipped. Players will not be awarded any permaperks after they reconnect, furthermore, if game starts on round 20, they won't be given round restricted permaperks, such as jug. In case of games, where players connect to the game after it's initially started (such as Ancient Pluto when most of the time player connects at round 2), they need to obtain their permaperks before connecting to the coop game.

Upon awarding permaperks, a game will restart (or end if it's Ancient Pluto or Redacted, for compatibility reasons. Players then should load the game again and they're good to go).

## Permaperk tracker

There is also a separate feature (can be disabled while requesting a patch without disabling the rest of permaperk system), where patch will inform players when they lose or gain permaperks.

## Awarded permaperks:

| Perk | Map restriction | Round restriction |
| --- | --- | --- |
| Jug | - | Below round 15 |
| Revive | - | - |
| Deadshot | - | - |
| Tombstone | - | - |
| Metal Boards | - | - |
| Flopper | Only Buried | - |
| Nube (RayGun) | Only Tranzit & Buried | Below round 10 |

## Removed permaperks:

| Perk | Map | Reason |
| --- | --- | --- |
| Better Box | Tranzit & Die Rise | Perk actually decreases the chances of getting MK2 on those maps. |
| Nube (RayGun) | Die Rise | Could be kinda hard to get to 10 without Ray. If there is a demand, optional plugin will be made to reverse that |

# Customized patch

Let me know which of the optional features you want enabled while requesting the patch. If you like the default settings (table below), use version from releases.

Default settings of First Room Fix:

| FUNCTION | SETTING |
| --- | --- |
| Vanilla | Disabled |
| Timer | Constant |
| Round Timer | End of round |
| Horde count | Enabled |
| Semtex Prenades | Enabled |
| Origins Zombie Blood override | Enabled |
| Permaperk Award | Enabled |
| Permaperk Tracker | Enabled |
| Fridge weapon | Disabled |
| Nuketown Mannequinns | Disabled |
| Nuketown Blue Eyes | Disabled |
| First Box Module | Disabled |

# Preprocessing

Version for Ancient (path called `_clientids.gsc` in releases), has 2 function call replacements done on the level of compilation via Python script you can find in the repository. It does not change functionality at all, it's merely due to how different launchers handle certain errors differently.

# Thanks to
- [JezuzLizard](https://github.com/JezuzLizard)
- [5and5](https://github.com/5and5)
- [Txchno](https://github.com/mbahgatTech)