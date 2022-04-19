import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase/firebase_messaging/custom_firebase_messaging.dart';
import 'package:flutter_firebase/remote_config/custom_remote_config.dart';
import 'package:flutter_firebase/remote_config/custom_visible_rc_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  /* antes de inicializar o app ele certifica que todas as plataformas(plataform channel)
   necessarias para o app iniciar foram carregadas */

  await Firebase.initializeApp();//inicializa o firebase

  await CustomFirebaseMessaging().inicialize();
  await CustomFirebaseMessaging().getTokenFirebase(); /*geralmente não fica na main,
   é usado somente para recuperar o token em momentos como por exemplo para salvar
   algo em um banco de dados*/
  await CustomRemoteConfig().initialize();

  runApp(const MyApp());
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

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
