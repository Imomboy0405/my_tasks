import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Welcome/Start/Bloc/start_bloc.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import 'package:my_tasks/Configuration/app_text_styles.dart';
import 'package:my_tasks/Data/Models/task_model.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/logic_service.dart';
import 'package:my_tasks/Data/Services/util_service.dart';

class MyFlagButton extends StatelessWidget {
  const MyFlagButton({
    super.key,
    required this.currentLang,
    required this.pageContext,
    required this.pageName,
  });

  final String pageName;
  final BuildContext pageContext;
  final Language currentLang;
  static const List<Language> lang = [
    Language.uz,
    Language.ru,
    Language.en,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 40,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            showModalBottomSheet(
              elevation: 0,
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.47,
                  maxChildSize: 0.5,
                  expand: true,
                  builder: (BuildContext cont, ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                          color: AppColors.darker,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 4,
                        itemBuilder: (c, index) {
                          return index == 0
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'choose_lang'.tr(),
                                    style: AppTextStyles.style4(context),
                                  ),
                                )
                              : RadioListTile(
                                  activeColor: AppColors.blue,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  secondary: Image(
                                    image: AssetImage('assets/icons/ic_flag_${lang[index - 1].name}.png'),
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.fill,
                                  ),
                                  title: Text('button_${index - 1}'.tr(), style: AppTextStyles.style15(context)),
                                  selected: lang[index - 1] == currentLang,
                                  value: lang[index - 1],
                                  groupValue: currentLang,
                                  onChanged: (value) {
                                    pageContext.read<StartBloc>().add(SelectLanguageEvent(lang: value as Language));
                                    Navigator.pop(cont);
                                  });
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
          icon: Image(
            image: AssetImage('assets/icons/ic_flag_${currentLang.name}.png'),
            width: 28,
            height: 28,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class MyProfileButton extends StatelessWidget {
  final Function function;
  final String text;
  final Widget endElement;

  const MyProfileButton({
    super.key,
    required this.text,
    required this.function,
    required this.endElement,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => function(),
      height: 44,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      color: AppColors.dark,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: AppTextStyles.style19(context)),
          endElement,
        ],
      ),
    );
  }
}

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({
    super.key,
    required this.textTitle,
    required this.textCancel,
    this.textDone,
    required this.functionCancel,
    this.functionDone,
    required this.child,
    this.doneButton = false,
    this.red = false,
  });

