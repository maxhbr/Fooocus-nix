#!/bin/sh

. $(dirname "$(readlink -f "$0")")/../venv/bin/activate

pip install insightface==0.7.3 gfpgan==1.3.8 --require-virtualenv

cat <<EOF
pip done...


Now add this to settings/powerup.json

  "Faceswap": {
    "type": "faceswap"
  }

Download models to models/faceswap/
https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth
...and inswapper_128.onnx from where you can find it
EOF
