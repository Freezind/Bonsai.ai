import '../goals/goal.dart';

/// The Day-90 demo world (docs/demo-fake-data.md, persona "Aya"): a garden
/// that has been tended for a season. Two projects in flight, each rooted in
/// its area — Career ⟵ Job Hunt, Health ⟵ Daily Training. Trees are grown
/// (later stages = happier faces). All content is fictional.
///
/// Day 1 = the empty registry: nothing planted, Home still asleep.
class DemoScenario {
  DemoScenario._();

  /// The Day-90 world, carrying the Day-1 narrative forward: if a project
  /// was already planted (the onboarding take), its TITLE becomes the
  /// job-hunt project's title — same seed, ninety days later.
  static List<Goal> day90For(List<Goal> existing) {
    Goal? planted;
    for (final g in existing) {
      if (g.kind == GoalKind.project) {
        planted = g;
        break;
      }
    }
    if (planted == null) return day90Goals;
    return [
      for (final g in day90Goals)
        if (g.slug == 'job-hunt')
          Goal(
            slug: g.slug,
            title: planted.title, // continuity with the planting take
            kind: g.kind,
            status: g.status,
            stage: g.stage,
            parentArea: g.parentArea,
            highlight: g.highlight,
          )
        else
          g,
    ];
  }

  static const day90Goals = <Goal>[
    Goal(
      slug: 'job-hunt',
      title: 'Job Hunt — Senior SWE',
      kind: GoalKind.project,
      status: GoalStatus.ready,
      stage: 3, // bloom — a strong week
      parentArea: 'career',
      highlight:
          'Two interviews booked; replies doubled after the resume rewrite.',
    ),
    Goal(
      slug: 'daily-training',
      title: 'Daily Training',
      kind: GoalKind.project,
      status: GoalStatus.ready,
      stage: 4, // fruit — 6-day streak paying off
      parentArea: 'health',
      highlight:
          'Stretch habit hit day 7; meditation streak at 6 and counting.',
    ),
    Goal(
      slug: 'career',
      title: 'Career',
      kind: GoalKind.area,
      status: GoalStatus.ready,
      stage: 3,
      highlight:
          'Both interviewers echoed the same strength: calm under pressure.',
    ),
    Goal(
      slug: 'health',
      title: 'Health',
      kind: GoalKind.area,
      status: GoalStatus.ready,
      stage: 2,
      highlight:
          'Sleep dipped under 6h on interview eves — wind-down is back on.',
    ),
  ];

  // ---- H0 · the weekly digest (Home) ----
  static const digestOverline = 'SUNDAY · JUL 5 · WEEK 27';
  static const digestTitle = 'This week, tended.';
  static const overnightTitle = 'While you slept';
  static const overnightBody =
      "Lumina's onsite is Tuesday at 2pm, but your focus peaks before noon — "
      'prep block moved to Monday morning. One thing needs a decision: '
      'Orbit has been silent for 12 days.';
  static const decisionPrimary = 'Draft a follow-up';
  static const decisionSecondary = 'Let it go';

  static const weekStats = <(String, String, String)>[
    ('Applications', '12', '+5'),
    ('In pipeline', '5', '+2'),
    ('Interviews', '2', '+2'),
  ];

  static const healthNote =
      'Sleep dipped under 6h on both interview eves. Wind-down reminder is '
      'on for 22:45 tonight.';
  static const footer = 'Grown overnight by your gardener · Sun 6:04';
}