  final String textTitle;
  final String textCancel;
  final String? textDone;
  final Function functionCancel;
  final Function? functionDone;
  final Widget child;
  final bool doneButton;
  final bool red;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // #backgoround
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: () => functionCancel(),
            splashColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: AppColors.transparentBlack,
              ),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: AppColors.transparent,
                child: Text(textTitle, style: AppTextStyles.style20(context), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              child,
              // #cancel_done_button
              Row(
                mainAxisAlignment: doneButton ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: [
                  red
                      ? Flexible(
                          child: SingleButton(
                            onPressed: () => functionCancel(),
                            red: true,
                            text: textCancel,
                          ),
                        )
                      : SelectButton(
                          context: context,
                          text: textCancel,
                          function: () => functionCancel(),
                          select: false,
                        ),
                  const SizedBox(width: 15),
                  if (doneButton)
                    red
                        ? Flexible(
                            child: SingleButton(
                              onPressed: () => functionDone!(),
                              red: true,
                              redDone: true,
                              text: textDone!,
                            ),
                          )
                        : SelectButton(
                            context: context,
                            text: textDone!,
                            function: () => functionDone!(),
                            select: true,
                            selectFunctionOn: true,
                          ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SelectButton extends StatelessWidget {
  final BuildContext context;
  final Function function;
  final String text;
  final bool select;
  final bool selectFunctionOn;

  const SelectButton({
    super.key,
    required this.context,
    required this.function,
    required this.text,
    required this.select,
    this.selectFunctionOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => select
          ? selectFunctionOn
              ? function()
              : () {}
          : function(),
      color: select ? AppColors.blue : AppColors.transparentBlue,
      splashColor: AppColors.blue,
      elevation: 0,
      highlightColor: AppColors.transparentBlue,
      minWidth: (MediaQuery.of(context).size.width - 130) / 2,
      height: 37,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: select ? AppTextStyles.style13(context).copyWith(color: Colors.white) : AppTextStyles.style14(context),
      ),
    );
  }
}

class SingleButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final bool red;
  final bool redDone;

  const SingleButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.red = false,
    this.redDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(),
      height: 40,
      minWidth: double.infinity,
      elevation: 0,
      color: redDone
          ? AppColors.red
          : red
              ? AppColors.transparentRed
              : AppColors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: red && !redDone ? AppTextStyles.style23_2(context) : AppTextStyles.style23_1(context).copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final Function? functionFilter;

  const MyAppBar({
    super.key,
    required this.titleText,
    this.functionFilter,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      backgroundColor: functionFilter != null ? AppColors.darker : AppColors.black,
      surfaceTintColor: AppColors.black,
      shadowColor: AppColors.gray,
      titleSpacing: 10,
      title: Row(
        children: [
          // #color_image
          const SizedBox(width: 10),
          const Image(
            image: AssetImage('assets/icons/ic_app.png'),
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          const SizedBox(width: 12),

          // #title
          Text(titleText, style: AppTextStyles.style18(context)),
          const Spacer(),

          // #filter
          if (functionFilter != null)
            IconButton(
                onPressed: () => functionFilter!(),
                highlightColor: AppColors.transparentWhite,
                icon: Image(image: const AssetImage('assets/icons/ic_filter.png'), width: 22, height: 22, color: AppColors.white)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size(0, 57);
}

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({
    super.key,
    required this.screenWidth,
    required this.bloc,
  });

  final double screenWidth;
  final MainBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      height: 83,
      decoration: BoxDecoration(
        color: AppColors.darker,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * .01),
        itemBuilder: (context, index) => SizedBox(
          width: screenWidth * .327,
          child: MaterialButton(
            onPressed: () => bloc.add(MainMenuButtonEvent(index: index)),
            splashColor: AppColors.transparentWhite,
            highlightColor: AppColors.transparentBlack,
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // #menu_icon
                Image(
                  image: index == bloc.currentScreen ? bloc.listOfMenuIcons[index + 3] : bloc.listOfMenuIcons[index],
                  height: index == bloc.currentScreen ? 30 : 26,
                  width: index == bloc.currentScreen ? 30 : 36,
                  color: index == bloc.currentScreen ? AppColors.white : AppColors.lightGrey,
                ),

                // #menu_text
                Text(bloc.listOfMenuTexts[index].tr(),
                    style: index == bloc.currentScreen ? AppTextStyles.style21(context) : AppTextStyles.style22(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Container myIsLoading(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    color: AppColors.transparentBlack,
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      color: AppColors.blue,
      backgroundColor: AppColors.transparentBlue,
    ),
  );
}

class MyNewTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onChanged;
  final Function onSubmitted;
  final bool suffixIconDone;
  final String snackBarText;
  final TextInputType textInputType;

  const MyNewTextField({
    super.key,
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.suffixIconDone,
    required this.snackBarText,
    required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: controller.text.isNotEmpty || focusNode.hasFocus ? AppTextStyles.style26(context) : AppTextStyles.style25(context),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .22),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (v) => onChanged(),
            onTap: () => onChanged(),
            onSubmitted: (v) => onSubmitted(),
            style: AppTextStyles.style13(context),
            cursorColor: AppColors.white,
            maxLines: null,
            keyboardType: textInputType,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 10),
              suffixIcon: controller.text.isNotEmpty || focusNode.hasFocus
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => !suffixIconDone ? Utils.mySnackBar(context: context, txt: snackBarText, errorState: true) : {},
                      icon:
                          suffixIconDone ? Icon(Icons.done, color: AppColors.white) : const Icon(Icons.error_outline, color: AppColors.red),
                    )
                  : const SizedBox.shrink(),
              enabledBorder: myInputBorder(
                itsColor1: controller.text.isNotEmpty || focusNode.hasFocus,
                color1: AppColors.white,
                color2: AppColors.gray,
              ),
              focusedBorder: myInputBorder(color1: AppColors.white),
              errorBorder: myInputBorder(color1: AppColors.red),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

OutlineInputBorder myInputBorder({required Color color1, bool itsColor1 = true, Color? color2}) {
  return OutlineInputBorder(
    gapPadding: 1,
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(width: 1.2, color: itsColor1 ? color1 : color2!),
  );
}

class MyDropdownButton extends StatelessWidget {
  const MyDropdownButton({
    super.key,
    required this.status,
    required this.titleText,
    required this.focusNode,
    required this.statusList,
    required this.onChanged,
  });

  final String? status;
  final String titleText;
  final List<String> statusList;
  final FocusNode focusNode;
  final void Function(String status) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titleText, style: status == null ? AppTextStyles.style25(context) : AppTextStyles.style26(context)),
        const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          width: double.infinity,
          height: 44,
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1.2,
              color: status == null ? AppColors.gray : AppColors.white,
            ),
          ),
          child: DropdownButton<String>(
            value: status,
            isExpanded: true,
            icon: const Icon(Icons.expand_circle_down_rounded),
            focusNode: focusNode,
            underline: const SizedBox.shrink(),
            padding: const EdgeInsets.only(left: 15, right: 10),
            borderRadius: BorderRadius.circular(6),
            dropdownColor: AppColors.dark,
            iconEnabledColor: status == null ? AppColors.gray : AppColors.white,
            selectedItemBuilder: (value) {
              return status != null
                  ? statusList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: AppTextStyles.style13(context)),
                      );
                    }).toList()
                  : [const DropdownMenuItem(child: SizedBox.shrink())];
            },
            items: statusList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: AppTextStyles.style23(context)),
              );
            }).toList(),
            onChanged: (status) => onChanged(status!),
          ),
        ),
      ],
    );
  }
}

