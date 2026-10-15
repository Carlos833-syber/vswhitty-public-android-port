# VS Whitty para Android

Este port mantém a Kade Engine e o conteúdo do mod. Os controles são inspirados
nos ports mobile da Psych Engine; não é uma migração para a Psych Engine.

## Gerar e baixar o APK

1. No GitHub, abra **Actions → Android APK → Run workflow** e selecione a branch
   que contém este port. Pushes em `main` e `coderabbit/**` também compilam.
2. Aguarde o job `build` terminar com sucesso.
3. Baixe o artifact **VS-Whitty-Android-arm64-debug**, extraia o ZIP e instale o APK.

O APK de testes é assinado com a chave de debug do runner. Requer Android 6+
(API 23) em aparelho ARM64. Não é um pacote de publicação na Play Store.
A chave de debug pode mudar entre builds: se houver conflito de assinatura,
será necessário desinstalar o APK anterior (isso remove os dados salvos).

## Controles

- Menus, pausa e game over: use LEFT / DOWN / UP / RIGHT, OK e BACK no rodapé.
- Música: quatro colunas de toque (LEFT / DOWN / UP / RIGHT) abaixo da barra superior.
  Aceitam vários dedos e notas sustentadas; deslizar muda a coluna pressionada.
- PAUSE abre a pausa. OK avança diálogos.
- **Options → Gameplay → Middlescroll** centraliza as notas do jogador e oculta
  as notas do adversário. Desativar restaura o layout normal.
- **Options → Gameplay → Hitboxes** alterna Visible / Invisible. O toque continua
  funcionando quando as áreas estão invisíveis. Os botões superiores permanecem visíveis.
- As duas preferências são salvas; middlescroll entra em vigor na próxima música.

## Toolchain

Haxe 4.2.5, Java 11, SDK 33, build-tools 30.0.3, NDK 21.4.7075529.
As versões das bibliotecas estão em `scripts/setup-android.sh`.
Com as ferramentas instaladas, execute:

```bash
bash scripts/setup-android.sh
export ANDROID_SETUP=true
export ANDROID_SDK="$ANDROID_HOME"
export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/21.4.7075529"
haxelib run lime build android -debug -DHXCPP_ARM64
```

Replays em arquivos e mods externos via Polymod ficam restritos ao desktop.
Scripts Lua do código original continuam exclusivos do Windows.

## Validação em aparelho

Após uma compilação bem-sucedida no Actions, testar: entrada na tela inicial,
Story/Freeplay, diálogos do Whitty, acordes, sustains, pausa/retomada, retry,
game over, upscroll/downscroll, middlescroll ligado/desligado e hitboxes
visíveis/invisíveis. Fechar e reabrir para conferir as preferências.
