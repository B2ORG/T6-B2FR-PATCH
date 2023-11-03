from traceback import print_exc
import subprocess
import sys
import os


# Config
CWD = os.path.dirname(os.path.abspath(__file__))
B2FR = "b2fr.gsc"
B2FR_COMPILED = "b2fr-compiled.gsc"
B2FR_PARSED_NOHUD = "b2fr_nohud.gsc" 
B2FR_PARSED_HUD = "b2fr_hud.gsc"
GAME_PARSE = "iw5"      # Change later once it's actually implemented for t6
GAME_COMP = "t6"
MODE_PARSE = "parse"
MODE_COMP = "comp"
COMPILER_XENSIK = "gsc-tool.exe"
COMPILER_XENSIK_11 = "gsc-tool-1.1.exe"
PARSED_DIR = os.path.join("parsed", GAME_PARSE)
COMPILED_DIR = os.path.join("compiled", GAME_COMP)
PLUGIN_DIR = "plugin_templates"
REPLACE_DEFAULT = {
    "#define NOHUD 1": "#define NOHUD 0",
}


def edit_in_place(path: str, **replace_pairs) -> None:
    with open(path, "r", encoding="utf-8") as gsc_io:
        gsc_content = gsc_io.read()

    for old, new in replace_pairs.items():
        if old in gsc_content:
            print(f"Replacing '{old}' with '{new}'")
            gsc_content = gsc_content.replace(old, new)

    with open(path, "w", encoding="utf-8") as gsc_io:
        gsc_io.write(gsc_content)


def wrap_subprocess_call(*calls: str, timeout: int = 5, **sbp_args) -> subprocess.CompletedProcess:
    call = " ".join(calls)
    try:
        print(f"Call: {call}")
        process = subprocess.run(call, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout, **sbp_args)
    except Exception:
        print_exc()
        sys.exit()
    else:
        print(process.stdout.decode())


def arg_path(*paths: str) -> str:
    return f'"{os.path.join(*paths)}"'


def file_rename(old: str, new: str) -> None:
    if os.path.isfile(new):
        os.remove(new)
    os.rename(old, new)


def main(cfg: list) -> None:
    # NOHUD
    redacted_update = dict(REPLACE_DEFAULT)
    redacted_update.update({"#define NOHUD 0": "#define NOHUD 1"})
    edit_in_place(os.path.join(CWD, B2FR), **redacted_update)
    wrap_subprocess_call(COMPILER_XENSIK, MODE_PARSE, GAME_PARSE, "pc", B2FR)
    wrap_subprocess_call(COMPILER_XENSIK, MODE_COMP, GAME_COMP, "pc", arg_path(CWD, PARSED_DIR, B2FR))
    file_rename(os.path.join(CWD, PARSED_DIR, B2FR), os.path.join(CWD, PARSED_DIR, B2FR_PARSED_NOHUD))
    file_rename(os.path.join(CWD, COMPILED_DIR, B2FR), os.path.join(CWD, COMPILED_DIR, B2FR_PARSED_NOHUD))

    # HUD
    pluto_update = dict(REPLACE_DEFAULT)
    edit_in_place(os.path.join(CWD, B2FR), **pluto_update)
    wrap_subprocess_call(COMPILER_XENSIK, MODE_PARSE, GAME_PARSE, "pc", B2FR)
    wrap_subprocess_call(COMPILER_XENSIK, MODE_COMP, GAME_COMP, "pc", arg_path(CWD, PARSED_DIR, B2FR))
    file_rename(os.path.join(CWD, PARSED_DIR, B2FR), os.path.join(CWD, PARSED_DIR, B2FR_PARSED_HUD))
    file_rename(os.path.join(CWD, COMPILED_DIR, B2FR), os.path.join(CWD, COMPILED_DIR, B2FR_PARSED_HUD))


if __name__ == "__main__":
    main(sys.argv)
