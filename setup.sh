#!/usr/bin/env bash
#
# setup.sh
#
# 1. Scans docker-compose.yml (and optionally other compose files) for
#    host-side ports.
# 2. Checks whether each is already in use, and by what (Docker container,
#    or an OS-level process on Linux/macOS/WSL2/native Windows).
# 3. Asks you to confirm before freeing them (docker rm / kill / taskkill,
#    picked automatically based on your environment).
# 4. Once every port is free, runs `docker compose <your args>` for you
#    (e.g. "up -d", "down -v", "restart", anything docker compose accepts).
# 5. After a successful "up", prints ready-to-click URLs for a target
#    service (default: agent-zero) using localhost, 127.0.0.1, and every
#    host-facing IP address it can detect — including WSL2's own vEthernet
#    IP, which is often the ONLY one that actually works when running
#    docker-ce directly inside WSL2 (no Docker Desktop vpnkit forwarding).
#
# Usage:
#   ./setup.sh [options] [--] <docker compose args...>
#
# Options:
#   -f FILE     compose file to scan (repeatable; default: docker-compose.yml
#               or compose.yml in the current directory)
#   -s NAME     service to print the URL for after "up" (default: agent-zero)
#   -y          auto-confirm removal/kill actions (non-interactive / CI use)
#   -n          dry-run: only report, never remove/kill/deploy anything
#   -h          show this help
#
# Common commands:
#   ./setup.sh -f docker-compose.yml up -d      # start everything (frees ports first)
#   ./setup.sh -f docker-compose.yml down -v    # stop everything AND remove all volumes
#
# More examples:
#   ./setup.sh up -d
#   ./setup.sh -y up -d
#   ./setup.sh -f docker-compose.yml -f idol-monitoring.yml down -v
#   ./setup.sh -s my-webapp up -d
#   ./setup.sh -n restart
#   ./setup.sh                       # just checks ports, no compose action
#
set -uo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
supports_color() {
  [[ -t 1 ]] || return 1
  [[ -z "${NO_COLOR:-}" ]] || return 1
  command -v tput >/dev/null 2>&1 || return 1
  [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]
}

if supports_color; then
  C_RESET="$(tput sgr0)"
  C_BOLD="$(tput bold)"
  C_RED="$(tput setaf 1)"
  C_GREEN="$(tput setaf 2)"
  C_YELLOW="$(tput setaf 3)"
  C_BLUE="$(tput setaf 4)"
  C_CYAN="$(tput setaf 6)"
else
  C_RESET="" ; C_BOLD="" ; C_RED="" ; C_GREEN="" ; C_YELLOW="" ; C_BLUE="" ; C_CYAN=""
fi

ok()    { echo "${C_GREEN}✓${C_RESET} $*"; }
warn()  { echo "${C_YELLOW}⚠${C_RESET} $*"; }
err()   { echo "${C_RED}✗${C_RESET} $*"; }
info()  { echo "${C_BLUE}==>${C_RESET} $*"; }

