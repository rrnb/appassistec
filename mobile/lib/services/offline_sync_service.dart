import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cliente_bomba.dart';
import '../models/produto.dart';
import 'api_client.dart';

class OfflineSyncService {
  static const String _queueKey = 'assistec_offline_queue';
  static const String _cachedClientesKey = 'assistec_cached_clientes';
  static const String _cachedProdutosKey = 'assistec_cached_produtos';

  // Enfileirar item para sincronizar quando a internet retornar
  static Future<void> enfileirarItem(String tipo, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentQueue = prefs.getStringList(_queueKey) ?? [];

    final item = {
      'tipo': tipo,
      'criado_em': DateTime.now().toIso8601String(),
      'payload': payload,
    };

    currentQueue.add(jsonEncode(item));
    await prefs.setStringList(_queueKey, currentQueue);
  }

  // Quantidade de itens pendentes na fila
  static Future<int> getPendentesCount() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentQueue = prefs.getStringList(_queueKey) ?? [];
    return currentQueue.length;
  }

  // Tentar sincronizar todos os itens enfileirados
  static Future<Map<String, dynamic>> sincronizarFila() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentQueue = prefs.getStringList(_queueKey) ?? [];

    if (currentQueue.isEmpty) {
      return {'processados': 0, 'restantes': 0, 'sucesso': true};
    }

    List<String> restantes = [];
    int processados = 0;

    for (String itemStr in currentQueue) {
      try {
        final Map<String, dynamic> item = jsonDecode(itemStr);
        final String tipo = item['tipo'];
        final Map<String, dynamic> payload = item['payload'];

        if (tipo == 'checklist') {
          // Tentar enviar direto via endpoint
          final res = await ApiClient.salvarChecklistDirect(payload);
          if (res) {
            processados++;
          } else {
            restantes.add(itemStr);
          }
        } else if (tipo == 'ordem_servico') {
          final res = await ApiClient.salvarOrdemDirect(payload);
          if (res) {
            processados++;
          } else {
            restantes.add(itemStr);
          }
        }
      } catch (e) {
        restantes.add(itemStr);
      }
    }

    await prefs.setStringList(_queueKey, restantes);
    return {
      'processados': processados,
      'restantes': restantes.length,
      'sucesso': restantes.isEmpty,
    };
  }

  // Cache de Clientes
  static Future<void> cacheClientes(List<Cliente> clientes) async {
    final prefs = await SharedPreferences.getInstance();
    // Salva em formato simplificado
  }

  static Future<List<Cliente>> getCachedClientes() async {
    return [];
  }

  // Cache de Produtos
  static Future<void> cacheProdutos(List<Produto> produtos) async {
    final prefs = await SharedPreferences.getInstance();
  }

  static Future<List<Produto>> getCachedProdutos() async {
    return [];
  }
}
