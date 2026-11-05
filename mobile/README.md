# Assistec Mobile (iOS & Android)

Aplicativo oficial da **Assistec** desenvolvido em **Flutter** para técnicos de campo realizarem vistorias metrológicas, calibrações de bicos, checklists de conformidade e ordens de serviço em postos de combustíveis.

---

## 📱 Estrutura do Projeto

```
mobile/
├── lib/
│   ├── main.dart
│   ├── theme/
│   │   └── app_theme.dart               # Paleta oficial Assistec (#00963A, #093620, etc.)
│   ├── models/
│   │   ├── usuario.dart                 # Sessão do técnico
│   │   ├── cliente_bomba.dart           # Postos e Bombas associadas
│   │   ├── produto.dart                 # Catálogo com 276 itens
│   │   ├── checklist_data.dart          # Vistoria metrológica, bicos, tolerâncias e lacres
│   │   └── ordem_servico.dart           # Orçamentos, Preventiva e Manutenção
│   ├── services/
│   │   ├── api_client.dart              # Comunicação com backend PHP
│   │   └── offline_sync_service.dart    # Fila de persistência offline-first
│   ├── screens/
│   │   ├── login_screen.dart            # Autenticação
│   │   ├── home_screen.dart             # Painel operacional e indicador de sincronização
│   │   ├── checklist_form_screen.dart   # Checklist com 8 seções completas
│   │   └── ordem_servico_form_screen.dart # Ordem de serviço (3 modalidades)
│   └── widgets/
│       ├── nozzle_calibration_tile.dart # Cálculo metrológico automático (ml e %)
│       ├── signature_pad_widget.dart    # Assinatura digital touch na tela
│       └── status_pill.dart             # Badges de status com cores oficiais
├── ios/                                 # Configurações nativas iOS (Info.plist, Câmera)
├── android/                             # Configurações nativas Android (Permissões, Gradle)
└── pubspec.yaml                         # Dependências do projeto
```

---

## 🚀 Como Compilar

### 1. No Celular Android (Gerar APK):
No diretório `mobile/`:
```bash
flutter pub get
flutter build apk --release
```
O arquivo APK pronto para instalar estará em:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

### 2. No iPhone / iOS:
Como o compilador do iOS requer macOS/Xcode:
* **Via GitHub Actions (Sem precisar de Mac)**:
  Basta subir este repositório para o seu GitHub. O workflow `.github/workflows/build_ios_android.yml` já configurado compilará automaticamente o `.app` / `.ipa` no ambiente macOS da nuvem e disponibilizará o download na aba **Actions ➔ Artifacts**.
* **Via Mac físico**:
  ```bash
  cd mobile
  flutter pub get
  flutter build ipa --no-codesign
  ```
