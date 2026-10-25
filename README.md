# Online Doc Editor

用于 DSH 在线文档写作、润色和格式修订的 Agent Skill。当前为预览版 0.1.0-rc.1，基于已实测的 2.2-local 整理。主体指令直接保留，只调整版本和本机专用称谓。

它帮助 agent 明确章节边界、按当前页面定位、保留修订、逐批回读并核验保存。包含写作、格式、金山文档和来源参考，以及8个评估规格，不提供账号登录、浏览器运行时或官方 WebOffice SDK 接入。

## 安装和使用

下载或克隆完整仓库，用 PowerShell 7 在仓库目录运行：

    pwsh -NoProfile -File ./install.ps1

默认安装到 DSH_HOME/skills/online-doc-editor；未设置 DSH_HOME 时使用用户目录的 .dsh/skills/online-doc-editor。预览或指定其他 DSH 根目录：

    pwsh -NoProfile -File ./install.ps1 -WhatIf
    pwsh -NoProfile -File ./install.ps1 -DshHome 'D:/MyDshHome'

安装器校验 skill-manifest.json。重复安装相同内容时不改文件，遇到不同版本、用户修改或链接目录时拒绝覆盖。本版不提供自动覆盖式升级；更新前请备份和比较。脚本只安装技能，不更改插件、模型或登录配置，也不接管已有手工安装。

在 DSH 调用 /online-doc-editor，说明文档、范围、参照和修订要求。例如：“只润色测试文档2.1节，保留引用和修订，格式参照2.3；每批检查正文和保存状态。”

卸载仅处理由此安装器安装且未修改的副本：

    pwsh -NoProfile -File ./uninstall.ps1 -WhatIf
    pwsh -NoProfile -File ./uninstall.ps1

存在修改、新增文件或缺少安装记录时保留目录。项目级安装也可以直接把 skills/online-doc-editor 复制到项目根的 .agents/skills。公开仓库：https://github.com/YangDaoxuan/dsh-online-doc-editor。下载或克隆仓库后执行上面的安装脚本。

## 能力和验证

单独的 [dsh-browser-plus](https://github.com/YangDaoxuan/dsh-browser-plus) 实验分支提供组合键、拖选、输入观察等增强。本 skill 不自动安装它，不假设新工具已存在。只安装 skill 不会生成浏览器工具。

已测环境为 Windows、DSH Desktop 0.2.1-rc.3 和金山文档，其他环境未验证。代理输入框和渲染文本不能单独证明真实正文选区；截图解析取决于实际模型和视觉工具。

    pwsh -NoProfile -File ./tests/test-install.ps1

安装器测试仅操作隔离目录。8个文档行为用例在 skills/online-doc-editor/evals/evals.json，是规格，不是全部已执行结果。来源与改写边界见 [sources.md](skills/online-doc-editor/references/sources.md)。本仓库不含真实文档、分享链接或聊天记录，采用 [MIT](LICENSE) 许可。
