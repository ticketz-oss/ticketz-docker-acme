#!/usr/bin/env python3
"""
Executa migrações declarativas no docker-compose.override.yaml.

Cada arquivo migrations/###_nome.yaml define uma "parte" de YAML que deve
estar presente na configuração efetiva. Se o predicado `check` não for
satisfeito, a parte `apply` é mesclada em docker-compose.override.yaml.

O arquivo migrations/.applied guarda os IDs das migrações já executadas.
"""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


MIGRATIONS_DIR = Path(__file__).resolve().parent
APPLIED_FILE = MIGRATIONS_DIR / ".applied"


def ensure_yaml():
    """Garante que o PyYAML esteja disponível."""
    try:
        import yaml

        return yaml
    except ImportError:
        print("PyYAML não encontrado. Tentando instalar python3-yaml...")
        subprocess.run(["apt-get", "update", "-qq"], capture_output=True)
        result = subprocess.run(
            ["apt-get", "install", "-y", "-qq", "python3-yaml"],
            capture_output=True,
        )
        if result.returncode != 0:
            print("Falha via apt. Tentando pip3 install pyyaml...")
            result = subprocess.run(
                ["pip3", "install", "--quiet", "pyyaml"],
                capture_output=True,
            )
            if result.returncode != 0:
                print(
                    "Não foi possível instalar PyYAML. "
                    "Instale manualmente (python3-yaml ou pyyaml) e tente novamente."
                )
                sys.exit(1)
        import yaml

        return yaml


def get_effective_config(project_dir):
    """Retorna a configuração efetiva do docker compose (merge de todos os arquivos)."""
    result = subprocess.run(
        ["docker", "compose", "config"],
        cwd=str(project_dir),
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"Erro ao obter configuração do docker compose: {result.stderr}")
        sys.exit(1)
    return result.stdout


def load_applied():
    if not APPLIED_FILE.exists():
        return set()
    with open(APPLIED_FILE, "r", encoding="utf-8") as f:
        return {line.strip() for line in f if line.strip()}


def save_applied(applied):
    APPLIED_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(APPLIED_FILE, "w", encoding="utf-8") as f:
        for mid in sorted(applied):
            f.write(f"{mid}\n")


def discover_migrations():
    pattern = re.compile(r"^(\d+)_(.+)\.yaml$")
    migrations = []
    for path in sorted(MIGRATIONS_DIR.iterdir()):
        match = pattern.match(path.name)
        if match and path.is_file():
            migrations.append((int(match.group(1)), path))
    return migrations


def _normalize_host_path(path):
    """Expande ~ para o HOME do usuário, facilitando comparações."""
    if isinstance(path, str) and path.startswith("~/"):
        return os.path.expanduser(path)
    return path


def _parse_volume(vol):
    """Retorna (host_path, container_path, mode) a partir de uma definição de volume."""
    if isinstance(vol, str):
        parts = vol.split(":")
        if len(parts) >= 2:
            host = _normalize_host_path(parts[0])
            container = parts[1]
            mode = parts[2] if len(parts) >= 3 else ""
            return (host, container, mode)
    elif isinstance(vol, dict):
        if vol.get("type", "volume") != "bind":
            return None
        host = _normalize_host_path(vol.get("source"))
        container = vol.get("target")
        if host and container:
            return (host, container, "")
    return None


def _volume_matches(target, candidate):
    """Verifica se uma definição de volume candidata satisfaz o alvo (host:container)."""
    t_parts = _parse_volume(target)
    c_parts = _parse_volume(candidate)
    if not t_parts or not c_parts:
        return False
    return t_parts[0] == c_parts[0] and t_parts[1] == c_parts[1]


def _contains_predicate(collection, expected):
    """Verifica se `expected` está contido em `collection` usando comparação de volumes quando aplicável."""
    if not isinstance(collection, list):
        return False

    for item in collection:
        if _volume_matches(expected, item):
            return True
    return False


def check_satisfied(check_tree, config_tree):
    """Verifica se a configuração efetiva satisfaz a árvore de `check`."""
    if isinstance(check_tree, dict):
        for key, expected in check_tree.items():
            if key == "contains" and isinstance(expected, str):
                # O nó pai deve ser uma lista; será tratado em _contains_predicate.
                continue
            actual = config_tree.get(key) if isinstance(config_tree, dict) else None
            if not check_satisfied(expected, actual):
                return False
        return True

    if isinstance(check_tree, list):
        if not isinstance(config_tree, list):
            return False
        for expected in check_tree:
            if isinstance(expected, dict) and len(expected) == 1 and "contains" in expected:
                target = expected["contains"]
                if not _contains_predicate(config_tree, target):
                    return False
            else:
                # Para itens simples, exige correspondência exata na lista.
                if expected not in config_tree:
                    return False
        return True

    return check_tree == config_tree


def merge(base, override):
    """Mescla `override` em `base` de forma recursiva; listas são concatenadas."""
    if isinstance(base, dict) and isinstance(override, dict):
        result = dict(base)
        for key, value in override.items():
            if key in result:
                result[key] = merge(result[key], value)
            else:
                result[key] = value
        return result

    if isinstance(base, list) and isinstance(override, list):
        return base + override

    return override


def load_override(override_path, yaml):
    if override_path.exists():
        with open(override_path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    return {}


def save_override(override_path, data, yaml):
    override_path.parent.mkdir(parents=True, exist_ok=True)
    with open(override_path, "w", encoding="utf-8") as f:
        yaml.safe_dump(
            data, f, default_flow_style=False, sort_keys=False, allow_unicode=True
        )


def run_migrations(project_dir, dry_run=False):
    yaml = ensure_yaml()
    applied = load_applied()
    override_path = project_dir / "docker-compose.override.yaml"

    for num, path in discover_migrations():
        mid = path.stem

        if mid in applied:
            print(f"[{mid}] já aplicada. Pulando.")
            continue

        with open(path, "r", encoding="utf-8") as f:
            migration = yaml.safe_load(f) or {}

        description = migration.get("description", "")
        check_tree = migration.get("check", {})
        apply_tree = migration.get("apply", {})

        config = yaml.safe_load(get_effective_config(project_dir))

        if check_satisfied(check_tree, config):
            print(f"[{mid}] não necessária. Marcando como aplicada.")
            applied.add(mid)
            save_applied(applied)
            continue

        print(f"[{mid}] {description}")

        if dry_run:
            print(f"[{mid}] (simulação) seria aplicada em {override_path}")
            applied.add(mid)
            save_applied(applied)
        else:
            override = load_override(override_path, yaml)
            merged = merge(override, apply_tree)
            save_override(override_path, merged, yaml)
            applied.add(mid)
            save_applied(applied)
            print(f"[{mid}] aplicada.")


def main():
    parser = argparse.ArgumentParser(
        description="Migrações declarativas do docker-compose.override.yaml"
    )
    parser.add_argument(
        "--project-dir",
        default=".",
        help="Diretório do projeto (onde fica docker-compose.yaml)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Verifica quais migrações seriam aplicadas sem alterar arquivos",
    )
    args = parser.parse_args()
    project_dir = Path(args.project_dir).resolve()

    if not (project_dir / "docker-compose.yaml").exists():
        print(f"docker-compose.yaml não encontrado em {project_dir}")
        sys.exit(1)

    run_migrations(project_dir, args.dry_run)


if __name__ == "__main__":
    main()
