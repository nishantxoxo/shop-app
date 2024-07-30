import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // // TODO: implement buildTransitions
    // return super
    //     .buildTransitions(context, animation, secondaryAnimation, child);
    if(settings.name=='/')return child;

    return FadeTransition(opacity: animation, child: child,);
  }
}
