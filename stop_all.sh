#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN="$ROOT/.run"
stop_pid() {
  local name="$1" pidfile="$2"
  [[ -f "$pidfile" ]] || return 0
  local pid; pid="$(cat "$pidfile")" || true
  if [[ -n "${pid:-}" ]] && kill -0 "$pid" 2>/dev/null; then
    echo "Parando ${name} (pid ${pid})…"
    kill "$pid" 2>/dev/null || true
    sleep 1
    kill -9 "$pid" 2>/dev/null || true
  fi
  rm -f "$pidfile"
}
stop_pid "Facturas"  "$RUN/facturas.pid"
stop_pid "Clientes"  "$RUN/clientes.pid"
stop_pid "Auditoría" "$RUN/auditoria.pid"

# No tumbamos DBs automáticamente (pueden servir a otros procesos).
# Si quieres bajar infraestructura:
# docker compose -f infra/docker-compose.yml down

echo "Listo. (DBs siguen arriba; usa 'docker compose -f infra/docker-compose.yml down' si quieres apagarlas)."
