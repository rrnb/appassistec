import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ordem_servico.dart';
import '../models/cliente_bomba.dart';
import '../models/produto.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/status_pill.dart';

class OrdemServicoFormScreen extends StatefulWidget {
  final int tecnicoId;
  final int? osId;

  const OrdemServicoFormScreen({
    Key? key,
    required this.tecnicoId,
    this.osId,
  }) : super(key: key);

  @override
  State<OrdemServicoFormScreen> createState() => _OrdemServicoFormScreenState();
}

class _OrdemServicoFormScreenState extends State<OrdemServicoFormScreen> {
  late OrdemServico _os;
  bool _isLoading = false;
  List<Cliente> _clientes = [];
  List<Produto> _produtos = [];
  Cliente? _clienteSelecionado;
  Bomba? _bombaSelecionada;

  final _numeroOsCtrl = TextEditingController();
  final _defeitoCtrl = TextEditingController();
  final _servicoCtrl = TextEditingController();
  final _novoLacreAzulCtrl = TextEditingController();

  final List<String> _preventivaItens = [
    '01. Filtros de Sucção',
    '02. Correias de Transmissão',
    '03. Válvula de Retenção',
    '04. Mangueiras de Abastecimento',
    '05. Bicos Automáticos & Guarda-Pó',
    '06. Bloco Medidor (Sem Vazamento)',
    '07. Eliminador de Ar',
    '08. Válvula Solenoide',
    '09. Totalizador Mecânico',
    '10. Pulser Eletrônico',
    '11. Display Eletrônico / CPU',
    '12. Iluminação da Bomba',
    '13. Fiação Elétrica & Conexões',
    '14. Prensa-Cabos / Selagem',
    '15. Caixa de Junção',
    '16. Aterramento da Carcaça',
    '17. Lacre da CPU / Inmetro',
    '18. Lacre do Bloco Medidor',
    '19. Painel e Pintura Geral',
    '20. Teclado de Pré-Determinação',
    '21. Válvula de Desarme Rápido',
    '22. Mangote de Conexão',
    '23. Chave Liga/Desliga e Alavanca',
    '24. Parafusos de Fixação e Base',
    '25. Identificação e Adesivos Inmetro',
  ];

  @override
  void initState() {
    super.initState();
    String anoAtual = DateTime.now().year.toString();
    String randomNum = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();

    _os = OrdemServico(
      id: widget.osId,
      numeroOs: 'OS-$anoAtual-$randomNum',
      clienteId: 0,
      bombaId: 0,
      tecnicoId: widget.tecnicoId,
    );
    _numeroOsCtrl.text = _os.numeroOs;

    // Inicializa checklist de 25 itens como aprovados
    for (var item in _preventivaItens) {
      _os.checklistPreventiva[item] = true;
    }

    _carregarDados();
  }

