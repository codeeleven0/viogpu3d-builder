# Patch viogpu3d driver source to fix build errors
# Run this after cloning kvm-guest-drivers-windows

param(
    [string]$DriverPath = "kvm-guest-drivers-windows"
)

$file = Join-Path $DriverPath "viogpu\viogpu3d\viogpu_adapter.cpp"

if (-not (Test-Path $file)) {
    Write-Error "File not found: $file"
    exit 1
}

$content = Get-Content $file -Raw

# Fix: Uninitialized variable 'vbuf'
$old = "PGPU_VBUFFER vbuf;"
$new = "PGPU_VBUFFER vbuf = { 0 };"

if ($content -match [regex]::Escape($old)) {
    $content = $content -replace [regex]::Escape($old), $new
    Set-Content $file $content -NoNewline
    Write-Host "Patched: $file"
    Write-Host "  Fixed uninitialized variable 'vbuf'"
} else {
    Write-Host "Patch not needed or already applied: $file"
}
