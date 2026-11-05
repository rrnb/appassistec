class BicoCalibracao {
  int numero;
  String combustivel;
  double volumePadrao; // 20000 ml
  double leituraInicial; // ml (ex: +20, -10)
  double leituraFinal;   // ml
  double encerranteInicial;
  double encerranteFinal;
  bool conforme;
  String? fotoBase64;

  BicoCalibracao({
    required this.numero,
    this.combustivel = 'Gasolina Comum',
    this.volumePadrao = 20000.0,
    this.leituraInicial = 0.0,
    this.leituraFinal = 0.0,
    this.encerranteInicial = 0.0,
    this.encerranteFinal = 0.0,
    this.conforme = true,
    this.fotoBase64,
  });

  // Cálculo metrológico: Erro % = ((Leitura Final / Volume Padrão)) * 100
  // Tolerância legal Portaria Inmetro: +/- 100 ml (0.50% em 20L)
  double get erroPercentual {
    if (volumePadrao == 0) return 0.0;
    return (leituraFinal / volumePadrao) * 100;
  }

  bool get estaDentroTolerancia {
    return leituraFinal.abs() <= 100.0; // Até 100 ml para 20 litros
  }

  Map<String, dynamic> toJson() => {
    'numero': numero,
    'combustivel': combustivel,
    'volume_padrao': volumePadrao,
    'leitura_inicial': leituraInicial,
    'leitura_final': leituraFinal,
    'erro_percentual': erroPercentual,
    'encerrante_inicial': encerranteInicial,
    'encerrante_final': encerranteFinal,
    'conforme': conforme && estaDentroTolerancia,
    'foto': fotoBase64,
  };

  factory BicoCalibracao.fromJson(Map<String, dynamic> json) {
    return BicoCalibracao(
      numero: json['numero'] ?? 1,
      combustivel: json['combustivel'] ?? 'Gasolina Comum',
      volumePadrao: (json['volume_padrao'] as num?)?.toDouble() ?? 20000.0,
      leituraInicial: (json['leitura_inicial'] as num?)?.toDouble() ?? 0.0,
      leituraFinal: (json['leitura_final'] as num?)?.toDouble() ?? 0.0,
      encerranteInicial: (json['encerrante_inicial'] as num?)?.toDouble() ?? 0.0,
      encerranteFinal: (json['encerrante_final'] as num?)?.toDouble() ?? 0.0,
      conforme: json['conforme'] ?? true,
      fotoBase64: json['foto'],
    );
  }
}

class ChecklistData {
  int? id;
  int bombaId;
  int tecnicoId;
  String status;

  // SSMA Inicial
  bool epiCompleto;
  bool isolamentoArea;
  bool extintorDisponivel;
  bool aterramentoOk;
  bool bombaDesenergizada;

  // Instrumento de Aferição
  String instrumentoModelo;
  String instrumentoSerie;
  String certificadoCalibracao;

  // Bicos 1 a 6
  List<BicoCalibracao> bicos;

  // Ensaios Visuais
  bool lacresInviolados;
  bool encerranteVisivel;
  bool mangueirasSemVazamento;
  bool juntasSemFolga;
  bool bicosBomEstado;

  // Lacres de Selagem Aplicados
  String primeiroLacre;
  String segundoLacre;
  DateTime dataValidadeLacre;

  // SSMA Final
  bool areaLimpa;
  bool semIncidentes;

  // Assinatura & Observações
  String? assinaturaCliente;
  String nomeClienteAssinatura;
  String observacoes;

  ChecklistData({
    this.id,
    required this.bombaId,
    required this.tecnicoId,
    this.status = 'Sincronizado',
    this.epiCompleto = true,
    this.isolamentoArea = true,
    this.extintorDisponivel = true,
    this.aterramentoOk = true,
    this.bombaDesenergizada = true,
    this.instrumentoModelo = 'Medidor Padrão 20L',
    this.instrumentoSerie = 'MP-20-449',
    this.certificadoCalibracao = 'INMETRO-CAL-2026',
    List<BicoCalibracao>? bicos,
    this.lacresInviolados = true,
    this.encerranteVisivel = true,
    this.mangueirasSemVazamento = true,
    this.juntasSemFolga = true,
    this.bicosBomEstado = true,
    this.primeiroLacre = '',
    this.segundoLacre = '',
    DateTime? dataValidadeLacre,
    this.areaLimpa = true,
    this.semIncidentes = true,
    this.assinaturaCliente,
    this.nomeClienteAssinatura = '',
    this.observacoes = '',
  }) : bicos = bicos ?? [
         BicoCalibracao(numero: 1, combustivel: 'Gasolina Comum'),
         BicoCalibracao(numero: 2, combustivel: 'Gasolina Aditivada'),
         BicoCalibracao(numero: 3, combustivel: 'Etanol'),
         BicoCalibracao(numero: 4, combustivel: 'Diesel S-10'),
       ],
       dataValidadeLacre = dataValidadeLacre ?? DateTime.now().add(const Duration(days: 365));

  Map<String, dynamic> toPayload() {
    return {
      if (id != null && id! > 0) 'id': id,
      'bomba_id': bombaId,
      'tecnico_id': tecnicoId,
      'status': status,
      'dados': {
        'ssma_inicial': {
          'epi_completo': epiCompleto,
          'isolamento_area': isolamentoArea,
          'extintor_disponivel': extintorDisponivel,
          'aterramento_ok': aterramentoOk,
          'bomba_desenergizada': bombaDesenergizada,
        },
        'instrumento': {
          'modelo': instrumentoModelo,
          'serie': instrumentoSerie,
          'certificado': certificadoCalibracao,
        },
        'bicos': bicos.map((b) => b.toJson()).toList(),
        'ensaios_visuais': {
          'lacres_inviolados': lacresInviolados,
          'encerrante_visivel': encerranteVisivel,
          'mangueiras_sem_vazamento': mangueirasSemVazamento,
          'juntas_sem_folga': juntasSemFolga,
          'bicos_bom_estado': bicosBomEstado,
        },
        'lacres_aplicados': {
          'primeiro_lacre': primeiroLacre,
          'segundo_lacre': segundoLacre,
          'validade': dataValidadeLacre.toIso8601String().substring(0, 10),
        },
        'ssma_final': {
          'area_limpa': areaLimpa,
          'sem_incidentes': semIncidentes,
        },
        'assinatura': {
          'nome': nomeClienteAssinatura,
          'imagem_base64': assinaturaCliente,
        },
        'observacoes': observacoes,
      }
    };
  }
}
