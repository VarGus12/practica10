import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => GaleriaPageState();
}

class GaleriaPageState extends State<GaleriaPage> {
  List fotos = [];
  bool cargando = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    cargarFotos();
  }

  Future<void> cargarFotos() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/fotos'));
      if (res.statusCode == 200) {
        fotos = json.decode(utf8.decode(res.bodyBytes));
        error = '';
      } else {
        error = 'No se pudieron cargar las fotos';
      }
    } catch (e) {
      error = 'Error de conexión con la API';
    }
    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  void verFoto(Map f) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FotoPage(foto: f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cuerpo;
    if (cargando) {
      cuerpo = const Center(child: CircularProgressIndicator());
    } else if (error.isNotEmpty) {
      cuerpo = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.black38),
            const SizedBox(height: 10),
            Text(error),
            TextButton(onPressed: cargarFotos, child: const Text('Reintentar')),
          ],
        ),
      );
    } else if (fotos.isEmpty) {
      cuerpo = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 56, color: Colors.black38),
            SizedBox(height: 10),
            Text('Todavía no hay fotos, sube la primera'),
          ],
        ),
      );
    } else {
      cuerpo = RefreshIndicator(
        onRefresh: cargarFotos,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: fotos.length,
          itemBuilder: (context, i) {
            Map f = fotos[i];
            return GestureDetector(
              onTap: () => verFoto(f),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'foto${f['id']}',
                        child: Image.network(
                          '$baseUrl/${f['ruta_foto']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['descripcion'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(formatoFecha(f['fecha']), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(fotos.isEmpty ? 'Galería' : 'Galería (${fotos.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => cargando = true);
              cargarFotos();
            },
          ),
        ],
      ),
      body: cuerpo,
    );
  }
}

class FotoPage extends StatelessWidget {
  final Map foto;

  const FotoPage({super.key, required this.foto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text('Foto #${foto['id']}')),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Hero(
                  tag: 'foto${foto['id']}',
                  child: Image.network('$baseUrl/${foto['ruta_foto']}', fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(foto['descripcion'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(formatoFecha(foto['fecha']), style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(foto['ruta_foto'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
