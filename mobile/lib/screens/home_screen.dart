import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/offline_sync_service.dart';
import 'checklist_form_screen.dart';
import 'ordem_servico_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final String tecnicoNome;
  final int tecnicoId;

  const HomeScreen({
    Key? key,
    required this.tecnicoNome,
    required this.tecnicoId,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pendentesCount = 0;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _atualizarContadorOffline();
  }

  void _atualizarContadorOffline() async {
    final count = await OfflineSyncService.getPendentesCount();
    if (mounted) {
      setState(() {
        _pendentesCount = count;
      });
    }
  }

  void _sincronizarAgora() async {
    setState(() => _sincronizando = true);
    final res = await OfflineSyncService.sincronizarFila();
    setState(() => _sincronizando = false);
    _atualizarContadorOffline();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sincronização concluída: ${res['processados']} enviados com sucesso.'),
        backgroundColor: AppColors.brandPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASSISTEC MOBILE'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.sync, color: Colors.white),
                if (_pendentesCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.brandAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '$_pendentesCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: _sincronizando ? null : _sincronizarAgora,
            tooltip: 'Sincronizar Pendências Offline',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner de Boas-Vindas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandDark, Color(0xFF14532D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.brandPrimary,
                  child: const Icon(Icons.engineering, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${widget.tecnicoNome}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Operação de Campo & Metrologia',
                        style: TextStyle(color: AppColors.brand200, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Alerta de Fila Offline se houver pendências
          if (_pendentesCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.statusWarningBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.statusWarning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_queue, color: AppColors.statusWarning, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_pendentesCount registro(s) aguardando conexão para envio ao servidor.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    ),
                  ),
                  TextButton(
                    onPressed: _sincronizarAgora,
                    child: const Text('ENVIAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

          const Text(
            'MÓDULOS OPERACIONAIS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // Card 1: Checklist & Vistoria Metrológica
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChecklistFormScreen(
                      tecnicoId: widget.tecnicoId,
                    ),
                  ),
                );
                _atualizarContadorOffline();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.brand50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brand100),
                      ),
                      child: const Icon(Icons.fact_check, color: AppColors.brandPrimary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Checklist & Vistoria Metrológica',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Aferição de bicos 20L, tolerância Inmetro, lacres de selagem, SSMA e assinatura.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Card 2: Ordem de Serviço & Manutenção Preventiva
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrdemServicoFormScreen(
                      tecnicoId: widget.tecnicoId,
                    ),
                  ),
                );
                _atualizarContadorOffline();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: const Icon(Icons.build, color: AppColors.brandAccent, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ordem de Serviço & Preventiva',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Orçamentos (catálogo 276 produtos), checklist preventiva de 25 itens e retorno de litros.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
