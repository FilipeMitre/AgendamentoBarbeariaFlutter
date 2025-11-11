@echo off
echo Iniciando API e Flutter...

start "API Backend" cmd /k "cd backend && npm run dev"
start "Flutter App" cmd /k "flutter run"

echo Ambos os servicos foram iniciados!
pause