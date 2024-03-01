# T6-B2FR-PATCH

Patch for playing world record games in Black Ops II Zombies for First Room games. It is fully tuned to ensure integrity of every type of First Room games accordingly to most recent ruleset (including vote from April 2023). This patch has previously been known as First Room Fix.

# Info

Please inform me about any issues you may encounter with the patch, so they can be fixed, preferably with decent amount of information in what circumstances an issue occured. The main channel for issues is GitHubs Issues section, although it won't hurt to ask about it on [Discord](https://discord.gg/fDY4VR6rNE) first

Before reporting a problem, please check out the FAQ section down below, you may find answers you're looking for there

# Categories

This patch is meant to be used during First Room games. Below you can see alternatives for other categories

| Category| Patch | Creator | Link |
| --- | --- | --- | --- |
| Highrounds / Round speedruns | B2OP | Zi0 & Astrox | [GitHub](https://github.com/B2ORG/T6-B2OP-PATCH) |
| EE Speedrun | Easter Egg GSC Timer | HuthTV | [GitHub](https://github.com/HuthTV/BO2-Easter-Egg-GSC-timer) |
| Song Speedruns | B2SONG | Zi0 | [GitHub](https://github.com/B2ORG/T6-B2SONG-PATCH) |

# Installation

Since version B2FR v1, the patch is only available for modern versions of Plutonium. Recommended version to play games on is Plutonium R2905 [installation guide](https://youtu.be/_8QjvejOuqU?t=176), but it will fully work with versions R3000+ (at least as of writing this readme, Plutonium has a record of breaking random stuff all the time). Download most recent version of your choice from [releases](https://github.com/B2ORG/T6-B2FR-PATCH/releases) section. DOWNLOADING RAW CODE FILES YOU SEE ON THIS PAGE WILL NOT WORK!

Put script you downloaded in Plutonium directory (unless you changed it it'll be)

```
%LOCALAPPDATA%\Plutonium\storage\t6\scripts\zm
```

Run this in a run window (press CTRL + R), that'll open the Plutonium scripts folder. If your plutonium folder is called differently (for example `Plutonium R2905` instead of `Plutonium`, adjust the path)

# FAQ

1) My game is restarting automatically, how do i fix it?

- You don't, that's intended behavior of the system that's giving you permaperks to prevent a rare bug where permaperks were not taken away from players sometimes. How it works is you load into the game, each player is scanned for missing permaperks, if anyone is missing something, they're awarded missing permaperks, and then the game will force a restart. After the restart you are free to carry on. Do note, most of the time you are going to lose some of the perks almost instantly, so restarts few minutes in will require the process to repeat.

2) I put the patch in the right folder but it does not work

- Make sure you downloaded compiled version from [releases](https://github.com/B2ORG/T6-B2FR-PATCH/releases) section (DO NOT download the zip file called Source code, it is added to the release automatically by github and contains raw code, that is not going to work).

3) Is there anything i need to worry about regarding legitimacy of my game while using this patch?

- Do not use this patch for categories it's not meant for. I've linked alternatives to other categories in a table above in [Categories](#categories) section. There isn't anything in this patch that is strictly forbidden for let's say a highround, however certain features may not be optimal or seen as grey area stuff by other communities.
- Always familiarize yourself with rules for a particular room / sub-category, this patch will not do all the work for you.

4) I heard this patch may cause early errors

- Technically any external script you load into your game will cause extra overhead, but B2FR is stable enough for playing out a game. If you notice any issue regarding stability, please let me know. I'm just a human, mistakes can always be made

5) Why support for other launchers has been dropped

- Because it is not needed. If you are playing solo offline games, you should be using Redacted Nightly or Ancient Plutonium without any patches, if you are playing coop or online maps (solo with permaperks), R2905 is the best version to play on

# Steps for basic troubleshooting

- Make sure you're using correct and up to date version and that the downloaded file is compiled (open in Notepad, if it's bunch of gibbrish, you know it's compiled)
- Remove other patches. B2 Extensions should not cause any issues, but if you are using any, for the sake of troubleshooting remove them as well.
- Check if the directory the patch is in is correct. Perhaps you have multiple instances of Plutonium or Redacted and you put it in the directory belonging to another instance.

# Features

Features in B2FR patch

## Core features

- Basic anticheat capabilities (DVARs, Box etc.)
- Fixed network frame (you may know it as a Tickrate issue)
- Reset backspeed values to the level of a Steam version (consistently with First Room ruleset)
- Fixed traps & JetGun (disabled for maps that don't need it)
- Automatic permaperks assignment (consistent with in-game logic)
- Automatic permaperks removal (if obtained illegaly, for instance during breaks)
- Full bank
- Removed Depth of Field

## HUD

- HUD elements scale accordingly to aspect ratio (solo only, because it's dependent on the ratio of hosts game, cannot be changed for clients separately via gsc patch)
- Timer & Round timer
- Shows times for key splits (round 20, 30 etc)
- Velocity meter (toogleable with `velocity_meter` dvar, set to 1 or 0 respectively)
- Horde count is printed out at the beginning of each round past 20 (works like zombacus, not a live zombie counter)
- Permaperks tracker (info when and what was gained / lost)

## Semtex

- Prenades are printed out each round

## Farm

- Built in support for Top Barn challenge (integrity checks for rules and if players remain within the right area)

## Nuketown

- Built it support for Yellow House challenge (integirity checks for rules and if players remain within the right area)
- Mannequin next to the yellow bus is automatically removed
- Players are warned if Jugg is going to be in the first room

## Origins

- Set reticle to always be default
- Game is always in custom game mode (zombie blood from reward box)

# Permaperks

Patch does award players with permaperks on connect, but only at the beginning of the game. Players joining in progress will not be given any permaperks. Every player joining the game past round 15 will have PermaJug taken away from him.
List of permaperks awarded by B2OP

| Perk | Notes |
| --- | --- |
| Revive | - |
| Better Headshots | - |
| Tombstone | - |
| Mini-Jug | Will not be awarded if game starts past round 15, will also actively be taken from players past round 15 |
| Flopper | Only on Buried |
| Nube | Only on Buried. Will be actively taken away on Tranzit & Die Rise and also will be removed past round 10 on Buried |

Map will always restart itself after permaperks are awarded. Do not restart manually if permaperks are being awarded (as the system for permaperks may break).

# Contributions

If you'd like to contribute to the code, please fork this repository, apply changes / fixes and open a pull request. If the change is in line with rules and the purpose of this patch, it'll be merged and a new version of the patch will be released.

Following things are required:

- [Python](https://www.python.org/downloads/windows/) 3.10 or newer (recommended 3.12)
- [gsc-tool](https://github.com/xensik/gsc-tool/releases) 1.4 or newer (currently i recommend using 1.4.1)

Install Python (and make sure to check adding it to the system PATH while doing so). Download gsc-tool, do not change the name of the program, put it in the main directory of the project.

After applying desired changes, run script `compile.py` while in the patch main directory (press on address bar in the folder view, put `cmd` and press enter. A command line will open with that folder already set). Run script by putting in `python compile.py`. If you did everything right, script should compile everything for you and put stuff in right folders.

Please note, as the modding scene for BO2 is still very young, stuff and tech is changing rapidly. Above description may not always be up to date, but i will try to not let that happen too often.

# B2 Extensions

THIS IS FOR ADVANCED USERS ONLY. The patch has few handles for external GSC scripts than can be used to modify certain behaviours in a controlled environment. Examples of such modification can be found in the [B2 Extensions repository](https://github.com/B2ORG/T6-B2EXTENSIONS) alongside further instructions

# Legacy info

Since some people just don't like updating, I'm leaving this legacy info regarding current state of legitimacy of old versions

## Network Frame

I will not be going deep into how and why Network Frame drama even came to be. But regarding First Room Fix, initial version of the fix has been implemented in Version 4, and remained unchaged until Version 5.2

That initial version of the fix was incorrect.

| VERSION | LEGIT - SOLO | LEGIT - COOP |
| --- | :---: | :---: |
| V3 & NO PATCH | NO | YES |
| V4 & V5.0 & V5.1 | YES | NO |
| V5.2+ | YES | YES |

## Permaperks

There was a flaw somewhere in the permaperk logic, that was causing the system to malfunction under certain conditions, if the perks are artificially awarded in the same game.

There's been few versions of the system, but up until version 6, the system was more or less malfunctioning

| VERSION | RISK - SOLO | RISK - COOP |
| --- | :---: | :---: |
| V4 | HIGH | HIGH |
| V5.0 - V5.5 | HIGH | HIGH |
| V5.6 | LOW | HIGH |
| V5.7 | ZERO (system disabled) | ZERO (system disabled) |
| V6 | VERY LOW | VERY LOW |