class MyButton extends StatelessWidget {
  final bool enable;
  final String text;
  final Function function;
  final DisabledAction? disabledAction;

  const MyButton({
    super.key,
    required this.enable,
    required this.text,
    required this.function,
    this.disabledAction,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (enable) {
          function();
        } else {
          if (disabledAction != null) {
            Utils.mySnackBar(txt: disabledAction!.text, context: disabledAction!.context, errorState: true);
          }
        }
      },
      color: enable ? AppColors.blue : AppColors.transparentBlue,
      minWidth: double.infinity,
      height: 48,
      elevation: 0,
      highlightColor: AppColors.transparentBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: enable ? AppTextStyles.style4(context).copyWith(color: Colors.white) : AppTextStyles.style5(context)),
    );
  }
}

class DisabledAction {
  final String text;
  final BuildContext context;

  DisabledAction({required this.text, required this.context});
}

class MyDateButton extends StatelessWidget {
  final Function onPressed;
  final String text;

  const MyDateButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(),
      height: 37,
      color: AppColors.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: text == 'to'.tr() ? AppTextStyles.style19_1(context) : AppTextStyles.style19(context)),
            Icon(Icons.calendar_month, size: 16, color: text == 'to'.tr() ? AppColors.lightGrey : AppColors.white),
          ],
        ),
      ),
    );
  }
}

Theme myDatePickerTheme(Widget? child) => Theme(
      data: ThemeData.light().copyWith(
        primaryColor: AppColors.white,
        hintColor: AppColors.gray,
        colorScheme: ColorScheme.light(
          primary: AppColors.blue,
          onPrimary: AppColors.black,
          surface: AppColors.black,
          onSurface: AppColors.white,
        ),
        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
      ),
      child: child ?? Container(),
    );