usage() {
  cat <<EOF
${C_BOLD}${C_CYAN}setup.sh${C_RESET} — free required ports, then deploy a docker compose stack

${C_BOLD}USAGE${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_YELLOW}[options]${C_RESET} ${C_YELLOW}[--]${C_RESET} ${C_CYAN}<docker compose args...>${C_RESET}

${C_BOLD}OPTIONS${C_RESET}
  ${C_YELLOW}-f FILE${C_RESET}   compose file to scan ${C_BOLD}(repeatable)${C_RESET}
              default: docker-compose.yml or compose.yml in cwd
  ${C_YELLOW}-s NAME${C_RESET}   service to print the URL for after "up" ${C_BOLD}(default: agent-zero)${C_RESET}
  ${C_YELLOW}-y${C_RESET}        auto-confirm removal/kill actions ${C_BOLD}(non-interactive)${C_RESET}
  ${C_YELLOW}-n${C_RESET}        dry-run — report only, never remove/kill/deploy
  ${C_YELLOW}-h${C_RESET}        show this help

${C_BOLD}COMMON COMMANDS${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_YELLOW}-f docker-compose.yml${C_RESET} ${C_CYAN}up -d${C_RESET}      ${C_BOLD}# start everything (frees ports first)${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_YELLOW}-f docker-compose.yml${C_RESET} ${C_CYAN}down -v${C_RESET}    ${C_BOLD}# stop everything AND remove all volumes${C_RESET}

${C_BOLD}MORE EXAMPLES${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_CYAN}up -d${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_YELLOW}-y${C_RESET} ${C_CYAN}up -d${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_YELLOW}-f docker-compose.yml -f idol-monitoring.yml${C_RESET} ${C_CYAN}down -v${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_YELLOW}-s my-webapp${C_RESET} ${C_CYAN}up -d${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET} ${C_YELLOW}-n${C_RESET} ${C_CYAN}restart${C_RESET}
  ${C_GREEN}./setup.sh${C_RESET}                    ${C_BOLD}# just checks ports, no deploy${C_RESET}
EOF
  exit 0
}

COMPOSE_FILES=()
AUTO_YES=0
DRY_RUN=0
SERVICE_NAME="agent-zero"

while getopts ":f:s:ynh" opt; do
  case "$opt" in
    f) COMPOSE_FILES+=("$OPTARG") ;;
    s) SERVICE_NAME="$OPTARG" ;;
    y) AUTO_YES=1 ;;
    n) DRY_RUN=1 ;;
    h) usage ;;
    \?) err "Unknown option: -$OPTARG"; usage ;;
  esac
done
shift $((OPTIND - 1))
[[ "${1:-}" == "--" ]] && shift

# Everything left on the command line is passed straight to `docker compose`
COMPOSE_ARGS=("$@")

