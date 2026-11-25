#!/usr/bin/env bash
# Build the web demo and copy it to deploy/ (Vercel serves deploy/).
# Run from prototype/. Keeps deploy/vercel.json.
set -euo pipefail
flutter build web --release --no-source-maps --pwa-strategy=none --no-web-resources-cdn
# Keep vercel.json, replace the rest.
find deploy -mindepth 1 ! -name vercel.json -delete
cp -r build/web/. deploy/
# Not used by the canvaskit renderer. Debug symbol files are never fetched.
rm -rf deploy/canvaskit/skwasm* deploy/canvaskit/*.symbols deploy/canvaskit/chromium/*.symbols
