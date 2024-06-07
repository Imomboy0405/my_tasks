import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Menus/View/menu_widgets.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import 'package:my_tasks/Configuration/app_text_styles.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';

import '../Bloc/start_bloc.dart';

class StartPage extends StatelessWidget {
  static const id = '/start_page';

  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StartBloc(),
      child: BlocBuilder<StartBloc, StartState>(
        builder: (context, state) {
          StartBloc bloc = context.read<StartBloc>();
          return Scaffold(
            backgroundColor: AppColors.black,
            appBar: AppBar(
              elevation: 0,
              toolbarHeight: 91,
              backgroundColor: AppColors.black,

              // #flag
              actions: [
                MyFlagButton(currentLang: bloc.selectedLang, pageContext: context, pageName: id),
              ],

              // #IBilling
              title: Text('My Tasks', style: AppTextStyles.style0_1(context)),
              leadingWidth: 60,
            ),
            body: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTabController(
                    length: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: const TabBarView(
                            children: [
                              StartView(img: 1),
                              StartView(img: 2),
                              StartView(img: 3),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          width: 50,
                          child: TabPageSelector(
                            indicatorSize: 8,
                            color: AppColors.darkGrey,
                            selectedColor: AppColors.blue,
                            borderStyle: BorderStyle.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Container(
                    padding: const EdgeInsets.only(bottom: 48, right: 24, left: 24),
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // #next
                        MaterialButton(
                          onPressed: () => context.read<StartBloc>().add(NextEvent(context: context)),
                          color: AppColors.blue,
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          height: 48,
                          child: Text('log_in'.tr(), style: AppTextStyles.style4(context).copyWith(color: Colors.white)),
                        ),
                        const Spacer(),

                        // #text
                        Text(
                          'log_info'.tr(),
                          style: AppTextStyles.style2(context),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class StartView extends StatelessWidget {
  final int img;

  const StartView({super.key, required this.img});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartBloc, StartState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // #images_tabview
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: AppColors.transparentGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Image(
                      image: AssetImage('assets/images/img_$img.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: MediaQuery.of(context).size.height * 0.22,
              padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // #text
                  Text(
                    'welcome_$img'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style1(context),
                  ),
                  Text(
                    'welcome_info'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style2(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
