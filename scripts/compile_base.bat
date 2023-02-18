@REM V5 for new pluto
@REM gsc-tool.exe comp t6 first_room_fix_v5.gsc

@REM V5 for Redacted / Ancient
@REM Compiler.exe first_room_fix_v5_redacted.gsc
@REM copy /y "first_room_fix_v5_redacted-compiled.gsc" "compiled\t6"
@REM DEL "first_room_fix_v5_redacted-compiled.gsc"

@REM V6 for New Pluto
gsc-tool.exe comp t6 "first_room_fix_v6.gsc"
@REM V6 for Redacted / Ancient
Compiler.exe "first_room_fix_v6.gsc"
copy /y "first_room_fix_v6-compiled.gsc" "compiled\t6\first_room_fix_v6_redacted.gsc"
DEL "first_room_fix_v6-compiled.gsc"

pause