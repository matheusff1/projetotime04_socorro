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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS DENTAL',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const TelaEmergencia(),
    );
  }
}


class TelaEmergencia extends StatefulWidget {
  const TelaEmergencia({
    super.key,
  });



  @override
  TelaEmergenciaState createState() {
    return TelaEmergenciaState();
  }
}

class TelaEmergenciaState extends State<TelaEmergencia> {

  XFile? filePhoto;

  // controler para observar o TextFormField
  final controllerNome = TextEditingController();
  final controllerNum = TextEditingController();


  final FirebaseStorage storage = FirebaseStorage.instance;

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

  Future<void> uploadPhoto(String path, String numero) async{
    File file = File(path);
    try{
      String ref = 'imagenspaciente/foto-${numero}.jpg';
      await storage.ref(ref).putFile(file);
    }on FirebaseException catch(e) {
      throw Exception('Erro no upload: ${e}');
    }

  }

   Future<XFile?> tirarFoto() async{
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image;
  }


  @override
  Widget build(BuildContext context) {
    return Material(
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
              filePhoto = await tirarFoto();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro')),
                );
              }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal
              ),
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
                  uploadPhoto(filePhoto!.path, controllerNum.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gravando dados no Firestore...')),
                  );
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ERRO: PREENCHA OS DADOS')),
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
    );


  }
}

