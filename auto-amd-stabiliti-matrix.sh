#!/bin/bash

# Kiểm tra quyền Root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Vui lòng chạy script này với quyền sudo (sudo ./mi50_utility_menu.sh)"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$REAL_USER)
ROCM_VERSION="6.2.4"
ROCM_REPO_VER="6.2"

# Hàm hỏi ý kiến restart sau khi gỡ
prompt_restart() {
    echo ""
    read -p "Bạn có muốn khởi động lại máy (reboot) ngay bây giờ không để hoàn tất việc dọn dẹp? (y/n): " reboot_ans
    if [[ "$reboot_ans" =~ ^[Yy]$ ]]; then
        echo "[+] Đang khởi động lại hệ thống..."
        reboot
    fi
}

# Hàm gỡ riêng Stability Matrix
uninstall_stability() {
    echo "===================================================="
    echo "         GỠ CÀI ĐẶT STABILITY MATRIX                "
    echo "===================================================="
    SM_DIR="$USER_HOME/StabilityMatrix"
    if [ -d "$SM_DIR" ]; then
        rm -rf "$SM_DIR"
        echo "[+] Đã xóa thư mục Stability Matrix thành công ($SM_DIR)!"
    else
        echo "[!] Không tìm thấy thư mục Stability Matrix trên hệ thống."
    fi
}

# Hàm gỡ sạch driver AMD/ROCm (DDU style)
uninstall_driver() {
    echo "===================================================="
    echo "       GỠ CÀI ĐẶT DRIVER & ROCM (CLEAN DDU)         "
    echo "===================================================="
    
    if command -v amdgpu-install &> /dev/null; then
        amdgpu-install --uninstall -y || true
    fi
    
    apt purge -y '*amdgpu*' '*rocm*' '*hip*' '*heterogeneous*' || true
    apt autoremove --purge -y
    apt clean
    
    # Xóa biến môi trường trick trong .bashrc nếu có
    PROFILE_FILE="$USER_HOME/.bashrc"
    if grep -q "HSA_OVERRIDE_GFX_VERSION" "$PROFILE_FILE"; then
        sed -i '/# AMD MI50/d' "$PROFILE_FILE"
        sed -i '/HSA_OVERRIDE_GFX_VERSION/d' "$PROFILE_FILE"
        sed -i '/ROCM_PATH/d' "$PROFILE_FILE"
        echo "[+] Đã dọn dẹp các biến môi trường cấu hình trong .bashrc."
    fi
    
    echo "[+] Đã gỡ sạch sẽ toàn bộ Driver và ROCm khỏi hệ thống!"
}

# Hàm menu Gỡ cài đặt tùy chọn
uninstall_menu() {
    while true; do
        clear
        echo "===================================================="
        echo "               MENU GỠ CÀI ĐẶT                      "
        echo "===================================================="
        echo "1. Chỉ gỡ Stability Matrix"
        echo "2. Chỉ gỡ Driver & ROCm"
        echo "3. Gỡ cài đặt tất cả (Khôi phục như chưa cài gì)"
        echo "4. Quay lại Menu chính"
        echo "===================================================="
        read -p "Nhập lựa chọn của bạn (1-4): " un_choice

        case $un_choice in
            1)
                uninstall_stability
                prompt_restart
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            2)
                uninstall_driver
                prompt_restart
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            3)
                echo "[!] CẢNH BÁO: Thao tác này sẽ xóa toàn bộ Stability Matrix và Driver/ROCm!"
                read -p "Bạn có chắc chắn muốn khôi phục hoàn toàn không? (y/n): " confirm_all
                if [[ "$confirm_all" =~ ^[Yy]$ ]]; then
                    uninstall_stability
                    uninstall_driver
                    echo "===================================================="
                    echo "[+] Hệ thống đã được khôi phục về trạng thái ban đầu!"
                    echo "===================================================="
                    prompt_restart
                fi
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            4)
                break
                ;;
            *)
                echo "Lựa chọn không hợp lệ!"
                sleep 1
                ;;
        esac
    done
}

