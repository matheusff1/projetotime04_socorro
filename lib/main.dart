import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';

//primeira página: botão que envia para a segunda(solicitar emergencia). Segunda: pedir nome, numero e enviar ao firestore, e pedri foto (storage)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp( TelaEmergencia(camera: firstCamera));
}



class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key, required this.title});

  final String title;

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,


          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TelaEmergencia extends StatefulWidget {
  const TelaEmergencia({
    super.key,
    required this.camera
  });

  final CameraDescription camera;

  @override

  TelaEmergenciaState createState() {
    return TelaEmergenciaState();
  }
}

class TelaEmergenciaState extends State<TelaEmergencia> {
  final FirebaseStorage storage = FirebaseStorage.instance;

  //controller camera
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  // controler para observar o TextFormField
  final controllerNome = TextEditingController();
  final controllerNum = TextEditingController();

  String endPhoto = "";


  late File fotoTirada;

  final _formKey = GlobalKey<FormState>();

  // Cria uma referência para a colecao emergencias no firestore.
  CollectionReference emergencias = FirebaseFirestore.instance.collection('emergencias');

  // funcao que insere no firestore o nome passsado como parametro
  Future<void> chamarEmergencia(String nome, String numero) {
    return emergencias
        .doc(nome).set({
      'nome': nome,
      'numero': numero
    }).then((value) => print("Emergência Enviada!"))
        .catchError((error) => print("Erro ao adicionar: $error"));
  }

  PickedFile? _image;
  File? imageFile;

   tirarFoto(bool camera) async{
     var temp;
     PickedFile? photoSelected;
    if(camera){
      _image = await ImagePicker.platform.pickImage(source: ImageSource.camera);
    } else{
      _image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    }
     setState(() {
       photoSelected = _image;
       imageFile = File(photoSelected!.path);
     });
  }

  Future<void> uploadFoto(File image, String fileName) async{
     try{
       await FirebaseStorage.instance.ref("fotosemergencia/$fileName").putFile(image);
     } on FirebaseException catch(e){
       print('Erro ao realizar o upload: $e');
     }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
      key: _formKey,
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
           Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              controller: controllerNome,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu nome';
                }
                return null;
              },
            ),
          ),

           Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: controllerNum,
              validator:  (value){
                if (value == null || value.isEmpty) {
                  return 'Digite seu Telefone';
                }
                return null;
              },
            )
          ),



           Padding(
            padding: const EdgeInsets.all(12.0),
            child:ElevatedButton.icon(
              onPressed: () async {
              try {
              tirarFoto(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro')),
                );
              }
              },
              icon: const Icon (Icons.camera_alt_outlined),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child:Text('TIRAR FOTO')
              ),

            ),
          ),


           Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  chamarEmergencia(controllerNome.text, controllerNum.text);
                  uploadFoto(imageFile!, controllerNum.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gravando dados no Firestore...')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red
    ),
              child: const Text('ENVIAR EMERGÊNCIA'),
            ),
          ),

        ],
      ),


    )
    );


  }
}

