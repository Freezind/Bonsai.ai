/// A goal is the unit Bonsai plants: a Project (has a finish line) or an
/// Area (tended for the long run). "goal" == project/area throughout.
enum GoalKind { project, area }

enum GoalStatus { growing, ready }

class Goal {
  const Goal({
    required this.slug,
    required this.title,
    required this.kind,
    required this.status,
  });

  /// Stable id; also the bridge cache key via [intent] (`goal:<slug>`).
  final String slug;
  final String title;
  final GoalKind kind;
  final GoalStatus status;

  String get intent => 'goal:$slug';

  Goal copyWith({GoalStatus? status}) => Goal(
        slug: slug,
        title: title,
        kind: kind,
        status: status ?? this.status,
      );

  Map<String, Object?> toJson() => {
        'slug': slug,
        'title': title,
        'kind': kind.name,
        'status': status.name,
      };

  static Goal fromJson(Map<String, dynamic> m) => Goal(
        slug: m['slug'] as String,
        title: m['title'] as String,
        kind: GoalKind.values.byName(m['kind'] as String? ?? 'project'),
        status: GoalStatus.values.byName(m['status'] as String? ?? 'growing'),
      );
}

/// Turn a free-text title into a stable slug ("Job hunt" -> "job-hunt").
String slugify(String title) {
  final s = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9一-鿿]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return s.isEmpty ? 'goal' : (s.length > 40 ? s.substring(0, 40) : s);
}
