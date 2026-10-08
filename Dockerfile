# Use the official NVIDIA CUDA 12.8 Toolkit image on Ubuntu 24.04
# Ubuntu 24.04 provides GLIBC 2.39 and GLIBCXX 3.4.32 (satisfying >= 2.38 and >= 3.4.21)
FROM nvidia/cuda:12.8.0-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system requirements: C++ compiler, ninja, Python 3.12, and download tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ninja-build \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Install 'uv' (the fast Python package installer requested by the docs)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Download the specific release artifact
RUN wget https://github.com/1CatAI/1Cat-vLLM/releases/download/v1.5.1/1cat_vllm-1.5.1-cp312-cp312-linux_x86_64.whl

# Follow the exact installation steps from the docs
# 1. Create a Python 3.12 virtual environment
RUN uv venv --python 3.12 .venv

# 2. Install the wheel (this automatically resolves PyTorch 2.10.0 + CUDA 12.8 dependencies)
RUN uv pip install --python .venv/bin/python ./1cat_vllm-1.5.1-cp312-cp312-linux_x86_64.whl

# Activate the virtual environment permanently in the container
ENV PATH="/workspace/.venv/bin:$PATH"

# Expose the API server port
EXPOSE 8000

# Start the OpenAI-compatible vLLM API server
ENTRYPOINT ["python", "-m", "vllm.entrypoints.openai.api_server"]