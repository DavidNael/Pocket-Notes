import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../enums/enums.dart';
import '../Constants/app_theme.dart';
import '../Constants/keys.dart';

class DateFormatView extends StatefulWidget {
  const DateFormatView({super.key});

  @override
  State<DateFormatView> createState() => _DateFormatViewState();
}

class _DateFormatViewState extends State<DateFormatView> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<AppTheme>(context).darkMood;
    bool isHourFormat = Provider.of<AppTheme>(context).hourFormat;
    int dateFormatOption = Provider.of<AppTheme>(context).dateFormatOption;
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    return Scaffold(
      backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
      appBar: AppBar(
        title: const Text('Date Format'),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ///Use 24 Hour Format Switch
              Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: isDarkMode ? darkTheme : lightTheme,
                ),
                child: SwitchListTile(
                  title: Row(
                    children: [
                      isDarkMode
                          ? IconWidget(
                              icon: Icons.access_time_filled_rounded,
                              color: darkBorderTheme,
                              iconColor: themeColor,
                              text: 'Use 24-Hour Format',
                              textColor: darkTextTheme,
                            )
                          : IconWidget(
                              icon: Icons.access_time_filled_rounded,
                              color: themeColor,
                              iconColor: Colors.white,
                              text: 'Use 24-Hour Format',
                              textColor: lightTextTheme,
                            ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: isDarkMode ? darkTheme : lightTheme, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  activeColor: themeColor,
                  tileColor: isDarkMode ? darkTheme : lightTheme,
                  value: isHourFormat,
                  onChanged: ((value) async {
                    Provider.of<AppTheme>(context, listen: false)
                        .setHourFormatOption(option: value);
                    AppTheme.prefs.setBool(keyHourFormatOption, value);
                  }),
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              ///Radio Options
              Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: isDarkMode ? darkTheme : lightTheme,
                ),
                child: Column(
                  children: <Widget>[
                    RadioListTile<DateFormatOption>(
                      title: Text(
                        'Day/Month/Year',
                        style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                      value: DateFormatOption.dmy,
                      groupValue: DateFormatOption.values[dateFormatOption],
                      activeColor: themeColor,
                      onChanged: (DateFormatOption? value) async {
                        Provider.of<AppTheme>(context, listen: false)
                            .setDateFormatOption(option: 0);
                        AppTheme.prefs.setInt(keyDateFormatOption, 0);
                        setState(() {});
                      },
                    ),
                    RadioListTile<DateFormatOption>(
                      title: Text(
                        'Month/Day/Year',
                        style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                      value: DateFormatOption.mdy,
                      groupValue: DateFormatOption.values[dateFormatOption],
                      activeColor: themeColor,
                      onChanged: (DateFormatOption? value) async {
                        Provider.of<AppTheme>(context, listen: false)
                            .setDateFormatOption(option: 1);
                        AppTheme.prefs.setInt(keyDateFormatOption, 1);
                        setState(() {});
                      },
                    ),
                    RadioListTile<DateFormatOption>(
                      title: Text(
                        'Year/Day/Month',
                        style: TextStyle(
                          color: isDarkMode ? darkTextTheme : lightTextTheme,
                        ),
                      ),
                      value: DateFormatOption.ymd,
                      groupValue: DateFormatOption.values[dateFormatOption],
                      activeColor: themeColor,
                      onChanged: (DateFormatOption? value) async {
                        Provider.of<AppTheme>(context, listen: false)
                            .setDateFormatOption(option: 2);
                        AppTheme.prefs.setInt(keyDateFormatOption, 2);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
