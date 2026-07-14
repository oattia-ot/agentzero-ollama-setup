# Detailed Setup Guide

## NVIDIA GPU Setup (Recommended)

1. Install NVIDIA drivers on host.
2. Install NVIDIA Container Toolkit:
   ```bash
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
   curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
     sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
     sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   sudo apt-get update
   sudo apt-get install -y nvidia-container-toolkit
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```
3. Verify: `docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi`

## First Run Checklist

- [ ] `docker compose up -d`
- [ ] Pull model: `docker compose exec ollama ollama pull glm-4.7-flash`
- [ ] Access http://localhost:8080 and configure Ollama provider
- [ ] Test with prompt: "Hello, what model are you running?"
- [ ] Open Portainer at http://localhost:9000 and set admin password

## Alternative Models

- Fast & capable: `qwen2.5:14b` or `qwen2.5-coder:7b`
- Lightweight: `llama3.2:3b` or `phi3:mini`
- Coding focused: `deepseek-coder-v2:16b`

Pull with: `docker compose exec ollama ollama pull <model>`

## Troubleshooting

See `docs/troubleshooting.md`
