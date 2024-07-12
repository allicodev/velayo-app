import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velayo_flutterapp/widgets/button.dart';

class RequestSuccessScreen extends StatefulWidget {
  const RequestSuccessScreen({super.key});

  @override
  State<RequestSuccessScreen> createState() => _RequestSuccessScreenState();
}

class _RequestSuccessScreenState extends State<RequestSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, -0.1),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.linear),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            height: 350,
            child: Lottie.asset("assets/lottie/success_transact.json",
                repeat: false)),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: SlideTransition(position: _animation, child: child),
            );
          },
          child: Column(
            children: [
              const Text(
                "Success. Please get your queue ticket",
                style: TextStyle(fontSize: 32.0, fontFamily: 'abel'),
              ),
              const Text(
                "and wait to the teller to call your queue number",
                style: TextStyle(fontSize: 32.0, fontFamily: 'abel'),
              ),
              const Text(
                'Thank you!',
                style: TextStyle(fontSize: 32.0, fontFamily: 'abel'),
              ),
              const SizedBox(height: 45.0),
              Button(
                  label: "Another Transaction?",
                  width: 250,
                  textColor: Colors.black87,
                  onPress: () {
                    Navigator.popAndPushNamed(context, "/home");
                  })
            ],
          ),
        )
      ],
    )));
  }
}
