import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=a3dfbaad";

void main() async {
  runApp(MaterialApp(
    home: Home(),
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
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  double dolar;
  double euro;
  String titleDolar = "Dolar hoje";
  String titleEuro = "Euro hoje";
  String dataAtualizacao = "data";


  void _updatePrice(){
    setState(() {

      var data = DateFormat('yyyy-MM-dd - kk:mm:ss').format(DateTime.now()) ;


      titleDolar = "Dólar atualizado";
      titleEuro = "Euro atualizado";
      dataAtualizacao = data;

    });

  }

  void _realChange(String text) {
    double real = double.parse(text);
    dolarControler.text = (real / dolar).toStringAsFixed(2);
    euroControler.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChange(String text) {
    double dolar = double.parse(text);
    realControler.text = (dolar * this.dolar).toStringAsFixed(2);
    euroControler.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChange(String text) {
    double euro = double.parse(text);
    realControler.text = (euro * this.euro).toStringAsFixed(2);
    dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        centerTitle: true,
        backgroundColor: Colors.amber,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _updatePrice)
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView( 
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$", realControler, _realChange),
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", dolarControler, _dolarChange),
                        Divider(),
                        buildTextField(
                            "Euros", "€", euroControler, _euroChange),
                        Divider(),
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(titleDolar + " R\$ ${dolar.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: Colors.amber, fontSize: 15.0))
                            ),
                            Divider(),
                            Align(
                              alignment: Alignment.bottomLeft,
                                child: Text(titleEuro + " R\$ ${euro.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: Colors.amber, fontSize: 15.0))
                            ),
                            Divider(),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(dataAtualizacao,
                            style: TextStyle(color: Colors.green, fontSize: 15.0))
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
