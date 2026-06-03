class ExerciseVideoHelper {
  static String? getVideoUrl({
    required String exerciseName,
    String? muscleGroup,
    String? category,
    String? explicitVideoUrl,
  }) {
    if (explicitVideoUrl != null && explicitVideoUrl.trim().isNotEmpty) {
      return explicitVideoUrl.trim();
    }

    final normalizedName = _normalize(exerciseName);

    final directMatch = _videoUrls[normalizedName];

    if (directMatch != null) {
      return directMatch;
    }

    final queryParts = [
      exerciseName,
      muscleGroup,
      category,
      "exercise technique",
    ]
        .where((item) => item != null && item.trim().isNotEmpty)
        .map((item) => item!.trim())
        .join(" ");

    if (queryParts.trim().isEmpty) {
      return null;
    }

    final encodedQuery = Uri.encodeComponent(queryParts);

    return "https://www.youtube.com/results?search_query=$encodedQuery";
  }

  static bool hasDirectVideo({
    required String exerciseName,
    String? explicitVideoUrl,
  }) {
    if (explicitVideoUrl != null && explicitVideoUrl.trim().isNotEmpty) {
      return true;
    }

    return _videoUrls.containsKey(_normalize(exerciseName));
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll("á", "a")
        .replaceAll("é", "e")
        .replaceAll("í", "i")
        .replaceAll("ó", "o")
        .replaceAll("ú", "u")
        .replaceAll("ü", "u")
        .replaceAll("ñ", "n")
        .replaceAll(RegExp(r'\s+'), " ");
  }

  static final Map<String, String> _videoUrls = {
    "sentadilla": "https://www.youtube.com/results?search_query=sentadilla+tecnica+ejercicio",
    "squat": "https://www.youtube.com/results?search_query=squat+proper+form",
    "press banca": "https://www.youtube.com/results?search_query=press+banca+tecnica",
    "bench press": "https://www.youtube.com/results?search_query=bench+press+proper+form",
    "peso muerto": "https://www.youtube.com/results?search_query=peso+muerto+tecnica",
    "deadlift": "https://www.youtube.com/results?search_query=deadlift+proper+form",
    "dominadas": "https://www.youtube.com/results?search_query=dominadas+tecnica",
    "pull up": "https://www.youtube.com/results?search_query=pull+up+proper+form",
    "flexiones": "https://www.youtube.com/results?search_query=flexiones+tecnica",
    "push up": "https://www.youtube.com/results?search_query=push+up+proper+form",
    "zancadas": "https://www.youtube.com/results?search_query=zancadas+tecnica+ejercicio",
    "lunges": "https://www.youtube.com/results?search_query=lunges+proper+form",
    "plancha": "https://www.youtube.com/results?search_query=plancha+abdominal+tecnica",
    "plank": "https://www.youtube.com/results?search_query=plank+proper+form",
    "remo": "https://www.youtube.com/results?search_query=remo+ejercicio+tecnica",
    "row": "https://www.youtube.com/results?search_query=row+exercise+proper+form",
    "curl biceps": "https://www.youtube.com/results?search_query=curl+biceps+tecnica",
    "biceps curl": "https://www.youtube.com/results?search_query=biceps+curl+proper+form",
    "press militar": "https://www.youtube.com/results?search_query=press+militar+tecnica",
    "shoulder press": "https://www.youtube.com/results?search_query=shoulder+press+proper+form",
  };
}