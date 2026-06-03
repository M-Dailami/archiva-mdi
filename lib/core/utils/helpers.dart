/// Fungsi utilitas untuk perhitungan XP
class XpUtils {
  static int xpForLevel(int level) {
    return level * 100;
  }

  static int levelFromXp(int totalXp) {
    int level = 1;
    int required = 100;
    int accumulated = 0;
    while (accumulated + required <= totalXp) {
      accumulated += required;
      level++;
      required = level * 100;
    }
    return level;
  }

  static double progressInLevel(int totalXp) {
    int level = 1;
    int required = 100;
    int accumulated = 0;
    while (accumulated + required <= totalXp) {
      accumulated += required;
      level++;
      required = level * 100;
    }
    int xpInLevel = totalXp - accumulated;
    return xpInLevel / required;
  }

  static String rankTitle(int totalXp) {
    if (totalXp < 100) return 'Penjelajah Muda';
    if (totalXp < 300) return 'Penjelajah Andal';
    if (totalXp < 600) return 'Sejarawan Muda';
    if (totalXp < 1000) return 'Sejarawan Senior';
    return 'Maestro Sejarah';
  }
}

