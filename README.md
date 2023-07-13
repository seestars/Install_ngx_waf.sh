# 简介
一个适用于 军哥的LNMP一键安装包 的 ngx_waf 安装脚本，可在脚本运行后下载 ngx_waf 防火墙最新版（Current）并进行编译。

## 脚本运行流程
1. 该脚本首先会查找当前系统中的lnmp文件夹位置
2. 随后读取当前系统中的 Nginx 版本
3. 克隆 Ngx_waf 文件及其前置
4. 克隆 Modsecurity 文件并编译
5. 将 Ngx_waf 编译进 Nginx

### 限制
 * 该脚本仅限于 Debian/Ubuntu 系统使用，如需在其他系统使用   请自行修改脚本

 * 该脚本仅适用于 军哥的LNMP一键安装包

 * 该脚本仅会编译ngx_waf模块，请自行完善网站配置
> 或等待猴年马月后我再写一个脚本，或者看看我的[手工配置版](https://blog.qvq.one/archives/169/ "LNMP 安装 Current 版的 ngx_waf")🤪 

# Ⅳ 使用教程

**拉取安装**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/seestars/Install_ngx_waf.sh/main/Install_ngx_waf.sh)
```

或者

```bash
wget -N --no-check-certificate https://github.com/seestars/Install_ngx_waf.sh/releases/latest/download/Install_ngx_waf.sh && bash Install_ngx_waf.sh
```

