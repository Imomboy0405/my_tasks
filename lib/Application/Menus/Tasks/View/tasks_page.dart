import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Menus/Tasks/Bloc/tasks_bloc.dart';
import 'package:my_tasks/Application/Menus/View/menu_widgets.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import 'package:my_tasks/Configuration/app_text_styles.dart';
import 'package:my_tasks/Data/Models/task_model.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/logic_service.dart';

class TasksPage extends StatefulWidget {
  static const id = '/tasks_page';

  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with AutomaticKeepAliveClientMixin {
  static bool first = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<MainBloc, MainState>(builder: (context, state) {
      final mainBloc = BlocProvider.of<MainBloc>(context);
      return BlocProvider(
        create: (context) => TasksBloc(mainBloc: mainBloc),
        child: BlocBuilder<TasksBloc, TasksState>(builder: (context, state) {
          TasksBloc bloc = context.read<TasksBloc>();
          if (first) {
            bloc.dayController.addListener(() => bloc.add(ListenEvent(width: MediaQuery.of(context).size.width)));
            bloc.add(InitialDayControllerEvent(width: MediaQuery.of(context).size.width));
            bloc.add(DayButtonEvent(selectedDay: bloc.selectedDay));
            first = false;
          }

          return Stack(
            children: [
              // #default_screen
              Scaffold(
                backgroundColor: AppColors.transparent,
                appBar: MyAppBar(
                  titleText: 'tasks'.tr(),
                  functionFilter: () => bloc.add(FilterEvent()),
                ),
                body: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // #day_month_year
                      if (!bloc.filterEnabled)
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.darker,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.transparentGray,
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // #month_year_buttons
                              SizedBox(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 10),
                                  child: Row(
                                    children: [
                                      // #month_year
                                      Text(
                                        '${bloc.monthNames[mainBloc.selectedMonth - 1].tr()}, ${mainBloc.selectedYear}',
                                        style: AppTextStyles.style18_1(context),
                                      ),
                                      const Spacer(),

                                      // #buttons_left_right
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.centerRight,
                                        highlightColor: AppColors.transparentWhite,
                                        onPressed: () => bloc.add(MonthButtonEvent(left: true, width: MediaQuery.of(context).size.width)),
                                        icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        highlightColor: AppColors.transparentWhite,
                                        onPressed: () => bloc.add(MonthButtonEvent()),
                                        icon: Icon(Icons.arrow_forward_ios, color: AppColors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // #day_buttons
                              Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  // #animations
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Lottie.asset(
                                      'assets/animations/animation_right_light.json',
                                      width: 72,
                                      height: 72,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Lottie.asset(
                                      'assets/animations/animation_left_light.json',
                                      width: 72,
                                      height: 72,
                                    ),
                                  ),

                                  // #day_buttons
                                  SizedBox(
                                    height: 72,
                                    child: ListView.builder(
                                      key: widget.key,
                                      itemBuilder: (BuildContext context, int index) {
                                        return MyMonthDayButton(
                                          onPressed: () => bloc.add(DayButtonEvent(selectedDay: index + 1)),
                                          weekDay:
                                              LogicService.weekDayName(year: bloc.selectedYear, month: bloc.selectedMonth, day: index + 1)
                                                  .tr(),
                                          monthDay: (index + 1).toString(),
                                          selected: index + 1 == mainBloc.selectedDay,
                                        );
                                      },
                                      dragStartBehavior: DragStartBehavior.down,
                                      controller: bloc.dayController,
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: bloc.monthDays[bloc.selectedMonth - 1] == 28 && bloc.selectedYear == 2024
                                          ? 29
                                          : bloc.monthDays[bloc.selectedMonth - 1],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // #tasks
                      RefreshIndicator(
                        onRefresh: () async => bloc.add(RefreshEvent(context: context)),
                        color: AppColors.blue,
                        backgroundColor: AppColors.transparentBlue,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - (bloc.filterEnabled ? 170 : 320),
                          child: CustomScrollView(
                            controller: bloc.invoiceController,
                            slivers: [
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  SizedBox(
                                    height: bloc.filterEnabled
                                        ? (bloc.filterTasks.length * 162) < (MediaQuery.of(context).size.height - 235)
                                            ? MediaQuery.of(context).size.height - 235
                                            : (bloc.filterTasks.length * 162)
                                        : (mainBloc.filterTasks.length * 162) < (MediaQuery.of(context).size.height - 386)
                                            ? MediaQuery.of(context).size.height - 386
                                            : (mainBloc.filterTasks.length * 162),
                                    child: ((bloc.filterEnabled ? bloc.filterTasks.length : mainBloc.filterTasks.length) == 0)
                                        ? MyNotFoundWidget(text: 'tasks_not_found'.tr())
                                        : ReorderableListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: (bloc.filterEnabled ? bloc.filterTasks.length : mainBloc.filterTasks.length),
                                            onReorder: (int oldIndex, int newIndex) =>
                                                bloc.add(OnReorderEvent(newIndex: newIndex, oldIndex: oldIndex)),
                                            itemBuilder: (BuildContext c, int index) {
                                              return
                                                  // #task_container
                                                  MyTaskContainer(
                                                key: Key(
                                                  bloc.filterEnabled ? bloc.filterTasks[index].id! : mainBloc.filterTasks[index].id!,
                                                ),
                                                index: index,
                                                taskModel: bloc.filterEnabled ? bloc.filterTasks[index] : mainBloc.filterTasks[index],
                                                onPressed: (c) => bloc.add(SinglePageEvent(index: index, context: c)),
                                                dismissibleFunc: () => bloc.add(DeleteEvent(
                                                  model: bloc.filterEnabled ? bloc.filterTasks[index] : mainBloc.filterTasks[index],
                                                  context: context,
                                                )),
                                              );
                                            },
                                          ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // #filter_screen
              if (state is TasksFilterState)
                MyFilterPage(
                  cancelPress: () => bloc.add(CancelFilterEvent()),
                  applyPress: () => bloc.add(ApplyFilterEvent(context: context)),
                  removePress: () => bloc.add(CancelFilterEvent(remove: true, width: MediaQuery.of(context).size.width)),
                  pressStatus: (TaskStatus status) => bloc.add(StatusFilterEvent(status: status)),
                  filterInProcess: bloc.statusInProcess,
                  filterCompleted: bloc.statusCompleted,
                  filterNotCompleted: bloc.statusNotCompleted,
                ),

              // #loading_screen
              if (state is TasksLoadingState) myIsLoading(context),
            ],
          );
        }),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
