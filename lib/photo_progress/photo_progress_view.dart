import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/photo_progress/add_progress_photo_view.dart';
import 'package:afermar3_tf_ipc/photo_progress/comparison_view.dart';
import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:flutter/material.dart';

import '../widgets/color_extension.dart';

class PhotoProgressView extends StatefulWidget {
  const PhotoProgressView({super.key});

  @override
  State<PhotoProgressView> createState() => _PhotoProgressViewState();
}

class _PhotoProgressViewState extends State<PhotoProgressView> {
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = "ALL";

  List<Map<String, dynamic>> _photos = [];

  final List<Map<String, String>> _filters = [
    {
      "label": "Todas",
      "value": "ALL",
    },
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
      "label": "Otros",
      "value": "OTHER",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final photos = await ProgressPhotoService.getMyProgressPhotos(
        photoType: _selectedFilter == "ALL" ? null : _selectedFilter,
      );

      if (!mounted) return;

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddPhoto() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProgressPhotoView(),
      ),
    );

    if (result == true) {
      _loadPhotos();
    }
  }

  Future<void> _deletePhoto(Map<String, dynamic> photo) async {
    final id = int.tryParse(photo["id"]?.toString() ?? "");

    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar foto"),
          content: const Text(
            "¿Seguro que quieres eliminar esta foto de progreso?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ProgressPhotoService.deleteProgressPhoto(id);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto eliminada correctamente"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _loadPhotos();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editPhoto(Map<String, dynamic> photo) async {
  final id = int.tryParse(photo["id"]?.toString() ?? "");

  if (id == null) return;

  final weightController = TextEditingController(
    text: photo["weight_kg"]?.toString() ?? "",
  );

  final noteController = TextEditingController(
    text: photo["note"]?.toString() ?? "",
  );

  String selectedType = photo["photo_type"]?.toString() ?? "FRONT";
  bool isSaving = false;

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: TColor.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> saveChanges() async {
            if (isSaving) return;

            setModalState(() {
              isSaving = true;
            });

            try {
              final weightText =
                  weightController.text.trim().replaceAll(",", ".");

              final weight = weightText.isEmpty
                  ? null
                  : double.tryParse(weightText);

              if (weightText.isNotEmpty && weight == null) {
                throw Exception("Introduce un peso válido");
              }

              await ProgressPhotoService.updateProgressPhoto(
                photoId: id,
                photoType: selectedType,
                weightKg: weight,
                note: noteController.text.trim(),
              );

              if (!context.mounted) return;

              Navigator.pop(context, true);
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString().replaceFirst("Exception: ", ""),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              setModalState(() {
                isSaving = false;
              });
            }
          }

          Widget typeChip({
            required String label,
            required String value,
          }) {
            final isSelected = selectedType == value;

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                setModalState(() {
                  selectedType = value;
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
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : TColor.primaryColor1,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Editar foto",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Modifica el tipo, peso o nota asociada a esta foto.",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      "Tipo de foto",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        typeChip(label: "Frontal", value: "FRONT"),
                        typeChip(label: "Lateral", value: "SIDE"),
                        typeChip(label: "Espalda", value: "BACK"),
                        typeChip(label: "Otro", value: "OTHER"),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Text(
                      "Peso (opcional)",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: weightController,
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
                      controller: noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Ej: Semana 3 de rutina...",
                        filled: true,
                        fillColor: TColor.lightGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : saveChanges,
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          isSaving ? "Guardando..." : "Guardar cambios",
                          style: const TextStyle(
                            fontSize: 15,
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
        },
      );
    },
  );

  weightController.dispose();
  noteController.dispose();

  if (result == true) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Foto actualizada correctamente"),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadPhotos();
  }
}

  void _openPhotoDetail(Map<String, dynamic> photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        final imageUrl = ProgressPhotoService.buildImageUrl(
          photo["image_url"]?.toString() ?? "",
        );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 360,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 260,
                        color: TColor.lightGray,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: TColor.gray,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _PhotoInfoRow(
                  label: "Tipo",
                  value: _photoTypeLabel(photo["photo_type"]?.toString()),
                ),
                _PhotoInfoRow(
                  label: "Fecha",
                  value: _formatDate(photo["created_at"]?.toString()),
                ),
                if (photo["weight_kg"] != null)
                  _PhotoInfoRow(
                    label: "Peso",
                    value: "${photo["weight_kg"]} kg",
                  ),
                if ((photo["note"]?.toString().trim() ?? "").isNotEmpty)
                  _PhotoInfoRow(
                    label: "Nota",
                    value: photo["note"].toString(),
                  ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (!mounted) return;
                        _editPhoto(photo);
                      });
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text(
                      "Editar foto",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primaryColor1,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _deletePhoto(photo);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text(
                      "Eliminar foto",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _photoTypeLabel(String? value) {
    switch (value) {
      case "FRONT":
        return "Frontal";
      case "SIDE":
        return "Lateral";
      case "BACK":
        return "Espalda";
      case "OTHER":
        return "Otro";
      default:
        return "Sin tipo";
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Sin fecha";
    }

    try {
      final date = DateTime.parse(value);

      final day = date.day.toString().padLeft(2, "0");
      final month = date.month.toString().padLeft(2, "0");
      final year = date.year.toString();

      return "$day/$month/$year";
    } catch (_) {
      return value;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupPhotosByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final photo in _photos) {
      final dateLabel = _formatDate(photo["created_at"]?.toString());

      grouped.putIfAbsent(dateLabel, () => []);
      grouped[dateLabel]!.add(photo);
    }

    return grouped;
  }

  Widget _buildReminderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: TColor.primaryColor1,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seguimiento visual",
                  style: TextStyle(
                    color: TColor.primaryColor1,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _photos.isEmpty
                      ? "Añade tu primera foto para empezar a registrar tu evolución."
                      : "Llevas ${_photos.length} foto(s) de progreso registradas.",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainProgressCard(Size media) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primaryColor2.withOpacity(0.24),
            TColor.primaryColor1.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Fotos de progreso",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Registra fotos periódicas para comparar tu cambio físico de forma visual.",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 130,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _openAddPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: const Text(
                      "Añadir foto",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: media.width * 0.27,
            height: media.width * 0.27,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.photo_camera_front_rounded,
              color: TColor.primaryColor1,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: TColor.primaryColor1.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.compare_rounded,
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
                  "Comparar fotos",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Compara dos momentos de tu evolución.",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 92,
            height: 34,
            child: RoundButton(
              title: "Comparar",
              type: RoundButtonType.bgGradient,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComparisonView(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter["value"];

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedFilter = filter["value"]!;
              });

              _loadPhotos();
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
                filter["label"]!,
                style: TextStyle(
                  color: isSelected ? Colors.white : TColor.primaryColor1,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Galería",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton(
          onPressed: _loadPhotos,
          child: Text(
            "Actualizar",
            style: TextStyle(
              color: TColor.primaryColor1,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: TColor.primaryColor1,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            "Aún no tienes fotos",
            style: TextStyle(
              color: TColor.black,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Sube tu primera foto para comenzar tu seguimiento visual.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 150,
            height: 42,
            child: ElevatedButton(
              onPressed: _openAddPhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Añadir foto",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            _error ?? "Ha ocurrido un error",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: _loadPhotos,
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGroups() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(
            color: TColor.primaryColor1,
          ),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_photos.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = _groupPhotosByDate();

    return Column(
      children: grouped.entries.map((entry) {
        return _PhotoSection(
          title: entry.key,
          photos: entry.value,
          onPhotoTap: _openPhotoDetail,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Evolución",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _loadPhotos,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: TColor.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: TColor.primaryColor1,
          onRefresh: _loadPhotos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 115),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReminderCard(),
                const SizedBox(height: 18),
                _buildMainProgressCard(media),
                const SizedBox(height: 18),
                _buildCompareCard(),
                const SizedBox(height: 24),
                _buildGalleryHeader(),
                const SizedBox(height: 8),
                _buildFilters(),
                const SizedBox(height: 18),
                _buildPhotoGroups(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: TColor.secondaryG),
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: _openAddPhoto,
          child: Icon(
            Icons.photo_camera_rounded,
            size: 25,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> photos;
  final void Function(Map<String, dynamic> photo) onPhotoTap;

  const _PhotoSection({
    required this.title,
    required this.photos,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 128,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                final imageUrl = ProgressPhotoService.buildImageUrl(
                  photo["image_url"]?.toString() ?? "",
                );

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    onPhotoTap(photo);
                  },
                  child: Container(
                    width: 128,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.045),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            imageUrl,
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported_rounded,
                                color: TColor.gray,
                                size: 32,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _typeLabel(photo["photo_type"]?.toString()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String? value) {
    switch (value) {
      case "FRONT":
        return "Frontal";
      case "SIDE":
        return "Lateral";
      case "BACK":
        return "Espalda";
      case "OTHER":
        return "Otro";
      default:
        return "Foto";
    }
  }
}

class _PhotoInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _PhotoInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: TColor.black,
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}