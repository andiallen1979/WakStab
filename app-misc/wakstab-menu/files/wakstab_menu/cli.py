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

PORTAGE_DIR = Path("/etc/portage")
MAKE_CONF_PATH = PORTAGE_DIR / "make.conf"
PKG_USE_BASE = PORTAGE_DIR / "package.use"
PKG_KW_BASE = PORTAGE_DIR / "package.accept_keywords"
PKG_MASK_BASE = PORTAGE_DIR / "package.mask"
PKG_ENV_BASE = PORTAGE_DIR / "package.env"
ENV_PROFILES_DIR = PORTAGE_DIR / "env"

STD_ENV_VARS = ["CFLAGS", "CXXFLAGS", "LDFLAGS", "MAKEOPTS", "FEATURES", "CC", "CXX"]

ENV_PRESETS = [
    ("NOLTO", 'CFLAGS="${CFLAGS} -fno-lto"\nCXXFLAGS="${CXXFLAGS} -fno-lto"\nLDFLAGS="${LDFLAGS} -fno-lto"', "Disable LTO (-fno-lto)"),
    ("O2_SAFE", 'CFLAGS="-O2 -pipe"\nCXXFLAGS="-O2 -pipe"', "Safe -O2 -pipe flags"),
    ("JOBS_1", 'MAKEOPTS="-j1"', "Limit build to single job (MAKEOPTS=-j1)"),
    ("NO_SANDBOX", 'FEATURES="${FEATURES} -sandbox -usersandbox"', "Disable Portage sandbox"),
    ("NO_TEST", 'FEATURES="${FEATURES} -test"', "Disable test phase"),
]

COMMON_GLOBAL_USE = [
    "X", "alsa", "bluetooth", "cups", "dbus", "dist-kernel", "elogind",
    "ffmpeg", "flac", "git", "gles2", "grub", "gtk", "icu", "ipv6",
    "jpeg", "lto", "mp3", "mp4", "networkmanager", "nls", "opengl",
    "pam", "pgo", "pipewire", "png", "policykit", "pulseaudio", "qt5",
    "qt6", "screencast", "seccomp", "ssl", "svg", "systemd", "truetype",
    "udev", "udisks", "unicode", "usb", "vaapi", "vdpau", "vulkan",
    "wayland", "webp", "x264", "x265", "zstd",
]

COMMON_FEATURES = [
    ("buildpkg", "Build binary packages (.gpkg.tar / .tbz2)"),
    ("buildpkg-live", "Build binary packages for live (-9999) ebuilds"),
    ("getbinpkg", "Fetch binary packages from configured binhosts"),
    ("binpkg-request-signature", "Require valid GPG signatures on binpkgs"),
    ("ccache", "Enable compiler caching via dev-util/ccache"),
    ("distcc", "Enable distributed compilation via sys-devel/distcc"),
    ("parallel-fetch", "Download sources in parallel while compiling"),
    ("parallel-install", "Install merged packages in parallel"),
    ("clean-logs", "Remove build logs after successful merges"),
    ("splitdebug", "Split debug symbols into /usr/lib/debug"),
    ("nodoc", "Skip installing documentation files"),
    ("noinfo", "Skip installing GNU info pages"),
    ("noman", "Skip installing manual pages"),
    ("sandbox", "Enable Portage filesystem sandbox"),
    ("usersandbox", "Drop privileges inside sandbox"),
    ("userpriv", "Build packages as unprivileged portage user"),
    ("test", "Run package test suites"),
]

def sanitize_symbol(raw: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]", "_", raw).upper()

def extract_cp(atom_tok: str) -> str | None:
    clean, _, _ = re.sub(r"^[<>~=]+", "", atom_tok).partition("::")
    clean, _, _ = clean.partition(":")
    if "/" not in clean:
        return None
    try:
        return portage.dep_getkey(clean)
    except portage.exception.InvalidAtom:
        return portage.cpv_getkey(clean) or None

def read_make_conf_var(text: str, var_name: str) -> list[str]:
    pat = re.compile(rf'(?m)^\s*{re.escape(var_name)}\s*=\s*(["\'])(.*?)\1', re.DOTALL)
    out = []
    for m in pat.finditer(text):
        for tok in m.group(2).split():
            if tok not in (f"${{{var_name}}}", f"${var_name}"):
                out.append(tok)
    return out

