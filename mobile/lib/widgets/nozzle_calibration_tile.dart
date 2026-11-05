import 'package:flutter/material.dart';
import '../models/checklist_data.dart';
import '../theme/app_theme.dart';

class NozzleCalibrationTile extends StatefulWidget {
  final BicoCalibracao bico;
  final VoidCallback onChanged;

  const NozzleCalibrationTile({
    Key? key,
    required this.bico,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NozzleCalibrationTile> createState() => _NozzleCalibrationTileState();
}

class _NozzleCalibrationTileState extends State<NozzleCalibrationTile> {
  late TextEditingController _leituraInicialCtrl;
  late TextEditingController _leituraFinalCtrl;
  late TextEditingController _encerranteIniCtrl;
  late TextEditingController _encerranteFimCtrl;

  @override
  void initState() {
    super.initState();
    _leituraInicialCtrl = TextEditingController(text: widget.bico.leituraInicial.toStringAsFixed(0));
    _leituraFinalCtrl = TextEditingController(text: widget.bico.leituraFinal.toStringAsFixed(0));
    _encerranteIniCtrl = TextEditingController(text: widget.bico.encerranteInicial.toStringAsFixed(2));
    _encerranteFimCtrl = TextEditingController(text: widget.bico.encerranteFinal.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _leituraInicialCtrl.dispose();
    _leituraFinalCtrl.dispose();
    _encerranteIniCtrl.dispose();
    _encerranteFimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bico = widget.bico;
    final bool estaOk = bico.estaDentroTolerancia;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Bico
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_gas_station, color: AppColors.brandPrimary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bico ${bico.numero}: ${bico.combustivel}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estaOk ? AppColors.statusSuccessBg : AppColors.statusErrorBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    estaOk ? 'DENTRO DA TOLERÂNCIA' : 'FORA DA TOLERÂNCIA',
                    style: TextStyle(
                      color: estaOk ? AppColors.statusSuccess : AppColors.statusError,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Leituras Metrológicas (Aferição 20L)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _leituraInicialCtrl,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: const InputDecoration(
                      labelText: '1ª Leitura (ml)',
                      hintText: 'Ex: 0, -20, +40',
                      suffixText: 'ml',
                    ),
                    onChanged: (val) {
                      bico.leituraInicial = double.tryParse(val) ?? 0.0;
                      setState(() {});
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _leituraFinalCtrl,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: InputDecoration(
                      labelText: '2ª Leitura Final (ml)',
                      hintText: 'Ex: +10',
                      suffixText: 'ml',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: estaOk ? AppColors.brandPrimary : AppColors.statusError,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      bico.leituraFinal = double.tryParse(val) ?? 0.0;
                      setState(() {});
                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Painel de Cálculo em Tempo Real
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Erro em 20 Litros: ${bico.leituraFinal >= 0 ? "+" : ""}${bico.leituraFinal.toStringAsFixed(0)} ml',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    'Desvio: ${bico.erroPercentual >= 0 ? "+" : ""}${bico.erroPercentual.toStringAsFixed(2)} %',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: estaOk ? AppColors.brandDark : AppColors.statusError,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Encerrantes Mecânicos
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _encerranteIniCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Encerrante Inicial (L)',
                      hintText: '0.00',
                    ),
                    onChanged: (val) {
                      bico.encerranteInicial = double.tryParse(val) ?? 0.0;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _encerranteFimCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Encerrante Final (L)',
                      hintText: '0.00',
                    ),
                    onChanged: (val) {
                      bico.encerranteFinal = double.tryParse(val) ?? 0.0;
                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
