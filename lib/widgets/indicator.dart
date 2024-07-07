import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget cIndicator(context) {
  return Center(
    child: CupertinoActivityIndicator(
      color: Theme.of(context).indicatorColor,
    ),
  );
}
