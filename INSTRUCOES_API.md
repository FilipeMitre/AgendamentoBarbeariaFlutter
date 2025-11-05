# Como configurar a API

## 1. Instalar Node.js
- Baixe e instale o Node.js de: https://nodejs.org/
- Versão recomendada: LTS (Long Term Support)

## 2. Instalar dependências
Abra o terminal na pasta `api` e execute:
```bash
npm install
```

## 3. Iniciar o servidor
```bash
npm start
```

## 4. Testar a API
Acesse: http://localhost:3000/api/test

## 5. Problemas resolvidos
✅ **Carteira inicia com R$ 0,00**
✅ **Créditos funcionam localmente (SharedPreferences)**
✅ **Agendamentos debitam corretamente**
✅ **API para persistência permanente**

## Como funciona agora:
1. **Sem API**: Usa SharedPreferences (dados locais)
2. **Com API**: Sincroniza com banco SQLite + backup local
3. **Dados persistem** mesmo saindo e voltando ao app

## Para usar a API:
1. Instale Node.js
2. Execute `npm install` na pasta api
3. Execute `npm start`
4. A API estará em http://localhost:3000