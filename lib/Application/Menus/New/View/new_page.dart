import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/Application/Main/Bloc/main_bloc.dart';
import 'package:my_tasks/Application/Menus/New/Bloc/new_bloc.dart';
import 'package:my_tasks/Application/Menus/View/menu_widgets.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import 'package:my_tasks/Configuration/app_text_styles.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';
import 'package:my_tasks/Data/Services/logic_service.dart';

class NewPage extends StatelessWidget {
  static const id = '/new_page';

  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainBloc = BlocProvider.of<MainBloc>(context);
    return BlocProvider(
      create: (context) => NewBloc(mainBloc: mainBloc),
      child: BlocBuilder<NewBloc, NewState>(builder: (context, state) {
        NewBloc bloc = context.read<NewBloc>();
        return Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: MyAppBar(titleText: 'new_task'.tr()),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 83),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // #task_title
                      MyNewTextField(
                        title: 'title'.tr(),
                        controller: bloc.titleController,
                        focusNode: bloc.focusTitle,
                        textInputType: TextInputType.name,
                        onChanged: () => context.read<NewBloc>().add(TaskChange()),
                        onSubmitted: () => context.read<NewBloc>().add(TaskSubmitted(title: true)),
                        suffixIconDone: bloc.suffixTitle,
                        snackBarText: 'snack_title'.tr(),
                      ),

                      // #task_content
                      MyNewTextField(
                        title: 'content'.tr(),
                        controller: bloc.contentController,
                        focusNode: bloc.focusContent,
                        textInputType: TextInputType.text,
                        onChanged: () => context.read<NewBloc>().add(TaskChange()),
                        onSubmitted: () => context.read<NewBloc>().add(TaskSubmitted(context: context)),
                        suffixIconDone: bloc.suffixContent,
                        snackBarText: 'snack_content'.tr(),
                      ),
                      const SizedBox(height: 10),

                      // #date_text
                      Text('date'.tr(), style: AppTextStyles.style26(context)),
                      const SizedBox(height: 10),

                      // #date_buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyDateButton(
                            onPressed: () => bloc.add(ShowDatePickerEvent(context: context, toDate: true)),
                            text: bloc.endDate != null ? bloc.endDate.toString().substring(0, 16) : 'to'.tr(),
                          ),
                          Container(height: 2, width: 8, color: AppColors.white, margin: const EdgeInsets.symmetric(horizontal: 10)),
                          Flexible(
                            child: Text(
                              bloc.endDate != null ? LogicService.difference(endDate: bloc.endDate!, startDate: bloc.startDate) : 'set_deadline'.tr(),
                              style: AppTextStyles.style26(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // #save_task
                      MyButton(
                        text: 'save_task'.tr(),
                        function: () => context.read<NewBloc>().add(TaskSave(context: context)),
                        enable: bloc.suffixContent && bloc.suffixTitle && bloc.endDate != null,
                        disabledAction: DisabledAction(
                          context: context,
                          text: 'fill_all_forms'.tr(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (state is NewTaskLoadingState) myIsLoading(context),
            ],
          ),
        );
      }),
    );
  }
}
