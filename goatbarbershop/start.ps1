Write-Host "Iniciando API e Flutter..." -ForegroundColor Green

# Inicia a API em uma nova janela
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; npm run dev"

# Aguarda 3 segundos para a API inicializar
Start-Sleep -Seconds 3

# Inicia o Flutter em uma nova janela
Start-Process powershell -ArgumentList "-NoExit", "-Command", "flutter run"

Write-Host "API e Flutter iniciados com sucesso!" -ForegroundColor Yellow