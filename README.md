# 🚀 AMD-GPU-Stability-Matrix-AIO

<p align="center">
  <img src="https://img.shields.io/badge/OS-Ubuntu_22.04_|_24.04-E95420?logo=ubuntu&logoColor=white" alt="Ubuntu" />
  <img src="https://img.shields.io/badge/ROCm-6.2.4-red" alt="ROCm 6.2.4" />
  <img src="https://img.shields.io/badge/GPU-AMD_Instinct_MI50_|_Vega20_|_Radeon-blue?logo=amd&logoColor=white" alt="AMD GPU" />
  <img src="https://img.shields.io/badge/Tool-Stability_Matrix-purple" alt="Stability Matrix" />
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" />
</p>

<p align="center">
  <b>Bộ công cụ All-In-One (AIO) tự động hóa cài đặt Driver AMDGPU, ROCm 6.2+, tối ưu hóa kiến trúc GFX906 và triển khai Stability Matrix trên Ubuntu. Đã kiểm thử tối ưu và ổn định cho card tăng tốc đồ họa máy chủ AMD Radeon Instinct MI50 16GB.</b>
</p>

---

## 📖 Giới Thiệu (Overview)

Việc cài đặt và chạy các mô hình AI tạo ảnh (Stable Diffusion, ComfyUI, Fooocus, InvokeAI...) trên card đồ họa AMD (đặc biệt là các dòng card Data Center/Compute Accelerator như **AMD Instinct MI50 16GB** - kiến trúc Vega 20 / `gfx906`) trên Linux thường gặp rất nhiều rào cản:
- Xung đột driver cũ dẫn đến lỗi module kernel DKMS hoặc mất hiển thị.
- Thiếu các biến môi trường tương thích kiến trúc (`HSA_OVERRIDE_GFX_VERSION=9.0.6`) khiến PyTorch / ROCm không nhận diện GPU.
- Cờ cài đặt driver `--unsupported-gpu` bắt buộc phải có đối với các dòng card không thuộc danh mục phổ thông của AMD.
- Lỗi phân quyền truy cập phần cứng (`render`, `video`) hoặc lỗi FUSE khi chạy AppImage.

**AMD-GPU-Stability-Matrix-AIO** ra đời để giải quyết toàn bộ các vấn đề trên chỉ bằng một menu giao diện trực quan trong dòng lệnh, giúp bạn triển khai môi trường làm việc AI hoàn chỉnh chỉ trong vài phút.

---

## ✨ Tính Năng Nổi Bật (Key Features)

- 🧹 **Dọn dẹp sạch sẽ (Clean DDU Style)**: Tự động gỡ bỏ triệt để driver AMD cũ, các gói ROCm, HIP và dọn sạch biến môi trường trong `.bashrc` trước khi cài mới để ngăn chặn 100% nguy cơ xung đột.
- ⚙️ **Cài đặt ROCm 6.2.4 & AMDGPU Driver**: Tự động nhận diện bản phân phối Ubuntu (22.04 Jammy / 24.04 Noble), tải `amdgpu-install` chuẩn và thực thi cài đặt với các cờ tối ưu: `--use-dkms`, `--iva`, `--unsupported-gpu`.
- 🧠 **Tối ưu hóa kiến trúc GFX906**: Tự động cấu hình các biến môi trường cần thiết vào `~/.bashrc`:
  ```bash
  export HSA_OVERRIDE_GFX_VERSION=9.0.6
  export ROCM_PATH=/opt/rocm
  export PATH=$ROCM_PATH/bin:$PATH
  ```
