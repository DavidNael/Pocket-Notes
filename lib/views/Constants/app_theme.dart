import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillCheckboxBuilder;
import 'package:intl/intl.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

///App Colors
const orangeDarkTheme = Color.fromARGB(255, 200, 75, 15);
const orangeLightTheme = Color.fromARGB(255, 255, 160, 10);
const orangeAccentTheme = Color.fromARGB(255, 255, 160, 40);
const greenDarkTheme = Color.fromARGB(255, 0, 120, 0);
const greenLightTheme = Color.fromARGB(255, 0, 200, 0);
const greenAccentTheme = Color.fromARGB(255, 50, 250, 60);
const purpleDarkTheme = Color.fromARGB(255, 110, 0, 150);
const purpleLightTheme = Color.fromARGB(255, 180, 0, 220);
const purpleAccentTheme = Color.fromARGB(255, 225, 80, 255);
const blueDarkTheme = Color.fromARGB(255, 0, 80, 170);
const blueLightTheme = Color.fromARGB(255, 20, 150, 255);
const blueAccentTheme = Color.fromARGB(255, 80, 180, 255);
const redDarkTheme = Color.fromARGB(255, 170, 0, 0);
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
  bool darkMode = AppTheme.prefs.getBool(keyDarkMode) ?? true;
  bool isList = AppTheme.prefs.getBool(keyNotesViewOption) ?? true;
  bool hourFormat = AppTheme.prefs.getBool(keyHourFormatOption) ?? false;
  String themeColor = AppTheme.prefs.getString(keyThemeColor) ?? 'orange';
  late MaterialColor swatch = getSwatch();

  ///Initialize SharedPreferences
  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Setters
  void setDarkTheme({required bool isDark}) {
    darkMode = isDark;
    notifyListeners();
  }

  void setNoteView({required bool option}) {
    isList = option;
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
        if (darkMode) {
          return orangeDarkSwatch;
        } else {
          return orangeLightSwatch;
        }
      case 'green':
        if (darkMode) {
          return greenDarkSwatch;
        } else {
          return greenLightSwatch;
        }
      case 'purple':
        if (darkMode) {
          return purpleDarkSwatch;
        } else {
          return purpleLightSwatch;
        }
      case 'blue':
        if (darkMode) {
          return blueDarkSwatch;
        } else {
          return blueLightSwatch;
        }
      case 'red':
        if (darkMode) {
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
    ThemeData theme = darkMode
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
        if (darkMode) {
          return orangeDarkTheme;
        } else {
          return orangeLightTheme;
        }
      case 'green':
        if (darkMode) {
          return greenDarkTheme;
        } else {
          return greenLightTheme;
        }
      case 'purple':
        if (darkMode) {
          return purpleDarkTheme;
        } else {
          return purpleLightTheme;
        }
      case 'blue':
        if (darkMode) {
          return blueDarkTheme;
        } else {
          return blueLightTheme;
        }
      case 'red':
        if (darkMode) {
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
      break;
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
  notes.sort((a, b) {
    if (b.isPinned) {
      return 1;
    }
    return -1;
  });
  notes.sort((a, b) {
    if (b.isPinned) {
      return 1;
    }
    return -1;
  });
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

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color circleColor;
  final Color iconColor;
  final Color tileColor;
  final Color disabledTileColor;
  final Color borderColor;
  final Color textColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;
  const SettingsTile({
    Key? key,
    required this.icon,
    required this.circleColor,
    required this.iconColor,
    required this.tileColor,
    this.disabledTileColor = Colors.grey,
    required this.borderColor,
    required this.textColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.trailing,
    this.isSelected = false,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: isEnabled,
      tileColor: isSelected ? disabledTileColor : tileColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      title: IconWidget(
        icon: icon,
        color: circleColor,
        iconColor: iconColor,
        textColor: textColor,
        text: title,
      ),
      subtitle: subtitle != null ? Text(subtitle ?? '') : null,
      onTap: onTap,
      trailing: trailing,
    );
  }
}

class ProfileImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  const ProfileImage({
    Key? key,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CachedNetworkImage(
        imageUrl: imagePath,
        maxHeightDiskCache: 512,
        progressIndicatorBuilder: (context, url, progress) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: CircularProgressIndicator(
              value: progress.progress,
            ),
          );
        },
        imageBuilder: (context, imageProvider) {
          return ClipOval(
            child: Material(
              color: Colors.transparent,
              child: Ink.image(
                image: imageProvider,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: onTap,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SlidePageTransition extends PageRouteBuilder {
  final Widget child;
  final AxisDirection direction;
  final int animationStartDuration;
  final int animationEndDuration;

  SlidePageTransition({
    required this.child,
    this.direction = AxisDirection.up,
    this.animationStartDuration = 500,
    this.animationEndDuration = 500,
  }) : super(
          transitionDuration: Duration(milliseconds: animationStartDuration),
          reverseTransitionDuration:
              Duration(milliseconds: animationEndDuration),
          pageBuilder: (context, animation, secondryAnimation) => child,
        );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: getBeginDirection(),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
  Offset getBeginDirection() {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);

      case AxisDirection.right:
        return const Offset(-1, 0);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
    }
  }
}

class ScalePageTransition extends PageRouteBuilder {
  final Widget child;
  final double? x;
  final double? y;
  final int startDuration;
  final int endDuration;

  final Key? key;
  ScalePageTransition(
      {required this.child,
      this.key,
      this.x,
      this.y,
      this.startDuration = 500,
      this.endDuration = 500})
      : super(
          transitionDuration: Duration(milliseconds: startDuration),
          reverseTransitionDuration: Duration(milliseconds: endDuration),
          pageBuilder: (context, animation, secondryAnimation) => child,
        );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (x != null && y != null) {
      return Transform.scale(
        scale: animation.value,
        origin: Offset(x!, y!),
        alignment: Alignment.topLeft,
        child: child,
      );
    } else {
      return Transform.scale(
        scale: animation.value,
        alignment: const Alignment(0, 0.9),
        child: child,
      );
    }
  }
}

//!WIP
class ColorPageTransition extends PageRouteBuilder {
  final Widget child;
  final Color color;
  final double? x;
  final double? y;

  final Key? key;
  ColorPageTransition(
      {required this.child, this.key, required this.color, this.x, this.y})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondryAnimation) => child,
        );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Transform.scale(
      scale: animation.value,
      origin: Offset(x!, y!),
      alignment: Alignment.topLeft,
      child: Container(
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(300),
          ),
        ),
      ),
    );
    return child;
  }
}

class FadePageTransition extends PageRouteBuilder {
  final Widget child;
  FadePageTransition({
    required this.child,
  }) : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondryAnimation) => child,
        );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(
        opacity: animation,
        child: child,
      );
}

class CustomCheckBox implements QuillCheckboxBuilder {
  const CustomCheckBox();

  @override
  Widget build({
    required BuildContext context,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
    return Center(
      child: InkWell(
        onTap: () {
          isChecked = !isChecked;
          onChanged(isChecked);
        },
        child: Container(
          width: 20,
          height: 20,
          // padding: const EdgeInsets.only(bottom: 12),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isChecked
                    ? themeColor
                    : isDarkMode
                        ? darkTextTheme
                        : lightTextTheme,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            color: isChecked
                ? themeColor
                : isDarkMode
                    ? darkTheme
                    : lightTheme,
          ),
          child: Icon(
            isChecked ? Icons.check : null,
            color: isChecked
                ? isDarkMode
                    ? darkTextTheme
                    : lightTextTheme
                : null,
            size: 15,
          ),
        ),
      ),
    );
  }
}
