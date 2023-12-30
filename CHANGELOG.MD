# B2FR 1.2

## Fixes

- Fixed velocity value if player is moving diagonally (thanks [JBleezy](https://github.com/Jbleezy))

# B2FR 1.1

## Fixes

- Fixed gameplay reminders
- Fixed rare possibility of the game failing to restart after awarding permaperks

## Changes

- Dvar sequence has been slightly delayed, which should reduce the emount of foreing scripts triggering the integrity checks
- Added back dvar rules from V6, including pre-patch recoil and aim assist
- Added text placeholder for round timer before round 1

# B2FR 1.0

This version marks moving from old First Room Fix codebase (again) to one built for [B2OP](https://github.com/B2ORG/T6-B2OP-PATCH), the two now have similar core functionality (adjusted for each respective category they're meant for). Only most important changes from First Room Fix V6 to B2FR V1 from player perspective are listed here, but under the hood almost all the code has been replaced.

## Fixes

- Fixed a bug where mannequins were not being removed from the map
- Fixed various issues with extensions
- Fixed bounds check in Nuketown Yellow House challenge controller
- Fixed hud timer to no longer cover BO2 native FPS counter (it is now the same as B2OP)
- Fixed hud elements positioning on aspect ratios other than 16:9

## Changes

- Changed extension handles so both B2OP and B2FR can use same extensions
- Removed powerup stats and moved that into a separate extension
- Removed the entire first box functionality (officially voted in 5th First Room vote). Only the check for foreign first box system remains in place
- Added bank refill upon connecting to the game
- Changed the compilation script
- Reintroduced split versions for HUD & NO HUD
- Dropped support for Redacted and Ancient Plutonium
- Added gameplay reminder for game host (it will also warn players at the beginning of the game that they'll have Juggernog on Nuketown, so everyone will need full gameplay, players can use this information to restart such game as well)
- RayGun permaperk (nube) is now actively removed on Tranzit and Die Rise (officially voted in 5th First Room vote)

# First Room Fix v6.0

## Fixes

- Fixed a bug where First Box module would not count box hits properly on Redacted
- Fixed rare issue where harmless config change could trigger noprint warning
- Changed most functions to optimize child variable allocation to fix potential child variable error
- Reworked permaperk system to fix problems with permaperk misbehavior
- Permaperks tracker will now work for players reconnecting to the game
- Fixed horde count tryint to display on leaper round
- Fixed mannequin remover leaving collision behind

## Changes

- Main patch can now be used with Redacted and Ancient Pluto (with slightly limited functionality)
- Pointdrop watching function now stops on round 50
- Implemented hooks for various plugins (hud properties, zones etc)
- Compilation scripts are now available in the repository
- Changed fridge system to work similar to first box (chat commands)
- Semtex prenades are now calculated up to the max round (via dynamically calculated values on higher rounds)
- Replaced some HUD elements with iprints (horde count, prenades, splits)
- Prenades and horde size can now be invoked at any point via chat message
- Box and Fridge systems now accept actual weapon codes in trigger chat messages
- Yellow House and Top Barn challenges are now supported and are triggering automatically if all of the conditions are met
