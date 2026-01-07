# viogpu3d Builder

Build automation for the viogpu3d Windows virtio GPU driver with Mesa virgl support.

## What This Builds

1. **Mesa with virgl** - OpenGL (viogpu_wgl.dll) and Direct3D 10 (viogpu_d3d10.dll) user-mode drivers
2. **viogpu3d** - Windows kernel-mode driver for virtio-gpu

## Quick Start

### Option 1: GitHub Actions (Automated)

Fork this repository and builds run automatically on push. Download artifacts from the Actions tab.

### Option 2: Local Build (Windows)

1. **Setup environment** (run as Administrator):
   ```cmd
   scripts\setup-environment.bat
   ```

2. **Install Visual Studio** with "Desktop development with C++" workload

3. **Build** (run from Developer Command Prompt for VS):
   ```cmd
   scripts\build.bat
   ```

## Local Build Scripts

| Script | Purpose |
|--------|---------|
| `scripts\setup-environment.bat` | Install dependencies (Chocolatey, Python, meson, ninja, winflexbison) |
| `scripts\build.bat` | Full build (Mesa + driver) |
| `scripts\build-mesa-only.bat` | Build only Mesa virgl |
| `scripts\build-driver-only.bat` | Build only viogpu3d driver (requires Mesa built first) |

### Prerequisites

- Windows 10/11
- Visual Studio with C++ build tools
- Run setup script as Administrator for initial setup
- Run build scripts from "Developer Command Prompt for VS" or "x64 Native Tools Command Prompt"

### Build Output

After building, find outputs in `viogpu3d-build\`:
- `mesa_prefix\bin\` - Mesa DLLs (viogpu_wgl.dll, viogpu_d3d10.dll)
- `kvm-guest-drivers-windows\viogpu\` - Driver files

## GitHub Actions

### Automatic Builds
- Push to `main` or `master` branch
- Pull requests

### Manual Builds
Trigger from Actions tab with custom branches:
- `mesa_branch` - Mesa source branch (default: `viogpu_win`)
- `driver_branch` - KVM drivers branch (default: `viogpu_win`)

### Artifacts
- **mesa-dlls** - Mesa virgl DLLs
- **viogpu3d-driver** - Compiled driver files
- **full-build** - Complete viogpu build directory

## Build Configuration

Mesa is configured with:
```
-Dgallium-drivers=virgl      # virgl driver only
-Dgallium-d3d10umd=true      # D3D10 user-mode driver
-Dgallium-wgl-dll-name=viogpu_wgl
-Dgallium-d3d10-dll-name=viogpu_d3d10
-Db_vscrt=mt                 # static C runtime
```

## References

- [Mesa virgl](https://docs.mesa3d.org/drivers/virgl.html)
- [virtio-gpu specification](https://docs.oasis-open.org/virtio/virtio/v1.1/virtio-v1.1.html)
- [KVM Guest Drivers for Windows](https://github.com/virtio-win/kvm-guest-drivers-windows)
