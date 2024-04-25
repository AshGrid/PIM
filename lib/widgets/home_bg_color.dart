import 'dart:ui';

import 'package:flutter/material.dart';

import '../Loginpages/welcome_page.dart';

class HomeBackgroundColor extends AnimatedWidget {
  final Animation<double> opacity;
  const HomeBackgroundColor(this.opacity, {Key? key})
      : super(key: key, listenable: opacity);

  Animation<double> get progress => opacity;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.5,
      child: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
              height:
                  (MediaQuery.of(context).size.height / 2.5) * progress.value,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withOpacity(lerpDouble(0.5, 1.0, progress.value) ?? 1.0),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -10,
            child: Container(
              width: 150,
              height: 150,
              decoration:
                  const ShapeDecoration(shape: CircleBorder(), color: Colorprimary),
            ),
          ),
          Positioned(
            top: -80 * (progress.value) - 50 * (1 - progress.value),
            left: -60,
            child: Container(
              width: 150 * (1 - progress.value) + 150,
              height: 150 * (1 - progress.value) + 150,
              decoration:
                  const ShapeDecoration(shape: CircleBorder(), color: Colorseconde),
            ),
          ),
        ],
      ),
    );
  }
}
