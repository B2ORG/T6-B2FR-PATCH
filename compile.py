from traceback import print_exc
from copy import copy, deepcopy
import subprocess, sys, os, zipfile, re, binascii, shutil


# Config
CWD = os.path.dirname(os.path.abspath(__file__))
B2FR = "b2fr.gsc"
B2FR_PARSED_NOHUD = "b2fr_nohud.gsc" 
B2FR_PARSED_HUD = "b2fr_hud.gsc"
GAME_PARSE = "iw5"                  # Change later once it's actually implemented for t6
GAME_COMP = "t6"
MODE_PARSE = "parse"
MODE_COMP = "comp"
COMPILER_GSCTOOL = "gsc-tool.exe"
PARSED_DIR = "parsed/" + GAME_PARSE
COMPILED_DIR = "compiled/" + GAME_COMP
FORCE_SPACES = True
REPLACE_DEFAULT: dict[str, str] = {}
BAD_COMPILER_VERSIONS: set["Version"] = set()
STRICT_FILE_RM_CHECK = int(os.environ.get("B2_STRICT_CHECK", True))


class Version:
    UNKNOWN = [-1, -1, -1]
    """Signature of an unknown version"""


    def __init__(self) -> None:
        self._version: list[int]


    def __eq__(self, __object) -> bool:
        return self._version == __object._version


    def __ne__(self, __object) -> bool:
        return self._version != __object._version


    def __lt__(self, __object) -> bool:
        if self._version[0] < __object._version[0]:
            return True
        if self._version[0] <= __object._version[0] and self._version[1] < __object._version[1]:
            return True
        if self._version[0] <= __object._version[0] and self._version[1] <= __object._version[1] and self._version[2] < __object._version[2]:
            return True
        return False


    def __gt__(self, __object) -> bool:
        if self._version[0] > __object._version[0]:
            return True
        if self._version[0] >= __object._version[0] and self._version[1] > __object._version[1]:
            return True
        if self._version[0] >= __object._version[0] and self._version[1] >= __object._version[1] and self._version[2] > __object._version[2]:
            return True
        return False


    def __le__(self, __object) -> bool:
        return self == __object or self < __object


    def __ge__(self, __object) -> bool:
        return self == __object or self > __object


    def __str__(self) -> str:
        return ".".join([str(v) for v in self._version])


    def __hash__(self) -> int:
        return hash(f"{self._version[0]}|{self._version[1]}|{self._version[2]}")


    @staticmethod
    def parse(_version: str):
        version = Version()
        version._version = [int(v) for v in _version.split(".")]
        version.trim()
        return version


    def trim(self):
        if len(self._version) > 3:
            self._version = self._version[:3]
        return self


class UnknownVersion(Version):
    def __init__(self) -> None:
        super().__init__()
        self._version = self.UNKNOWN


class Chunk:
    def __init__(self, header: str | None = None) -> None:
        self.header = header


    def __enter__(self):
        if self.header is not None:
            print(self.header)
        print("-" * 100)


    def __exit__(self, *args):
        print("-" * 100, "\n")


class Gsc:
    REPLACEMENTS: dict[str, str] = {}
    def __init__(self, skip_changes: bool = False) -> None:
        self._code: str
        self._skip_changes: bool = skip_changes


    def load_file(self, path: str) -> "Gsc":
        with open(path, "r", encoding="utf-8") as gsc_io:
            self._code = gsc_io.read()
        return self


    def check_whitespace(self) -> "Gsc":
        tab: int = self._code.find("\t")
        if tab != -1:
            line: int = self._code.count("\n", 0, tab)
            print(f"TAB found in line {line + 1}. Make sure to use 4 spaces instead of a tab!")
            if FORCE_SPACES:
                sys.exit(1)
        return self


    def save(self, path: str, local_changes: dict[str, str]) -> "Gsc":
        changes: dict[str, str] = deepcopy(Gsc.REPLACEMENTS) | local_changes
        changed: str = copy(self._code)
        if not self._skip_changes:
            for old, new in changes.items():
                changed = changed.replace(old, new)
        with open(path, "w", encoding="utf-8") as gsc_io:
            gsc_io.write(changed)
        return self


def edit_in_place(path: str, **replace_pairs) -> None:
    with open(path, "r", encoding="utf-8") as gsc_io:
        gsc_content = gsc_io.read()

    for old, new in replace_pairs.items():
        if old in gsc_content:
            print(f"Replacing '{old}' with '{new}'")
            gsc_content = gsc_content.replace(old, new)

    with open(path, "w", encoding="utf-8") as gsc_io:
        gsc_io.write(gsc_content)


def wrap_subprocess_call(*calls: str, timeout: int = 5, cli_output: bool = True, **sbp_args) -> subprocess.CompletedProcess:
    call: str = " ".join(calls)
    try:
        print(f"Call: {call}")
        process: subprocess.CompletedProcess = subprocess.run(call, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, timeout=timeout, **sbp_args)
    except Exception:
        print_exc()
        sys.exit(1)
    else:
        print("Output:")
        print(process.stdout.strip() if cli_output else "suppressed")
        return process


def arg_path(*paths: str) -> str:
    return f'"{os.path.join(*paths)}"'


