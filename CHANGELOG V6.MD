# Version 6.0

- Fixes
    * Fixed a bug where First Box module would not count box hits properly on Redacted
    * Fixed rare issue where harmless config change could trigger noprint warning
    * Changed most functions to optimize child variable allocation to fix potential child variable error
    * Reworked permaperk system to fix problems with permaperk misbehavior
    * Permaperks tracker will now work for players reconnecting to the game
    * Fixed horde count tryint to display on leaper round
    * Fixed mannequin remover leaving collision behind

- Changes
    * Main patch can now be used with Redacted and Ancient Pluto (with slightly limited functionality)
    * Pointdrop watching function now stops on round 50
    * Implemented hooks for various plugins (hud properties, zones etc)
    * Compilation scripts are now available in the repository
    * Changed fridge system to work similar to first box (chat commands)
    * Semtex prenades are now calculated up to the max round (via dynamically calculated values on higher rounds)
    * Replaced some HUD elements with iprints (horde count, prenades, splits)
    * Prenades and horde size can now be invoked at any point via chat message
    * Box and Fridge systems now accept actual weapon codes in trigger chat messages
    * Yellow House and Top Barn challenges are now supported and are triggering automatically if all of the conditions are met

# Version 6.1

- Fixes
    * Fixed a bug where mannequins were not being removed from the map
