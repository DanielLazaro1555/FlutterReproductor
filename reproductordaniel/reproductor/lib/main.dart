import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 58, 183, 79),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Daniel Reproductor de Musica'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> apiData = [];
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
    audioPlayer = AudioPlayer();
  }

  Future<void> fetchDataFromApi() async {
    try {
      final response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/DanielLazaro1555/Musica1/main/public/bd.json'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          apiData = List<Map<String, dynamic>>.from(jsonData);
        });
      } else {
        print(
            'Failed to load data from JSON. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> playAudio(String audioUrl) async {
    try {
      await audioPlayer.play(audioUrl);
    } catch (e) {
      print('Error al reproducir audio: $e');
    }
    await audioPlayer.stop();
    await audioPlayer.play(audioUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Data from API:'),
            Expanded(
              child: ListView.builder(
                itemCount: apiData.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> data = apiData[index];
                  return Card(
                    margin: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Row(
                        children: [
                          Image.network(
                            'https://raw.githubusercontent.com/DanielLazaro1555/Musica1/main/public/${data["imagen"]}',
                            width:
                                100, // Ajusta el ancho de la imagen según sea necesario
                            height:
                                100, // Ajusta la altura de la imagen según sea necesario
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                              width: 10), // Espacio entre la imagen y el texto
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Titulo: ${data["titulo"]}'),
                              Text('Artista: ${data["artista"]}'),
                              Text('Album: ${data["album"]}'),
                              Text('Año: ${data["Año"]}'),
                            ],
                          ),
                        ],
                      ),
                      subtitle: ElevatedButton(
                        onPressed: () {
                          playAudio(
                            'https://github.com/DanielLazaro1555/Musica1/raw/main/public/${data["archivo_musica"]}',
                          );
                        },
                        child: Text('Reproducir'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDataFromApi,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