if [[ ${#COMPOSE_FILES[@]} -eq 0 ]]; then
  if [[ -f "docker-compose.yml" ]]; then
    COMPOSE_FILES+=("docker-compose.yml")
  elif [[ -f "compose.yml" ]]; then
    COMPOSE_FILES+=("compose.yml")
  else
    err "No docker-compose.yml/compose.yml found in current directory."
    echo "Pass one explicitly with -f <file>." >&2
    exit 1
  fi
fi

for f in "${COMPOSE_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    err "Compose file not found: $f"
    exit 1
  fi
done

FILE_ARGS=()
for f in "${COMPOSE_FILES[@]}"; do FILE_ARGS+=(-f "$f"); done

# ---------------------------------------------------------------------------
# Environment detection
# ---------------------------------------------------------------------------
detect_env() {
  if grep -qi microsoft /proc/version 2>/dev/null || grep -qi wsl /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "${OSTYPE:-}" == "darwin"* ]]; then
    echo "macos"
  elif [[ "${OSTYPE:-}" == "msys"* || "${OSTYPE:-}" == "cygwin"* ]]; then
    echo "windows"
  elif [[ "${OSTYPE:-}" == "linux-gnu"* || "$(uname -s 2>/dev/null)" == "Linux" ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}
ENV_TYPE="$(detect_env)"
info "Detected environment: ${C_BOLD}${ENV_TYPE}${C_RESET}"
echo

info "Scanning for published host ports in:"
for f in "${COMPOSE_FILES[@]}"; do echo "    - $f"; done
echo

# --- Load .env (if present) so ${VAR} references without an inline
#     default can still be resolved, same as docker compose would. -----
load_env_file() {
  local dir envfile
  dir="$(dirname "$1")"
  envfile="$dir/.env"
  if [[ -f "$envfile" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$envfile"
    set +a
  fi
}

resolve_vars() {
  local line="$1" resolved="$1"
  while [[ "$resolved" =~ \$\{([A-Za-z_][A-Za-z0-9_]*)(:-([^}]*))?\} ]]; do
    local var="${BASH_REMATCH[1]}"
    local default="${BASH_REMATCH[3]}"
    local value="${!var:-}"
    [[ -z "$value" ]] && value="$default"
    resolved="${resolved/${BASH_REMATCH[0]}/$value}"
  done
  echo "$resolved"
}

extract_ports() {
  local file="$1"
  load_env_file "$file"
  # Scope extraction to actual "ports:" blocks so we never pick up
  # unrelated colon'd values elsewhere (environment vars, labels, etc.).
  awk '
    /^[[:space:]]*ports:[[:space:]]*$/ { in_ports=1; next }
    in_ports {
      if ($0 ~ /^[[:space:]]*-[[:space:]]*/) { print; next }
      else { in_ports=0 }
    }
  ' "$file" \
    | sed -E 's/^[[:space:]]*-[[:space:]]*//' \
    | sed -E 's/^["\x27]//' \
    | sed -E 's/["\x27][[:space:]]*(#.*)?$//' \
    | sed -E 's/[[:space:]]*(#.*)?$//' \
    | while read -r line; do
        [[ -z "$line" ]] && continue
        line="$(resolve_vars "$line")"
        line="${line%%/*}"
        IFS=':' read -ra parts <<< "$line"
        n=${#parts[@]}
        if [[ $n -ge 2 ]]; then
          host_port="${parts[$((n-2))]}"
          if [[ "$host_port" =~ ^[0-9]+$ ]]; then
            echo "$host_port"
          else
            echo "  (could not resolve host port from: '$line')" >&2
          fi
        fi
      done
}

ALL_PORTS=()
for f in "${COMPOSE_FILES[@]}"; do
  while IFS= read -r p; do
    [[ -n "$p" ]] && ALL_PORTS+=("$p")
  done < <(extract_ports "$f")
done

if [[ ${#ALL_PORTS[@]} -eq 0 ]]; then
  warn "No published host ports found in the given compose file(s)."
else
  readarray -t ALL_PORTS < <(printf '%s\n' "${ALL_PORTS[@]}" | sort -un)
  echo "Ports declared in compose file(s): ${C_BOLD}${ALL_PORTS[*]}${C_RESET}"
  echo
fi

# ---------------------------------------------------------------------------
# Port-in-use checks
# ---------------------------------------------------------------------------
port_in_use() {
  local port="$1"
  if command -v ss >/dev/null 2>&1; then
    ss -ltnH 2>/dev/null | awk '{print $4}' | grep -qE "[.:]${port}\$"; return $?
  elif command -v netstat >/dev/null 2>&1; then
    netstat -ltn 2>/dev/null | awk '{print $4}' | grep -qE "[.:]${port}\$"; return $?
  elif command -v lsof >/dev/null 2>&1; then
    lsof -iTCP -sTCP:LISTEN -P 2>/dev/null | grep -q ":${port} "; return $?
  else
    warn "no ss/netstat/lsof available - cannot check port $port"
    return 1
  fi
}

docker_owner_of_port() {
  local port="$1"
  command -v docker >/dev/null 2>&1 || return 0
  docker ps --format '{{.ID}}|{{.Names}}|{{.Ports}}' 2>/dev/null | while IFS='|' read -r id name ports; do
    if echo "$ports" | grep -qE "(^|[^0-9])${port}->"; then
      echo "$id|$name"; break
    fi
  done
}

CONFLICTS=()
for port in "${ALL_PORTS[@]}"; do
  if port_in_use "$port"; then
    owner="$(docker_owner_of_port "$port")"
    if [[ -n "$owner" ]]; then
      cid="${owner%%|*}"; cname="${owner##*|}"
      err "Port $port is IN USE by docker container: ${C_BOLD}${cname}${C_RESET} ($cid)"
      CONFLICTS+=("$port|$cid|$cname")
    else
      err "Port $port is IN USE by a non-docker (or unidentified) process"
      CONFLICTS+=("$port||")
    fi
  else
    ok "Port $port is free"
  fi
done
echo

# ---------------------------------------------------------------------------
# OS-level kill helpers (used for non-docker conflicts)
# ---------------------------------------------------------------------------
get_unix_pids() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    lsof -ti tcp:"$port" -sTCP:LISTEN 2>/dev/null
  elif command -v fuser >/dev/null 2>&1; then
    fuser "${port}/tcp" 2>/dev/null | tr -s ' '
  elif command -v ss >/dev/null 2>&1; then
    ss -ltnp 2>/dev/null | grep ":${port} " | grep -oE 'pid=[0-9]+' | cut -d= -f2
  fi
}

kill_unix_pids() {
  local pid
  for pid in $1; do
    [[ -z "$pid" ]] && continue
    info "Killing PID $pid (kill -TERM)..."
    kill "$pid" 2>/dev/null
    sleep 0.5
    if kill -0 "$pid" 2>/dev/null; then
      warn "PID $pid still alive, sending SIGKILL..."
      kill -9 "$pid" 2>/dev/null
    fi
  done
}

# Windows-side lookups/kills, used both from WSL (via interop with cmd.exe)
# and from native Windows bash shells (Git Bash / MSYS / Cygwin), where
# cmd.exe / netstat.exe / taskkill.exe are directly on PATH.
get_windows_pids() {
  local port="$1"
  cmd.exe /c "netstat -ano" 2>/dev/null \
    | tr -d '\r' \
    | grep -E "LISTENING" \
    | grep -E "[.:]${port}[[:space:]]" \
    | awk '{print $NF}' \
    | sort -u
}

kill_windows_pids() {
  local pid
  for pid in $1; do
    [[ -z "$pid" ]] && continue
    info "Killing Windows PID $pid (taskkill /F)..."
    cmd.exe /c "taskkill /PID $pid /F" >/dev/null 2>&1
  done
}

kill_process_on_port() {
  local port="$1"
  case "$ENV_TYPE" in
    linux|macos)
      kill_unix_pids "$(get_unix_pids "$port")"
      ;;
    wsl)
      # WSL2 has its own network namespace, separate from the Windows
      # host — a listener could be on either side (or both), so check both.
      kill_unix_pids "$(get_unix_pids "$port")"
      kill_windows_pids "$(get_windows_pids "$port")"
      ;;
    windows)
      kill_windows_pids "$(get_windows_pids "$port")"
      ;;
    *)
      warn "Unknown environment — can't auto-kill port $port. Free it manually."
      ;;
  esac
}

if [[ ${#CONFLICTS[@]} -eq 0 ]]; then
  ok "All required ports are free."
  RESOLVED=1
else
  DOCKER_CONFLICTS=()
  NON_DOCKER_CONFLICTS=()
  for c in "${CONFLICTS[@]}"; do
    cid="$(cut -d'|' -f2 <<< "$c")"
    if [[ -n "$cid" ]]; then DOCKER_CONFLICTS+=("$c"); else NON_DOCKER_CONFLICTS+=("$c"); fi
  done

  RESOLVED=1

  if [[ $DRY_RUN -eq 1 ]]; then
    warn "Dry-run mode: not removing/killing anything, and not deploying."
    exit 2
  fi

  # --- Docker-owned conflicts -> docker stop/rm ---
  if [[ ${#DOCKER_CONFLICTS[@]} -gt 0 ]]; then
    echo "The following docker containers are holding required ports:"
    declare -A UNIQUE_CONTAINERS=()
    for c in "${DOCKER_CONFLICTS[@]}"; do
      port="$(cut -d'|' -f1 <<< "$c")"; cid="$(cut -d'|' -f2 <<< "$c")"; cname="$(cut -d'|' -f3 <<< "$c")"
      UNIQUE_CONTAINERS["$cid"]="$cname"
      echo "   - port $port -> ${C_BOLD}${cname}${C_RESET} ($cid)"
    done
    echo
    do_remove=$AUTO_YES
    if [[ $AUTO_YES -eq 0 ]]; then
      read -r -p "${C_YELLOW}Stop and remove these ${#UNIQUE_CONTAINERS[@]} container(s) now? [y/N]${C_RESET} " ans
      [[ "$ans" =~ ^[yY] ]] && do_remove=1 || do_remove=0
    fi
    if [[ $do_remove -eq 1 ]]; then
      for cid in "${!UNIQUE_CONTAINERS[@]}"; do
        cname="${UNIQUE_CONTAINERS[$cid]}"
        info "Stopping $cname ($cid)..."; docker stop "$cid" >/dev/null 2>&1
        info "Removing $cname ($cid)..."; docker rm -f "$cid" >/dev/null 2>&1
      done
      docker container prune -f >/dev/null 2>&1
      docker network prune -f >/dev/null 2>&1
    else
      warn "Skipped removing docker containers."
      RESOLVED=0
    fi
  fi

  # --- Non-docker conflicts -> OS-level kill/taskkill ---
  if [[ ${#NON_DOCKER_CONFLICTS[@]} -gt 0 ]]; then
    echo "The following ports are held by non-docker processes:"
    for c in "${NON_DOCKER_CONFLICTS[@]}"; do
      echo "   - port $(cut -d'|' -f1 <<< "$c")"
    done
    echo
    do_kill=$AUTO_YES
    if [[ $AUTO_YES -eq 0 ]]; then
      case "$ENV_TYPE" in
        wsl)     hint="kill (Linux side) + taskkill (Windows side)" ;;
        windows) hint="taskkill /F" ;;
        macos|linux) hint="kill -9" ;;
        *)       hint="an OS-appropriate kill" ;;
      esac
      read -r -p "${C_YELLOW}Force-stop the process(es) holding these ports using ${hint}? [y/N]${C_RESET} " ans
      [[ "$ans" =~ ^[yY] ]] && do_kill=1 || do_kill=0
    fi
    if [[ $do_kill -eq 1 ]]; then
      for c in "${NON_DOCKER_CONFLICTS[@]}"; do
        port="$(cut -d'|' -f1 <<< "$c")"
        kill_process_on_port "$port"
      done
      sleep 1
      # Re-verify
      for c in "${NON_DOCKER_CONFLICTS[@]}"; do
        port="$(cut -d'|' -f1 <<< "$c")"
        if port_in_use "$port"; then
          err "Port $port is still in use after kill attempt — free it manually."
          RESOLVED=0
        else
          ok "Port $port is now free."
        fi
      done
    else
      warn "Skipped killing processes."
      RESOLVED=0
    fi
  fi
fi
echo

# ---------------------------------------------------------------------------
# WSL_E_DISTRO_NOT_FOUND note
# ---------------------------------------------------------------------------
cat <<EOF
${C_CYAN}------------------------------------------------------------------------------${C_RESET}
${C_BOLD}NOTE on "WSL_E_DISTRO_NOT_FOUND" / "Failed to delete N items" in Docker Desktop${C_RESET}
${C_CYAN}------------------------------------------------------------------------------${C_RESET}
That error is unrelated to port conflicts. It happens when Docker Desktop's
WSL2 backend loses track of the distro (e.g. "docker-desktop" or
"docker-desktop-data") a stack's containers live in. If you hit it:

    wsl --shutdown
    # restart Docker Desktop, then check Settings > Resources > WSL Integration

Last resort: Docker Desktop's Troubleshoot > "Clean / Purge data" (wipes all
local images/containers/volumes).
${C_CYAN}------------------------------------------------------------------------------${C_RESET}
EOF

# ---------------------------------------------------------------------------
# Host-IP URL generation
# ---------------------------------------------------------------------------
get_host_ips() {
  case "$ENV_TYPE" in
    linux|wsl)
      # Primary: whatever IP this machine/VM uses for its default route.
      # For WSL2 this is the vEthernet (WSL) address the Windows host
      # actually reaches you on — far more reliable than range-guessing,
      # since WSL2's own subnet commonly overlaps Docker's default bridge
      # range (172.16.0.0/12).
      local primary
      primary="$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[0-9.]+' | head -1)"
      [[ -n "$primary" ]] && echo "$primary"

      # Secondary: any other global-scope IPv4 addresses, skipping
      # Docker's own bridge/veth interfaces by NAME, not by IP range.
      ip -4 -o addr show scope global 2>/dev/null \
        | grep -vE 'docker0|br-|veth' \
        | awk '{print $4}' | cut -d/ -f1 \
        | grep -v "^${primary}\$"
      ;;
    macos)
      ifconfig 2>/dev/null | awk '/inet /{print $2}' | grep -v '^127\.'
      ;;
    windows)
      ipconfig 2>/dev/null | tr -d '\r' | awk -F': ' '/IPv4 Address/{print $2}'
      ;;
  esac
}

print_service_url() {
  local svc="$1" container_port="$2"
  local hostport
  hostport="$(docker compose "${FILE_ARGS[@]}" port "$svc" "$container_port" 2>/dev/null | tail -1 | sed -E 's/^[^:]+://')"
  if [[ -z "$hostport" ]]; then
    warn "Could not determine host port for service '$svc' — skipping URL."
    return
  fi
  echo
  info "${C_BOLD}${svc}${C_RESET} should be reachable at:"
  echo "   ${C_BOLD}http://localhost:${hostport}${C_RESET}"
  echo "   ${C_BOLD}http://127.0.0.1:${hostport}${C_RESET}"
  while IFS= read -r ip; do
    [[ -z "$ip" || "$ip" == "127.0.0.1" ]] && continue
    echo "   ${C_BOLD}http://${ip}:${hostport}${C_RESET}"
  done < <(get_host_ips)
  if [[ "$ENV_TYPE" == "wsl" ]]; then
    echo "   ${C_YELLOW}(if localhost doesn't load in your Windows browser, use the WSL IP above —${C_RESET}"
    echo "   ${C_YELLOW} it changes on reboot/'wsl --shutdown', re-run this script to get the current one)${C_RESET}"
  fi
}

# ---------------------------------------------------------------------------
# Deploy
# ---------------------------------------------------------------------------
if [[ ${#COMPOSE_ARGS[@]} -eq 0 ]]; then
  info "No docker compose command given — nothing to deploy. (e.g. run: ./setup.sh up -d)"
  exit 0
fi

if [[ $RESOLVED -ne 1 ]]; then
  err "One or more ports/containers were not resolved — aborting deploy."
  echo "Fix the conflicts above, then re-run: ./setup.sh ${COMPOSE_ARGS[*]}"
  exit 3
fi

CMD=(docker compose)
for f in "${COMPOSE_FILES[@]}"; do CMD+=(-f "$f"); done
CMD+=("${COMPOSE_ARGS[@]}")

info "Running: ${C_BOLD}${CMD[*]}${C_RESET}"
if [[ $DRY_RUN -eq 1 ]]; then
  warn "Dry-run mode — not actually executing."
  exit 0
fi

"${CMD[@]}"
DEPLOY_STATUS=$?

if [[ $DEPLOY_STATUS -eq 0 ]] && [[ " ${COMPOSE_ARGS[*]} " == *" up "* ]]; then
  if grep -qE "^\s*${SERVICE_NAME}:\s*$" "${COMPOSE_FILES[@]}" 2>/dev/null; then
    print_service_url "$SERVICE_NAME" 80
  fi
fi

exit $DEPLOY_STATUS