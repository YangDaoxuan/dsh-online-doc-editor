# Online Doc Editor

A DSH Agent Skill for scoped online writing and formatting, revision preservation, targeting and readback checks. Preview version 0.1.0-rc.1, derived from tested 2.2-local instructions.

Download or clone https://github.com/YangDaoxuan/dsh-online-doc-editor first.

With PowerShell 7, run:

    pwsh -NoProfile -File ./install.ps1

Use -WhatIf to preview or -DshHome for a custom root. The manifest-checked installer refuses to overwrite different or modified skills. It installs no browser plugins and changes no account/model settings. Invoke /online-doc-editor in DSH with the scope and revision requirements.

Run ./uninstall.ps1 to remove an unchanged installer-managed copy; modified/manual directories are preserved. Automatic replacement upgrades are not implemented.

Tests:

    pwsh -NoProfile -File ./tests/test-install.ps1

Only Windows, DSH Desktop 0.2.1-rc.3 and Kdocs were tested. The [DSH Browser Plus fork](https://github.com/YangDaoxuan/dsh-browser-plus) is optional and separate. DOM evidence is not a verified document-model range. The eight behavior cases are specifications, not eight completed experiments. See the Chinese README and source references for details. MIT licensed.
