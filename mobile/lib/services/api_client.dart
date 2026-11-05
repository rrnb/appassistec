import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/cliente_bomba.dart';
import '../models/produto.dart';
import '../models/checklist_data.dart';
import '../models/ordem_servico.dart';
import 'offline_sync_service.dart';

class ApiClient {
  // Altere para o IP do seu servidor local ou domínio de produção
  // Exemplo emulador Android: 'http://10.0.2.2/assistec/desktop/api'
  // Exemplo iOS Simulator / Mac: 'http://localhost/assistec/desktop/api'
  // Exemplo rede Wi-Fi local: 'http://192.168.1.100/assistec/desktop/api'
  static String baseUrl = 'http://10.0.2.2/assistec/desktop/api';

  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Login
  static Future<Map<String, dynamic>> login(String login, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': login, 'senha': senha}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  // Obter Clientes e Bombas vinculadas
  static Future<List<Cliente>> getClientesBombas({int? clienteId}) async {
    try {
      String url = '$baseUrl/clientes_bombas.php';
      if (clienteId != null && clienteId > 0) {
        url += '?cliente_id=$clienteId';
      }

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((c) => Cliente.fromJson(c)).toList();
        } else if (decoded is Map && decoded['clientes'] is List) {
          return (decoded['clientes'] as List).map((c) => Cliente.fromJson(c)).toList();
        }
      }
      return [];
    } catch (e) {
      // Retorna cache offline se disponível
      return OfflineSyncService.getCachedClientes();
    }
  }

  // Obter Catálogo de Produtos
  static Future<List<Produto>> getProdutos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/produtos.php')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['dados'] is List) {
          list = decoded['dados'];
        }
        return list.map((p) => Produto.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      return OfflineSyncService.getCachedProdutos();
    }
  }

  // Salvar Checklist (com sincronização offline imediata se falhar)
  static Future<Map<String, dynamic>> salvarChecklist(ChecklistData checklist) async {
    final payload = checklist.toPayload();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checklist.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': 'Checklist sincronizado com sucesso!', 'dados': data};
      }
      throw Exception(data['message'] ?? 'Erro no servidor');
    } catch (e) {
      // Salva na fila local offline
      await OfflineSyncService.enfileirarItem('checklist', payload);
      return {
        'success': true,
        'offline': true,
        'message': 'Sem conexão. Checklist salvo no dispositivo e será sincronizado quando a internet retornar.'
      };
    }
  }

  // Salvar Ordem de Serviço
  static Future<Map<String, dynamic>> salvarOrdemServico(OrdemServico os) async {
    final payload = os.toPayload();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ordens.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': 'Ordem de Serviço salva com sucesso!', 'dados': data};
      }
      throw Exception(data['message'] ?? 'Erro no servidor');
    } catch (e) {
      await OfflineSyncService.enfileirarItem('ordem_servico', payload);
      return {
        'success': true,
        'offline': true,
        'message': 'Sem conexão. OS guardada no dispositivo para sincronização automática posterior.'
      };
    }
  }
}
