import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Menus/View/Single/Bloc/single_bloc.dart';
import 'package:my_tasks/Application/Menus/View/menu_widgets.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import 'package:my_tasks/Configuration/app_text_styles.dart';
import 'package:my_tasks/Data/Models/task_model.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';

class SinglePage extends StatelessWidget {
  static const String id = '/single_page';
  final TaskModel taskModel;
  final MainBloc mainBloc;

  const SinglePage({
    super.key,
    required this.mainBloc,
    required this.taskModel
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainBloc(),
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return BlocProvider(
            create: (context) => SingleBloc(
              mainBloc: mainBloc,
              taskModel: taskModel,
            ),
            child: BlocBuilder<SingleBloc, SingleState>(
              builder: (context, state) {
                SingleBloc bloc = context.read<SingleBloc>();
                if (bloc.initial) {
                  bloc.add(CompletedButtonEvent(context: context));
                }
                return Stack(
                  children: [
                    Scaffold(
                      backgroundColor: AppColors.black,
                      appBar: AppBar(
                        backgroundColor: AppColors.darker,
                        surfaceTintColor: AppColors.black,
                        elevation: 2,
                        shadowColor: AppColors.gray,
                        leading: const SizedBox.shrink(),
                        leadingWidth: 0,
                        titleSpacing: 10,
                        title: Row(
                          children: [
                            // #icon
                            const SizedBox(width: 10),
                            const Image(
                              image: AssetImage('assets/icons/ic_task.png'),
                              width: 24,
                              height: 24,
                              fit: BoxFit.fill,
                            ),
                            const SizedBox(width: 12),

                            // #my_task
                            Text(
                              'my_task'.tr(),
                              style: AppTextStyles.style18_1(context),
                            ),

                            // #completed
                            const Spacer(),
                            IconButton(
                              onPressed: () => bloc.add(CompletedButtonEvent(context: context)),
                              highlightColor: AppColors.transparentWhite,
                              icon: Image(
                                image: AssetImage('assets/icons/ic_done_${bloc.completed ? 'fill' : 'outlined'}.png'),
                                height: 24,
                                width: 24,
                                color: bloc.completed ? AppColors.white : AppColors.lightGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      body: SingleChildScrollView(
                        controller: bloc.controller,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // #task
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.dark,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 0.5,
                                    blurRadius: 1.5,
                                    offset: const Offset(0, 2.5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // #title
                                  RichText(
                                    text: TextSpan(
                                      text: '${'title'.tr()}:  ',
                                      style: AppTextStyles.style19(context),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: bloc.taskModel.title,
                                          style: AppTextStyles.style23(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),

                                  // #content
                                  RichText(
                                    text: TextSpan(
                                      text: '${'content'.tr()}:  ',
                                      style: AppTextStyles.style19(context),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: bloc.taskModel.content,
                                          style: AppTextStyles.style23(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),

                                  // #status
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${'status'.tr()}:  ', style: AppTextStyles.style19(context)),
                                      Flexible(
                                        child: Text(
                                          bloc.taskModel.status!.name.tr(),
                                          style: AppTextStyles.style23(context),
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),

                                  // #created_time
                                  Row(
                                    children: [
                                      Text('${'create_time'.tr()}:  ', style: AppTextStyles.style19(context)),
                                      Text(
                                        bloc.taskModel.createdTime!.toString().substring(0,16),
                                        style: AppTextStyles.style23(context),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),

                                  // #end_time
                                  Row(
                                    children: [
                                      Text('${'end_date'.tr()}:  ', style: AppTextStyles.style19(context)),
                                      Text(
                                        bloc.taskModel.endDate!.toString().substring(0,16),
                                        style: AppTextStyles.style23(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // #delete_create_buttons
                            Padding(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // #delete_button
                                    Flexible(
                                      child: SingleButton(
                                        red: true,
                                        text: 'delete_task'.tr(),
                                        onPressed: () => bloc.add(DeleteButtonEvent()),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // #create_button
                                    Flexible(
                                      child: SingleButton(
                                        text: 'create_task'.tr(),
                                        onPressed: () => bloc.add(CreateButtonEvent(context: context)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                          ],
                        ),
                      ),
                    ),

                    // #delete_screen
                    if (state is SingleDeleteState)
                      MyProfileScreen(
                        red: true,
                        doneButton: true,
                        functionCancel: () => bloc.add(DeleteCancelEvent()),
                        functionDone: () => bloc.add(DeleteConfirmEvent(context: context)),
                        textCancel: 'cancel'.tr(),
                        textDone: 'done'.tr(),
                        textTitle: 'delete_this_task'.tr(),
                        child: const SizedBox.shrink(),
                      ),

                    // #loading_screen
                    if (state is SingleLoadingState) myIsLoading(context),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
