New-PSDrive Code FileSystem /home/anselmschueler/Code/ | Out-Null

Set-PSReadLineOption -EditMode Windows

$PromptEndComponents = switch ($Env:USER) {
    "root" {@('╘','# ')}
    default {@('└','$ ')}
} # Array for final part of prompt, split for convenience

Set-PSReadLineOption -PromptText $PromptEndComponents[1] # Last element is the only one that should turn red on syntax error
Set-PSReadLineOption -ContinuationPrompt "| "
function prompt {
    $Success, $Code = $?, ($LASTEXITCODE ?? 0)
    $SuccessString = $Success ? "OK" : "!!"
    $SuccessColor = $Success ? [ConsoleColor]::Green : [ConsoleColor]::Red
    $CodeColor = $Code ? [ConsoleColor]::Red : [ConsoleColor]::Green
    $MiddleColor = # Turns red when either side is red
        [Bool]$Code -or (-not $Success) ? [ConsoleColor]::Red : [ConsoleColor]::Green
    $Time = Get-Date -Format "HH:mm:ss"
    
    Write-Host "┌[$Time] " -NoNewline
    Write-Host "[pwsh] " -ForegroundColor DarkGray -NoNewline
    Write-Host "$env:USER " -ForegroundColor Green -NoNewline
    Write-Host "$PWD " -ForegroundColor Green -NoNewline
    Write-Host "[$SuccessString" -ForegroundColor $SuccessColor -NoNewline
    Write-Host "/" -ForegroundColor $MiddleColor -NoNewline
    Write-Host "$Code]" -ForegroundColor $CodeColor

    Write-Output ($PromptEndComponents -join "")
}