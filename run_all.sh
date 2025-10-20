#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS="$ROOT/logs"
RUN="$ROOT/.run"
INFRA="$ROOT/infra/docker-compose.yml"

mkdir -p "$LOGS" "$RUN"

ts() { date +"%H:%M:%S"; }
banner() { echo -e "\n[$(ts)] \033[1m$*\033[0m"; }
ok() { echo "[$(ts)] ✅ $*"; }
warn() { echo "[$(ts)] ⚠️  $*" >&2; }
die() { echo "[$(ts)] ❌ $*" >&2; exit 1; }

wait_port() {
  local host="$1" port="$2" tries="${3:-60}"
  for ((i=1;i<=tries;i++)); do
    if (exec 3<>"/dev/tcp/${host}/${port}") 2>/dev/null; then
      exec 3>&-
      ok "Puerto ${host}:${port} listo"
      return 0
    fi
    sleep 1
  done
  return 1
}

start_bg() { # name, cmd, logfile, pidfile
  local name="$1"
  local cmd="$2"
  local logfile="$3"
  local pidfile="$4"

  banner "Iniciando ${name}…"
  nohup bash -lc "$cmd" >"$logfile" 2>&1 & echo $! > "$pidfile"
  sleep 1
  if kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    ok "${name} corriendo (pid $(cat "$pidfile")) → logs: ${logfile}"
  else
    warn "Parece que ${name} no arrancó. Revisa ${logfile}"
  fi
}

# ── Prechecks ──────────────────────────────────────────────────────────────────
command -v docker >/dev/null || die "Docker no está en PATH. Habilita WSL integration."
command -v dotnet >/dev/null || warn "No encuentro dotnet. Si falla Auditoría, instala .NET 8 en WSL."
command -v bundle >/dev/null || warn "No encuentro bundler. (gem install bundler) si las apps Rails fallan."

# ── Entorno común ──────────────────────────────────────────────────────────────
export NLS_LANG=".AL32UTF8"

# ── 1) Bases de datos (Docker) ────────────────────────────────────────────────
banner "Levantando infraestructura (Docker Compose)…"
if [[ -f "$INFRA" ]]; then
  docker compose -f "$INFRA" up -d
else
  warn "No encontré $INFRA. Intento fallback para Mongo…"
  docker ps -a --format '{{.Names}}' | grep -qx "mongo" || \
    docker run -d --name mongo -p 27017:27017 -v mongo-data:/data/db mongo:7
  ok "Mongo arriba. Para Oracle usa tu compose habitual."
fi

wait_port localhost 27017 60  || warn "Mongo (27017) no respondió a tiempo."
wait_port localhost 1521 120 || warn "Oracle (1521) no respondió a tiempo. ¿oracle-xe está Up?"

# ── 2) Auditoría (.NET + Mongo) ───────────────────────────────────────────────
export MONGO_URL="mongodb://localhost:27017"
export ASPNETCORE_URLS="http://localhost:5240"

if [[ -d "$ROOT/auditoria-dotnet/Auditoria.Api" ]]; then
  start_bg "Auditoría .NET (5240)" \
    "cd '$ROOT/auditoria-dotnet/Auditoria.Api' && dotnet run" \
    "$LOGS/auditoria.log" "$RUN/auditoria.pid"
else
  warn "No existe auditoria-dotnet/Auditoria.Api. Saltando Auditoría."
fi

# ── Helper para Rails (instala, migra, arranca) ───────────────────────────────
rails_up() { # name dir port extra_env
  local name="$1"
  local dir="$2"
  local port="$3"
  local extra_env="${4:-}"
  local log="$LOGS/${name// /_}.log"
  local pid="$RUN/${name// /_}.pid"

  # rbenv si existe
  local env_eval=""
  if command -v rbenv >/dev/null; then env_eval='eval "$(rbenv init - bash)" &&'; fi

  # Export comunes Oracle
  local common_env='export ORACLE_HOST=localhost ORACLE_PORT=1521 ORACLE_DB=XEPDB1 ORACLE_USER=app_user ORACLE_PASS=app_pass NLS_LANG=.AL32UTF8'

  local cmd="
    cd '$dir' && $env_eval $common_env $extra_env &&
    bundle install &&
    RAILS_ENV=development bundle exec rails db:migrate &&
    RAILS_ENV=development bundle exec rails s -p $port
  "
  start_bg "$name" "$cmd" "$log" "$pid"
}

# ── 3) Clientes (Rails 3000) ─────────────────────────────────────────────────
if [[ -d "$ROOT/clientes-ruby" ]]; then
  rails_up "Clientes Rails (3000)" "$ROOT/clientes-ruby" 3000 \
           'export AUDITORIA_URL="http://localhost:5240"'
else
  warn "No existe clientes-ruby. Saltando Clientes."
fi

# ── 4) Facturas (Rails 3001) ─────────────────────────────────────────────────
if [[ -d "$ROOT/facturas-ruby" ]]; then
  rails_up "Facturas Rails (3001)" "$ROOT/facturas-ruby" 3001 \
           'export CLIENTES_URL="http://localhost:3000" AUDITORIA_URL="http://localhost:5240"'
else
  warn "No existe facturas-ruby. Saltando Facturas."
fi

banner "Todo lanzado. Endpoints:"
echo "  Auditoría:  http://localhost:5240/swagger"
echo "  Clientes:   http://localhost:3000/clientes"
echo "  Facturas:   http://localhost:3001/facturas"
echo
echo "  Logs en:    $LOGS"
echo "  Para detener: ./stop_all.sh"
echo

trap 'echo; banner "Deteniendo (Ctrl+C)…"; "$ROOT/stop_all.sh"; exit 0' INT
while true; do sleep 3600; done