# Hàm cài driver mới kèm ROCm
install_driver_menu() {
    echo "===================================================="
    echo "            1. CÀI ĐẶT DRIVER & ROCM                "
    echo "===================================================="
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_VERSION=$VERSION_ID
    else
        OS_VERSION="22.04"
    fi

    UBUNTU_CODENAME="jammy"
    if [[ "$OS_VERSION" > "22.04" ]]; then
        echo "[!] Phát hiện Ubuntu cao hơn 22.04 ($OS_VERSION)."
        read -p "Bạn có muốn áp dụng trick tương thích hệ thống (gfx906) không? (y/n): " trick_ans
        if [[ "$trick_ans" =~ ^[Yy]$ ]]; then
            UBUNTU_CODENAME="noble"
            PROFILE_FILE="$USER_HOME/.bashrc"
            if ! grep -q "HSA_OVERRIDE_GFX_VERSION" "$PROFILE_FILE"; then
                echo -e "\nexport HSA_OVERRIDE_GFX_VERSION=9.0.6" >> "$PROFILE_FILE"
                echo "export ROCM_PATH=/opt/rocm" >> "$PROFILE_FILE"
                echo "export PATH=\$ROCM_PATH/bin:\$PATH" >> "$PROFILE_FILE"
                chown $REAL_USER:$REAL_USER "$PROFILE_FILE"
            fi
        fi
    fi

    # Gọi hàm gỡ sạch trước khi cài mới để tránh xung đột
    uninstall_driver

    echo "[+] Cập nhật hệ thống và cài đặt gói phụ thuộc..."
    apt update && apt install -y wget curl git build-essential python3-pip python3-venv libgl1 libglib2.0-0 fuse libfuse2 pciutils

    echo "[+] Cấp quyền phần cứng cho user: $REAL_USER..."
    usermod -aG render,video $REAL_USER

    echo "[+] Đang tải và cài đặt AMDGPU-Install (ROCm $ROCM_VERSION)..."
    cd /tmp
    wget -nc https://repo.radeon.com/amdgpu-install/$ROCM_REPO_VER/ubuntu/$UBUNTU_CODENAME/amdgpu-install_${ROCM_VERSION}-60404-1_all.deb
    apt install -y ./amdgpu-install_${ROCM_VERSION}-60404-1_all.deb

    echo "[+] Tiến hành cài đặt driver với cờ --unsupported-gpu..."
    amdgpu-install --use-dkms --iva --unsupported-gpu --accept-eula -y

    echo "===================================================="
    echo "             CÀI ĐẶT DRIVER HOÀN TẤT!               "
    echo "===================================================="
    
    read -p "Bạn có muốn khởi động lại máy (reboot) ngay bây giờ không? (y/n): " reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        echo "[+] Đang khởi động lại hệ thống..."
        reboot
    fi
}

# Hàm kiểm tra GPU và trạng thái ROCm
check_gpu_rocm() {
    echo "===================================================="
    echo "          2. KIỂM TRA GPU & TRẠNG THÁI ROCM         "
    echo "===================================================="
    
    echo "[+] Thiết bị hiển thị (PCIe):"
    lspci -nn | grep -iE 'vga|3d|display'
    echo ""

    echo "[+] Trạng thái Module Kernel (amdgpu):"
    if lsmod | grep -q amdgpu; then
        echo "    -> Driver amdgpu đang chạy bình thường."
    else
        echo "    -> [!] Module amdgpu chưa tải (Có thể cần khởi động lại máy)."
    fi
    echo ""

    echo "[+] Thông tin chi tiết qua rocminfo:"
    if command -v rocminfo &> /dev/null; then
        rocminfo | grep -E "Name:|Marketing Name:" || echo "    -> Không tìm thấy thiết bị qua rocminfo."
    else
        echo "    -> Lệnh 'rocminfo' chưa khả dụng hoặc chưa khởi động lại máy."
    fi
    echo ""

    echo "[+] Trạng thái quản lý xung nhịp/nhiệt độ (rocm-smi):"
    if command -v rocm-smi &> /dev/null; then
        rocm-smi || echo "    -> Không thể đọc thông số rocm-smi."
    else
        echo "    -> Lệnh 'rocm-smi' chưa khả dụng."
    fi
    echo "===================================================="
    read -p "Nhấn Enter để quay lại menu chính..."
}

# Hàm cài đặt Stability Matrix
install_stability_matrix() {
    echo "===================================================="
    echo "          3. TIẾN HÀNH CÀI STABILITY MATRIX         "
    echo "===================================================="
    
    SM_DIR="$USER_HOME/StabilityMatrix"
    mkdir -p "$SM_DIR"

    echo "[+] Đang tải Stability Matrix AppImage mới nhất..."
    SM_URL=$(curl -s https://api.github.com/repos/LykosAI/StabilityMatrix/releases/latest | grep "browser_download_url" | grep "AppImage" | cut -d '"' -f 4)
    
    if [ -z "$SM_URL" ]; then
        SM_URL="https://github.com/LykosAI/StabilityMatrix/releases/download/v2.5.4/StabilityMatrix-linux-x64.AppImage"
    fi

    wget -O "$SM_DIR/StabilityMatrix.AppImage" "$SM_URL"
    chmod +x "$SM_DIR/StabilityMatrix.AppImage"
    chown -R $REAL_USER:$REAL_USER "$SM_DIR"

    echo "[+] Cài đặt thành công!"
    echo "[+] File chạy được đặt tại: $SM_DIR/StabilityMatrix.AppImage"
    echo "===================================================="
    read -p "Nhấn Enter để quay lại menu chính..."
}

# Vòng lặp Menu chính
while true; do
    clear
    echo "===================================================="
    echo "       AMD MI50 & STABILITY MATRIX UTILITY MENU     "
    echo "===================================================="
    echo "1. Cài đặt Driver (Clean DDU cũ + Cài ROCm mới)"
    echo "2. Kiểm tra GPU & Trạng thái ROCm"
    echo "3. Tiến hành cài Stability Matrix"
    echo "4. Gỡ cài đặt (Tùy chọn: Stability / Driver / Tất cả)"
    echo "5. Thoát chương trình"
    echo "===================================================="
    read -p "Nhập lựa chọn của bạn (1-5): " choice

    case $choice in
        1)
            install_driver_menu
            ;;
        2)
            check_gpu_rocm
            ;;
        3)
            install_stability_matrix
            ;;
        4)
            uninstall_menu
            ;;
        5)
            echo "Thoát chương trình. Tạm biệt!"
            exit 0
            ;;
        *)
            echo "Lựa chọn không hợp lệ! Vui lòng chọn từ 1 đến 5."
            sleep 2
            ;;
    esac
done