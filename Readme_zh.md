此项目是用 Zig 语言编写 node-addon (n-api) 的一个样例工程，用最简单的示例来演示编写的流程。

项目目前仅支持在 Windows 系统下编译。

## 构建说明

### 环境准备

- Windows 10 或更新的操作系统
- Node.js 环境和 NPM（或其他 Node.js 包管理器）
- Zig 语言 v0.14.0

其他版本的 Zig 可能也能编译此项目。但由于 Zig 语言处于快速发展阶段，API 变动较为频繁，其他版本可能会存在潜在的问题。

### 构建步骤

```batch
rem 安装必要工具（也可使用 pnpm / yarn 等其他包管理器）
npm install -g node-gyp
node-gyp install

rem 执行构建和测试
.\build_and_test.cmd
```

如需自定义构建或测试流程，可以根据需要修改 `build_and_test.cmd` 文件。

## 许可协议

本项目采用 GNU 宽通用公共许可证（GNU Lesser General Public License，简称 LGPL）第 3 版授权。详细信息请查看 [LICENSE](./LICENSE) 文件。
