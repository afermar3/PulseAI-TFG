import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  final Map<String, dynamic> beforePhoto;
  final Map<String, dynamic> afterPhoto;

  const ResultView({
    super.key,
    required this.beforePhoto,
    required this.afterPhoto,
  });

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

  double? _parseWeight(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  String _formatWeight(dynamic value) {
    final weight = _parseWeight(value);

    if (weight == null) {
      return "No registrado";
    }

    return "${weight.toStringAsFixed(1)} kg";
  }

  String _buildWeightDifferenceText() {
    final beforeWeight = _parseWeight(beforePhoto["weight_kg"]);
    final afterWeight = _parseWeight(afterPhoto["weight_kg"]);

    if (beforeWeight == null || afterWeight == null) {
      return "Añade el peso en ambas fotos para ver la diferencia.";
    }

    final diff = afterWeight - beforeWeight;

    if (diff == 0) {
      return "Tu peso se ha mantenido estable entre ambas fotos.";
    }

    final absDiff = diff.abs().toStringAsFixed(1);

    if (diff > 0) {
      return "Has subido $absDiff kg entre ambas fotos.";
    }

    return "Has bajado $absDiff kg entre ambas fotos.";
  }

  Color _weightDifferenceColor() {
    final beforeWeight = _parseWeight(beforePhoto["weight_kg"]);
    final afterWeight = _parseWeight(afterPhoto["weight_kg"]);

    if (beforeWeight == null || afterWeight == null) {
      return TColor.gray;
    }

    final diff = afterWeight - beforeWeight;

    if (diff == 0) {
      return TColor.gray;
    }

    return diff > 0 ? Colors.orange : Colors.green;
  }

  Widget _buildHeaderCard() {
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
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(20),
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
                  "Comparación visual",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${_formatDate(beforePhoto["created_at"]?.toString())}  →  ${_formatDate(afterPhoto["created_at"]?.toString())}",
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

  Widget _buildImageComparison() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ComparisonImageCard(
            label: "Antes",
            photo: beforePhoto,
            typeLabel: _photoTypeLabel(
              beforePhoto["photo_type"]?.toString(),
            ),
            dateLabel: _formatDate(
              beforePhoto["created_at"]?.toString(),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ComparisonImageCard(
            label: "Después",
            photo: afterPhoto,
            typeLabel: _photoTypeLabel(
              afterPhoto["photo_type"]?.toString(),
            ),
            dateLabel: _formatDate(
              afterPhoto["created_at"]?.toString(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightSummaryCard() {
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _weightDifferenceColor().withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.monitor_weight_outlined,
              color: _weightDifferenceColor(),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cambio de peso",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _buildWeightDifferenceText(),
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

  Widget _buildInfoTable() {
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
      child: Column(
        children: [
          _ComparisonInfoRow(
            label: "Fecha",
            beforeValue: _formatDate(beforePhoto["created_at"]?.toString()),
            afterValue: _formatDate(afterPhoto["created_at"]?.toString()),
          ),
          _ComparisonInfoRow(
            label: "Tipo",
            beforeValue: _photoTypeLabel(beforePhoto["photo_type"]?.toString()),
            afterValue: _photoTypeLabel(afterPhoto["photo_type"]?.toString()),
          ),
          _ComparisonInfoRow(
            label: "Peso",
            beforeValue: _formatWeight(beforePhoto["weight_kg"]),
            afterValue: _formatWeight(afterPhoto["weight_kg"]),
          ),
          _ComparisonInfoRow(
            label: "Nota",
            beforeValue:
                beforePhoto["note"]?.toString().trim().isNotEmpty == true
                    ? beforePhoto["note"].toString()
                    : "Sin nota",
            afterValue: afterPhoto["note"]?.toString().trim().isNotEmpty == true
                ? afterPhoto["note"].toString()
                : "Sin nota",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            color: TColor.primaryColor1,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Consejo: intenta tomar las fotos con una iluminación y postura parecidas para que la comparación sea más útil.",
              style: TextStyle(
                color: TColor.black,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
          "Resultado",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 22),
              _buildImageComparison(),
              const SizedBox(height: 22),
              _buildWeightSummaryCard(),
              const SizedBox(height: 22),
              Text(
                "Detalles",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoTable(),
              const SizedBox(height: 22),
              _buildAdviceCard(),
              const SizedBox(height: 26),
              RoundButton(
                title: "Volver",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonImageCard extends StatelessWidget {
  final String label;
  final Map<String, dynamic> photo;
  final String typeLabel;
  final String dateLabel;

  const _ComparisonImageCard({
    required this.label,
    required this.photo,
    required this.typeLabel,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ProgressPhotoService.buildImageUrl(
      photo["image_url"]?.toString() ?? "",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: TColor.gray,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 0.78,
          child: Container(
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
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
                        size: 34,
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
                            typeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateLabel,
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
        ),
      ],
    );
  }
}

class _ComparisonInfoRow extends StatelessWidget {
  final String label;
  final String beforeValue;
  final String afterValue;
  final bool isLast;

  const _ComparisonInfoRow({
    required this.label,
    required this.beforeValue,
    required this.afterValue,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 14,
        top: isLast ? 0 : 0,
      ),
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 14,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Colors.grey.shade100,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
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
              beforeValue,
              style: TextStyle(
                color: TColor.black,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              afterValue,
              style: TextStyle(
                color: TColor.primaryColor1,
                fontSize: 12,
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