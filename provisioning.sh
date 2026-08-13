#!/bin/bash

# ============================================================
# Vast.ai ComfyUI Provisioning
# V1.0 - Environment Detection
# ============================================================

set -e

echo ""
echo "============================================================"
echo "   Vast.ai ComfyUI Provisioning"
echo "   V1.0 - Environment Detection"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# 1. GPU
# ------------------------------------------------------------

echo "[1/5] Detectando GPU..."

if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=name,memory.total,driver_version \
        --format=csv,noheader

    echo ""
    echo "CUDA:"
    nvidia-smi | grep -i "CUDA Version" || true
else
    echo "⚠️ nvidia-smi no encontrado."
fi

echo ""

# ------------------------------------------------------------
# 2. Python
# ------------------------------------------------------------

echo "[2/5] Detectando Python..."

if [ -x "/venv/main/bin/python" ]; then
    PYTHON="/venv/main/bin/python"
elif [ -x "/opt/venv/bin/python" ]; then
    PYTHON="/opt/venv/bin/python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON="$(command -v python3)"
elif command -v python >/dev/null 2>&1; then
    PYTHON="$(command -v python)"
else
    echo "❌ Python no encontrado."
    exit 1
fi

echo "Python encontrado:"
echo "$PYTHON"

"$PYTHON" --version

echo ""

# ------------------------------------------------------------
# 3. PyTorch
# ------------------------------------------------------------

echo "[3/5] Detectando PyTorch..."

"$PYTHON" - <<'PY'
try:
    import torch

    print("PyTorch:", torch.__version__)
    print("CUDA disponible:", torch.cuda.is_available())
    print("CUDA compilado:", torch.version.cuda)

    if torch.cuda.is_available():
        print("GPU:", torch.cuda.get_device_name(0))
        print(
            "VRAM:",
            round(
                torch.cuda.get_device_properties(0).total_memory / 1024**3,
                2
            ),
            "GB"
        )

except Exception as e:
    print("⚠️ PyTorch todavía no está disponible.")
    print("Motivo:", e)
PY

echo ""

# ------------------------------------------------------------
# 4. Buscar ComfyUI
# ------------------------------------------------------------

echo "[4/5] Buscando ComfyUI..."

COMFYUI=""

POSSIBLE_PATHS=(
    "/workspace/ComfyUI"
    "/workspace/SwarmUI/dlbackend/ComfyUI"
    "/opt/ComfyUI"
    "/root/ComfyUI"
    "/ComfyUI"
)

for PATH_TO_CHECK in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$PATH_TO_CHECK/main.py" ]; then
        COMFYUI="$PATH_TO_CHECK"
        break
    fi
done

if [ -n "$COMFYUI" ]; then
    echo "✅ ComfyUI encontrado:"
    echo "$COMFYUI"
else
    echo "⚠️ ComfyUI no encontrado en las rutas conocidas."
fi

echo ""

# ------------------------------------------------------------
# 5. Resumen
# ------------------------------------------------------------

echo "[5/5] Resumen"
echo ""

echo "------------------------------------------------------------"
echo "Python : $PYTHON"
echo "ComfyUI: ${COMFYUI:-NO ENCONTRADO}"
echo "------------------------------------------------------------"

echo ""
echo "============================================================"
echo "   Provisioning V1 completado"
echo "============================================================"
echo ""
