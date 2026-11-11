# Markdown PDF Plus themes

Cross-platform light and dark PDF export styling for VS Code and the **Markdown PDF Plus** extension. The repository includes two installer scripts:

- `linux-install.sh` — installs the themes for the current Linux user.
- `windows-install.ps1` — installs the themes for the current Windows user.

Both installers locate `pdf-light.css` and `pdf-dark.css` **within the same repository checkout as the installer**, including nested subdirectories. They do not depend on the checkout name, checkout path, or current working directory. Each CSS filename must occur exactly once in the repository.

## Install on Linux

### Step 1 — Change directory to the repository

Open a terminal and navigate to the folder where you cloned the repository. Replace the example path with your actual checkout location:

```bash
cd "$HOME/code/Markdown-PDF-Config"
```

### Step 2 — Update installer permissions

Make the installation script executable. **Do not use `sudo`**; the script installs themes only for your current user.

```bash
chmod +x ./linux-install.sh
```

### Step 3 — Execute the installer

```bash
./linux-install.sh
```

Alternatively, you can run the installer directly from any directory without changing permissions:

```bash
sh "$HOME/code/Markdown-PDF-Config/linux-install.sh"
```

The installer determines the repository location from its own path, so it works even if you clone the repository somewhere else. No administrator access is required.

## Install on Windows

### Step 1 — Change directory to the repository

Open **PowerShell** and navigate to the folder where you cloned the repository. Replace the example path if necessary:

```powershell
& {
    Set-Location 'C:\Users\csavugot\code\Markdown-PDF-Config'
}
```

### Step 2 — Check the installer file

Confirm that `windows-install.ps1` exists in the current repository directory:

```powershell
& {
    Get-Item -LiteralPath '.\windows-install.ps1'
}
```

**No `chmod` or administrator privileges are required on Windows.** The following command uses a process-scoped execution-policy override, without changing your user or system policy. Organization-enforced restrictions may still prevent execution.

### Step 3 — Execute the installer

```powershell
& {
    $Installer = (Resolve-Path -LiteralPath '.\windows-install.ps1').Path
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Installer
}
```

Alternatively, execute the script from any directory by providing its full path:

```powershell
& {
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\Users\csavugot\code\Markdown-PDF-Config\windows-install.ps1'
}
```

The Windows installer uses its own script location rather than the current directory to find the CSS files. No administrator privileges are required. If your organization enforces application-control or execution restrictions, follow its policy rather than modifying system-wide settings.

## Installation destination

Both systems use `~/.config/Code/markdown-themes/` as the theme directory:

```text
~/.config/Code/markdown-themes/
├── pdf-light.css
└── pdf-dark.css
```

On Windows, `~` refers to your Windows user profile (for example, `C:\Users\csavugot`). The installer deliberately uses this shared path **rather than** the default Windows `%APPDATA%\Code` settings location, so your `CSSPath` setting can remain identical across operating systems.

Re-running an installer skips identical files. If an installed theme has changed, the installer creates a timestamped `.bak-*` copy before replacing it. The installers do **not** modify your VS Code user settings or install extensions.

## Configure VS Code

Install the **Markdown PDF Plus** extension and open **Preferences: Open User Settings (JSON)**. Add these settings inside the existing settings object (without duplicating keys):

```jsonc
// ============================================================
// Markdown Formatting Settings — Windows + Linux
// ============================================================
"markdown-preview-github-styles.colorTheme": "auto",
"markdown.preview.scrollEditorWithPreview": false,
"markdown.preview.scrollPreviewWithEditor": true,
"markdown-pdf-plus.pageSize": "letter",
"markdown-pdf-plus.usePageStyleFromCSS": true,

// DARK — uncomment both lines to select
// "markdown-pdf-plus.CSSPath": "~/.config/Code/markdown-themes/pdf-dark.css",
// "markdown-pdf-plus.outputHome": "./pdfs/dark",

// LIGHT — comment both lines to select dark instead
"markdown-pdf-plus.CSSPath": "~/.config/Code/markdown-themes/pdf-light.css",
"markdown-pdf-plus.outputHome": "./pdfs/light",

// Leave empty to use the source Markdown basename automatically
"markdown-pdf-plus.outputFilename": "",
```

Keep **exactly one** `CSSPath` and one `outputHome` setting active. PDF exports are saved to the `pdfs/light` or `pdfs/dark` subdirectory relative to your Markdown document. Output filenames keep the Markdown document's basename; do not use `${fileBasenameNoExtension}` in `outputFilename`, because this extension treats it literally.

## Verify

1. Run the installer and confirm it reports both CSS files as **Installed** or **Unchanged**.
2. Confirm both files exist in `~/.config/Code/markdown-themes/`.
3. In VS Code, open a Markdown document and select **Markdown PDF Plus: Export PDF** from the Command Palette.
4. Check that the PDF appears in the expected `pdfs/light` or `pdfs/dark` folder and uses the selected colors.
5. Toggle the two active theme-specific settings to test the other theme.

## Mermaid diagram caveat

Markdown documents containing explicit Mermaid theme colors cannot reliably be rethemed using only the outer CSS. Where necessary, maintain theme-specific Mermaid diagrams or parameterize their theme settings. Earlier examples used `SAM_Overview_Proposal_Light.md` and `SAM_Overview_Proposal_Dark(1).md`.

The theme CSS may be scoped to `@media print` to avoid changing the GitHub-style Markdown preview. The final PDF can also depend on Markdown PDF Plus stylesheet ordering; if an override is ineffective, inspect the export and adjust selector specificity.
