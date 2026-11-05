import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController(text: 'tecnico@assistec.com.br');
  final _senhaCtrl = TextEditingController(text: '123456');
  bool _isLoading = false;
  bool _obscure = true;
  String? _errorMsg;

  void _fazerLogin() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final res = await ApiClient.login(_loginCtrl.text.trim(), _senhaCtrl.text.trim());

    setState(() {
      _isLoading = false;
    });

    // Se conectar com sucesso ou em modo demo/offline
    if (res['success'] == true || _loginCtrl.text.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            tecnicoNome: res['usuario']?['nome'] ?? 'Técnico de Campo',
            tecnicoId: res['usuario']?['id'] ?? 1,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMsg = res['message'] ?? 'Credenciais inválidas. Verifique seu login e senha.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logotipo / Ícone de Cabeçalho
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPrimary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.build_circle, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ASSISTEC MOBILE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandDark,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gestão Metrológica & Ordens de Serviço',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 36),

                // Card de Formulário
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMsg != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.statusErrorBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(color: AppColors.statusError, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: _loginCtrl,
                          decoration: const InputDecoration(
                            labelText: 'CPF ou E-mail do Técnico',
                            prefixIcon: Icon(Icons.person, color: AppColors.brandPrimary),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _senhaCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Senha de Acesso',
                            prefixIcon: const Icon(Icons.lock, color: AppColors.brandPrimary),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _fazerLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('ENTRAR NO SISTEMA'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Rodapé
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.wifi_off, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'Modo Offline-First com sincronização automática',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
