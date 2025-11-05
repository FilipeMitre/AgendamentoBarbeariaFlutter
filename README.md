# AgendamentoBarbeariaFlutter (GoatBarber)

Resumo
App Flutter para agendamento em barbearias, alinhado ao design no Figma: GoatBarber.

Quickstart
1. Instale Flutter 3.10+ (Dart 3).
2. Clone o repo:
   git clone https://github.com/FilipeMitre/AgendamentoBarbeariaFlutter.git
3. Checkout da branch:
   git checkout feat/figma-restructure
4. Instale dependências:
   flutter pub get
5. Rodar:
   flutter run

Configuração de API
- Edite lib/utils/constants.dart e atualize AppConfig.baseUrl para apontar para sua API.

Assets do Figma
- As imagens enviadas foram adicionadas em assets/images/ (nomes com sufixo se necessário para evitar sobrescrita).

Estrutura
- lib/
  - main.dart
  - app.dart
  - models/, services/, providers/, screens/, widgets/, utils/
- db/schema.sql (schema MySQL e dados de exemplo)

Próximos passos
- Implementar telas do booking_flow conforme Figma.
- Integrar com API.
- Ajustar e validar estilos do Figma.