- 📦 **Triển khai Stability Matrix tự động**: Tự động lấy bản phát hành AppImage mới nhất từ [LykosAI/StabilityMatrix](https://github.com/LykosAI/StabilityMatrix), cấp quyền thực thi `chmod +x` và gán quyền sở hữu đúng cho user thông thường (tránh lỗi sandbox AppImage khi chạy bằng quyền root).
- 🔍 **Công cụ chẩn đoán phần cứng (Diagnostics)**: Tích hợp menu kiểm tra nhanh thiết bị PCIe qua `lspci`, module kernel `amdgpu`, thông tin nhận diện `rocminfo` và theo dõi xung nhịp, VRAM, công suất, nhiệt độ qua `rocm-smi`.
- 🗑️ **Tùy chọn gỡ cài đặt linh hoạt (Uninstall Menu)**:
  - Chỉ gỡ Stability Matrix.
  - Chỉ gỡ Driver AMD & ROCm.
  - Khôi phục toàn bộ hệ thống về trạng thái ban đầu.

---

## ⚡ Cài Đặt Nhanh (Quick Start)

### 1. Chạy Trực Tiếp Bằng 1 Lệnh (One-Line Command)

Mở terminal trên Ubuntu và chạy lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/kingbone2006/AMD-GPU-Stability-Matrix-AIO/main/auto-amd-stabiliti-matrix.sh -o auto-amd-stabiliti-matrix.sh && chmod +x auto-amd-stabiliti-matrix.sh && sudo ./auto-amd-stabiliti-matrix.sh
```

---

### 2. Hoặc Clone Repository Về Máy

```bash
git clone https://github.com/kingbone2006/AMD-GPU-Stability-Matrix-AIO.git
cd AMD-GPU-Stability-Matrix-AIO
chmod +x auto-amd-stabiliti-matrix.sh
sudo ./auto-amd-stabiliti-matrix.sh
```

---

## 🖥️ Hướng Dẫn Sử Dụng Chi Tiết (Usage Workflow)

Khi khởi chạy script, menu giao diện sẽ hiển thị như sau:

```text
====================================================
       AMD MI50 & STABILITY MATRIX UTILITY MENU     
====================================================
1. Cài đặt Driver (Clean DDU cũ + Cài ROCm mới)
2. Kiểm tra GPU & Trạng thái ROCm
3. Tiến hành cài Stability Matrix
4. Gỡ cài đặt (Tùy chọn: Stability / Driver / Tất cả)
5. Thoát chương trình
====================================================
```

### 🔹 Bước 1: Cài đặt Driver & ROCm (Chọn `1`)
1. Script sẽ kiểm tra phiên bản Ubuntu, tự động gỡ sạch sẽ driver cũ nếu có.
2. Tải và cài đặt các gói phụ thuộc hệ thống (`wget`, `curl`, `git`, `python3-pip`, `fuse`, `libfuse2`, `pciutils`...).
3. Phân quyền tài khoản người dùng vào nhóm `render` và `video`.
4. Cài đặt driver AMDGPU kèm ROCm với cờ `--unsupported-gpu`.
5. Khi hoàn tất, hệ thống sẽ hỏi có muốn khởi động lại không -> Chọn `y` để **Reboot** máy.

### 🔹 Bước 2: Kiểm tra trạng thái GPU sau khi Reboot (Chọn `2`)
Sau khi máy khởi động lại, mở lại terminal và chạy lại script, chọn menu `2`:
- Kiểm tra xem thiết bị MI50 có xuất hiện trong danh sách PCIe không.
- Module kernel `amdgpu` đã load thành công chưa.
- Lệnh `rocminfo` và `rocm-smi` đã đọc được thông tin VRAM 16GB và nhiệt độ chưa.

### 🔹 Bước 3: Cài đặt Stability Matrix (Chọn `3`)
1. Script tự động tải bản `StabilityMatrix.AppImage` mới nhất về thư mục:
   ```text
   ~/StabilityMatrix/StabilityMatrix.AppImage
   ```
2. Phân quyền thực thi và quyền sở hữu cho tài khoản người dùng của bạn.

### 🔹 Bước 4: Khởi chạy Stability Matrix

> [!IMPORTANT]
> **TUYỆT ĐỐI KHÔNG** dùng quyền `sudo` để chạy AppImage (AppImage sẽ báo lỗi bảo mật sandbox và từ chối chạy dưới quyền root). Hãy chạy bằng tài khoản người dùng thông thường:

```bash
~/StabilityMatrix/StabilityMatrix.AppImage
```

*(Hoặc mở trình quản lý file trên màn hình Desktop, vào thư mục `StabilityMatrix` và nhấp đúp chuột vào file `StabilityMatrix.AppImage`)*.

---

## 💡 Lưu Ý Quan Trọng Cho AMD Radeon Instinct MI50

1. **Thiết lập BIOS Bo Mạch Chủ**:
   - Bắt buộc phải **BẬT (Enable)** tính năng **Above 4G Decoding** và **Resizable BAR (ReBAR / Smart Access Memory)** trong BIOS của bo mạch chủ. Nếu tắt ReBAR, driver ROCm sẽ không thể phân bổ bộ nhớ lớn của MI50 và gây crash.
2. **Hệ Thống Tản Nhiệt**:
   - AMD Instinct MI50 là card server tản nhiệt thụ động (Passive Cooling). Khi lắp trên máy bàn (Desktop), bắt buộc phải có quạt hút gió cưỡng bức (blower fan 3D print hoặc ống dẫn gió công suất cao) để giữ nhiệt độ dưới 75°C.
3. **Thư Viện FUSE**:
   - Trên Ubuntu 22.04 và 24.04, gói `libfuse2` là điều kiện cần để thực thi các file định dạng `.AppImage`. Script đã tích hợp tự động cài đặt sẵn gói này.

---

## 📁 Cấu Trúc Thư Mục (Project Structure)

```text
AMD-GPU-Stability-Matrix-AIO/
├── auto-amd-stabiliti-matrix.sh  # Script bash tương tác chính
├── README.md                     # Tài liệu hướng dẫn sử dụng chi tiết
├── LICENSE                       # Giấy phép mã nguồn mở MIT
└── .gitignore                    # Loại trừ các file rác / deb / log
```

---

## 🛠️ Xử Lý Sự Cố Thường Gặp (Troubleshooting)

| Hiện tượng / Lỗi | Nguyên nhân | Cách xử lý |
| :--- | :--- | :--- |
| `rocminfo: command not found` | Chưa nạp đường dẫn PATH hoặc chưa reboot | Khởi động lại máy hoặc chạy `source ~/.bashrc` |
| `Cannot open display / Fuse error` | Thiếu thư viện FUSE trên Ubuntu mới | Chạy lệnh `sudo apt install -y fuse libfuse2` |
| `Permission denied` khi truy cập GPU | User chưa thuộc nhóm `render` | Chạy `sudo usermod -aG render,video $USER` và đăng xuất đăng nhập lại |
| PyTorch báo `HIP error: invalid device ordinal` | Thiếu biến môi trường GFX | Kiểm tra file `~/.bashrc` đã có dòng `export HSA_OVERRIDE_GFX_VERSION=9.0.6` chưa |

---

## 📜 Giấy Phép (License)

Dự án này được phát hành dưới giấy phép mã nguồn mở [MIT License](LICENSE). Bạn được toàn quyền sử dụng, sửa đổi và chia sẻ tự do cho cộng đồng đam mê AI & AMD GPU.

---

<p align="center">
  Tạo bởi <a href="https://github.com/kingbone2006">kingbone2006</a>
</p>
