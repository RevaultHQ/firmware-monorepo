# VaultBase Firmware Monorepo

VaultBase 硬件的固件 monorepo，基于 Buildroot 构建，目标平台为 STM32MP2。

本仓库包含 BSP（板级支持）和 System（系统层），是产品固件的核心。App 层和 SE 固件位于独立仓库。

## 仓库职责划分

| 仓库 | 内容 | 开源状态 |
|------|------|---------|
| **本仓库** | Buildroot 构建系统、BSP（设备树、内核补丁、驱动）、系统层（核心服务、HAL、启动器） | 待定 |
| [firmware-apps](https://github.com/RevaultHQ/firmware-apps) | 用户态应用（设置等），通过 System SDK 与底层交互 | 开源 |
| [firmware-se](https://github.com/RevaultHQ/firmware-se) | Secure Element 固件，运行在独立安全芯片上 | 闭源 |

## 产品 SKU（一套代码，两套编译产物）

VaultBase 有两个硬件 SKU，共享同一套 MPU / SE / RAM / ROM / PMIC / 蓝牙，差异如下：

| 模块 | VaultBase Air | VaultBase Pro |
|------|--------------|---------------|
| 显示屏 | 4" LCD | 4.3" AMOLED |
| 摄像头 | A 型号 | B 型号 |
| 指纹识别 | 无 | 指纹模组 + 按键 |
| 电池 | ❌ | ✅ |

两个 SKU 共享同一套代码仓库，通过各自的 defconfig 分别构建，产出独立的固件镜像。每个 SKU 拥有专属的设备树、内核配置和软件包选择——Air 不包含指纹驱动和蓝牙协议栈，Pro 不包含 Air 专属的屏幕驱动，确保镜像精简且不含无关组件。

## 仓库结构

```
firmware-monorepo/
├── modules/                        # 第三方上游（Git Submodules）
│   ├── buildroot/                  #   Buildroot 构建系统 (bootlin/buildroot, st/2025.02.5)
│   └── buildroot-external-st/      #   ST 官方 Buildroot 扩展 (st/2025.02.5)
│
├── bsp/                            # 板级支持
│   ├── configs/                    #   Buildroot defconfig（air / pro）
│   ├── board/                      #   设备树、内核补丁、rootfs overlay、镜像布局
│   └── package/                    #   自定义驱动包（指纹、蓝牙、摄像头）
│
├── system/                         # 系统层
│   ├── services/                   #   核心系统服务（SE 通信、加密存储、OTA 等）
│   ├── framework/                  #   App SDK、HAL、App 运行时
│   └── ui/                         #   系统启动器（Qt）
│
├── Makefile                        # 顶层构建入口
├── .github/workflows/build.yml     # GitHub Actions CI
├── .gitmodules                     # Submodule 定义
└── .gitignore
```

## 构建

### 环境要求

- Linux x86_64 或 AArch64 主机
- 至少 25 GB 可用磁盘空间
- 基本构建工具：`build-essential`, `libncurses-dev`, `device-tree-compiler`, `dosfstools`, `mtools`

### 快速开始

```bash
# 克隆（含 submodules）
git clone --recurse-submodules https://github.com/RevaultHQ/firmware-monorepo.git
cd firmware-monorepo

# 构建
make build

# 构建产物位于
ls modules/buildroot/output/images/
```

### 烧录

构建完成后，使用 STM32CubeProgrammer 通过 USB DFU 烧录：

```bash
# 所需文件在 output/images/ 中：
# - flash_full.tsv                 — 烧录布局定义
# - tf-a-*-programmer-usb.stm32   — TF-A 引导
# - fip-*-programmer-usb.bin      — FIP 镜像
# - emmc_full.img                 — 完整 eMMC 镜像
```

### CI

GitHub Actions 自动构建，手动触发（`workflow_dispatch`）。构建使用三级缓存策略：

- **output 缓存**：缓存完整构建产物目录，利用 Buildroot stamp 机制实现增量构建
- **dl 缓存**：缓存源码下载包，跳过重复下载
- **ccache**：编译器缓存，加速 C/C++ 重编译

冷启动构建约 2 小时，增量构建（代码变更后）约 8-12 分钟。

## License

TBD
