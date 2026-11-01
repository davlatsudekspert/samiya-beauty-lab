/// Bepul va Pro chegarasi (90 kunlik kampaniyadan keyin). Kampaniya davomida hammasi ochiq.
/// Bepul qism doim foydali bo'lib qoladi: skaner, ingredientlar bazasi, Akademiyaning birinchi darslari va h.k.
class ProGate {
  static const freeLessons = 2;
  static const freeRecipes = 4;
  static const freeRituals = 1;
  static const freeIbnSina = 6;
  static const freeShelf = 5;

  /// [index] (0 dan) bepul chegarada bo'lsa yoki [unlocked] bo'lsa ochiq.
  static bool open({required bool unlocked, required int index, required int freeCount}) => unlocked || index < freeCount;
}
