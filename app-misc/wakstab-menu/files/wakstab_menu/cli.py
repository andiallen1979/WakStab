import os
import re
import sys
import tempfile
from pathlib import Path

try:
    import portage
except ImportError:
    sys.exit("Error: Gentoo 'portage' Python module not found.")

import kconfiglib
import menuconfig


PACKAGE_USE_BASE = Path("/etc/portage/package.use")


def sanitize_symbol(raw: str) -> str:
    """Convert category/package + flag into a valid uppercase Kconfig symbol."""
    return re.sub(r"[^A-Za-z0-9_]", "_", raw).upper()


def collect_installed_useflags() -> list[dict]:
    """Read all installed packages from Portage vardb grouped by unversioned category/package."""
    vardb = portage.db[portage.root]["vartree"].dbapi
    cpvs = sorted(vardb.cpv_all())

    grouped: dict[str, dict[str, bool]] = {}
    for cpv in cpvs:
        cp = portage.cpv_getkey(cpv)
        iuse_raw, active_use_raw = vardb.aux_get(cpv, ["IUSE", "USE"])

        active_set = set(active_use_raw.split())
        flags = {
            f.lstrip("+-")
            for f in iuse_raw.split()
            if not f.lstrip("+-").startswith(
                ("abi_", "kernel_", "elibc_", "userland_", "video_cards_", "input_devices_")
            )
        }

        if not flags:
            continue

        pkg_flags = grouped.setdefault(cp, {})
        for flag in flags:
            is_enabled = flag in active_set
            pkg_flags[flag] = pkg_flags.get(flag, False) or is_enabled

    packages = []
    for cp in sorted(grouped):
        flag_entries = []
        for flag in sorted(grouped[cp]):
            sym_name = f"PKG_{sanitize_symbol(cp)}__{sanitize_symbol(flag)}"
            flag_entries.append(
                {
                    "flag": flag,
                    "enabled": grouped[cp][flag],
                    "sym": sym_name,
                }
            )

        packages.append(
            {
                "cp": cp,
                "flags": flag_entries,
            }
        )

    return packages


def generate_kconfig(packages: list[dict], kconfig_path: Path) -> None:
    """Write a Kconfig file grouping all installed packages and their USE flags."""
    lines = ['mainmenu "WakStab Portage USE Flag Manager"\n']

    for pkg in packages:
        lines.append(f'menu "{pkg["cp"]}"')
        for item in pkg["flags"]:
            default_val = "y" if item["enabled"] else "n"
            lines.append(f'config {item["sym"]}')
            lines.append(f'    bool "{item["flag"]}"')
            lines.append(f"    default {default_val}")
            lines.append("    help")
            lines.append(f'      Toggle USE flag "{item["flag"]}" for {pkg["cp"]}.')
            lines.append("")
        lines.append("endmenu\n")

    kconfig_path.write_text("\n".join(lines), encoding="utf-8")


def merge_setpkguse_file(target_file: Path, target_atom: str, new_toggles: dict[str, bool]) -> None:
    """Ensure target_file contains at most one consolidated entry for target_atom (cat/pkg)."""
    target_file.parent.mkdir(parents=True, exist_ok=True)

    comment_lines: list[str] = []
    flag_order: list[str] = []
    flag_states: dict[str, bool] = {}

    if target_file.is_file():
        for raw_line in target_file.read_text(encoding="utf-8").splitlines():
            stripped = raw_line.strip()
            if not stripped:
                continue
            if stripped.startswith("#"):
                comment_lines.append(raw_line)
                continue

            tokens = stripped.split()
            for tok in tokens[1:]:
                is_enabled = not tok.startswith("-")
                base_flag = tok[1:] if not is_enabled else tok
                if base_flag not in flag_states:
                    flag_order.append(base_flag)
                flag_states[base_flag] = is_enabled

    for base_flag in sorted(new_toggles):
        if base_flag not in flag_states:
            flag_order.append(base_flag)
        flag_states[base_flag] = new_toggles[base_flag]

    output_lines: list[str] = list(comment_lines)
    if flag_order:
        merged_tokens = [
            f"{'' if flag_states[f] else '-'}{f}" for f in flag_order
        ]
        output_lines.append(f"{target_atom} {' '.join(merged_tokens)}")

    if output_lines:
        target_file.write_text("\n".join(output_lines) + "\n", encoding="utf-8")
    elif target_file.is_file():
        target_file.unlink()


def write_package_use_changes(packages: list[dict], kconf: kconfiglib.Kconfig) -> None:
    """Save USE flag updates with strictly one unversioned entry per package.use file."""
    changes: dict[str, dict[str, bool]] = {}

    for pkg in packages:
        cp = pkg["cp"]
        for item in pkg["flags"]:
            sym = kconf.syms.get(item["sym"])
            if sym is None:
                continue
            new_enabled = sym.str_value == "y"
            if new_enabled != item["enabled"]:
                changes.setdefault(cp, {})[item["flag"]] = new_enabled

    if not changes:
        print("\nNo USE flag changes made.")
        return

    if os.geteuid() != 0:
        base_dir = Path.cwd() / "package.use"
        print(f"\nNot running as root; writing setpkguse structure to {base_dir}/")
    else:
        base_dir = PACKAGE_USE_BASE

    print("\nUpdated Portage USE configuration:")
    for cp in sorted(changes):
        cat_name, pkg_name = cp.split("/", 1)
        target_file = base_dir / cat_name / pkg_name

        merge_setpkguse_file(target_file, cp, changes[cp])
        flags_preview = " ".join(
            f"{'' if changes[cp][f] else '-'}{f}" for f in sorted(changes[cp])
        )
        print(f"  [{target_file}] -> {cp} {flags_preview}")

    print("\nRun 'emerge -auDN @world' to rebuild affected packages.")


def main() -> None:
    print("Scanning installed packages in /var/db/pkg...")
    packages = collect_installed_useflags()
    if not packages:
        sys.exit("No installed packages with configurable USE flags found.")

    with tempfile.TemporaryDirectory(prefix="wakstab-menu-") as tmpdir:
        tmp_path = Path(tmpdir)
        kconfig_file = tmp_path / "Kconfig"
        config_file = tmp_path / ".config"

        generate_kconfig(packages, kconfig_file)
        os.environ["KCONFIG_CONFIG"] = str(config_file)

        kconf = kconfiglib.Kconfig(str(kconfig_file))
        menuconfig.menuconfig(kconf)

        if config_file.is_file():
            kconf.load_config(str(config_file))
            write_package_use_changes(packages, kconf)
        else:
            print("\nExited without saving changes.")


if __name__ == "__main__":
    main()