  void _carregarDados() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiClient.getClientesBombas(),
      ApiClient.getProdutos(),
    ]);

    if (mounted) {
      setState(() {
        _clientes = results[0] as List<Cliente>;
        _produtos = results[1] as List<Produto>;
        _isLoading = false;

        if (_clientes.isNotEmpty) {
          _clienteSelecionado = _clientes.first;
          _os.clienteId = _clienteSelecionado!.id;
          if (_clienteSelecionado!.bombas.isNotEmpty) {
            _bombaSelecionada = _clienteSelecionado!.bombas.first;
            _os.bombaId = _bombaSelecionada!.id;
          }
        }
      });
    }
  }

  void _abrirModalProdutos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        String filtro = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtrados = _produtos.where((p) => p.descricao.toLowerCase().contains(filtro.toLowerCase()) || p.codigo.contains(filtro)).toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Catálogo de Produtos (276 itens)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Digite código ou nome da peça...',
                    ),
                    onChanged: (val) => setModalState(() => filtro = val),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtrados.isEmpty
                        ? const Center(child: Text('Nenhum produto encontrado.'))
                        : ListView.separated(
                            itemCount: filtrados.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, idx) {
                              final p = filtrados[idx];
                              return ListTile(
                                title: Text(p.descricao, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                subtitle: Text('Cód: ${p.codigo} | R\$ ${p.preco.toStringAsFixed(2)}'),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                  onPressed: () {
                                    setState(() {
                                      _os.itens.add(ItemOrdemServico(
                                        produtoId: p.id,
                                        codigo: p.codigo,
                                        descricao: p.descricao,
                                        quantidade: 1,
                                        valorUnitario: p.preco,
                                      ));
                                    });
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Adicionar', style: TextStyle(fontSize: 12)),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _aprovarTodosPreventiva() {
    setState(() {
      for (var item in _preventivaItens) {
        _os.checklistPreventiva[item] = true;
      }
    });
  }

  void _adicionarLacreAzul() {
    if (_novoLacreAzulCtrl.text.trim().isEmpty) return;
    setState(() {
      _os.lacresAzuis.add(_novoLacreAzulCtrl.text.trim());
      _novoLacreAzulCtrl.clear();
    });
  }

  void _salvarOS() async {
    _os.numeroOs = _numeroOsCtrl.text.trim();
    _os.defeitoRelatado = _defeitoCtrl.text.trim();
    _os.servicoRealizado = _servicoCtrl.text.trim();

    setState(() => _isLoading = true);
    final res = await ApiClient.salvarOrdemServico(_os);
    setState(() => _isLoading = false);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              res['offline'] == true ? Icons.cloud_off : Icons.check_circle,
              color: res['offline'] == true ? AppColors.statusWarning : AppColors.brandPrimary,
            ),
            const SizedBox(width: 8),
            Text(res['offline'] == true ? 'Salvo no Celular' : 'Sucesso!'),
          ],
        ),
        content: Text(res['message'] ?? 'Ordem de Serviço processada.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordem de Serviço'),
      ),
      body: _isLoading && _clientes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Seletor dos 3 Modelos de OS
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      _buildTipoTab('orcamento', 'Orçamento', Icons.request_quote),
                      _buildTipoTab('preventiva', 'Preventiva', Icons.verified_user),
                      _buildTipoTab('manutencao', 'Manutenção', Icons.build),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card Principal: Dados da OS & Horário Automático
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _numeroOsCtrl,
                                decoration: const InputDecoration(labelText: 'Nº da OS'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.brand50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Data & Hora:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    Text(
                                      dateFormat.format(_os.dataAbertura),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.brandDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.access_time, color: AppColors.brandPrimary),
                              tooltip: 'Atualizar para Agora',
                              onPressed: () => setState(() => _os.dataAbertura = DateTime.now()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Cliente>(
                          value: _clienteSelecionado,
                          decoration: const InputDecoration(labelText: 'Posto / Cliente'),
                          items: _clientes.map((c) => DropdownMenuItem(value: c, child: Text(c.razaoSocial, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (c) {
                            setState(() {
                              _clienteSelecionado = c;
                              _os.clienteId = c?.id ?? 0;
                              _bombaSelecionada = c != null && c.bombas.isNotEmpty ? c.bombas.first : null;
                              _os.bombaId = _bombaSelecionada?.id ?? 0;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Bomba>(
                          value: _bombaSelecionada,
                          decoration: const InputDecoration(labelText: 'Bomba de Combustível'),
                          items: (_clienteSelecionado?.bombas ?? []).map((b) => DropdownMenuItem(value: b, child: Text(b.displayName, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (b) {
                            setState(() {
                              _bombaSelecionada = b;
                              _os.bombaId = b?.id ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // VISÃO 1: ORÇAMENTO (Tabela de Produtos com Totalizador)
                if (_os.tipo == 'orcamento' || _os.tipo == 'manutencao') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PEÇAS & PRODUTOS UTILIZADOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      TextButton.icon(
                        onPressed: _abrirModalProdutos,
                        icon: const Icon(Icons.search, size: 16, color: AppColors.brandPrimary),
                        label: const Text('Buscar no Catálogo', style: TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_os.itens.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 36),
                              SizedBox(height: 6),
                              Text('Nenhuma peça adicionada ainda.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: [
                          ..._os.itens.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            return ListTile(
                              title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('R\$ ${item.valorUnitario.toStringAsFixed(2)} x ${item.quantidade} = R\$ ${item.subtotal.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.textMuted),
                                    onPressed: () {
                                      if (item.quantidade > 1) {
                                        setState(() => item.quantidade--);
                                      } else {
                                        setState(() => _os.itens.removeAt(idx));
                                      }
                                    },
                                  ),
                                  Text('${item.quantidade}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.brandPrimary),
                                    onPressed: () => setState(() => item.quantidade++),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('VALOR TOTAL DA OS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(
                                  'R\$ ${_os.valorTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.brandPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],

                // VISÃO 2: MANUTENÇÃO PREVENTIVA (25 Itens, Lacres Azuis, Litros Retornados)
                if (_os.tipo == 'preventiva') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CHECKLIST PREVENTIVA (25 PONTOS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      TextButton.icon(
                        onPressed: _aprovarTodosPreventiva,
                        icon: const Icon(Icons.done_all, size: 16, color: AppColors.brandPrimary),
                        label: const Text('Aprovar Todos', style: TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: _preventivaItens.map((item) {
                          bool aprovado = _os.checklistPreventiva[item] ?? true;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(child: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                                GestureDetector(
                                  onTap: () => setState(() => _os.checklistPreventiva[item] = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: !aprovado ? AppColors.statusError : AppColors.statusErrorBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('REPRO.', style: TextStyle(color: !aprovado ? Colors.white : AppColors.statusError, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(() => _os.checklistPreventiva[item] = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: aprovado ? AppColors.statusSuccess : AppColors.statusSuccessBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('APRO.', style: TextStyle(color: aprovado ? Colors.white : AppColors.statusSuccess, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Múltiplos Lacres Azuis
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lacres Azuis Aplicados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _novoLacreAzulCtrl,
                                  decoration: const InputDecoration(labelText: 'Nº do Lacre Azul', hintText: 'Ex: AZ-884920'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _adicionarLacreAzul,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusInfo),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: _os.lacresAzuis.map((lacre) {
                              return Chip(
                                label: Text(lacre, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                backgroundColor: AppColors.statusInfo,
                                deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                                onDeleted: () => setState(() => _os.lacresAzuis.remove(lacre)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Litros Retornados ao Tanque
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Combustível Retornado ao Tanque (Litros)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),
                          ..._os.litrosRetornados.keys.map((comb) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                initialValue: _os.litrosRetornados[comb]?.toStringAsFixed(1) ?? '0.0',
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: comb, suffixText: 'Litros'),
                                onChanged: (v) => _os.litrosRetornados[comb] = double.tryParse(v) ?? 0.0,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Seletor de Status & Fluxo de Faturamento
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status da Ordem de Serviço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Agendada',
                            'Em Andamento',
                            'Concluída',
                            'Enviado para Faturamento',
                            'Faturado',
                          ].map((st) {
                            return StatusPill(
                              status: st,
                              isSelected: _os.status == st,
                              onTap: () => setState(() => _os.status = st),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão Salvar
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _salvarOS,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SALVAR ORDEM DE SERVIÇO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildTipoTab(String tipo, String label, IconData icon) {
    bool selecionado = _os.tipo == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _os.tipo = tipo),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selecionado ? AppColors.brandPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: selecionado ? Colors.white : AppColors.textMuted, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selecionado ? Colors.white : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
