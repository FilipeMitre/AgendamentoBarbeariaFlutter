Write-Host "Iniciando ambiente de desenvolvimento..." -ForegroundColor Green

# Iniciar API em processo separado
Write-Host "Iniciando API..." -ForegroundColor Yellow
$apiProcess = Start-Process -FilePath "node" -ArgumentList "server.js" -WorkingDirectory ".\api" -PassThru -WindowStyle Normal

# Aguardar um pouco para API inicializar
Start-Sleep -Seconds 3

# Verificar se API está rodando
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/test" -TimeoutSec 5
    Write-Host "API iniciada com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "Aviso: API pode não ter iniciado completamente" -ForegroundColor Yellow
}

# Iniciar Flutter
Write-Host "Iniciando Flutter..." -ForegroundColor Yellow
flutter run -d chrome

# Cleanup quando Flutter terminar
Write-Host "Finalizando API..." -ForegroundColor Red
Stop-Process -Id $apiProcess.Id -Force -ErrorAction SilentlyContinue