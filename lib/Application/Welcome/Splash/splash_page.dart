import 'package:flutter/material.dart';
import 'package:my_tasks/Configuration/app_colors.dart';
import 'package:my_tasks/Configuration/app_text_styles.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            const Image(image: AssetImage('assets/images/img_0.png')),
            Text('My Tasks', style: AppTextStyles.style0),
          ],
        ),
      ),
    );
  }
}