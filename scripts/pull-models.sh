#!/bin/bash
# Pull recommended models for Agent Zero + Ollama
# Profile: 64GB RAM / 16 cores, CPU-only, WSL2
#
# With this much RAM/CPU you can comfortably run larger models than the
# original laptop-oriented defaults (which pulled a 19GB MoE model on a
# profile documented as "16GB RAM minimum" — a mismatch on small hardware,
# but fine here). Defaults below favor quality; lighter fallbacks are
# listed too.

set -e

echo "Pulling gemma4:e4b (main/chat model — good quality, fast enough on CPU)..."
docker compose exec ollama ollama pull gemma4:e4b

echo "Pulling qwen2.5-coder:7b (useful for coding-heavy agent tasks)..."
docker compose exec ollama ollama pull qwen2.5-coder:7b

echo "Pulling nomic-embed-text (recommended embedding model)..."
docker compose exec ollama ollama pull nomic-embed-text

echo "Done! You can now select these models in Agent Zero settings."
echo
echo "Other options for this hardware:"
echo "  docker compose exec ollama ollama pull qwen2.5:14b       # strong all-rounder"
echo "  docker compose exec ollama ollama pull glm-4.7-flash     # ~19GB, 30B-class MoE, needs Ollama 0.14.3+"
echo "  docker compose exec ollama ollama pull gemma4:e2b        # lighter/faster fallback"
echo "  docker compose exec ollama ollama pull gemma2:2b         # fastest, lowest RAM"
