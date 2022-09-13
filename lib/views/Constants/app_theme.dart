import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:pocketnotes/views/Constants/keys.dart';

const darkModeKey = 'key-dark-mode';

final orangeDarkTheme = Colors.orange.shade600;
const orangeLightTheme = Colors.amber;
final greenDarkTheme = Colors.green.shade600;
const greenLightTheme = Colors.green;
final purpleDarkTheme = Colors.purple.shade600;
const purpleLightTheme = Colors.purple;
final blueDarkTheme = Colors.blue.shade600;
const blueLightTheme = Colors.blue;
final redDarkTheme = Colors.red.shade600;
const redLightTheme = Colors.red;

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
Map<int, Color> orangeMap = {
  50: orangeLightTheme,
  100: orangeLightTheme,
  200: orangeLightTheme,
  300: orangeLightTheme,
  400: orangeDarkTheme,
  500: orangeDarkTheme,
  600: orangeDarkTheme,
  700: orangeDarkTheme,
  800: orangeDarkTheme,
  900: orangeDarkTheme,
};
Map<int, Color> greenMap = {
  50: greenLightTheme,
  100: greenLightTheme,
  200: greenLightTheme,
  300: greenLightTheme,
  400: greenDarkTheme,
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
  400: purpleDarkTheme,
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
  400: blueDarkTheme,
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
  400: redDarkTheme,
  500: redDarkTheme,
  600: redDarkTheme,
  700: redDarkTheme,
  800: redDarkTheme,
  900: redDarkTheme,
};
MaterialColor orangeDarkSwatch = MaterialColor(orangeDarkTheme.value, orangeMap);
MaterialColor orangeLightSwatch = MaterialColor(orangeLightTheme.value, orangeMap);
MaterialColor greenDarkSwatch = MaterialColor(greenDarkTheme.value, greenMap);
MaterialColor greenLightSwatch = MaterialColor(greenLightTheme.value, greenMap);
MaterialColor purpleDarkSwatch = MaterialColor(purpleDarkTheme.value, purpleMap);
MaterialColor purpleLightSwatch = MaterialColor(purpleLightTheme.value, purpleMap);
MaterialColor blueDarkSwatch = MaterialColor(blueDarkTheme.value, blueMap);
MaterialColor blueLightSwatch = MaterialColor(blueLightTheme.value, blueMap);
MaterialColor redDarkSwatch = MaterialColor(redDarkTheme.value, redMap);
MaterialColor redLightSwatch = MaterialColor(redLightTheme.value, redMap);

///AppTheme Class
class AppTheme extends ChangeNotifier {
  bool darkMood = Settings.getValue<bool>(darkModeKey) ?? true;
  String themeColor = Settings.getValue<String>(keyThemeColor) ?? 'orange';
  late MaterialColor swatch=getSwatch();
  void setDarkTheme({required bool isDark}) {
    darkMood = isDark;
    notifyListeners();
  }

  void setColorTheme({required String color}) {
    themeColor = color;
    notifyListeners();
  }
  MaterialColor getSwatch (){
  switch(themeColor){
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

  ThemeData getDarkTheme() {
    ThemeData theme = darkMood
        ? ThemeData(
            primarySwatch: getSwatch(),
            canvasColor: darkCanvasTheme,
          )
        : ThemeData(
            primarySwatch: getSwatch(),
            canvasColor: lightCanvasTheme,
          );
    return theme;
  }

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
