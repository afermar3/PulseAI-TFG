import 'dart:typed_data';

import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/color_extension.dart';

class AddProgressPhotoView extends StatefulWidget {
  const AddProgressPhotoView({super.key});

  @override
  State<AddProgressPhotoView> createState() => _AddProgressPhotoViewState();
}

class _AddProgressPhotoViewState extends State<AddProgressPhotoView> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  XFile? _selectedImage;
  Uint8List? _webImageBytes;

  String _selectedType = "FRONT";
  bool _isSaving = false;

  final List<Map<String, String>> _photoTypes = [
    {
      "label": "Frontal",
      "value": "FRONT",
    },
    {
      "label": "Lateral",
      "value": "SIDE",
    },
    {
      "label": "Espalda",
      "value": "BACK",
    },
    {
      "label": "Otro",
      "value": "OTHER",
    },
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      Uint8List? bytes;

      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }

      setState(() {
        _selectedImage = image;
        _webImageBytes = bytes;
      });
    } catch (e) {
      _showError(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  Future<void> _showImageSourceSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: TColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: TColor.lightGray,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                _SourceOption(
                  icon: Icons.photo_library_rounded,
                  title: "Elegir desde galería",
                  subtitle: "Selecciona una imagen de tu dispositivo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                _SourceOption(
                  icon: Icons.photo_camera_rounded,
                  title: "Hacer foto",
                  subtitle: "Usa la cámara del dispositivo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _savePhoto() async {
    if (_selectedImage == null) {
      _showError("Selecciona una foto antes de guardar");
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final weightText = _weightController.text.trim().replaceAll(",", ".");
      final weight = weightText.isEmpty ? null : double.tryParse(weightText);

      if (weightText.isNotEmpty && weight == null) {
        throw Exception("Introduce un peso válido");
      }

      await ProgressPhotoService.uploadProgressPhoto(
        photoType: _selectedType,
        filePath: _selectedImage!.path,
        webBytes: _webImageBytes,
        fileName: _selectedImage!.name,
        weightKg: weight,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: _showImageSourceSheet,
        child: Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            color: TColor.lightGray,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_rounded,
                color: TColor.primaryColor1,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                "Añadir foto",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selecciona una imagen de progreso",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: TColor.lightGray,
            borderRadius: BorderRadius.circular(26),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: kIsWeb
                ? Image.memory(
                    _webImageBytes!,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _selectedImage!.path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_rounded,
                        color: TColor.gray,
                        size: 38,
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: _showImageSourceSheet,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _photoTypes.map((type) {
        final isSelected = _selectedType == type["value"];

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            setState(() {
              _selectedType = type["value"]!;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? TColor.primaryColor1
                  : TColor.primaryColor1.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              type["label"]!,
              style: TextStyle(
                color: isSelected ? Colors.white : TColor.primaryColor1,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Nueva foto",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColor.black,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePreview(),
              const SizedBox(height: 24),
              Text(
                "Tipo de foto",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              Text(
                "Peso actual (opcional)",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: "Ej: 72.5",
                  filled: true,
                  fillColor: TColor.lightGray,
                  suffixText: "kg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Nota personal (opcional)",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Ej: Semana 3 de rutina, me noto mejor...",
                  filled: true,
                  fillColor: TColor.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _savePhoto,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    _isSaving ? "Guardando..." : "Guardar foto",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColor.lightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: TColor.primaryColor1,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}