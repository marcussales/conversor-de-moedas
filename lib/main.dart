import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance';

void main() async {
  runApp(MaterialApp(home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  double dolar;
  double euro;

  void _realChanged(String text) {
    if(text.isEmpty) {
      clearFields();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      clearFields();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      clearFields();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void clearFields() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Conversor de moedas"),
          centerTitle: true,
          backgroundColor: Colors.amber,
          actions: [
            IconButton(icon: Icon(Icons.refresh), onPressed: clearFields)
          ],
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando Dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Ocorreu um erro, reinicie o aplicativo",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                            Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                        buildFieds("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildFieds("Doláres", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildFieds("Euros", "€", euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          },
        ));
  }
}

Widget buildFieds(String label, String prefix, TextEditingController controller, Function function) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 25.0, color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}
