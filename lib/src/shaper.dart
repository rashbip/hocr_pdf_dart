class HocrShaper {
  static const int halant = 0x09CD;
  static const int ra = 0x09B0;
  
  // Pre-vowels that must move to the front of their cluster
  static const Set<int> preVowels = {
    0x09BF, // ি (i-kar)
    0x09C7, // ে (e-kar)
    0x09C8, // ৈ (oi-kar)
  };

  // Dependent signs that attach to a consonant
  static bool _isDependentSign(int c) {
    return (c >= 0x09BE && c <= 0x09CC) || 
           (c >= 0x09D7 && c <= 0x09D7) || 
           (c >= 0x0981 && c <= 0x0983) ||
           (c == 0x09BC); // Nukta
  }

  /// Advanced Bengali shaper that handles cluster-based reordering.
  static String shape(String text) {
    if (text.isEmpty) return text;

    final runes = text.runes.toList();
    final List<int> result = [];

    int i = 0;
    while (i < runes.length) {
      // 1. Find the boundaries of the current cluster
      int clusterStart = i;
      int clusterEnd = i + 1;

      // Extend cluster with dependent signs and halant-consonant sequences
      while (clusterEnd < runes.length) {
        int c = runes[clusterEnd];
        if (_isDependentSign(c)) {
          clusterEnd++;
        } else if (c == halant) {
          clusterEnd++; // consume halant
          if (clusterEnd < runes.length) {
            clusterEnd++; // consume the consonant following halant
          }
        } else {
          break;
        }
      }

      // 2. Extract and process the cluster
      List<int> cluster = runes.sublist(clusterStart, clusterEnd);

      // --- Rule A: Decompose Split Vowels (O-kar, OU-kar) ---
      // 0x09CB (ো) -> 0x09C7 (ে) + 0x09BE (া)
      // 0x09CC (ৌ) -> 0x09C7 (ে) + 0x09D7 (ৗ)
      final List<int> decomposed = [];
      for (var c in cluster) {
        if (c == 0x09CB) {
          decomposed.add(0x09C7);
          decomposed.add(0x09BE);
        } else if (c == 0x09CC) {
          decomposed.add(0x09C7);
          decomposed.add(0x09D7);
        } else {
          decomposed.add(c);
        }
      }
      cluster = decomposed;

      // --- Rule B: Handle Pre-vowels (Move to front of cluster) ---
      // We look for any pre-vowels in the cluster (besides the first index)
      for (int k = 1; k < cluster.length; k++) {
        if (preVowels.contains(cluster[k])) {
          int v = cluster.removeAt(k);
          cluster.insert(0, v);
          break; // Usually a cluster has only one such vowel
        }
      }

      // --- Rule B: Handle Ref (Ra + Halant at word/cluster start) ---
      // Ra + Halant as a prefix of a cluster should move to the end of that cluster
      if (cluster.length >= 2 && cluster[0] == ra && cluster[1] == halant) {
        // Only do this if it's acting as a 'Ref' (attached to follow-up)
        // Note: we move it to the end of the cluster for visual placement in some fonts
        int r = cluster.removeAt(0);
        int h = cluster.removeAt(0);
        cluster.add(r);
        cluster.add(h);
      }

      result.addAll(cluster);
      i = clusterEnd;
    }

    return String.fromCharCodes(result);
  }
}
