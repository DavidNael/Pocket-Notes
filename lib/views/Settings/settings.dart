import 'package:flutter/material.dart';
import 'package:pocketnotes/views/Constants/app_theme.dart';
import 'package:pocketnotes/views/Constants/keys.dart';
import 'package:pocketnotes/views/Settings/date_format_page.dart';
import 'package:pocketnotes/views/Settings/filter_page.dart';
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
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
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
            //!General Tab
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'General',
                style: TextStyle(
                  color: isDarkMode ? darkTextTheme : lightTextTheme,
                ),
              ),
            ),

            //!Dark mode Switch
            SwitchListTile(
              title: Row(
                children: [
                  IconWidget(
                    icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? darkBorderTheme : themeColor,
                    iconColor: isDarkMode ? themeColor : Colors.white,
                    text: isDarkMode ? 'Dark Mode' : 'Light Mode',
                    textColor: isDarkMode ? darkTextTheme : lightTextTheme,
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

            //!Theme Color Button
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
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'green',
                      child: Text(
                        'Green',
                        style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'purple',
                      child: Text(
                        'Purple',
                        style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'blue',
                      child: Text(
                        'Blue',
                        style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'red',
                      child: Text(
                        'Red',
                        style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
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

            //!Filter Option Button
            SettingsTile(
                              isEnabled: true,
                isSelected: false,

              icon: Icons.filter_alt,
              circleColor: isDarkMode ? darkBorderTheme : themeColor,
              iconColor: isDarkMode ? themeColor : Colors.white,
              tileColor: isDarkMode ? darkTheme : lightTheme,
              borderColor: isDarkMode ? darkTheme : lightTheme,
              title: 'Sort Notes',
              textColor: isDarkMode ? darkTextTheme : lightTextTheme,
              subtitle: null,
              trailing: Icon(
                size: 20,
                Icons.arrow_forward_ios,
                color: themeColor,
              ),
              onTap: () {
                Navigator.of(context).push(
                  SlidePageTransition(
                    direction: AxisDirection.left,
                    animationStartDuration: 300,
                    animationEndDuration: 300,
                    child: const FilterPageView(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 4,
            ),

            //!Date Format Button
            SettingsTile(
                              isEnabled: true,
                isSelected: false,

              icon: Icons.date_range_rounded,
              title: 'Date Format',
              circleColor: isDarkMode ? darkBorderTheme : themeColor,
              iconColor: isDarkMode ? themeColor : Colors.white,
              tileColor: isDarkMode ? darkTheme : lightTheme,
              borderColor: isDarkMode ? darkTheme : lightTheme,
              textColor: isDarkMode ? darkTextTheme : lightTextTheme,
              subtitle: null,
              trailing: Icon(
                size: 20,
                Icons.arrow_forward_ios,
                color: themeColor,
              ),
              onTap: () {
                Navigator.of(context).push(
                  SlidePageTransition(
                    direction: AxisDirection.left,
                    animationStartDuration: 300,
                    animationEndDuration: 300,
                    child: const DateFormatView(),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 4,
            ),
            //!App Version Button
            ListTile(
              tileColor: isDarkMode ? darkTheme : lightTheme,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: isDarkMode ? darkTheme : lightTheme, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              title: IconWidget(
                icon: Icons.info,
                color: isDarkMode ? darkBorderTheme : themeColor,
                iconColor: isDarkMode ? themeColor : Colors.white,
                text: 'App Version',
                textColor: isDarkMode ? darkTextTheme : lightTextTheme,
              ),
              trailing: Text(
                'V1.1.0',
                style: TextStyle(
                  color: isDarkMode ? darkTextTheme : lightTextTheme,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
