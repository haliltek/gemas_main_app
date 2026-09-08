import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gemas/widgets/platform_duyarli_widget.dart';

class PlatformDuyarliAlertDialog extends PlatformDuyarliWidget {
  final String baslik;
  final String icerik;
  final String anaButonYazisi;
  final String iptalButonYazisi;

  PlatformDuyarliAlertDialog({required this.baslik, required this.icerik, required this.anaButonYazisi, required this.iptalButonYazisi});

  Future<Future> goster(BuildContext context) async {
    return Platform.isIOS
        ? showCupertinoDialog(context: context, builder: (context) => this, barrierDismissible: false)
        : showDialog<bool>(context: context, builder: (context) => this, barrierDismissible: false);
  }

  @override
  Widget buildAndroidWidget(BuildContext context) {
    return AlertDialog(
      title: Text(baslik),
      content: Text(icerik),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  @override
  Widget buildIOSWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(baslik),
      content: Text(icerik),
      actions: _dialogButonlariniAyarla(context),
    );
  }

  List<Widget> _dialogButonlariniAyarla(BuildContext context) {
    final tumButonlar = <Widget>[];

    if (Platform.isIOS) {
      if (iptalButonYazisi != null) {
        tumButonlar.add(
          CupertinoDialogAction(
            child: Text(iptalButonYazisi),
            onPressed: () {},
          ),
        );
      }

      tumButonlar.add(
        CupertinoDialogAction(
          child: Text(anaButonYazisi),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    } else {
      if (iptalButonYazisi != null) {
        tumButonlar.add(
          TextButton(
            child: Text(iptalButonYazisi),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      }
      tumButonlar.add(
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(anaButonYazisi),
        ),
      );
    }

    return tumButonlar;
  }
}
