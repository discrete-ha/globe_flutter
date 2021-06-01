// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appTitle": MessageLookupByLibrary.simpleMessage("GLOBE"),
        "contact": MessageLookupByLibrary.simpleMessage("Contact us"),
        "deleted": MessageLookupByLibrary.simpleMessage("deleted"),
        "enter_email":
            MessageLookupByLibrary.simpleMessage("Enter your e-mail address"),
        "enter_message":
            MessageLookupByLibrary.simpleMessage("Enter your message here"),
        "enter_title": MessageLookupByLibrary.simpleMessage("Enter title here"),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "history": MessageLookupByLibrary.simpleMessage("History"),
        "localNotificationBody": MessageLookupByLibrary.simpleMessage(
            "Let\'s see what is happening in your area!"),
        "notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "off": MessageLookupByLibrary.simpleMessage("Off"),
        "on": MessageLookupByLibrary.simpleMessage("On"),
        "reminder": MessageLookupByLibrary.simpleMessage("Reminder"),
        "subTitle":
            MessageLookupByLibrary.simpleMessage("Realtime news in a nutshell"),
        "title": MessageLookupByLibrary.simpleMessage("Title"),
        "to_delete": MessageLookupByLibrary.simpleMessage("Delete")
      };
}
