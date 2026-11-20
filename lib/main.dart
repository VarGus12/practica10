import 'package:flutter/material.dart';
import 'subir_page.dart';
import 'galeria_page.dart';

const String baseUrl = "http://10.0.2.2:8000";
const Color morado = Color(0xFF5B3CC4);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Fotos P10',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: morado),
      scaffoldBackgroundColor: const Color(0xFFF5F3FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: morado,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
    ),
    home: const InicioPage(),
  ));
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _pagina = 0;
  final GlobalKey<GaleriaPageState> _galeriaKey = GlobalKey<GaleriaPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pagina,
        children: [
          SubirFotoPage(
            alSubir: () {
              _galeriaKey.currentState?.cargarFotos();
            },
          ),
          GaleriaPage(key: _galeriaKey),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pagina,
        onDestinationSelected: (i) {
          setState(() => _pagina = i);
          if (i == 1) {
            _galeriaKey.currentState?.cargarFotos();
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add_a_photo_outlined), selectedIcon: Icon(Icons.add_a_photo), label: 'Subir foto'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'Galería'),
        ],
      ),
    );
  }
}

String formatoFecha(String? fecha) {
  if (fecha == null) return '';
  DateTime? f = DateTime.tryParse(fecha);
  if (f == null) return fecha;
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
}
