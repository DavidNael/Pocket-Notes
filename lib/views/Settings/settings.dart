import 'package:flutter/material.dart';
import 'package:pocketnotes/views/Constants/app_theme.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:pocketnotes/views/Constants/routes.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    Color themeColor = Provider.of<AppTheme>(context).getColorTheme();
    bool isDarkMode = Provider.of<AppTheme>(context).darkMood;
    String colorName = Provider.of<AppTheme>(context).themeColor;
    return Scaffold(
      backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? darkTextTheme : lightTextTheme,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeColor,
        iconTheme: IconThemeData(
          color: isDarkMode ? darkTextTheme : lightTextTheme,
        ),
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
                  color: isDarkMode ? darkTextTheme : lightTextTheme,
                ),
              ),
            ),

            ///Dark mode Switch
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
                    color: isDarkMode ? darkTheme : lightTheme, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              tileColor: isDarkMode ? darkTheme : lightTheme,
              activeColor: themeColor,
              value: isDarkMode,
              onChanged: ((value) async {
                Provider.of<AppTheme>(context, listen: false)
                    .setDarkTheme(isDark: value);
                AppTheme.prefs.setBool(keyDarkMode, value);
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
                    color: isDarkMode ? darkTheme : lightTheme, width: 1),
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
                ],
              ),
              trailing: Container(
                color: isDarkMode ? darkTheme : lightTheme,
                child: DropdownButton(
                  underline: Container(
                    height: 2,
                    color: themeColor,
                  ),
                  iconEnabledColor: themeColor,
                  // iconSize: 35,
                  alignment: Alignment.centerRight,
                  value: colorName,
                  items: [
                    DropdownMenuItem(
                      value: 'orange',
                      child: Text(
                        'Orange',
                        style: TextStyle(
                          color:
                              isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'green',
                      child: Text(
                        'Green',
                        style: TextStyle(
                          color:
                              isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'purple',
                      child: Text(
                        'Purple',
                        style: TextStyle(
                          color:
                              isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'blue',
                      child: Text(
                        'Blue',
                        style: TextStyle(
                          color:
                              isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'red',
                      child: Text(
                        'Red',
                        style: TextStyle(
                          color:
                              isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                  ],
                  onChanged: ((value) {
                    if (value is String) {
                      Provider.of<AppTheme>(context, listen: false)
                          .setColorTheme(color: value);
                      AppTheme.prefs.setString(keyThemeColor, value);
                    }
                  }),
                ),
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            ///Filter Option Button
            isDarkMode
                ? SettingsTile(
                    icon: Icons.filter_alt,
                    color: darkBorderTheme,
                    iconColor: themeColor,
                    title: 'Sort Notes',
                    textColor: darkTextTheme,
                    isDarkMode: isDarkMode,
                    subtitle: null,
                    onTap: () {
                      Navigator.pushNamed(context, filterSettingsRoute);
                    },
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: themeColor,
                    ),
                  )
                : SettingsTile(
                    icon: Icons.filter_alt,
                    color: themeColor,
                    iconColor: Colors.white,
                    title: 'Sort Notes',
                    textColor: lightTextTheme,
                    isDarkMode: isDarkMode,
                    subtitle: null,
                    onTap: () {
                      Navigator.pushNamed(context, filterSettingsRoute);
                    },
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: themeColor,
                    ),
                  ),
            const SizedBox(
              height: 4,
            ),

            ///Date Format Button
            isDarkMode
                ? SettingsTile(
                    icon: Icons.date_range_rounded,
                    color: darkBorderTheme,
                    iconColor: themeColor,
                    title: 'Date Format',
                    textColor: darkTextTheme,
                    isDarkMode: isDarkMode,
                    subtitle: null,
                    onTap: () {
                      Navigator.pushNamed(context, dateFormatSettingsRoute);
                    },
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: themeColor,
                    ),
                  )
                : SettingsTile(
                    icon: Icons.date_range_rounded,
                    color: themeColor,
                    iconColor: Colors.white,
                    title: 'Date Format',
                    textColor: lightTextTheme,
                    isDarkMode: isDarkMode,
                    subtitle: null,
                    onTap: () {
                      Navigator.pushNamed(context, dateFormatSettingsRoute);
                    },
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: themeColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
