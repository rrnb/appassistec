import 'package:flutter/material.dart';
import '../models/checklist_data.dart';
import '../models/cliente_bomba.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/nozzle_calibration_tile.dart';
import '../widgets/signature_pad_widget.dart';

class ChecklistFormScreen extends StatefulWidget {
  final int tecnicoId;
  final int? checklistId;

  const ChecklistFormScreen({
    Key? key,
    required this.tecnicoId,
    this.checklistId,
  }) : super(key: key);

  @override
  State<ChecklistFormScreen> createState() => _ChecklistFormScreenState();
}

class _ChecklistFormScreenState extends State<ChecklistFormScreen> {
  late ChecklistData _data;
  bool _isLoading = false;
  List<Cliente> _clientes = [];
  Cliente? _clienteSelecionado;
  Bomba? _bombaSelecionada;

  final _nomeAssinaturaCtrl = TextEditingController();
  final _primeiroLacreCtrl = TextEditingController();
  final _segundoLacreCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _data = ChecklistData(
      id: widget.checklistId,
      bombaId: 0,
      tecnicoId: widget.tecnicoId,
    );
    _carregarClientes();
  }

  void _carregarClientes() async {
    setState(() => _isLoading = true);
    final lista = await ApiClient.getClientesBombas();
    if (mounted) {
      setState(() {
        _clientes = lista;
        _isLoading = false;
        if (_clientes.isNotEmpty) {
          _clienteSelecionado = _clientes.first;
          if (_clienteSelecionado!.bombas.isNotEmpty) {
            _bombaSelecionada = _clienteSelecionado!.bombas.first;
            _data.bombaId = _bombaSelecionada!.id;
          }
        }
      });
    }
  }

  void _adicionarBico() {
    if (_data.bicos.length >= 8) return;
    setState(() {
      int nextNum = _data.bicos.length + 1;
      _data.bicos.add(BicoCalibracao(
        numero: nextNum,
        combustivel: 'Bico $nextNum',
      ));
    });
  }

  void _salvarChecklist() async {
    if (_data.bombaId <= 0 && _bombaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma Bomba antes de salvar.'),
          backgroundColor: AppColors.statusError,
        ),
      );
      return;
    }

    _data.bombaId = _bombaSelecionada?.id ?? _data.bombaId;
    _data.primeiroLacre = _primeiroLacreCtrl.text.trim();
    _data.segundoLacre = _segundoLacreCtrl.text.trim();
    _data.nomeClienteAssinatura = _nomeAssinaturaCtrl.text.trim();
    _data.observacoes = _obsCtrl.text.trim();

    setState(() => _isLoading = true);
    final res = await ApiClient.salvarChecklist(_data);
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
        content: Text(res['message'] ?? 'Operação realizada.'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vistoria Metrológica'),
      ),
      body: _isLoading && _clientes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Equipamento & Posto
                _buildCardSection(
                  titulo: '1. Identificação do Equipamento',
                  icone: Icons.local_gas_station,
                  child: Column(
                    children: [
                      DropdownButtonFormField<Cliente>(
                        value: _clienteSelecionado,
                        decoration: const InputDecoration(labelText: 'Posto / Cliente'),
                        items: _clientes.map((c) => DropdownMenuItem(value: c, child: Text(c.razaoSocial, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (c) {
                          setState(() {
                            _clienteSelecionado = c;
                            _bombaSelecionada = c != null && c.bombas.isNotEmpty ? c.bombas.first : null;
                            if (_bombaSelecionada != null) _data.bombaId = _bombaSelecionada!.id;
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
                            if (b != null) _data.bombaId = b.id;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. SSMA Inicial
                _buildCardSection(
                  titulo: '2. SSMA Inicial (Segurança do Trabalho)',
                  icone: Icons.health_and_safety,
                  child: Column(
                    children: [
                      _buildSwitch('EPIs Completos e em bom estado?', _data.epiCompleto, (v) => setState(() => _data.epiCompleto = v)),
                      _buildSwitch('Isolamento e sinalização da área efetuados?', _data.isolamentoArea, (v) => setState(() => _data.isolamentoArea = v)),
                      _buildSwitch('Extintor de incêndio pressurizado e próximo?', _data.extintorDisponivel, (v) => setState(() => _data.extintorDisponivel = v)),
                      _buildSwitch('Aterramento verificado e seguro?', _data.aterramentoOk, (v) => setState(() => _data.aterramentoOk = v)),
                      _buildSwitch('Bomba desenergizada na chave seccionadora?', _data.bombaDesenergizada, (v) => setState(() => _data.bombaDesenergizada = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Instrumento Padrão
                _buildCardSection(
                  titulo: '3. Medidor Padrão de Calibração',
                  icone: Icons.straighten,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _data.instrumentoModelo,
                              decoration: const InputDecoration(labelText: 'Modelo'),
                              onChanged: (v) => _data.instrumentoModelo = v,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: _data.instrumentoSerie,
                              decoration: const InputDecoration(labelText: 'Nº de Série'),
                              onChanged: (v) => _data.instrumentoSerie = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: _data.certificadoCalibracao,
                        decoration: const InputDecoration(labelText: 'Certificado de Calibração / Inmetro'),
                        onChanged: (v) => _data.certificadoCalibracao = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Calibração dos Bicos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '4. ENSAIO METROLÓGICO DOS BICOS (20L)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                    TextButton.icon(
                      onPressed: _adicionarBico,
                      icon: const Icon(Icons.add, size: 16, color: AppColors.brandPrimary),
                      label: const Text('Adicionar Bico', style: TextStyle(color: AppColors.brandPrimary, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._data.bicos.map((b) => NozzleCalibrationTile(bico: b, onChanged: () => setState(() {}))).toList(),
                const SizedBox(height: 16),

                // 5. Ensaios Visuais
                _buildCardSection(
                  titulo: '5. Ensaios Visuais & Estanqueidade',
                  icone: Icons.visibility,
                  child: Column(
                    children: [
                      _buildSwitch('Lacres anteriores estavam intactos?', _data.lacresInviolados, (v) => setState(() => _data.lacresInviolados = v)),
                      _buildSwitch('Totalizador mecânico perfeitamente visível?', _data.encerranteVisivel, (v) => setState(() => _data.encerranteVisivel = v)),
                      _buildSwitch('Mangueiras sem dobras, cortes ou vazamentos?', _data.mangueirasSemVazamento, (v) => setState(() => _data.mangueirasSemVazamento = v)),
                      _buildSwitch('Juntas de expansão e conexões estanques?', _data.juntasSemFolga, (v) => setState(() => _data.juntasSemFolga = v)),
                      _buildSwitch('Bicos automáticos desarmando perfeitamente?', _data.bicosBomEstado, (v) => setState(() => _data.bicosBomEstado = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Lacres de Selagem Aplicados
                _buildCardSection(
                  titulo: '6. Lacres Oficiais Aplicados',
                  icone: Icons.lock_clock,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _primeiroLacreCtrl,
                              decoration: const InputDecoration(labelText: '1º Lacre (Nº Série)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _segundoLacreCtrl,
                              decoration: const InputDecoration(labelText: '2º Lacre Adicional'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.brand50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Validade Legal dos Lacres: ${_data.dataValidadeLacre.day.toString().padLeft(2, "0")}/${_data.dataValidadeLacre.month.toString().padLeft(2, "0")}/${_data.dataValidadeLacre.year} (1 ano)',
                          style: const TextStyle(color: AppColors.brandDark, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 7. Encerramento SSMA
                _buildCardSection(
                  titulo: '7. Encerramento da Operação',
                  icone: Icons.clean_hands,
                  child: Column(
                    children: [
                      _buildSwitch('Área de trabalho limpa, desobstruída e seca?', _data.areaLimpa, (v) => setState(() => _data.areaLimpa = v)),
                      _buildSwitch('Serviço finalizado SEM acidentes ou incidentes?', _data.semIncidentes, (v) => setState(() => _data.semIncidentes = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Assinatura Touch
                _buildCardSection(
                  titulo: '8. Assinatura Digital do Responsável',
                  icone: Icons.draw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nomeAssinaturaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome Legível do Gerente / Responsável',
                          hintText: 'Ex: Carlos Silva (Gerente do Posto)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SignaturePadWidget(
                        onSigned: (points) {
                          _data.assinaturaCliente = 'SIGNATURE_TOUCH_CAPTURED';
                        },
                        onClear: () {
                          _data.assinaturaCliente = null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _obsCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Observações Finais',
                          hintText: 'Digite aqui ressalvas ou anotações...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de Salvar
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _salvarChecklist,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('SALVAR & SINCRONIZAR CHECKLIST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildCardSection({required String titulo, required IconData icone, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.brandDark),
                ),
              ],
            ),
            const Divider(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
          Switch(
            value: value,
            activeColor: AppColors.brandPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