def file_rename(old: str, new: str) -> None:
    if os.path.isfile(new):
        os.remove(new)
    if os.path.isfile(old):
        if not os.path.isdir(os.path.dirname(new)):
            os.makedirs(os.path.dirname(new))
        os.rename(old, new)


def clear_files(dir: str, pattern: str) -> None:
    file_list: list[str] = os.listdir(dir)
    if STRICT_FILE_RM_CHECK or len(file_list) >= 16:
        input(f"You're about to remove {len(file_list)} files. Press ENTER to continue, or abord the program\n\t{"\n\t".join([os.path.basename(f) for f in file_list])}")

    for file in file_list:
        if re.match(pattern, file):
            path_to_file = os.path.join(dir, file)
            os.remove(path_to_file) if os.path.isfile(path_to_file) else shutil.rmtree(path_to_file)


def flash_hash(file_path: str) -> str:
    with open(file_path, "rb") as file_io:
        # Convert to uINT and represent as uppercase hex
        hash: str = format(binascii.crc32(file_io.read()) & 0xFFFFFFFF, "08X")
    print(f"Hash of {os.path.basename(file_path)}: '0x{hash}'")
    return hash


def create_zipfile(zip_target: str, file_to_zip: str, file_in_zip: str) -> None:
    try:
        with zipfile.ZipFile(zip_target, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zip:
            zip.write(file_to_zip, file_in_zip)
    except FileNotFoundError:
        print("WARNING! Failed to create zip file due to missing compiled file")


def verify_compiler() -> Version | bool:
    return verify_compiler_version() if os.path.isfile(os.path.join(CWD, COMPILER_GSCTOOL)) else False


def verify_compiler_version() -> Version:
    compiler: subprocess.CompletedProcess = wrap_subprocess_call(COMPILER_GSCTOOL, cli_output=False)
    lines: list[str] = compiler.stdout.split("\n")
    if not lines:
        print("Could not verify compiler version")
        return UnknownVersion()

    version: list[str] = re.compile(r"([\d.]+)").findall(lines[0])
    if len(version) != 1:
        print("Could not verify compiler version")
        return UnknownVersion()

    ver: Version = Version.parse(version[0])
    if ver < Version.parse("1.4.0") or ver in BAD_COMPILER_VERSIONS:
        input(f"WARNING! Potentially incompatibile version of the compiler ({str(ver)}) was found. Press ENTER to continue")
    return ver


def main() -> None:
    os.chdir(CWD)
    print(f"\nSet CWD to: {os.getcwd()}\n")

    # Util
    compiler: Version | bool = verify_compiler()
    if compiler is False:
        print(f"'{COMPILER_GSCTOOL}' compiler executable not found in '{CWD}'")
        sys.exit(1)
    print()

    # Clear up all previous files
    clear_files(os.path.join(CWD, PARSED_DIR), r".*")
    clear_files(os.path.join(CWD, COMPILED_DIR), r".*")

    gsc: Gsc = Gsc().load_file(os.path.join(CWD, B2FR)).check_whitespace()

    # HUD
    with Chunk("WITH HUD:"):
        gsc.save(
            os.path.join(CWD, B2FR), {"#define NOHUD 1": "#define NOHUD 0"}
        )
        wrap_subprocess_call(
            COMPILER_GSCTOOL, "-m", MODE_PARSE, "-g", GAME_PARSE, "-s", "pc", B2FR
        )
        wrap_subprocess_call(
            COMPILER_GSCTOOL, "-m", MODE_COMP, "-g", GAME_COMP, "-s", "pc", arg_path(CWD, PARSED_DIR, B2FR)
        )
        file_rename(
            os.path.join(CWD, PARSED_DIR, B2FR), os.path.join(CWD, PARSED_DIR, "b2fr_precompiled_hud.gsc")
        )
        file_rename(
            os.path.join(CWD, COMPILED_DIR, B2FR), os.path.join(CWD, COMPILED_DIR, "b2fr_hud.gsc")
        )

        flash_hash(os.path.join(CWD, COMPILED_DIR, "b2fr_hud.gsc"))

    # No HUD
    with Chunk("NO HUD:"):
        gsc.save(
            os.path.join(CWD, B2FR), {"#define NOHUD 0": "#define NOHUD 1"}
        )
        wrap_subprocess_call(
            COMPILER_GSCTOOL, "-m", MODE_PARSE, "-g", GAME_PARSE, "-s", "pc", B2FR
        )
        wrap_subprocess_call(
            COMPILER_GSCTOOL, "-m", MODE_COMP, "-g", GAME_COMP, "-s", "pc", arg_path(CWD, PARSED_DIR, B2FR)
        )
        file_rename(
            os.path.join(CWD, PARSED_DIR, B2FR), os.path.join(CWD, PARSED_DIR, "b2fr_precompiled_nohud.gsc")
        )
        file_rename(
            os.path.join(CWD, COMPILED_DIR, B2FR), os.path.join(CWD, COMPILED_DIR, "b2fr_nohud.gsc")
        )

        flash_hash(os.path.join(CWD, COMPILED_DIR, "b2fr_nohud.gsc"))

    # Reset file
    gsc.save(os.path.join(CWD, B2FR), {})


if __name__ == "__main__":
    main()