def update_make_conf_var(text: str, var_name: str, tokens: list[str], self_ref: bool = False) -> str:
    prefix = f"${{{var_name}}} " if self_ref else ""
    line = f'{var_name}="{(prefix + " ".join(tokens)).strip()}"'
    pat = re.compile(rf'(?m)^\s*{re.escape(var_name)}\s*=\s*(["\'])(.*?)\1', re.DOTALL)
    matches = list(pat.finditer(text))
    if matches:
        res = text
        for m in reversed(matches[:-1]):
            res = res[:m.start()] + res[m.end():]
        last = list(pat.finditer(res))[-1]
        return res[:last.start()] + line + res[last.end():]
    sep = "" if (not text or text.endswith("\n")) else "\n"
    return f"{text}{sep}\n{line}\n"

def parse_env_vars(content: str) -> dict[str, str]:
    pat = re.compile(r'(?m)^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(["\'])(.*?)\2', re.DOTALL)
    return {m.group(1): m.group(3) for m in pat.finditer(content)}

def render_env_vars(var_map: dict[str, str]) -> str:
    lines = [f'{k}="{v}"' for k, v in var_map.items() if v.strip()]
    return "\n".join(lines) + ("\n" if lines else "")

def iter_cfg_lines(base_path: Path):
    if not base_path.exists():
        return
    files = [base_path] if base_path.is_file() else [p for p in sorted(base_path.rglob("*")) if p.is_file() and not p.name.startswith(".")]
    for f in files:
        for raw in f.read_text(encoding="utf-8", errors="ignore").splitlines():
            s = raw.strip()
            if s and not s.startswith("#"):
                yield s.split()

def collect_portage_state() -> dict:
    # Collects installed packages, USE flags, keywords, masking rules, environment profiles, and make.conf settings.
    ...
def generate_kconfig(state: dict, kpath: Path) -> None:
    # Generates a hierarchical Kconfig structure covering USE flags, keywords, masking, package environments, env profiles, and global make.conf settings.
    ...

def write_one(target: Path, line: str | None) -> None:
    comments = [r for r in target.read_text(encoding="utf-8").splitlines() if r.strip().startswith("#")] if target.is_file() else []
    if not line:
        if comments:
            target.write_text("\n".join(comments) + "\n", encoding="utf-8")
        elif target.is_file():
            target.unlink()
            try:
                target.parent.rmdir()
            except OSError:
                pass
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text("\n".join(comments + [line]) + "\n", encoding="utf-8")

