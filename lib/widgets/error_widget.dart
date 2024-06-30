import 'package:flutter/material.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/generated/l10n.dart';
import 'package:lottie/lottie.dart';

class ErrorRetryWidget extends StatelessWidget {
  const ErrorRetryWidget({super.key, required this.lottie, this.onTap});
  final String lottie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final S locals = S.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        kHeightBox20,
        Center(
          child: LottieBuilder.asset(
            lottie,
            width: 200,
            height: 200,
          ),
        ),
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.refresh),
          label: Text(locals.retry),
        )
      ],
    );
  }
}
