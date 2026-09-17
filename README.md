# 🚀 AMD-GPU-Stability-Matrix-AIO

<p align="center">
  <a href="README.md"><strong>🇺🇸 English (Current)</strong></a> &nbsp;|&nbsp; 
  <a href="README_VI.md"><strong>🇻🇳 Xem bản Tiếng Việt</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OS-Ubuntu_22.04_|_24.04-E95420?logo=ubuntu&logoColor=white" alt="Ubuntu" />
  <img src="https://img.shields.io/badge/ROCm-6.2.4-red" alt="ROCm 6.2.4" />
  <img src="https://img.shields.io/badge/GPU-AMD_Instinct_MI50_|_Vega20_|_Radeon-blue?logo=amd&logoColor=white" alt="AMD GPU" />
  <img src="https://img.shields.io/badge/Tool-Stability_Matrix-purple" alt="Stability Matrix" />
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" />
</p>

<p align="center">
  <b>An All-In-One (AIO) automated bash toolkit for installing AMDGPU drivers, ROCm 6.2+, optimizing GFX906 architecture compatibility, and deploying Stability Matrix on Ubuntu. Optimized and tested on AMD Radeon Instinct MI50 16GB.</b>
</p>

---

## 📖 Overview

Deploying generative AI tools (Stable Diffusion WebUI, ComfyUI, Fooocus, InvokeAI) on AMD GPUs—especially server-grade compute accelerators like the **AMD Instinct MI50 16GB** (Vega 20 architecture / `gfx906`)—often encounters steep hurdles on Linux:
- Old driver remnants leading to broken DKMS kernel modules or display blackouts.
- Missing architecture override variables (`HSA_OVERRIDE_GFX_VERSION=9.0.6`) causing PyTorch / ROCm to fail GPU detection.
- Requiring the `--unsupported-gpu` installer flag for enterprise/datacenter cards.
- Permission issues accessing hardware devices (`render`, `video`) or missing FUSE libraries for AppImage execution.

**AMD-GPU-Stability-Matrix-AIO** streamlines this entire workflow into an interactive, automated terminal menu.

---

## ✨ Key Features

- 🧹 **Clean DDU-Style Purge**: Fully uninstalls legacy AMD drivers, ROCm packages, HIP libraries, and purges environment configurations in `.bashrc` before fresh installation.
- ⚙️ **Automated ROCm 6.2.4 & AMDGPU Setup**: Detects your Ubuntu release (22.04 Jammy / 24.04 Noble) and installs driver packages with `--use-dkms`, `--iva`, and `--unsupported-gpu`.
- 🧠 **GFX906 Architecture Patching**: Automatically exports necessary environment variables in `~/.bashrc`:
  ```bash
  export HSA_OVERRIDE_GFX_VERSION=9.0.6
  export ROCM_PATH=/opt/rocm
  export PATH=$ROCM_PATH/bin:$PATH
  ```
- 📦 **Stability Matrix Automated Deployment**: Fetches the latest AppImage release from [LykosAI/StabilityMatrix](https://github.com/LykosAI/StabilityMatrix), applies execute permissions, and sets appropriate user ownership.
- 🔍 **Hardware & ROCm Diagnostics**: Quick status checks for PCIe device detection (`lspci`), kernel module loading (`amdgpu`), device properties (`rocminfo`), and clock/VRAM/power/temperature monitoring via `rocm-smi`.
- 🗑️ **Flexible Uninstallation**: Easily remove just Stability Matrix, just drivers, or restore your entire system to pristine state.

---

## ⚡ Quick Start

### Run Directly via 1-Line Command

```bash
curl -sSL https://raw.githubusercontent.com/kingbone2006/AMD-GPU-Stability-Matrix-AIO/main/auto-amd-stabiliti-matrix.sh -o auto-amd-stabiliti-matrix.sh && chmod +x auto-amd-stabiliti-matrix.sh && sudo ./auto-amd-stabiliti-matrix.sh
```

---

## 🖥️ Usage Workflow

Launch the script with root permissions to open the interactive menu:

```text
====================================================
       AMD MI50 & STABILITY MATRIX UTILITY MENU     
====================================================
1. Install Driver (Clean DDU legacy + Install ROCm)
2. Verify GPU & ROCm Status
3. Install Stability Matrix
4. Uninstall Options (Stability / Drivers / All)
5. Exit
====================================================
```

### Step 1: Install Driver & ROCm (Option `1`)
- Run option `1`. The script purges old conflicting drivers, installs system dependencies (`fuse`, `libfuse2`, `python3-pip`, `pciutils`), grants user group access (`render`, `video`), and installs ROCm with `--unsupported-gpu`.
- Reboot the system when prompted.

### Step 2: Verify GPU Status (Option `2`)
- After reboot, re-run the script and select option `2` to confirm `amdgpu` driver module is loaded and `rocm-smi` reports the GPU.

### Step 3: Install Stability Matrix (Option `3`)
- Select option `3` to automatically download the latest `StabilityMatrix.AppImage` into `~/StabilityMatrix/`.

### Step 4: Launch Stability Matrix

> [!IMPORTANT]
> **DO NOT** run the AppImage using `sudo` (AppImage sandboxing will refuse root execution). Run as your normal user account:

```bash
~/StabilityMatrix/StabilityMatrix.AppImage
```

---

## 💡 Important Notes for AMD Instinct MI50

1. **Motherboard BIOS Settings**:
   - You **MUST enable Above 4G Decoding** and **Resizable BAR (ReBAR / Smart Access Memory)** in your motherboard BIOS.
2. **Forced Airflow Cooling**:
   - AMD Instinct MI50 is a passively-cooled enterprise server card. You must attach a high-static-pressure blower fan (e.g., 3D printed shroud) to maintain temperatures below 75°C.
3. **FUSE Libraries**:
   - Ubuntu 22.04 and 24.04 require `libfuse2` to run AppImage files. This is installed automatically by the script.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).
