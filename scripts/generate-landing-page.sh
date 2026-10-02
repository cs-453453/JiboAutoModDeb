#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_DIR="${ROOT_DIR}/public"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-cs-453453/JiboAutoModDeb}"

mkdir -p "${PUBLIC_DIR}"

cat > "${PUBLIC_DIR}/index.html" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Jibo Auto-Mod apt Repository</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 980px; margin: 2rem auto; padding: 1rem; color: #222; background: #f6f7fb; }
    .card { background: white; border-radius: 12px; padding: 1.5rem; box-shadow: 0 6px 20px rgba(0,0,0,0.08); margin-bottom: 1.5rem; }
    h1, h2 { margin-bottom: 0.75rem; }
    pre, code { background: #111827; color: #f9fafb; padding: 0.75rem; border-radius: 8px; overflow-x: auto; }
    a { color: #2563eb; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .pill { display:inline-block; padding:0.3rem 0.7rem; border-radius:999px; background:#dbeafe; color:#1e3a8a; font-weight:700; font-size:0.82rem; margin-right:0.5rem; }
    ul { margin-left: 1.2rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Jibo Auto-Mod apt Repository</h1>
    <p><span class="pill">stable</span><span class="pill">amd64</span><span class="pill">daily sync</span></p>
    <p>This repository publishes a Debian package for Jibo Auto-Mod and refreshes it from the upstream source every day.</p>
  </div>

  <div class="card">
    <h2>Install</h2>
    <pre>echo "deb [arch=amd64] https://YOUR_GITHUB_USERNAME.github.io/JiboAutoModDeb stable main" | sudo tee /etc/apt/sources.list.d/jibo-automod.list
sudo apt update
sudo apt install jibo-automod</pre>
    <p>If you use a signed repo:</p>
    <pre>curl -fsSL https://YOUR_GITHUB_USERNAME.github.io/JiboAutoModDeb/keys/jibo-automod.asc | sudo gpg --dearmor -o /usr/share/keyrings/jibo-automod.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/jibo-automod.gpg] https://YOUR_GITHUB_USERNAME.github.io/JiboAutoModDeb stable main" | sudo tee /etc/apt/sources.list.d/jibo-automod.list</pre>
    <p>For source packages:</p>
    <pre>echo "deb-src [arch=amd64] https://YOUR_GITHUB_USERNAME.github.io/JiboAutoModDeb stable main" | sudo tee -a /etc/apt/sources.list.d/jibo-automod.list</pre>
  </div>

  <div class="card">
    <h2>Release history</h2>
    <p><a href="./releases.json">View releases.json</a></p>
    <p>Packages are versioned as <code>YYYYMMDD+gitsha</code>, for example <code>20261002+a1b2c3d</code>.</p>
  </div>

  <div class="card">
    <h2>What gets built</h2>
    <ul>
      <li>Current upstream source from <a href="https://github.com/Jibo-Revival-Group/JiboAutoMod">Jibo-Revival-Group/JiboAutoMod</a></li>
      <li>Debian package named <code>jibo-automod</code></li>
      <li>Binary package + source package metadata</li>
      <li>Generated apt repo metadata and release signing support</li>
    </ul>
  </div>

  <div class="card">
    <h2>Repository</h2>
    <p><a href="https://github.com/${GITHUB_REPOSITORY}">GitHub repo</a></p>
  </div>
</body>
</html>
HTML

echo "Landing page generated: ${PUBLIC_DIR}/index.html"
