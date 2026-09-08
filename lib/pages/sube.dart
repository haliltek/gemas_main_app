import 'package:flutter/material.dart';
import 'package:gemas/models/sube.dart';
import 'package:gemas/widgets/gemas_app_bar.dart';

class SubePage extends StatelessWidget {
  final Sube sube;

  const SubePage({required this.sube}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GemasAppBar(title: 'ŞUBE'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sube.ad,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(sube.adres),
                  SizedBox(height: 20),
                  Text(sube.tlf + ' - ' + sube.tlf),
                  SizedBox(height: 30),
                  Text("ÇALIŞMA SAATLERİMİZ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pazartesi"),
                            Text("Salı"),
                            Text("Çarşamba"),
                            Text("Perşembe"),
                            Text("Cuma"),
                            Text("Cumartesi"),
                            Text("Pazar")
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(": " + sube.pazartesi),
                            Text(": " + sube.sali),
                            Text(": " + sube.carsamba),
                            Text(": " + sube.persembe),
                            Text(": " + sube.cuma),
                            Text(": " + (sube.cumartesi != null ? sube.cumartesi! : "Kapalı")),
                            Text(": Kapalı")
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
