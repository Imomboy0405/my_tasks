import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Menus/New/View/new_page.dart';
import 'package:my_tasks/Application/Menus/Profile/View/profile_page.dart';
import 'package:my_tasks/Application/Menus/Tasks/View/tasks_page.dart';
import 'package:my_tasks/Application/Menus/View/menu_widgets.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import '../Bloc/main_bloc.dart';

class MainPage extends StatelessWidget {
  static const id = '/main_page';

  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => MainBloc(),
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          MainBloc bloc = context.read<MainBloc>();
          bloc.controller.addListener(() => bloc.listen());
          return Scaffold(
            backgroundColor: AppColors.black,
            body: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 200,
                      height: 83,
                      color: AppColors.dark,
                    ),
                    MyBottomNavigationBar(screenWidth: screenWidth, bloc: bloc),

                    PageView(
                      physics: state is MainInitialState
                                 ? const BouncingScrollPhysics()
                                 : const NeverScrollableScrollPhysics(),
                      controller: bloc.controller,
                      pageSnapping: true,
                      children: const [
                        TasksPage(),
                        NewPage(),
                        ProfilePage(),
                      ],
                    ),

                    if(state is! MainHideBottomNavigationBarState)
                      MyBottomNavigationBar(screenWidth: screenWidth, bloc: bloc),

                  ],
                ),
              ),
            ),

          );
        },
      ),
    );
  }
}
