import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'main.dart';

class SubirFotoPage extends StatefulWidget {
  final VoidCallback alSubir;

  const SubirFotoPage({super.key, required this.alSubir});

  @override
  State<SubirFotoPage> createState() => _SubirFotoPageState();
}

class _SubirFotoPageState extends State<SubirFotoPage> {
  File? _imagen;
  final TextEditingController _descripcionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _subiendo = false;

  Future<void> _elegirFoto(ImageSource origen) async {
    final XFile? foto = await _picker.pickImage(source: origen, imageQuality: 80, maxWidth: 1600);
    if (foto != null) {
      setState(() {
        _imagen = File(foto.path);
      });
    }
  }

  MediaType _tipoImagen(String ruta) {
    String ext = ruta.split('.').last.toLowerCase();
    if (ext == 'png') return MediaType('image', 'png');
    if (ext == 'webp') return MediaType('image', 'webp');
    if (ext == 'gif') return MediaType('image', 'gif');
    return MediaType('image', 'jpeg');
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _subirAApi() async {
    if (_imagen == null || _descripcionController.text.trim().isEmpty) {
      _mensaje("Por favor toma una foto y escribe una descripción");
      return;
    }

    setState(() {
      _subiendo = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/fotos'));
      request.fields['descripcion'] = _descripcionController.text.trim();
      request.files.add(
        await http.MultipartFile.fromPath('file', _imagen!.path, contentType: _tipoImagen(_imagen!.path)),
      );

      var response = await request.send();

      if (!mounted) return;
      if (response.statusCode == 200) {
        _mensaje("Foto subida correctamente");
        setState(() {
          _imagen = null;
          _descripcionController.clear();
        });
        widget.alSubir();
      } else {
        String cuerpo = await response.stream.bytesToString();
        _mensaje("Error al subir: ${response.statusCode} $cuerpo");
      }
    } catch (e) {
      _mensaje("Error de conexión: $e");
    } finally {
      if (mounted) {
        setState(() {
          _subiendo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subir Foto")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _elegirFoto(ImageSource.camera),
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: morado.withValues(alpha: 0.3), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagen == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 64, color: morado),
                          SizedBox(height: 10),
                          Text("No hay imagen seleccionada", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 4),
                          Text("Toca aquí para tomar una foto", style: TextStyle(color: Colors.black54)),
                        ],
                      )
                    : Image.file(_imagen!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descripcionController,
              maxLength: 255,
              decoration: InputDecoration(
                labelText: "Descripción",
                prefixIcon: const Icon(Icons.edit_note),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _elegirFoto(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text("Tomar Foto"),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _elegirFoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Galería"),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _subiendo
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _subirAApi,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text("Subir a API", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: morado,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