def apply_all_changes(state: dict, kconf: kconfiglib.Kconfig) -> None:
    is_root = os.geteuid() == 0
    base = PORTAGE_DIR if is_root else (Path.cwd() / "portage-preview")
    changed = 0

    nu, u_chg = dict(state["exp_use"]), False
    for i in state["g_use"]:
        s = kconf.syms.get(i["sym"])
        if s and (s.str_value == "y") != i["initial"]:
            u_chg, nu[i["flag"]] = True, (s.str_value == "y")

    nf, f_chg = dict(state["exp_feat"]), False
    for i in state["g_feat"]:
        s = kconf.syms.get(i["sym"])
        if s and (s.str_value == "y") != i["initial"]:
            f_chg, nf[i["feature"]] = True, (s.str_value == "y")

    if u_chg or f_chg:
        changed += 1
        mc = state["mc_text"]
        if u_chg:
            mc = update_make_conf_var(mc, "USE", [f"{'' if nu[k] else '-'}{k}" for k in sorted(nu)], False)
            print("  [make.conf] Updated USE")
        if f_chg:
            mc = update_make_conf_var(mc, "FEATURES", [f"{'' if nf[k] else '-'}{k}" for k in sorted(nf)], True)
            print("  [make.conf] Updated FEATURES")
        out_mc = state["mc_file"] if is_root else (base / "make.conf")
        out_mc.parent.mkdir(parents=True, exist_ok=True)
        out_mc.write_text(mc, encoding="utf-8")

    for ef in state["ed_envs"]:
        t_f = base / "env" / ef["fname"]
        if kconf.syms.get(ef["sym_del"]) and kconf.syms[ef["sym_del"]].str_value == "y":
            changed += 1
            t_f.unlink(missing_ok=True)
            print(f"  [env] Deleted {t_f}")
            continue
        nv, vc = {}, False
        for vf in ef["vars"]:
            sv = kconf.syms.get(vf["sym"])
            val = sv.str_value if sv else vf["initial"]
            if val != vf["initial"]:
                vc = True
            if val.strip():
                nv[vf["key"]] = val
        if vc:
            changed += 1
            t_f.parent.mkdir(parents=True, exist_ok=True)
            t_f.write_text(render_env_vars(nv), encoding="utf-8")
            print(f"  [env] Updated {t_f}")

    nfn = kconf.syms["ENEW_FILENAME"].str_value.strip() if "ENEW_FILENAME" in kconf.syms else ""
    if nfn:
        nvm = {k: kconf.syms[f"ENEW_{k}"].str_value.strip() for k in ["CFLAGS", "CXXFLAGS", "LDFLAGS", "MAKEOPTS", "FEATURES"] if f"ENEW_{k}" in kconf.syms and kconf.syms[f"ENEW_{k}"].str_value.strip()}
        if nvm:
            changed += 1
            t_f = base / "env" / Path(nfn).name
            t_f.parent.mkdir(parents=True, exist_ok=True)
            t_f.write_text(render_env_vars(nvm), encoding="utf-8")
            print(f"  [env] Created {t_f}")

    for i in state["env_items"]:
        s = kconf.syms.get(i["sym"])
        if s and (s.str_value == "y") != i["initial"]:
            changed += 1
            t = base / "env" / i["fname"]
            if s.str_value == "y":
                t.parent.mkdir(parents=True, exist_ok=True)
                t.write_text(i["body"] + "\n", encoding="utf-8")
                print(f"  [env] Created {t}")
            else:
                t.unlink(missing_ok=True)
                print(f"  [env] Removed {t}")

    for p in state["packages"]:
        cp, cat, name = p["cp"], p["cat"], p["name"]
        uchg, duse = False, {}
        for i in p["flags"]:
            s = kconf.syms.get(i["sym"])
            val = (s.str_value == "y") if s else i["effective"]
            if val != i["effective"]:
                uchg = True
            if val != i["installed"]:
                duse[i["flag"]] = val
        if uchg:
            changed += 1
            t = base / "package.use" / cat / name
            write_one(t, f"{cp} {' '.join(f'{'' if duse[k] else '-'}{k}' for k in sorted(duse))}" if duse else None)
            print(f"  [package.use] Updated {t}")

        st, sl = kconf.syms.get(p["sym_kt"]), kconf.syms.get(p["sym_kl"])
        nt = (st.str_value == "y") if st else p["kw_t"]
        nl = (sl.str_value == "y") if sl else p["kw_l"]
        if nt != p["kw_t"] or nl != p["kw_l"]:
            changed += 1
            kws = (["~amd64"] if nt else []) + (["**"] if nl else [])
            t = base / "package.accept_keywords" / cat / name
            write_one(t, f"{cp} {' '.join(kws)}" if kws else None)
            print(f"  [package.accept_keywords] Updated {t}")

        nm = next((mk for mk, sk in [("ALL", "sym_ma"), ("EQ", "sym_me"), ("FWD", "sym_mf")] if kconf.syms.get(p[sk]) and kconf.syms[p[sk]].str_value == "y"), "NONE")
        if nm != p["mask_mode"]:
            changed += 1
            t = base / "package.mask" / cat / name
            na = None if nm == "NONE" else (cp if nm == "ALL" else ((p["mask_atom"] if p["mask_mode"] == "EQ" else f"={p['cpv']}") if nm == "EQ" else (p["mask_atom"] if p["mask_mode"] == "FWD" else f">={p['cpv']}")))
            write_one(t, na)
            print(f"  [package.mask] Updated {t} -> {na or 'unmasked'}")

        echg, aenvs = False, []
        for e in p["envs"]:
            s = kconf.syms.get(e["sym"])
            val = (s.str_value == "y") if s else e["initial"]
            if val != e["initial"]:
                echg = True
            if val:
                aenvs.append(e["name"])
        if echg:
            changed += 1
            t = base / "package.env" / cat / name
            write_one(t, f"{cp} {' '.join(sorted(aenvs))}" if aenvs else None)
            print(f"  [package.env] Updated {t}")

    print("\nNo changes made." if changed == 0 else "\nSaved cleanly. Run 'emerge -auDN @world' to apply.")

def main() -> None:
    print("Scanning installed packages and /etc/portage...")
    state = collect_portage_state()
    if not state["packages"]:
        sys.exit("No installed packages found.")
    with tempfile.TemporaryDirectory(prefix="wakstab-menu-") as tmp:
        kp, cp = Path(tmp) / "Kconfig", Path(tmp) / ".config"
        generate_kconfig(state, kp)
        os.environ["KCONFIG_CONFIG"] = str(cp)
        kc = kconfiglib.Kconfig(str(kp))
        menuconfig.menuconfig(kc)
        if cp.is_file():
            kc.load_config(str(cp))
            apply_all_changes(state, kc)
        else:
            print("\nExited without saving.")

if __name__ == "__main__":
    main()
