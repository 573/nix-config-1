local on_wsl = vim.loop.os_uname().release:match 'WSL'

if on_wsl then
vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
        ["+"] = {'clip.exe'},
        ["*"] = {'clip.exe'},
    },
    paste = {
        ["+"] = {'powershell.exe', '-c', '[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'},
        ["*"] = {'powershell.exe', '-c', '[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'},
    },
    cache_enabled = false,
}
end
