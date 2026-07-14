# Troubleshooting

## Common Issues

### Ollama not detecting GPU
- Ensure NVIDIA Container Toolkit is installed and Docker restarted.
- Check logs: `docker compose logs ollama`
- Verify inside container: `docker compose exec ollama nvidia-smi`

### Agent Zero cannot connect to Ollama
- In the Agent Zero UI (Settings → Configure Models), the API Base URL
  **must** be `http://ollama:11434` — the Ollama service name, since both
  containers share the same Compose network.
- Do **not** use `http://host.docker.internal:11434` here. That address
  targets the host machine, not the ollama container, and on plain Linux
  hosts it won't resolve at all unless you add
  `extra_hosts: ["host.docker.internal:host-gateway"]`. This was a mistake
  in an earlier version of this repo's own onboarding instructions.
- Confirm `OLLAMA_BASE_URL=http://ollama:11434` is set as an env var too
  (docker-compose.yml already does this), but note the UI value set during
  onboarding takes precedence once saved to `settings.json`.
- Restart agent-zero after model pull: `docker compose restart agent-zero`

### Port 8080 or 9000 already in use
- Change ports in `docker-compose.yml` (e.g. `"9090:80"` for agent-zero)

### Watchtower not updating containers
- Ensure services have the label `com.centurylinklabs.watchtower.enable=true`
- Check watchtower logs: `docker compose logs watchtower`
- Manually trigger: `docker compose restart watchtower`

### Out of memory / slow responses
- Use smaller model (e.g. `qwen2.5:7b`)
- Increase `OLLAMA_CONTEXT_LENGTH` carefully
- Add resource limits in compose (see commented section)

### Container keeps restarting
- Check logs for the specific service.
- Common cause: missing model or wrong base URL (see above).

### Watchtower auto-updated Agent Zero and now it errors on startup
- Agent Zero has shipped major version jumps (e.g. v1.x → v2.0) that are
  not drop-in upgrades — they require Settings → Backup & Restore, not
  just a new image pull. This repo intentionally does **not** put the
  Watchtower label on the `agent-zero` service, so it only auto-updates
  on `docker compose pull agent-zero && docker compose up -d agent-zero`
  when you choose to. If you add the label back, back up first.

## Getting Help

- GitHub Issues
- Agent Zero Discord / official docs
- Ollama GitHub discussions
