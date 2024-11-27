// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'pt';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'Sem assinantes', one: 'assinante', other: 'assinantes')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Resposta', other: 'Respostas')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Sem visualizações', one: 'visualização', other: 'visualizações')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Sobre"),
        "canada": MessageLookupByLibrary.simpleMessage("Canada"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("Não encontrado"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("Comum"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("Qualidade padrão"),
        "developer": MessageLookupByLibrary.simpleMessage("Desenvolvedor"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("Disable PIP player"),
        "disableVideoHistory": MessageLookupByLibrary.simpleMessage(
            "Desativar histórico de vídeos"),
        "distractionFree":
            MessageLookupByLibrary.simpleMessage("Sem distração"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "Ativa tocador HLS para habilitar todas as opções de qualidade.\nDesativar em caso de erros."),
        "france": MessageLookupByLibrary.simpleMessage("France"),
        "hideComments":
            MessageLookupByLibrary.simpleMessage("Esconder Comentários"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Esconde botão comentários da tela."),
        "hideRelated":
            MessageLookupByLibrary.simpleMessage("Esconder Relacionados"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Esconde vídeos relacionados da tela"),
        "history": MessageLookupByLibrary.simpleMessage("Histórico"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Tocador Hls"),
        "home": MessageLookupByLibrary.simpleMessage("Início"),
        "includeTitle": MessageLookupByLibrary.simpleMessage("Incluir título"),
        "india": MessageLookupByLibrary.simpleMessage("India"),
        "instances": MessageLookupByLibrary.simpleMessage("Instâncias"),
        "language": MessageLookupByLibrary.simpleMessage("Idioma"),
        "netherlands": MessageLookupByLibrary.simpleMessage("Netherlands"),
        "noCommentsFound":
            MessageLookupByLibrary.simpleMessage("No Comments Found"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("Sem data"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("Sem nome"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "Nenhuma fonte de vídeo disponível, mudando automaticamente para hls"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("Sem descrição"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("Sem título"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("Ler mais"),
        "region": MessageLookupByLibrary.simpleMessage("Região"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("Relacionado"),
        "repliesPlural": m1,
        "retrieveDislikeCounts": MessageLookupByLibrary.simpleMessage(
            "Recupera contagem de dislikes"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("Recuperar Dislikes"),
        "retry": MessageLookupByLibrary.simpleMessage("Tenta novamente"),
        "saved": MessageLookupByLibrary.simpleMessage("Salvos"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("Vídeos salvos"),
        "settings": MessageLookupByLibrary.simpleMessage("Configurações"),
        "share": MessageLookupByLibrary.simpleMessage("Compartilhar"),
        "showLessText": MessageLookupByLibrary.simpleMessage("Mostrar menos"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Inscrever"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe down to dismiss\' disabled"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "\'Swipe up to dismiss\' enabled"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "Please consider switching to a different region for better results."),
        "theme": MessageLookupByLibrary.simpleMessage("Tema"),
        "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
            "Não existem vídeos/histórico salvos"),
        "thereIsNoSavedVideos":
            MessageLookupByLibrary.simpleMessage("Não existem vídeos salvos"),
        "translators": MessageLookupByLibrary.simpleMessage("Tradutores"),
        "trending": MessageLookupByLibrary.simpleMessage("Tendência"),
        "unitedKingdom": MessageLookupByLibrary.simpleMessage("United Kingdom"),
        "unitedStates": MessageLookupByLibrary.simpleMessage("United States"),
        "unknown": MessageLookupByLibrary.simpleMessage("desconhecido"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("Qualidade desconhecida"),
        "version": MessageLookupByLibrary.simpleMessage("Versão"),
        "video": MessageLookupByLibrary.simpleMessage("Vídeo"),
        "videoViews": m2
      };
}
