from traceback import print_exc
import subprocess
import sys
import os
import os.path
import re


def preprocessor(cwd: str) -> None:
    filepath = os.path.join(cwd, "first_room_fix_v6_copy.gsc")
    with open(filepath, "r", encoding="utf-8") as gsc_io:
        gsc_content = gsc_io.readlines()

    patterns = {
        "print": {
            "pattern": re.compile(r"\sprint\("),
            "replacing": "print(",
            "replacement": "stub(",
        },
        "main": {
            "pattern": re.compile(r"^main\(\)\s[^}]*}\s", re.MULTILINE),
            "replacing": None,
            "replacement": "",
        }
    }

    new_gsc = "".join(gsc_content)

    for pattern_data in patterns.values():
        while (match_obj := re.search(pattern_data["pattern"], new_gsc)) is not None:
            gsc_before = new_gsc[:match_obj.start()]
            gsc_after = new_gsc[match_obj.end():]
            gsc_remainer = new_gsc[match_obj.start():match_obj.end()]

            gsc_remainer = gsc_remainer.replace(pattern_data["replacing"], pattern_data["replacement"]) if pattern_data["replacing"] is not None else pattern_data["replacement"]

            new_gsc = f"{gsc_before}{gsc_remainer}{gsc_after}"
            print(f"new_fragment={gsc_remainer} matched={match_obj}")

    with open(filepath, "w", encoding="utf-8") as gsc_io:
        gsc_io.write(new_gsc)


def wrap_subprocess_call(*calls: str, **sbp_args) -> subprocess.CompletedProcess:
    call = " ".join(calls)
    try:
        print(f"Call: {call}")
        process = subprocess.run(call, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=5, **sbp_args)
    except Exception:
        print_exc()
        sys.exit()
    else:
        print(process.stdout.decode())


def main(cfg) -> None:
    """CFG:\n
    -s: skip main part\n
    -p: compile player scripts\n
    -x: compile plugin scripts\n
    -k: keep copied file\n
    -r: keep raw filename of frfix"""

    cwd = os.path.dirname(os.path.abspath(__file__))
    compiled_dir = os.path.join(cwd, "compiled", "t6")
    # cmd = os.path.join("C:\\", "Windows", "System32", "cmd.exe")

    if "-s" not in cfg:
        # Compile main script
        wrap_subprocess_call("gsc-tool.exe", "comp", "t6", "first_room_fix_v6.gsc")
        # Copy main script
        wrap_subprocess_call("COPY", "/y", f"\"{os.path.join(cwd, 'first_room_fix_v6.gsc')}\"", f"\"{os.path.join(cwd, 'first_room_fix_v6_copy.gsc')}\"", shell=True)
        # Preprocess the GSC content
        try:
            preprocessor(cwd)
        except Exception:
            print_exc()
            sys.exit()
        # Compile copy
        wrap_subprocess_call("Compiler.exe", "first_room_fix_v6_copy.gsc")
        # Move compiled copy to the same folder as main
        wrap_subprocess_call("MOVE", "/y", f"\"{os.path.join(cwd, 'first_room_fix_v6_copy-compiled.gsc')}\"", f"\"{os.path.join(cwd, 'compiled', 't6', '_clientids.gsc')}\"", shell=True)
        # Delete uncompiled copy
        if "-k" not in cfg:
            wrap_subprocess_call("DEL", f"\"{os.path.join(cwd, 'first_room_fix_v6_copy.gsc')}\"", shell=True)
        if "-r" not in cfg:
            wrap_subprocess_call("DEL", f"\"{os.path.join(compiled_dir, 'First-Room-Fix-V6.gsc')}\"", shell=True)
            wrap_subprocess_call("REN", f"\"{os.path.join(compiled_dir, 'first_room_fix_v6.gsc')}\"", f"\"First-Room-Fix-V6.gsc\"", shell=True)

    if "-p" in cfg:
        # Compile players scripts
        players = ["plant", "shadez", "tek", "tonestone", "vistek", "yojurt", "magafeezz", "zi0", "maarten"]
        for player in players:
            wrap_subprocess_call("gsc-tool.exe", "comp", "t6", f"\"Player Raws\\{player}.gsc\"")

    if "-x" in cfg:
        # Compile plugins scripts
        plugins = ["fridge", "hud", "permaperks", "test", "zones"]
        for plugin in plugins:
            # Possibility of having to add some players to 'print' removing workflow if they want to use ancient
            wrap_subprocess_call("gsc-tool.exe", "comp", "t6", f"\"Plugins\\frfix_plugin_{plugin}.gsc\"")


if __name__ == "__main__":
    main(sys.argv)
