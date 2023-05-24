import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';


/*void main() async {
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

  File? filePhoto;

  // controler para observar o TextFormField
  final controllerNome = TextEditingController();
  final controllerNum = TextEditingController();


  final FirebaseStorage storage = FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();

  // Cria uma referência para a colecao emergencias no firestore.
  CollectionReference emergencia = FirebaseFirestore.instance.collection('emergencia');

  // funcao que insere no firestore o nome passsado como parametro
  Future<void> chamarEmergencia(String nome, String numero) {
    return emergencia
        .doc().set({
      'nome': nome,
      'numero': numero
    }).then((value) => print("Emergência Enviada!"))
        .catchError((error) => print("Erro ao adicionar: $error"));
  }

  Future<void> uploadPhoto(File path,String numero) async{
    File file = File(path.path);
    try{
        String ref = 'imagenspaciente/foto-${numero}.jpg';
        await storage.ref(ref).putFile(file);

    }on FirebaseException catch(e) {
      throw Exception('Erro no upload: ${e}');
    }

  }


   Future tirarFoto() async{
    final foto =  await ImagePicker().pickImage(source: ImageSource.camera);

    if(foto==null){
      return;
    } else {
      final imagelink = File(foto.path);

      setState(() {
        filePhoto = imagelink;
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return Material(
      key: _formKey,
      child: Form(
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
           Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              autofocus: true,
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
              autofocus: true,
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
              tirarFoto;
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

           //Padding(
               //padding: const EdgeInsets.all(10.0),
               //child: Image.file(File(filePhoto!.path))
           //),


           Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  chamarEmergencia(controllerNome.text, controllerNum.text)
                      .whenComplete(() =>
                      uploadPhoto(filePhoto!,controllerNum.text)
                  );
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
}*/

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;


  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar foto tirada')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          try {
            final FirebaseStorage storage = FirebaseStorage.instance;
            File file = File(imagePath);
            String ref = 'minhafoto/$imagePath.jpg';
            await storage.ref(ref).putFile(file);
          } catch(e){
            print(e);
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),

      ),
    );
  }
  Future<void> uploadPhoto(String path,String nome) async{
    final FirebaseStorage storage = FirebaseStorage.instance;
    File file = File(path);
    try{
      String ref = 'minhafoto/{$nome}.jpg';
      await storage.ref(ref).putFile(file);

    }on FirebaseException catch(e) {
      throw Exception('Erro no upload: ${e}');
    }

  }
}

