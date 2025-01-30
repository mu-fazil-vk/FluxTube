// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, zero: 'Aucun abonné', one: 'abonné', other: 'abonnés')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Réponse', other: 'Réponses')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'Aucune vue', one: 'vue', other: 'vues')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("À propos"),
        "canada": MessageLookupByLibrary.simpleMessage("Canada"),
        "channelSubscribers": m0,
        "commentAuthorNotFound":
            MessageLookupByLibrary.simpleMessage("Introuvable"),
        "commonSettingsTitle": MessageLookupByLibrary.simpleMessage("Général"),
        "defaultQuality":
            MessageLookupByLibrary.simpleMessage("Qualité par défaut"),
        "developer": MessageLookupByLibrary.simpleMessage("Développeur"),
        "disablePipPlayer":
            MessageLookupByLibrary.simpleMessage("Désactiver le lecteur PIP"),
        "disableVideoHistory": MessageLookupByLibrary.simpleMessage(
            "Désactiver l\'historique des vidéos"),
        "distractionFree":
            MessageLookupByLibrary.simpleMessage("Sans distraction"),
        "enableHlsPlayerDescription": MessageLookupByLibrary.simpleMessage(
            "Activez le lecteur HLS pour déverrouiller toutes les options de qualité. Désactivez-le si des erreurs se produisent."),
        "france": MessageLookupByLibrary.simpleMessage("France"),
        "hideComments":
            MessageLookupByLibrary.simpleMessage("Masquer les commentaires"),
        "hideCommentsButtonFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Masquer le bouton des commentaires de l\'écran de visionnage."),
        "hideRelated": MessageLookupByLibrary.simpleMessage(
            "Masquer les vidéos similaires"),
        "hideRelatedVideosFromWatchScreen":
            MessageLookupByLibrary.simpleMessage(
                "Masquer les vidéos similaires de l\'écran de visionnage"),
        "history": MessageLookupByLibrary.simpleMessage("Historique"),
        "hlsPlayer": MessageLookupByLibrary.simpleMessage("Lecteur HLS"),
        "home": MessageLookupByLibrary.simpleMessage("Accueil"),
        "includeTitle":
            MessageLookupByLibrary.simpleMessage("Inclure un titre"),
        "india": MessageLookupByLibrary.simpleMessage("Inde"),
        "instances": MessageLookupByLibrary.simpleMessage("Instances"),
        "language": MessageLookupByLibrary.simpleMessage("Langue"),
        "netherlands": MessageLookupByLibrary.simpleMessage("Pays-Bas"),
        "noCommentsFound":
            MessageLookupByLibrary.simpleMessage("Aucun commentaire trouvé"),
        "noUploadDate": MessageLookupByLibrary.simpleMessage("Aucune date"),
        "noUploaderName": MessageLookupByLibrary.simpleMessage("Aucun nom"),
        "noVideoAvailableChangedToHls": MessageLookupByLibrary.simpleMessage(
            "Aucune source vidéo disponible, HLS automatiquement sélectionné"),
        "noVideoDescription":
            MessageLookupByLibrary.simpleMessage("Aucune description"),
        "noVideoTitle": MessageLookupByLibrary.simpleMessage("Aucun titre"),
        "readMoreText": MessageLookupByLibrary.simpleMessage("Lire plus"),
        "region": MessageLookupByLibrary.simpleMessage("Région"),
        "relatedTitle": MessageLookupByLibrary.simpleMessage("Similaire"),
        "repliesPlural": m1,
        "retrieveDislikeCounts": MessageLookupByLibrary.simpleMessage(
            "Récupérer le compteur de dislikes"),
        "retrieveDislikes":
            MessageLookupByLibrary.simpleMessage("Récupérer les dislikes"),
        "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
        "saved": MessageLookupByLibrary.simpleMessage("Sauvegardées"),
        "savedVideosTitle":
            MessageLookupByLibrary.simpleMessage("Vidéos enregistrées"),
        "settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "share": MessageLookupByLibrary.simpleMessage("Partager"),
        "showLessText": MessageLookupByLibrary.simpleMessage("Voir moins"),
        "subscribe": MessageLookupByLibrary.simpleMessage("S\'abonner"),
        "swipeDownToDismissDisabled": MessageLookupByLibrary.simpleMessage(
            "« Glisser vers le bas pour ignorer » désactivé"),
        "swipeUpToDismissEnabled": MessageLookupByLibrary.simpleMessage(
            "« Glisser vers le haut pour ignorer » activé"),
        "switchRegion": MessageLookupByLibrary.simpleMessage(
            "Merci de sélectionner une autre région pour de meilleurs résultats."),
        "theme": MessageLookupByLibrary.simpleMessage("Thème"),
        "thereIsNoSavedOrHistoryVideos": MessageLookupByLibrary.simpleMessage(
            "Il n\'y a pas de vidéos enregistrées, ni d\'historique"),
        "thereIsNoSavedVideos": MessageLookupByLibrary.simpleMessage(
            "Il n\'y a pas de vidéos enregistrées"),
        "translators": MessageLookupByLibrary.simpleMessage("Traducteurs"),
        "trending": MessageLookupByLibrary.simpleMessage("Tendance"),
        "unitedKingdom": MessageLookupByLibrary.simpleMessage("Angleterre"),
        "unitedStates": MessageLookupByLibrary.simpleMessage("États-Unis"),
        "unknown": MessageLookupByLibrary.simpleMessage("inconnu"),
        "unknownQuality":
            MessageLookupByLibrary.simpleMessage("Qualité inconnue"),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "video": MessageLookupByLibrary.simpleMessage("Vidéo"),
        "videoViews": m2
      };
}
