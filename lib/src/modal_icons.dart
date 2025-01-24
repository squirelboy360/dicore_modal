import 'package:flutter/material.dart';

class ModalIcons {
  // Navigation
  static const String xmark = "xmark";
  static const String chevronLeft = "chevron.left";
  static const String chevronRight = "chevron.right";
  static const String chevronUp = "chevron.up";
  static const String chevronDown = "chevron.down";
  static const String arrowLeft = "arrow.left";
  static const String arrowRight = "arrow.right";
  static const String arrowUp = "arrow.up";
  static const String arrowDown = "arrow.down";
  
  // Actions
  static const String plus = "plus";
  static const String minus = "minus";
  static const String multiply = "multiply";
  static const String divide = "divide";
  static const String equals = "equals";
  static const String checkmark = "checkmark";
  static const String trash = "trash";
  static const String pencil = "pencil";
  static const String square = "square";
  static const String circle = "circle";
  
  // Media
  static const String play = "play";
  static const String pause = "pause";
  static const String stop = "stop";
  static const String forward = "forward";
  static const String backward = "backward";
  static const String shuffle = "shuffle";
  static const String repeat = "repeat";
  static const String speaker = "speaker";
  static const String mic = "mic";
  static const String camera = "camera";
  
  // Communication
  static const String message = "message";
  static const String phone = "phone";
  static const String video = "video";
  static const String mail = "envelope";
  static const String bell = "bell";
  static const String person = "person";
  static const String personCircle = "person.circle";
  static const String group = "person.2";
  
  // Interface
  static const String gear = "gear";
  static const String info = "info.circle";
  static const String question = "questionmark.circle";
  static const String exclamation = "exclamationmark.circle";
  static const String lock = "lock";
  static const String unlock = "lock.open";
  static const String wifi = "wifi";
  static const String bluetooth = "bluetooth";
  
  // Content
  static const String doc = "doc";
  static const String folder = "folder";
  static const String calendar = "calendar";
  static const String clock = "clock";
  static const String tag = "tag";
  static const String bookmark = "bookmark";
  static const String link = "link";
  static const String location = "location";
  
  // Get Flutter icon fallback for platforms that don't support SF Symbols
  static IconData getIcon(String sfSymbol) {
    switch (sfSymbol) {
      case xmark:
        return Icons.close;
      case chevronLeft:
        return Icons.chevron_left;
      case chevronRight:
        return Icons.chevron_right;
      case chevronUp:
        return Icons.expand_less;
      case chevronDown:
        return Icons.expand_more;
      case arrowLeft:
        return Icons.arrow_back;
      case arrowRight:
        return Icons.arrow_forward;
      case arrowUp:
        return Icons.arrow_upward;
      case arrowDown:
        return Icons.arrow_downward;
      case plus:
        return Icons.add;
      case minus:
        return Icons.remove;
      case multiply:
        return Icons.close;
      case checkmark:
        return Icons.check;
      case trash:
        return Icons.delete;
      case pencil:
        return Icons.edit;
      case square:
        return Icons.crop_square;
      case circle:
        return Icons.circle_outlined;
      case play:
        return Icons.play_arrow;
      case pause:
        return Icons.pause;
      case stop:
        return Icons.stop;
      case forward:
        return Icons.fast_forward;
      case backward:
        return Icons.fast_rewind;
      case shuffle:
        return Icons.shuffle;
      case repeat:
        return Icons.repeat;
      case speaker:
        return Icons.volume_up;
      case mic:
        return Icons.mic;
      case camera:
        return Icons.camera_alt;
      case message:
        return Icons.message;
      case phone:
        return Icons.phone;
      case video:
        return Icons.videocam;
      case mail:
        return Icons.mail;
      case bell:
        return Icons.notifications;
      case person:
        return Icons.person;
      case personCircle:
        return Icons.account_circle;
      case group:
        return Icons.group;
      case gear:
        return Icons.settings;
      case info:
        return Icons.info;
      case question:
        return Icons.help;
      case exclamation:
        return Icons.warning;
      case lock:
        return Icons.lock;
      case unlock:
        return Icons.lock_open;
      case wifi:
        return Icons.wifi;
      case bluetooth:
        return Icons.bluetooth;
      case doc:
        return Icons.description;
      case folder:
        return Icons.folder;
      case calendar:
        return Icons.calendar_today;
      case clock:
        return Icons.access_time;
      case tag:
        return Icons.local_offer;
      case bookmark:
        return Icons.bookmark;
      case link:
        return Icons.link;
      case location:
        return Icons.location_on;
      default:
        return Icons.help_outline;
    }
  }
}