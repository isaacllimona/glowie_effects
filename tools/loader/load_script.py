from pathlib import Path
import argparse

from glowie import Glowie, find_glowie

glowie_lib_path = (Path(__file__).parent / "../../scripts").resolve()
if not glowie_lib_path.exists():
    print("Could not find glowie efect library")

def main():
    args = parse_args()

    if args.script_path is not None:
        script_path = Path(args.script_path)
        if not script_path.is_file():
            print(f"file {args.script_path} does not exist")
            return
    else:
        script_path = None

    scripts_dir = Path(args.directory).resolve()
    if not scripts_dir.is_dir():
        print(f"directory {args.directory} does not exist")
        return

    print("Looking for glowies...")

    glowie = find_glowie()
    if glowie is None:
        print("No glowies found :(")
        return

    with glowie:
        print("Found a glowie! Loading effect library...")
        load_script(glowie_lib_path / "lib/effect_engine.lua", glowie)

        if script_path is not None:
            print("Loading script...")
            load_script(script_path, glowie)
            _ = input("Script loaded. Press Enter to stop")
            stop_script(glowie)
        else:
            run_interactive(glowie, scripts_dir)

def parse_args():
    parser = argparse.ArgumentParser("glowie script loader")

    parser.add_argument("script_path", nargs='?',
        help="path to the script to be loaded")
    parser.add_argument("-d", "--directory",
        default=glowie_lib_path)

    args = parser.parse_args()
    return args

def run_interactive(glowie: Glowie, scripts_dir: Path):
    print("Enter the path to a lua script to load it to the glowie")
    print("Type \"exit\" to exit")

    while True:
        input_str = input(f" > {scripts_dir}$ ")

        if input_str.strip() == "exit":
            stop_script(glowie)
            break

        if input_str.strip() == "stop":
            stop_script(glowie)
            continue

        script_path = scripts_dir / input_str
        if not script_path.is_file():
            print(f"{input_str} is not a file")
            continue

        load_script(script_path, glowie)
        print("Script loaded. Enter a new path or type \"stop\" to stop the running script")

def load_script(script_path: Path, glowie: Glowie):
    script = script_path.read_text()
    glowie.send_script(script)

def stop_script(glowie: Glowie):
    glowie.send_script("led.setColor(0,0,0) stop()")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
