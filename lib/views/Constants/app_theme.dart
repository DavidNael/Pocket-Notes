import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:pocketnotes/views/Settings/filter_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

///App Colors
const orangeDarkTheme = Color.fromARGB(255, 200, 100, 0);
const orangeLightTheme = Color.fromARGB(255, 255, 160, 10);
const orangeAccentTheme = Color.fromARGB(255, 255, 160, 40);
const greenDarkTheme = Color.fromARGB(255, 0, 100, 0);
const greenLightTheme = Color.fromARGB(255, 0, 200, 7);
const greenAccentTheme = Color.fromARGB(255, 50, 250, 60);
const purpleDarkTheme = Color.fromARGB(255, 110, 0, 150);
const purpleLightTheme = Color.fromARGB(255, 180, 0, 220);
const purpleAccentTheme = Color.fromARGB(255, 225, 80, 255);
const blueDarkTheme = Color.fromARGB(255, 0, 70, 130);
const blueLightTheme = Color.fromARGB(255, 20, 150, 255);
const blueAccentTheme = Color.fromARGB(255, 80, 180, 255);
const redDarkTheme = Color.fromARGB(255, 130, 0, 0);
const redLightTheme = Color.fromARGB(255, 255, 50, 25);
const redAccentTheme = Color.fromARGB(255, 255, 90, 60);

///App Theme Colors
final darkTheme = Colors.grey.shade800;
const darkHeaderTheme = Colors.white;
final darkTextTheme = Colors.grey.shade300;
final darkBorderTheme = Colors.grey.shade900;
final darkCanvasTheme = Colors.grey.shade600;

final lightTheme = Colors.grey.shade200;
const lightHeaderTheme = Colors.black;
const lightTextTheme = Colors.black;
final lightBorderTheme = Colors.grey.shade300;
final lightCanvasTheme = Colors.grey.shade200;

///Swatch Maps
Map<int, Color> orangeMap = {
  50: orangeLightTheme,
  100: orangeLightTheme,
  200: orangeLightTheme,
  300: orangeLightTheme,
  400: orangeLightTheme,
  500: orangeLightTheme,
  600: orangeLightTheme,
  700: orangeDarkTheme,
  800: orangeDarkTheme,
  900: orangeDarkTheme,
};
Map<int, Color> greenMap = {
  50: greenLightTheme,
  100: greenLightTheme,
  200: greenLightTheme,
  300: greenLightTheme,
  400: greenLightTheme,
  500: greenDarkTheme,
  600: greenDarkTheme,
  700: greenDarkTheme,
  800: greenDarkTheme,
  900: greenDarkTheme,
};
Map<int, Color> purpleMap = {
  50: purpleLightTheme,
  100: purpleLightTheme,
  200: purpleLightTheme,
  300: purpleLightTheme,
  400: purpleLightTheme,
  500: purpleDarkTheme,
  600: purpleDarkTheme,
  700: purpleDarkTheme,
  800: purpleDarkTheme,
  900: purpleDarkTheme,
};
Map<int, Color> blueMap = {
  50: blueLightTheme,
  100: blueLightTheme,
  200: blueLightTheme,
  300: blueLightTheme,
  400: blueLightTheme,
  500: blueDarkTheme,
  600: blueDarkTheme,
  700: blueDarkTheme,
  800: blueDarkTheme,
  900: blueDarkTheme,
};
Map<int, Color> redMap = {
  50: redLightTheme,
  100: redLightTheme,
  200: redLightTheme,
  300: redLightTheme,
  400: redLightTheme,
  500: redDarkTheme,
  600: redDarkTheme,
  700: redDarkTheme,
  800: redDarkTheme,
  900: redDarkTheme,
};

///Swatches
MaterialColor orangeDarkSwatch =
    MaterialColor(orangeDarkTheme.value, orangeMap);
MaterialColor orangeLightSwatch =
    MaterialColor(orangeLightTheme.value, orangeMap);
MaterialColor greenDarkSwatch = MaterialColor(greenDarkTheme.value, greenMap);
MaterialColor greenLightSwatch = MaterialColor(greenLightTheme.value, greenMap);
MaterialColor purpleDarkSwatch =
    MaterialColor(purpleDarkTheme.value, purpleMap);
MaterialColor purpleLightSwatch =
    MaterialColor(purpleLightTheme.value, purpleMap);
MaterialColor blueDarkSwatch = MaterialColor(blueDarkTheme.value, blueMap);
MaterialColor blueLightSwatch = MaterialColor(blueLightTheme.value, blueMap);
MaterialColor redDarkSwatch = MaterialColor(redDarkTheme.value, redMap);
MaterialColor redLightSwatch = MaterialColor(redLightTheme.value, redMap);

///AppTheme Class
class AppTheme extends ChangeNotifier {
  static late SharedPreferences prefs;
  int filterOption = AppTheme.prefs.getInt(keyFilterOption) ?? 0;
  int dateFormatOption = AppTheme.prefs.getInt(keyDateFormatOption) ?? 0;
  bool darkMood = AppTheme.prefs.getBool(keyDarkMode) ?? true;
  bool hourFormat = AppTheme.prefs.getBool(keyHourFormatOption) ?? false;
  String themeColor = AppTheme.prefs.getString(keyThemeColor) ?? 'orange';
  late MaterialColor swatch = getSwatch();

  ///Initialize SharedPreferences
  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Setters
  void setDarkTheme({required bool isDark}) {
    darkMood = isDark;
    notifyListeners();
  }

  void setFilterOption({required int option}) {
    filterOption = option;
    notifyListeners();
  }

