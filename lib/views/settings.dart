import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:pocketnotes/main.dart';
import 'package:pocketnotes/views/Constants/app_theme.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late SharedPreferences prefs;
  late String colorName;
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> initialzeSettings() async {
    prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool(keyDarkMode) ?? true;
    colorName = prefs.getString(keyThemeColor) ?? 'orange';
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    return FutureBuilder<bool>(
        future: initialzeSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
              appBar: AppBar(
                title: const Text('Settings'),
                backgroundColor: themeColor,
              ),
              body: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  children: [
                    ///General
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'General',
                        style: TextStyle(
                            color: isDarkMode ? darkTextTheme : lightTextTheme),
                      ),
                    ),

                    ///Dark mode
                    SwitchListTile(
                      title: Row(
                        children: [
                          isDarkMode
                              ? IconWidget(
                                  icon: Icons.dark_mode,
                                  color: darkBorderTheme,
                                  iconColor: themeColor,
                                  text: 'Dark Mode',
                                  textColor: darkTextTheme,
                                )
                              : IconWidget(
                                  icon: Icons.light_mode,
                                  color: themeColor,
                                  iconColor: Colors.white,
                                  text: 'Light Mode',
                                  textColor: lightTextTheme,
                                ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: isDarkMode ? darkTheme : lightTheme,
                            width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      tileColor: isDarkMode ? darkTheme : lightTheme,
                      value: isDarkMode,
                      onChanged: ((value) {
                        Provider.of<AppTheme>(context, listen: false)
                            .setDarkTheme(isDark: value);
                        prefs.setBool(keyDarkMode, value);
                        setState(() {});
                      }),
                    ),
                    const SizedBox(
                      height: 4,
                    ),

                    ///Theme Color Button
                    ListTile(
                      tileColor: isDarkMode ? darkTheme : lightTheme,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: isDarkMode ? darkTheme : lightTheme,
                            width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isDarkMode
                              ? IconWidget(
                                  icon: Icons.color_lens,
                                  color: darkBorderTheme,
                                  iconColor: themeColor,
                                  text: 'Theme',
                                  textColor: darkTextTheme,
                                )
                              : IconWidget(
                                  icon: Icons.color_lens,
                                  color: themeColor,
                                  iconColor: Colors.white,
                                  text: 'Theme',
                                  textColor: lightTextTheme,
                                ),
                          DropdownButton(
                            alignment: Alignment.centerRight,
                            value: colorName,
                            items: [
                              DropdownMenuItem(
                                value: 'orange',
                                child: Text(
                                  'Orange',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode?orangeDarkTheme:orangeLightTheme,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'green',
                                child: Text(
                                  'Green',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode?greenDarkTheme:greenLightTheme,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'purple',
                                child: Text(
                                  'Purple',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode?purpleDarkTheme:purpleLightTheme,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'blue',
                                child: Text(
                                  'Blue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode?blueDarkTheme:blueLightTheme,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'red',
                                child: Text(
                                  'Red',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode?redDarkTheme:redLightTheme,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: ((value) {
                              if (value is String) {
                                Provider.of<AppTheme>(context, listen: false)
                                    .setColorTheme(color: value);
                                prefs.setString(keyThemeColor, value);
                                setState(() {});
                              }
                            }),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Loading...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
          }
        });
  }
}
