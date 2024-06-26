import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Menus/Profile/Bloc/profile_bloc.dart';
import 'package:my_tasks/Application/Menus/View/menu_widgets.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import 'package:my_tasks/Configuration/app_text_styles.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';

class ProfilePage extends StatefulWidget {
  static const id = '/profile_page';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<MainBloc, MainState>(builder: (context, state) {
      final mainBloc = BlocProvider.of<MainBloc>(context);
      return BlocProvider(
          create: (context) => ProfileBloc(mainBloc: mainBloc),
          child: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
            ProfileBloc bloc = context.read<ProfileBloc>();

            if ((bloc.fullName == ''
                || (mainBloc.darkMode != bloc.darkMode)
                || (mainBloc.language != bloc.selectedLang)) && state is ProfileInitialState) {
              context.read<ProfileBloc>().add(InitialUserEvent());
            }
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: AppColors.transparent,

                  appBar: MyAppBar(titleText: 'profile'.tr()),

                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // #profil
                        Container(
                          height: 120,
                          margin: const EdgeInsets.only(top: 20, bottom: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 0.5,
                                blurRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // #full_name
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_circle_rounded, color: AppColors.blue, size: 48),
                                  const SizedBox(width: 10),
                                  Text('my_tasks_user'.tr(), style: AppTextStyles.style19(context)),
                                ],
                              ),

                              // #date_of_sign_up
                              Row(
                                children: [
                                  Text("${'date_sign'.tr()}:", style: AppTextStyles.style19(context)),
                                  const SizedBox(width: 10),
                                  Text(bloc.dateSign, style: AppTextStyles.style23(context)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // #theme
                        MyProfileButton(
                          text: 'theme'.tr(),
                          function: () => context.read<ProfileBloc>().add(DarkModeEvent(darkMode: !bloc.darkMode)),
                          endElement: SizedBox(
                            height: 30,
                            child: ToggleButtons(
                              selectedColor: Colors.white,
                              color: AppColors.darkGrey,
                              fillColor: AppColors.blue,
                              hoverColor: AppColors.red,
                              splashColor: AppColors.blue,
                              borderColor: AppColors.darkGrey,
                              borderWidth: 0.3,
                              borderRadius: BorderRadius.circular(6),
                              isSelected: [!mainBloc.darkMode, mainBloc.darkMode],
                              onPressed: (i) => context.read<ProfileBloc>().add(DarkModeEvent(darkMode: i == 1)),
                              children: const <Widget>[
                                Icon(CupertinoIcons.sun_max_fill, size: 20),
                                Icon(CupertinoIcons.moon_stars_fill, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // #language
                        MyProfileButton(
                          text: 'current_lang'.tr(),
                          function: () => context.read<ProfileBloc>().add(LanguageEvent()),
                          endElement: Image(
                            image: AssetImage('assets/icons/ic_flag_${bloc.selectedLang.name}.png'),
                            width: 20,
                            height: 20,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // #sign_out
                        MyProfileButton(
                          text: 'sign_out'.tr(),
                          function: () => context.read<ProfileBloc>().add(SignOutEvent()),
                          endElement: const Icon(CupertinoIcons.square_arrow_right, size: 24, color: AppColors.red),
                        ),
                        const SizedBox(height: 10),

                        // #info
                        MyProfileButton(
                          text: 'info'.tr(),
                          function: () => context.read<ProfileBloc>().add(InfoEvent()),
                          endElement:  Icon(CupertinoIcons.info, size: 24, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // #choose_language_screen
                if (state is ProfileLangState)
                  MyProfileScreen(
                    doneButton: true,
                    textTitle: 'choose_lang'.tr(language: bloc.selectedLang),
                    textCancel: 'cancel'.tr(language: bloc.selectedLang),
                    textDone: 'done'.tr(language: bloc.selectedLang),
                    functionCancel: () => context.read<ProfileBloc>().add(CancelEvent()),
                    functionDone: () => context.read<ProfileBloc>().add(DoneEvent(context: context)),
                    // #languages
                    child: SizedBox(
                      height: 175,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        padding: EdgeInsets.zero,
                        itemBuilder: (c, index) {
                          return RadioListTile(
                              activeColor: AppColors.blue,
                              hoverColor: AppColors.blue,
                              overlayColor: MaterialStatePropertyAll(AppColors.transparentBlue),
                              selectedTileColor: AppColors.blue,
                              controlAffinity: ListTileControlAffinity.trailing,
                              contentPadding: EdgeInsets.zero,
                              secondary: Image(
                                image: AssetImage('assets/icons/ic_flag_${bloc.lang[index].name}.png'),
                                width: 24,
                                height: 24,
                                fit: BoxFit.fill,
                              ),
                              title: Text('button_$index'.tr(), style: AppTextStyles.style23(context)),
                              selected: bloc.lang[index] == bloc.selectedLang,
                              value: bloc.lang[index],
                              groupValue: bloc.selectedLang,
                              onChanged: (value) => context.read<ProfileBloc>()
                                  .add(SelectLanguageEvent(lang: value as Language)));
                        },
                      ),
                    ),
                  ),

                // #sign_out_screen
                if (state is ProfileSignOutState)
                  MyProfileScreen(
                    doneButton: true,
                    textTitle: 'sign_out'.tr(),
                    textCancel: 'cancel'.tr(),
                    textDone: 'confirm'.tr(),
                    functionCancel: () => context.read<ProfileBloc>().add(CancelEvent()),
                    functionDone: () => context.read<ProfileBloc>().add(ConfirmEvent(context: context)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('confirm_sign_out'.tr(), style: AppTextStyles.style23(context)),
                    ),
                  ),


                // #info_screen
                if (state is ProfileInfoState)
                  MyProfileScreen(
                    textTitle: 'info'.tr(),
                    textCancel: 'back'.tr(),
                    functionCancel: () => context.read<ProfileBloc>().add(CancelEvent()),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('info_text'.tr(), style: AppTextStyles.style23(context)),
                    ),
                  ),
              ],
            );
          }
          ),
        );
      }
    );
  }

  @override
  bool get wantKeepAlive => true;
}