  void setDateFormatOption({required int option}) {
    dateFormatOption = option;
    notifyListeners();
  }

  void setHourFormatOption({required bool option}) {
    hourFormat = option;
    notifyListeners();
  }

  void setColorTheme({required String color}) {
    themeColor = color;
    notifyListeners();
  }

  ///Get Primary Swatch Color
  MaterialColor getSwatch() {
    switch (themeColor) {
      case 'orange':
        if (darkMood) {
          return orangeDarkSwatch;
        } else {
          return orangeLightSwatch;
        }
      case 'green':
        if (darkMood) {
          return greenDarkSwatch;
        } else {
          return greenLightSwatch;
        }
      case 'purple':
        if (darkMood) {
          return purpleDarkSwatch;
        } else {
          return purpleLightSwatch;
        }
      case 'blue':
        if (darkMood) {
          return blueDarkSwatch;
        } else {
          return blueLightSwatch;
        }
      case 'red':
        if (darkMood) {
          return redDarkSwatch;
        } else {
          return redLightSwatch;
        }
      default:
        return orangeDarkSwatch;
    }
  }

  ///Get App Accent Color
  Color getAccent() {
    switch (themeColor) {
      case 'orange':
        return orangeAccentTheme;
      case 'green':
        return greenAccentTheme;
      case 'purple':
        return purpleAccentTheme;
      case 'blue':
        return blueAccentTheme;
      case 'red':
        return redAccentTheme;
      default:
        return orangeAccentTheme;
    }
  }

  /// Get App Theme
  ThemeData getDarkTheme() {
    ThemeData theme = darkMood
        ? ThemeData(
            primarySwatch: getSwatch(),
            canvasColor: darkBorderTheme,
          )
        : ThemeData(
            primarySwatch: getSwatch(),
            canvasColor: lightBorderTheme,
          );
    return theme;
  }

  ///Get App Color
  Color getColorTheme() {
    switch (themeColor) {
      case 'orange':
        if (darkMood) {
          return orangeDarkTheme;
        } else {
          return orangeLightTheme;
        }
      case 'green':
        if (darkMood) {
          return greenDarkTheme;
        } else {
          return greenLightTheme;
        }
      case 'purple':
        if (darkMood) {
          return purpleDarkTheme;
        } else {
          return purpleLightTheme;
        }
      case 'blue':
        if (darkMood) {
          return blueDarkTheme;
        } else {
          return blueLightTheme;
        }
      case 'red':
        if (darkMood) {
          return redDarkTheme;
        } else {
          return redLightTheme;
        }
      default:
        return orangeDarkTheme;
    }
  }
}

///Date Format
formatDate(
    {required String date,
    required int formatOption,
    required bool isHourFormat}) {
  DateTime dateTime = DateFormat("yyyy/MM/dd HH:mm:ss").parse(date);
  String newDate = '';
  switch (formatOption) {
    case 0:
      if (isHourFormat) {
        newDate = DateFormat('dd/MM/yyyy HH:MM').format(dateTime);
      } else {
        newDate = DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
      }
      break;
    case 1:
      if (isHourFormat) {
        newDate = DateFormat('MM/dd/yyyy HH:MM').format(dateTime);
      } else {
        newDate = DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);
      }
      break;
    case 2:
      if (isHourFormat) {
        newDate = DateFormat('yyyy/MM/dd HH:MM').format(dateTime);
      } else {
        newDate = DateFormat('yyyy/MM/dd hh:mm a').format(dateTime);
      }
      break;
  }
  return newDate;
}

/// Note Sorting
sortNotes({required List notes, required int filterOption}) async {
  switch (filterOption) {
    case 0:
      notes.sort(
        (a, b) => a.title.toLowerCase().compareTo(
              b.title.toLowerCase(),
            ),
      );
      break;
    case 1:
      notes.sort(
        (b, a) => a.title.toLowerCase().compareTo(
              b.title.toLowerCase(),
            ),
      );
      break;
    case 2:
      notes.sort(
        (b, a) => a.dateModified.toLowerCase().compareTo(
              b.dateModified.toLowerCase(),
            ),
      );
      return notes;

    case 3:
      notes.sort(
        (a, b) => a.dateModified.toLowerCase().compareTo(
              b.dateModified.toLowerCase(),
            ),
      );
      break;
    case 4:
      notes.sort(
        (b, a) => a.dateCreated.toLowerCase().compareTo(
              b.dateCreated.toLowerCase(),
            ),
      );
      break;
    case 5:
      notes.sort(
        (a, b) => a.dateCreated.toLowerCase().compareTo(
              b.dateCreated.toLowerCase(),
            ),
      );
      break;
    default:
      notes.sort(
        (b, a) => a.text.toLowerCase().compareTo(
              b.text.toLowerCase(),
            ),
      );
      break;
  }
  return notes.toList();
}

/// Icon Widget Class
class IconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final String text;
  const IconWidget({
    Key? key,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.textColor,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: iconColor)),
        const SizedBox(
          width: 10,
        ),
        Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ],
    );
  }
}

dynamic ac = FilterPageView();

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDarkMode;
  final VoidCallback onTap;
  const SettingsTile({
    Key? key,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.textColor,
    required this.title,
    required this.isDarkMode,
    required this.subtitle,
    required this.onTap,
    required this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isDarkMode ? darkTheme : lightTheme,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isDarkMode ? darkTheme : lightTheme, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      title: IconWidget(
          icon: icon,
          color: color,
          iconColor: iconColor,
          textColor: textColor,
          text: title),
      subtitle: subtitle != null ? Text(subtitle ?? '') : null,
      onTap: onTap,
      trailing: trailing,
    );
  }
}
