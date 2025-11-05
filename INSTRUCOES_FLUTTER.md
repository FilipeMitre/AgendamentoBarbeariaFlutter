# Instruções para Instalar e Executar o Flutter

## Problemas Corrigidos
✅ **Erro de sintaxe no `carteira_screen.dart`** - Corrigido a estrutura da classe `_CarteiraScreenState`
✅ **Suporte web adicionado** - Criados os arquivos necessários na pasta `web/`

## 1. Instalar o Flutter

### Opção 1: Download Manual
1. Acesse: https://docs.flutter.dev/get-started/install/windows
2. Baixe o Flutter SDK
3. Extraia para `C:\flutter`
4. Adicione `C:\flutter\bin` ao PATH do sistema

### Opção 2: Via Chocolatey (Recomendado)
```cmd
# Instalar Chocolatey primeiro (se não tiver)
# Execute como Administrador no PowerShell:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar Flutter
choco install flutter
```

## 2. Verificar Instalação
```cmd
flutter doctor
```

## 3. Instalar Dependências do Projeto
```cmd
cd "C:\Users\acbar\OneDrive\Área de Trabalho\AgendamentoBarbeariaFlutter-master"
flutter pub get
```

## 4. Executar o Projeto

### Para Web (Chrome):
```cmd
flutter run -d chrome
```

### Para Windows Desktop:
```cmd
flutter run -d windows
```

### Para Android (se tiver emulador):
```cmd
flutter run -d android
```

## 5. Verificar Dispositivos Disponíveis
```cmd
flutter devices
```

## Estrutura de Arquivos Web Criada
```
web/
├── index.html          # Página principal
├── manifest.json       # Configurações PWA
├── favicon.png         # Ícone (placeholder)
└── icons/              # Pasta para ícones
```

## Próximos Passos
1. Instale o Flutter seguindo as instruções acima
2. Execute `flutter pub get` para instalar dependências
3. Execute `flutter run -d chrome` para testar no navegador
4. Se necessário, substitua o `favicon.png` por um ícone real da aplicação

## Observações
- O projeto agora tem suporte completo para web
- Todos os erros de sintaxe foram corrigidos
- A API backend deve estar rodando na porta 3000 para funcionar completamente