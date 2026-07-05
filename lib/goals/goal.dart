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
    this.spec = '',
    this.stage = 0,
    this.parentArea,
    this.highlight = '',
  });

  /// Stable id; also the bridge cache key via [intent] (`goal:<slug>`).
  final String slug;
  final String title;
  final GoalKind kind;
  final GoalStatus status;

  /// The dashboard generation spec (conversation digest + requirements).
  /// Persisted with the goal so a reinstall/retry can regenerate the
  /// dashboard; it shapes the prompt but never the cache key.
  final String spec;

  /// Growth stage 0..4 (seed → sprout → bonsai → bloom → fruit). The tree
  /// grows — and its face gets happier — as the goal is tended over time.
  final int stage;

  /// For projects: the area (by slug) this project belongs to. Areas list
  /// their projects through this link (Career ⟵ Job Hunt).
  final String? parentArea;

  /// One-line weekly highlight, surfaced on the Home digest.
  final String highlight;

  String get intent => 'goal:$slug';

  Goal copyWith({GoalStatus? status, int? stage, String? highlight}) => Goal(
        slug: slug,
        title: title,
        kind: kind,
        status: status ?? this.status,
        spec: spec,
        stage: stage ?? this.stage,
        parentArea: parentArea,
        highlight: highlight ?? this.highlight,
      );

  Map<String, Object?> toJson() => {
        'slug': slug,
        'title': title,
        'kind': kind.name,
        'status': status.name,
        'spec': spec,
        'stage': stage,
        if (parentArea != null) 'parentArea': parentArea,
        if (highlight.isNotEmpty) 'highlight': highlight,
      };

  static Goal fromJson(Map<String, dynamic> m) => Goal(
        slug: m['slug'] as String,
        title: m['title'] as String,
        kind: GoalKind.values.byName(m['kind'] as String? ?? 'project'),
        status: GoalStatus.values.byName(m['status'] as String? ?? 'growing'),
        spec: m['spec'] as String? ?? '',
        stage: (m['stage'] as num?)?.toInt() ?? 0,
        parentArea: m['parentArea'] as String?,
        highlight: m['highlight'] as String? ?? '',
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
