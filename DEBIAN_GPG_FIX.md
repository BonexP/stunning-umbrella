# 解决 Debian Testing GPG 密钥问题

如果你在 Code Space 中遇到类似以下的 GPG 密钥错误：

```
NO_PUBKEY 6ED0E7B82643E131 NO_PUBKEY 78DBA3BC47EF2265
The repository 'http://deb.debian.org/debian testing InRelease' is not signed.
```

## 问题原因

这个问题是由于 Debian testing 存储库的 GPG 公钥缺失导致的。系统无法验证软件包的签名，因此拒绝更新或安装软件包。

## 解决方案

### 方案 1: 自动修复脚本

使用我们提供的自动安装脚本：

```bash
# 下载并运行自动安装脚本
chmod +x install_pandoc.sh
./install_pandoc.sh
```

### 方案 2: 手动修复 GPG 密钥

```bash
#!/bin/bash
# 手动添加缺失的 GPG 密钥

echo "正在修复 Debian GPG 密钥..."

# 添加 Debian 存档密钥
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 78DBA3BC47EF2265

# 添加 Debian 安全更新密钥
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BDE6D2B9216EC7A8
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8E9F831205B4BA95

echo "密钥添加完成，正在更新软件包列表..."
sudo apt update

echo "尝试安装 Pandoc..."
sudo apt install -y pandoc

# 验证安装
pandoc --version
```

### 方案 3: 使用不同的密钥服务器

如果默认密钥服务器不工作，尝试其他服务器：

```bash
# 尝试不同的密钥服务器
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 6ED0E7B82643E131
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 6ED0E7B82643E131
sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-keys 6ED0E7B82643E131
```

### 方案 4: 绕过 APT，直接下载安装

如果 APT 完全不工作，可以直接下载 Pandoc：

```bash
# 下载最新的 Pandoc 二进制文件
PANDOC_VERSION="3.1.11.1"
wget https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz

# 解压和安装
tar xvzf pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz
sudo cp pandoc-${PANDOC_VERSION}/bin/pandoc /usr/local/bin/
sudo chmod +x /usr/local/bin/pandoc

# 清理下载文件
rm -rf pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz pandoc-${PANDOC_VERSION}/

# 验证安装
pandoc --version
```

## 常见的密钥 ID

以下是一些常见的 Debian 密钥 ID，你可能需要添加：

| 密钥 ID | 用途 |
|---------|------|
| 6ED0E7B82643E131 | Debian Archive Automatic Signing Key |
| 78DBA3BC47EF2265 | Debian Archive Automatic Signing Key |
| BDE6D2B9216EC7A8 | Debian Security Archive Automatic Signing Key |
| 8E9F831205B4BA95 | Debian Security Archive Automatic Signing Key |

## 预防措施

为了避免将来出现类似问题：

1. **定期更新系统**：
   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. **备份工作环境**：使用 Docker 或容器来保存工作环境

3. **使用稳定版**：考虑使用 Debian stable 而不是 testing

## 如果问题持续存在

如果上述方法都不工作：

1. **检查网络连接**：确保可以访问外部服务器
2. **检查防火墙设置**：某些企业防火墙可能阻止密钥服务器
3. **使用代理**：如果需要代理访问互联网
4. **联系系统管理员**：在受限环境中可能需要管理员权限

## 验证修复

修复完成后，运行以下命令验证：

```bash
# 检查 APT 是否正常工作
sudo apt update

# 检查 Pandoc 是否安装成功
pandoc --version

# 测试基本功能
echo "# 测试" | pandoc -f markdown -t html
```

如果看到 HTML 输出，说明 Pandoc 安装成功！