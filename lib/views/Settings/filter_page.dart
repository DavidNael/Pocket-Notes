import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/enums.dart';
import '../Constants/app_theme.dart';
import '../Constants/keys.dart';

class FilterPageView extends StatefulWidget {
  const FilterPageView({super.key});

  @override
  State<FilterPageView> createState() => _FilterPageViewState();
}

class _FilterPageViewState extends State<FilterPageView> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
    int filterOption = Provider.of<AppTheme>(context).filterOption;
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    return Scaffold(
      backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
      appBar: AppBar(
        title: const Text('Filter Option'),
        backgroundColor: themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              color: isDarkMode ? darkTheme : lightTheme,
            ),
            child: Column(
              children: <Widget>[
                RadioListTile<FilterOption>(
                  title: Text(
                    'Title Ascending',
                    style: TextStyle(
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                  ),
                  value: FilterOption.titleA,
                  groupValue: FilterOption.values[filterOption],
                  activeColor: themeColor,
                  onChanged: (FilterOption? value) async {
                    Provider.of<AppTheme>(context, listen: false)
                        .setFilterOption(option: 0);
                    AppTheme.prefs.setInt(keyFilterOption, 0);
                    setState(() {});
                  },
                ),
                RadioListTile<FilterOption>(
                  title: Text(
                    'Title Descending',
                    style: TextStyle(
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                  ),
                  value: FilterOption.titleD,
                  groupValue: FilterOption.values[filterOption],
                  activeColor: themeColor,
                  onChanged: (FilterOption? value) async {
                    Provider.of<AppTheme>(context, listen: false)
                        .setFilterOption(option: 1);
                    AppTheme.prefs.setInt(keyFilterOption, 1);
                    setState(() {});
                  },
                ),
                RadioListTile<FilterOption>(
                  title: Text(
                    'Date Modified New',
                    style: TextStyle(
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                  ),
                  value: FilterOption.dateModifiedN,
                  groupValue: FilterOption.values[filterOption],
                  activeColor: themeColor,
                  onChanged: (FilterOption? value) async {
                    Provider.of<AppTheme>(context, listen: false)
                        .setFilterOption(option: 2);
                    AppTheme.prefs.setInt(keyFilterOption, 2);
                    setState(() {});
                  },
                ),
                RadioListTile<FilterOption>(
                  title: Text(
                    'Date Modified Old',
                    style: TextStyle(
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                  ),
                  value: FilterOption.dateModifiedO,
                  groupValue: FilterOption.values[filterOption],
                  activeColor: themeColor,
                  onChanged: (FilterOption? value) async {
                    Provider.of<AppTheme>(context, listen: false)
                        .setFilterOption(option: 3);
                    AppTheme.prefs.setInt(keyFilterOption, 3);
                    setState(() {});
                  },
                ),
                RadioListTile<FilterOption>(
                  title: Text(
                    'Date Created New',
                    style: TextStyle(
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                  ),
                  value: FilterOption.dateCreatedN,
                  groupValue: FilterOption.values[filterOption],
                  activeColor: themeColor,
                  onChanged: (FilterOption? value) async {
                    Provider.of<AppTheme>(context, listen: false)
                        .setFilterOption(option: 4);
                    AppTheme.prefs.setInt(keyFilterOption, 4);
                    setState(() {});
                  },
                ),
                RadioListTile<FilterOption>(
                  title: Text(
                    'Date Created Old',
                    style: TextStyle(
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                  ),
                  value: FilterOption.dateCreatedO,
                  groupValue: FilterOption.values[filterOption],
                  activeColor: themeColor,
                  onChanged: (FilterOption? value) async {
                    Provider.of<AppTheme>(context, listen: false)
                        .setFilterOption(option: 5);
                    AppTheme.prefs.setInt(keyFilterOption, 5);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
