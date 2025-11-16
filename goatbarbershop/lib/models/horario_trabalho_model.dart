class HorarioTrabalhoModel {
  final int id;
  final int barbeiroId;
  final String diaSemana; // 'domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'
  final String horaInicio;
  final String horaFim;
  final bool ativo;

  HorarioTrabalhoModel({
    required this.id,
    required this.barbeiroId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
    required this.ativo,
  });

  factory HorarioTrabalhoModel.fromJson(Map<String, dynamic> json) {
    return HorarioTrabalhoModel(
      id: json['id'] ?? 0,
      barbeiroId: json['barbeiro_id'] ?? 0,
      diaSemana: json['dia_semana'] ?? 'segunda',
      horaInicio: json['hora_inicio'] ?? '09:00',
      horaFim: json['hora_fim'] ?? '18:00',
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbeiro_id': barbeiroId,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'ativo': ativo,
    };
  }

  // Converter nome do dia para índice (0-6)
  static int diaParaIndice(String dia) {
    const mapa = {
      'domingo': 0,
      'segunda': 1,
      'terca': 2,
      'quarta': 3,
      'quinta': 4,
      'sexta': 5,
      'sabado': 6,
    };
    return mapa[dia.toLowerCase()] ?? 1;
  }

  // Converter índice para nome do dia
  static String indiceparaDia(int indice) {
    const dias = ['domingo', 'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado'];
    if (indice >= 0 && indice < dias.length) {
      return dias[indice];
    }
    return 'segunda';
  }

  // Nomes dos dias da semana (formatado)
  static String nomeDia(String dia) {
    const nomes = {
      'domingo': 'Domingo',
      'segunda': 'Segunda',
      'terca': 'Terça',
      'quarta': 'Quarta',
      'quinta': 'Quinta',
      'sexta': 'Sexta',
      'sabado': 'Sábado',
    };
    return nomes[dia.toLowerCase()] ?? 'Desconhecido';
  }

  // Abreviação do dia da semana
  static String abreviacao(String dia) {
    const abrev = {
      'domingo': 'Dom',
      'segunda': 'Seg',
      'terca': 'Ter',
      'quarta': 'Qua',
      'quinta': 'Qui',
      'sexta': 'Sex',
      'sabado': 'Sab',
    };
    return abrev[dia.toLowerCase()] ?? '?';
  }
}