class MyMonthDayButton extends StatelessWidget {
  const MyMonthDayButton({
    super.key,
    required this.onPressed,
    required this.weekDay,
    required this.monthDay,
    this.selected = false,
  });

  final Function onPressed;
  final String weekDay;
  final String monthDay;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darker,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 46,
        child: MaterialButton(
          padding: EdgeInsets.zero,
          onPressed: () => onPressed(),
          height: 72,
          elevation: 0,
          color: selected ? AppColors.blue : AppColors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // #weed_day
              Text(weekDay,
                  style: selected ? AppTextStyles.style23_1(context).copyWith(color: Colors.white) : AppTextStyles.style25_1(context)),
              const SizedBox(height: 4),

              // #month_day
              Text(monthDay,
                  style: selected ? AppTextStyles.style23_1(context).copyWith(color: Colors.white) : AppTextStyles.style25_1(context)),
              Divider(
                height: 10,
                color: selected ? Colors.white : AppColors.darkGrey,
                indent: 14,
                endIndent: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyFilterPage extends StatelessWidget {
  final void Function() cancelPress;
  final void Function() applyPress;
  final void Function() removePress;
  final void Function(TaskStatus status) pressStatus;
  final bool filterCompleted;
  final bool filterInProcess;
  final bool filterNotCompleted;

  const MyFilterPage({
    super.key,
    required this.cancelPress,
    required this.applyPress,
    required this.removePress,
    required this.pressStatus,
    required this.filterNotCompleted,
    required this.filterCompleted,
    required this.filterInProcess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.darker,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24, color: AppColors.white),
            highlightColor: AppColors.white,
            onPressed: () => cancelPress(),
          ),
          centerTitle: true,
          title: Text('filters'.tr(), style: AppTextStyles.style18_0(context)),
          actions: [
            MaterialButton(
              onPressed: () => removePress(),
              child: Text('remove'.tr(), style: AppTextStyles.style23_2(context)),
            )
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Flexible(
                child: Container(
                  color: AppColors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('status'.tr(), style: AppTextStyles.style23_3(context)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // #notCompleted
                          MyFilterDatePickerButton(
                            text: 'notCompleted'.tr(),
                            onPressed: () => pressStatus(TaskStatus.notCompleted),
                            selected: filterNotCompleted,
                          ),
                          const SizedBox(width: 10),

                          // #completed
                          MyFilterDatePickerButton(
                            text: 'completed'.tr(),
                            onPressed: () => pressStatus(TaskStatus.completed),
                            selected: filterCompleted,
                          ),
                        ],
                      ),
                      // #inProcess
                      MyFilterDatePickerButton(
                        text: 'inProcess'.tr(),
                        onPressed: () => pressStatus(TaskStatus.inProcess),
                        selected: filterInProcess,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Flexible(
                            child: MyFilterButton(
                              function: () => cancelPress(),
                              text: 'cancel'.tr(),
                              enable: false,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: MyFilterButton(
                              function: () => applyPress(),
                              text: 'apply_filter'.tr(),
                              enable: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 83,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      color: AppColors.transparentBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class MyFilterDatePickerButton extends StatelessWidget {
  final String text;
  final bool selected;
  final Function onPressed;

  const MyFilterDatePickerButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(),
      padding: EdgeInsets.zero,
      minWidth: 165,
      child: SizedBox(
        width: 160,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // #icon
            Image(
              image: AssetImage('assets/icons/ic_done_${selected ? 'fill' : 'outlined'}.png'),
              height: 24,
              width: 24,
              color: selected ? AppColors.white : AppColors.lightGrey,
            ),
            const SizedBox(width: 8),
            // #text
            Text(text, style: selected ? AppTextStyles.style19(context) : AppTextStyles.style19_1(context)),
          ],
        ),
      ),
    );
  }
}

class MyFilterButton extends StatelessWidget {
  final bool enable;
  final String text;
  final Function function;

  const MyFilterButton({
    super.key,
    required this.enable,
    required this.text,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => function(),
      color: enable ? AppColors.blue : AppColors.transparentBlue,
      minWidth: double.infinity,
      height: 40,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: enable ? AppTextStyles.style19(context) : AppTextStyles.style19_0(context)),
    );
  }
}

class MyTaskContainer extends StatelessWidget {
  final int index;
  final void Function(BuildContext c) onPressed;
  final TaskModel? taskModel;
  final Function? dismissibleFunc;

  const MyTaskContainer({
    super.key,
    required this.index,
    required this.onPressed,
    this.taskModel,
    this.dismissibleFunc,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      delay: const Duration(milliseconds: 50),
      child: SlideAnimation(
        duration: const Duration(milliseconds: 2000),
        curve: Curves.fastLinearToSlowEaseIn,
        horizontalOffset: 0,
        verticalOffset: 300.0,
        child: FlipAnimation(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastLinearToSlowEaseIn,
          flipAxis: FlipAxis.y,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Dismissible(
              key: Key(taskModel!.id!),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async => await dismissibleFunc!(),
              background: Container(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('delete'.tr(), style: AppTextStyles.style23_2(context)),
                    const SizedBox(width: 5),
                    const Icon(Icons.delete_sweep, color: AppColors.red, size: 32),
                  ],
                ),
              ),
              child: taskContainerChild(context),
            ),
          ),
        ),
      ),
    );
  }

  MaterialButton taskContainerChild(BuildContext context) {
    return MaterialButton(
      onPressed: () => onPressed(context),
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: AppColors.dark,
      child: SizedBox(
        height: 136,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // #status
            Row(
              children: [
                const Image(
                  image: AssetImage('assets/icons/ic_task.png'),
                  height: 18,
                  width: 18,
                ),
                const Spacer(),
                Container(
                  height: 21,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: switch (taskModel!.status!) {
                        TaskStatus.completed => AppColors.transparentBlueStatus,
                        TaskStatus.inProcess => AppColors.transparentOrange,
                        TaskStatus.notCompleted => AppColors.transparentRedStatus,
                      },
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(taskModel!.status!.name.tr(),
                      style: AppTextStyles.style27(context).copyWith(
                          color: switch (taskModel!.status!) {
                        TaskStatus.completed => AppColors.blueStatus,
                        TaskStatus.inProcess => AppColors.orange,
                        TaskStatus.notCompleted => AppColors.redStatus,
                      })),
                )
              ],
            ),
            const SizedBox(height: 5),

            // #title
            Text(taskModel!.title!, style: AppTextStyles.style19(context), maxLines: 1),

            // #content_created_time
            Row(
              children: [
                Expanded(child: Text(taskModel!.content.toString(), style: AppTextStyles.style23(context), maxLines: 2)),
                Text(taskModel!.createdTime!.toString().substring(0, 16),
                    style: AppTextStyles.style25_2(context).copyWith(color: AppColors.blue)),
              ],
            ),

            // #end_date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.clock_fill, color: AppColors.blue, size: 18),
                      Flexible(
                        child: Text(LogicService.difference(endDate: taskModel!.endDate!),
                            style: AppTextStyles.style19(context), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                Text(taskModel!.endDate!.toString().substring(0, 16),
                    style: AppTextStyles.style25_2(context).copyWith(color: AppColors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyNotFoundWidget extends StatelessWidget {
  final String text;

  const MyNotFoundWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Image(
              image: const AssetImage('assets/icons/ic_not_found.png'),
              color: AppColors.lightGrey,
              height: 100,
              width: 100,
            ),
          ),
          Text(
            text,
            style: AppTextStyles.style18(context),
          )
        ],
      ),
    );
  }
}
