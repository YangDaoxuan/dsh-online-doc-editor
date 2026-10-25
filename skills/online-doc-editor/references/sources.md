# 来源与改写说明

核对日期：2026-10-25。以下为原作者或官方资料；本 skill 是针对当前任务重新编写的指令，不附带原项目脚本。线上 main 和文档会变化，运行时以实际安装版本为准。本地历史只用于补充故障场景。

| 来源 | 对本 skill 的影响 |
|---|---|
| [Agent Skills 规范](https://agentskills.io/specification) | 使用标准名称、描述和按需参考文件 |
| [Agent Skills 编写建议](https://agentskills.io/skill-creation/best-practices) | 将可核验的前置条件与完成条件写清，复杂操作先核对计划 |
| [Agent Skills 评估](https://agentskills.io/skill-creation/evaluating-skills) | 用相同任务对比旧版／无 skill 与新版的结果和执行成本 |
| [Anthropic doc-coauthoring](https://github.com/anthropics/skills/blob/main/skills/doc-coauthoring/SKILL.md) | 理解背景、调整结构和读者检查；省去不适合已授权编辑的多轮提问 |
| [Anthropic docx](https://github.com/anthropics/skills/blob/main/skills/docx/SKILL.md) | 参考段落、标题、修订的结构意识；不移植本地 XML 工作流及专有许可脚本 |
| [Google 技术写作语气指南](https://developers.google.com/style/tone) | 参考清楚、直接、少套话的表达；正式中文文体由实际模板决定 |
| [Playwright 输入操作](https://playwright.dev/docs/input)与[操作前检查](https://playwright.dev/docs/actionability) | 先确认目标再操作，区分原生输入与 DOM 事件；不把表单填充泛化为文档编辑 |
| [Playwright MCP 快照说明](https://github.com/microsoft/playwright.dev/blob/main/mcp/snapshots.mdx) | 重视当前观察、局部读取和失效引用，不把快照当全部正文 |
| [DSH skills](https://deepseek-harness.github.io/deepseek-harness/en/reference/subsystems/skills) | 按 DSH 的目录、加载方式和当前工具使用技能 |
| [BrowserSkill DSH 插件](https://github.com/Tencent/BrowserSkill/blob/main/packages/dsh-plugin-browserskill/README.md) | 参考其会话归属与状态同步思路；没有把该插件设为本 skill 的必需依赖 |
| [WPS SDK 内容填充](https://open.wps.cn/documents/app-integration-dev/docs-center/online-preview-edit/demo/word/content-fill)与[接入说明](https://open.wps.cn/documents/app-integration-dev/docs-center/online-preview-edit/callback/summary) | 明确 SDK 接入与消费者分享页的差别，不猜测可用接口 |

事实边界：当前插件工具限制来自本地 0.4.15 的源码与 schema。第三方项目说明不构成本机安装、兼容或金山文档编辑成功的证明。独立 BrowserSkill skill 文件本轮未能读取，因此参考仅限其插件文档。
