class ItemOrdemServico {
  int? id;
  int produtoId;
  String codigo;
  String descricao;
  int quantidade;
  double valorUnitario;

  ItemOrdemServico({
    this.id,
    required this.produtoId,
    required this.codigo,
    required this.descricao,
    this.quantidade = 1,
    this.valorUnitario = 0.0,
  });

  double get subtotal => quantidade * valorUnitario;

  Map<String, dynamic> toJson() => {
    'produto_id': produtoId,
    'codigo': codigo,
    'descricao': descricao,
    'quantidade': quantidade,
    'valor_unitario': valorUnitario,
    'subtotal': subtotal,
  };

  factory ItemOrdemServico.fromJson(Map<String, dynamic> json) {
    return ItemOrdemServico(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      produtoId: json['produto_id'] is int ? json['produto_id'] : int.tryParse(json['produto_id']?.toString() ?? '0') ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      descricao: json['descricao'] ?? '',
      quantidade: json['quantidade'] is int ? json['quantidade'] : int.tryParse(json['quantidade']?.toString() ?? '1') ?? 1,
      valorUnitario: (json['valor_unitario'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrdemServico {
  int? id;
  String numeroOs;
  int clienteId;
  int bombaId;
  int tecnicoId;
  String tipo; // 'orcamento', 'preventiva', 'manutencao'
  String prioridade; // 'baixa', 'media', 'alta', 'urgente'
  String status; // 'Agendada', 'Em Andamento', 'Concluída', 'Enviado para Faturamento', 'Faturado'
  DateTime dataAbertura;
  DateTime? dataConclusao;
  String defeitoRelatado;
  String servicoRealizado;
  List<ItemOrdemServico> itens;

  // Campos específicos de Manutenção Preventiva
  Map<String, bool> checklistPreventiva;
  List<String> lacresAzuis;
  Map<String, double> litrosRetornados; // Gasolina Comum, Supra, Aditivada, Etanol, Diesel, Diesel S-10

  OrdemServico({
    this.id,
    required this.numeroOs,
    required this.clienteId,
    required this.bombaId,
    required this.tecnicoId,
    this.tipo = 'manutencao',
    this.prioridade = 'media',
    this.status = 'Agendada',
    DateTime? dataAbertura,
    this.dataConclusao,
    this.defeitoRelatado = '',
    this.servicoRealizado = '',
    List<ItemOrdemServico>? itens,
    Map<String, bool>? checklistPreventiva,
    List<String>? lacresAzuis,
    Map<String, double>? litrosRetornados,
  }) : dataAbertura = dataAbertura ?? DateTime.now(),
       itens = itens ?? [],
       checklistPreventiva = checklistPreventiva ?? {},
       lacresAzuis = lacresAzuis ?? [],
       litrosRetornados = litrosRetornados ?? {
         'Gasolina Comum': 0.0,
         'Gasolina Aditivada': 0.0,
         'Etanol': 0.0,
         'Diesel S-10': 0.0,
       };

  double get valorTotal => itens.fold(0.0, (acc, item) => acc + item.subtotal);

  Map<String, dynamic> toPayload() {
    return {
      if (id != null && id! > 0) 'id': id,
      'numero_os': numeroOs,
      'cliente_id': clienteId,
      'bomba_id': bombaId,
      'tecnico_id': tecnicoId,
      'tipo': tipo,
      'prioridade': prioridade,
      'status': status,
      'data_abertura': dataAbertura.toIso8601String(),
      'defeito_relatado': defeitoRelatado,
      'servico_realizado': servicoRealizado,
      'valor_total': valorTotal,
      'itens': itens.map((it) => it.toJson()).toList(),
      'dados_afericao': {
        'checklist_preventiva': checklistPreventiva,
        'lacres_azuis': lacresAzuis,
        'litros_retornados': litrosRetornados,
      }
    };
  }
}
