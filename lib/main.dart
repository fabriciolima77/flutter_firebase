import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase/firebase_auth/auth_interface.dart';
import 'package:flutter_firebase/firebase_auth/custom_firebase_auth.dart';
import 'package:flutter_firebase/firebase_messaging/custom_firebase_messaging.dart';
import 'package:flutter_firebase/remote_config/custom_remote_config.dart';
import 'package:flutter_firebase/remote_config/custom_visible_rc_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    /* antes de inicializar o app ele certifica que todas as plataformas(plataform channel)
   necessarias para o app iniciar foram carregadas */

    await Firebase.initializeApp();//inicializa o firebase

    /*await CustomFirebaseMessaging().getTokenFirebase(); *//*geralmente não fica na main,
   é usado somente para recuperar o token em momentos como por exemplo para salvar
   algo em um banco de dados*/
    await CustomRemoteConfig().initialize();

    await CustomFirebaseMessaging().inicialize(
      callback: () => CustomRemoteConfig().forceFetch(),
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    runApp(const MyApp());
  },(error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const MyHomePage(title: 'Home Page'),
        '/virtual': (_) => Scaffold(
          appBar: AppBar(),
          body: const SizedBox.expand(
            child: Center(child: Text('Virtual Page')),
          ),
        )
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  final AuthInterface _auth = CustomFirebaseAuth();

  var controllerUser = TextEditingController();
  var controllerPass = TextEditingController();

  String? errorMsg;


  void _incrementCounter() async {
    setState(() => _isLoading = true);
    await CustomRemoteConfig().forceFetch();//quando apertar o botão ele vai diretamente ao firebase ignorando o cache e atualizar os valores
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomRemoteConfig().getValueOrDefault(
            key: 'isActiveBlue',
            defaultValue: false,
        )
          ? Colors.blue
          : Colors.red,
        title: Text(widget.title),
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.blue.withOpacity(.3),
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  TextFormField(
                    controller: controllerUser,
                    decoration: const InputDecoration(
                      label: Text('Usuário'),
                    ),
                  ),
                  TextFormField(
                    controller: controllerPass,
                    decoration: const InputDecoration(
                      label: Text('Senha')
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        String user = controllerUser.text;
                        String pass = controllerPass.text;

                        var result = await _auth.login(user, pass);
                        if(result.isSucess){
                          setState(() => errorMsg = null);
                          print('Sucess Login');
                        }else{
                          setState(() => errorMsg = result.msgError);
                        }
                      },
                      child: const Text('Login')
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        String user = controllerUser.text;
                        String pass = controllerPass.text;

                        var result = await _auth.register(user, pass);
                        if(result.isSucess){
                          setState(() => errorMsg = null);
                          print('Sucess Register');
                        }else{
                          setState(() => errorMsg = result.msgError);
                        }
                      },
                      child: const Text('Registrar'),
                  ),
                  if(errorMsg != null) Text(errorMsg!),
                ],
              ),
            ),
            ElevatedButton(onPressed: () {
              FirebaseCrashlytics.instance.log('Ocorreu uma exception manual');
              //logica
              throw Error;
            }, child: const Text('Btn')),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              CustomRemoteConfig().getValueOrDefault(
                  key: 'novaString',
                  defaultValue: 'defaultValue',).toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            CustomVisibleRCWidget(
              rmKey: 'show_container',
                defaultValue: false,
                child: Container(color: Colors.blue, height: 100, width: 100,))
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
