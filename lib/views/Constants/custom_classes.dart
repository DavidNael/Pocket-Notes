import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketnotes/views/Constants/routes.dart';
import 'package:pocketnotes/views/Notes/category_notes.dart';
import 'package:pocketnotes/views/Notes/notes_view.dart';
import 'package:pocketnotes/views/Notes/trash_notes.dart';
import 'package:provider/provider.dart';

import '../../Services/auth/bloc/auth_bloc.dart';
import '../../Services/auth/bloc/auth_event.dart';
import '../../Services/cloud/cloud_user.dart';
import '../../Services/cloud/firebase_cloud_storage.dart';
import '../../utilities/dialogs/logout_dialog.dart';
import '../Notes/archived_notes.dart';
import 'app_theme.dart';

class AppDrawer extends StatefulWidget {
  final bool isDarkMode;
  final bool uploading;
  final bool isHomeSelected;
  final bool isHomeEnabled;
  final bool isArchivedSelected;
  final bool isArchivedEnabled;
  final bool isCategorySelected;
  final bool isCategoryEnabled;
  final bool isTrashSelected;
  final bool isTrashEnabled;
  final Color themeColor;
  final CloudUser user;
  final FirebaseCloudStorage notesService;
  final Function updateProfile;
  const AppDrawer({
    Key? key,
    required this.isDarkMode,
    required this.uploading,
    required this.themeColor,
    required this.user,
    required this.notesService,
    required this.updateProfile,
    this.isHomeSelected = false,
    this.isHomeEnabled = true,
    this.isArchivedSelected = false,
    this.isArchivedEnabled = true,
    this.isCategorySelected = false,
    this.isCategoryEnabled = true,
    this.isTrashSelected = false,
    this.isTrashEnabled = true,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final themeColor = widget.themeColor;
    final user = widget.user;
    final isHomeSelected = widget.isHomeSelected;
    final isHomeEnabled = widget.isHomeEnabled;
    final isCategorySelected = widget.isCategorySelected;
    final isCategoryEnabled = widget.isCategoryEnabled;
    final isArchivedSelected = widget.isArchivedSelected;
    final isArchivedEnabled = widget.isArchivedEnabled;
    final isTrashSelected = widget.isTrashSelected;
    final isTrashEnabled = widget.isTrashEnabled;
    final updateProfile = widget.updateProfile;
    File? userImage;
    bool uploading = widget.uploading;
    return SafeArea(
      child: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),

              Stack(
                children: [
                  //!Image
                  uploading
                  
                      ? ClipOval(
                          child: Container(
                            color: themeColor,
                            width: 64,
                            height: 64,
                            child: const CircularProgressIndicator()
                          ),
                        )
                      : user.userImage.isEmpty
                          ? ClipOval(
                              child: Container(
                                color: themeColor,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    width: 64,
                                    height: 64,
                                    child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          context: context,
                                          builder: (context) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                //!Camera Button
                                                SettingsTile(
                                                  isEnabled: true,
                                                  isSelected: false,
                                                  icon: Icons.camera,
                                                  circleColor: isDarkMode
                                                      ? darkBorderTheme
                                                      : themeColor,
                                                  iconColor: isDarkMode
                                                      ? themeColor
                                                      : Colors.white,
                                                  tileColor: isDarkMode
                                                      ? darkBorderTheme
                                                      : lightBorderTheme,
                                                  borderColor: isDarkMode
                                                      ? darkBorderTheme
                                                      : lightBorderTheme,
                                                  title: 'Camera',
                                                  textColor: isDarkMode
                                                      ? darkTextTheme
                                                      : lightTextTheme,
                                                  subtitle: null,
                                                  trailing: null,
                                                  onTap: () async {
                                                    uploading = true;
                                                    final pickedFile =
                                                        await ImagePicker()
                                                            .pickImage(
                                                      source:
                                                          ImageSource.camera,
                                                    );
                                                    if (pickedFile != null) {
                                                      userImage =
                                                          File(pickedFile.path);

                                                      await updateProfile(
                                                          userImage);
                                                    }
                                                  },
                                                ),
                                                //!Gallery Buttton
                                                SettingsTile(
                                                  isEnabled: true,
                                                  isSelected: false,
                                                  icon: Icons.photo_library,
                                                  circleColor: isDarkMode
                                                      ? darkBorderTheme
                                                      : themeColor,
                                                  iconColor: isDarkMode
                                                      ? themeColor
                                                      : Colors.white,
                                                  tileColor: isDarkMode
                                                      ? darkBorderTheme
                                                      : lightBorderTheme,
                                                  borderColor: isDarkMode
                                                      ? darkBorderTheme
                                                      : lightBorderTheme,
                                                  title: 'Gallery',
                                                  textColor: isDarkMode
                                                      ? darkTextTheme
                                                      : lightTextTheme,
                                                  subtitle: null,
                                                  trailing: null,
                                                  onTap: () async {
                                                    final pickedFile =
                                                        await ImagePicker()
                                                            .pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                    if (pickedFile != null) {
                                                      userImage =
                                                          File(pickedFile.path);
                                                      await updateProfile(
                                                          userImage);
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Center(
                                        child: Text(
                                          user.userName[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ProfileImage(
                              imagePath: user.userImage,
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        //!Camera Button
                                        SettingsTile(
                                          isEnabled: true,
                                          isSelected: false,
                                          icon: Icons.camera,
                                          circleColor: isDarkMode
                                              ? darkBorderTheme
                                              : themeColor,
                                          iconColor: isDarkMode
                                              ? themeColor
                                              : Colors.white,
                                          tileColor: isDarkMode
                                              ? darkBorderTheme
                                              : lightBorderTheme,
                                          borderColor: isDarkMode
                                              ? darkBorderTheme
                                              : lightBorderTheme,
                                          title: 'Camera',
                                          textColor: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme,
                                          subtitle: null,
                                          trailing: null,
                                          onTap: () async {
                                            final pickedFile =
                                                await ImagePicker().pickImage(
                                              source: ImageSource.camera,
                                            );
                                            if (pickedFile != null) {
                                              userImage = File(pickedFile.path);
                                              await updateProfile(userImage);
                                            }
                                          },
                                        ),
                                        //!Gallery Buttton
                                        SettingsTile(
                                          isEnabled: true,
                                          isSelected: false,
                                          icon: Icons.photo_library,
                                          circleColor: isDarkMode
                                              ? darkBorderTheme
                                              : themeColor,
                                          iconColor: isDarkMode
                                              ? themeColor
                                              : Colors.white,
                                          tileColor: isDarkMode
                                              ? darkBorderTheme
                                              : lightBorderTheme,
                                          borderColor: isDarkMode
                                              ? darkBorderTheme
                                              : lightBorderTheme,
                                          title: 'Gallery',
                                          textColor: isDarkMode
                                              ? darkTextTheme
                                              : lightTextTheme,
                                          subtitle: null,
                                          trailing: null,
                                          onTap: () async {
                                            final pickedFile =
                                                await ImagePicker().pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            if (pickedFile != null) {
                                              userImage = File(pickedFile.path);
                                              await updateProfile(userImage);
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),

                  //!Camera Icon
                  Positioned(
                    bottom: -10,
                    right: -15,
                    child: IconWidget(
                      icon: Icons.camera_alt,
                      color: isDarkMode ? darkBorderTheme : lightBorderTheme,
                      iconColor: themeColor,
                      text: '',
                      textColor: darkTextTheme,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              //!Welcome Text
              Text(
                'Welcome Back, \n${user.userName}',
                style: TextStyle(
                  color: isDarkMode ? darkTextTheme : lightTextTheme,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 10,
              ),

              //!Home Button
              SettingsTile(
                isEnabled: isHomeEnabled,
                isSelected: isHomeSelected,
                disabledTileColor:
                    isDarkMode ? darkTheme : Colors.grey.shade500,
                icon: Icons.home,
                circleColor: isDarkMode ? darkBorderTheme : themeColor,
                iconColor: isDarkMode ? themeColor : Colors.white,
                tileColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                borderColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                title: 'Home',
                textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                subtitle: null,
                onTap: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return const NotesView();
                      },
                    ),
                  );
                },
                trailing: null,
              ),

              //!Archive Button
              SettingsTile(
                isEnabled: isArchivedEnabled,
                isSelected: isArchivedSelected,
                disabledTileColor:
                    isDarkMode ? darkTheme : Colors.grey.shade500,
                icon: Icons.archive,
                circleColor: isDarkMode ? darkBorderTheme : themeColor,
                iconColor: isDarkMode ? themeColor : Colors.white,
                tileColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                borderColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                title: 'Archive',
                textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                subtitle: null,
                onTap: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return const ArchivedNotesView();
                      },
                    ),
                  );
                },
                trailing: null,
              ),

              //!Categories Button
              SettingsTile(
                isEnabled: isCategoryEnabled,
                isSelected: isCategorySelected,
                disabledTileColor:
                    isDarkMode ? darkTheme : Colors.grey.shade500,
                icon: Icons.category,
                circleColor: isDarkMode ? darkBorderTheme : themeColor,
                iconColor: isDarkMode ? themeColor : Colors.white,
                tileColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                borderColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                title: 'Categories',
                textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                subtitle: null,
                onTap: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return const CategoryNotesView();
                      },
                    ),
                  );
                },
                trailing: null,
              ),

              //!Trash Button
              SettingsTile(
                isEnabled: isTrashEnabled,
                isSelected: isTrashSelected,
                disabledTileColor:
                    isDarkMode ? darkTheme : Colors.grey.shade500,
                icon: Icons.delete,
                circleColor: isDarkMode ? darkBorderTheme : themeColor,
                iconColor: isDarkMode ? themeColor : Colors.white,
                tileColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                borderColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                title: 'Trash',
                textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                subtitle: null,
                onTap: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        return const TrashNotesView();
                      },
                    ),
                  );
                },
                trailing: null,
              ),

              //!Settings Button
              SettingsTile(
                isEnabled: true,
                isSelected: false,
                icon: Icons.settings,
                circleColor: isDarkMode ? darkBorderTheme : themeColor,
                iconColor: isDarkMode ? themeColor : Colors.white,
                tileColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                borderColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                title: 'Settings',
                textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                subtitle: null,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    settingsRoute,
                  );
                },
                trailing: null,
              ),

              //!Logout Button
              SettingsTile(
                isEnabled: true,
                isSelected: false,
                icon: Icons.logout,
                circleColor: isDarkMode ? darkBorderTheme : themeColor,
                iconColor: isDarkMode ? themeColor : Colors.white,
                tileColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                borderColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
                title: 'Logout',
                textColor: isDarkMode ? darkTextTheme : lightTextTheme,
                subtitle: null,
                onTap: () async {
                  final confirmLogout = await logoutConfirmation(context);
                  if (confirmLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                },
                trailing: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
