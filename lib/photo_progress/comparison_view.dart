import 'package:afermar3_tf_ipc/photo_progress/result_view.dart';
import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:flutter/material.dart';

import '../widgets/color_extension.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _photos = [];

  Map<String, dynamic>? _beforePhoto;
  Map<String, dynamic>? _afterPhoto;

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
      final photos = await ProgressPhotoService.getMyProgressPhotos();

      if (!mounted) return;

      setState(() {
        _photos = photos;
        _isLoading = false;

        if (_photos.length >= 2) {
          _beforePhoto ??= _photos.last;
          _afterPhoto ??= _photos.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _comparePhotos() {
    if (_beforePhoto == null || _afterPhoto == null) {
      _showSnackBar("Selecciona dos fotos para comparar");
      return;
    }

    final beforeId = _beforePhoto?["id"]?.toString();
    final afterId = _afterPhoto?["id"]?.toString();

    if (beforeId != null && beforeId == afterId) {
      _showSnackBar("Selecciona dos fotos diferentes");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultView(
          beforePhoto: _beforePhoto!,
          afterPhoto: _afterPhoto!,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectPhoto({
    required bool isBefore,
  }) async {
    if (_photos.isEmpty) return;

    final selectedPhoto = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.78,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                child: Column(
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
                    Text(
                      isBefore ? "Elegir foto inicial" : "Elegir foto actual",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Selecciona una foto de tu galería de progreso.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        itemCount: _photos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final photo = _photos[index];

                          return _PhotoPickerCard(
                            photo: photo,
                            onTap: () {
                              Navigator.pop(context, photo);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (selectedPhoto == null) return;

    setState(() {
      if (isBefore) {
        _beforePhoto = selectedPhoto;
      } else {
        _afterPhoto = selectedPhoto;
      }
    });
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
        return "Foto";
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

  Widget _buildInfoCard() {
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
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.compare_rounded,
              color: TColor.primaryColor1,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Compara tu progreso",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Elige una foto inicial y una foto actual para ver tu evolución física.",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPhotoCard({
    required String title,
    required String emptyText,
    required Map<String, dynamic>? photo,
    required VoidCallback onTap,
  }) {
    final hasPhoto = photo != null;

    final imageUrl = hasPhoto
        ? ProgressPhotoService.buildImageUrl(
            photo["image_url"]?.toString() ?? "",
          )
        : "";

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(24),
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
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: hasPhoto
                    ? Image.network(
                        imageUrl,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported_rounded,
                            color: TColor.gray,
                            size: 32,
                          );
                        },
                      )
                    : Icon(
                        Icons.add_photo_alternate_rounded,
                        color: TColor.primaryColor1,
                        size: 34,
                      ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hasPhoto
                        ? "${_photoTypeLabel(photo["photo_type"]?.toString())} · ${_formatDate(photo["created_at"]?.toString())}"
                        : emptyText,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasPhoto && photo["weight_kg"] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "${photo["weight_kg"]} kg",
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewComparison() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(24),
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
          Expanded(
            child: _PreviewPhotoBox(
              label: "Antes",
              photo: _beforePhoto,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: TColor.primaryColor1,
              size: 24,
            ),
          ),
          Expanded(
            child: _PreviewPhotoBox(
              label: "Después",
              photo: _afterPhoto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(
          color: TColor.primaryColor1,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? "No se han podido cargar las fotos",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadPhotos,
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                color: TColor.primaryColor1,
                size: 54,
              ),
              const SizedBox(height: 14),
              Text(
                "Necesitas al menos dos fotos",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sube dos fotos de progreso para poder comparar tu evolución.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_photos.length < 2) {
      return _buildEmptyState();
    }

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 26),
            Text(
              "Selecciona dos fotos",
              style: TextStyle(
                color: TColor.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Elige una foto inicial y otra más reciente para compararlas.",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildSelectedPhotoCard(
              title: "Foto inicial",
              emptyText: "Selecciona la foto de antes",
              photo: _beforePhoto,
              onTap: () {
                _selectPhoto(isBefore: true);
              },
            ),
            const SizedBox(height: 16),
            _buildSelectedPhotoCard(
              title: "Foto actual",
              emptyText: "Selecciona la foto de después",
              photo: _afterPhoto,
              onTap: () {
                _selectPhoto(isBefore: false);
              },
            ),
            const SizedBox(height: 24),
            _buildPreviewComparison(),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _comparePhotos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Comparar evolución",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
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
        title: Text(
          "Comparar fotos",
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
        child: Column(
          children: [
            _buildContent(),
          ],
        ),
      ),
    );
  }
}

class _PhotoPickerCard extends StatelessWidget {
  final Map<String, dynamic> photo;
  final VoidCallback onTap;

  const _PhotoPickerCard({
    required this.photo,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final imageUrl = ProgressPhotoService.buildImageUrl(
      photo["image_url"]?.toString() ?? "",
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: TColor.lightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported_rounded,
                    color: TColor.gray,
                    size: 36,
                  );
                },
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.58),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeLabel(photo["photo_type"]?.toString()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(photo["created_at"]?.toString()),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _PreviewPhotoBox extends StatelessWidget {
  final String label;
  final Map<String, dynamic>? photo;

  const _PreviewPhotoBox({
    required this.label,
    required this.photo,
  });

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

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null;

    final imageUrl = hasPhoto
        ? ProgressPhotoService.buildImageUrl(
            photo!["image_url"]?.toString() ?? "",
          )
        : "";

    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasPhoto)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported_rounded,
                    color: TColor.gray,
                    size: 32,
                  );
                },
              )
            else
              Icon(
                Icons.image_outlined,
                color: TColor.gray,
                size: 34,
              ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.58),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (hasPhoto) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(photo!["created_at"]?.toString()),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}