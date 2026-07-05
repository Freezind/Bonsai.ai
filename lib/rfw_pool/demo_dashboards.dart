/// Fixed Day-90 dashboards (docs/demo-fake-data.md G1–G3 + a training board
/// in the same spirit) — build-time rfw templates rendered straight from the
/// frozen pool, NO bridge involved. This is the pivoted shape of the product:
/// screens are designed frames; the AI only adjusts limited slots later.
///
/// The AppBar title binds `data.goal.title`, so the dashboard carries
/// whatever name the goal was planted under (narrative continuity between
/// the Day-1 seeding take and the Day-90 world).
library;

/// slug -> fixed dashboard DSL.
const Map<String, String> kDemoDashboards = {
  'job-hunt': _jobHunt,
  'career': _career,
  'health': _health,
  'daily-training': _dailyTraining,
};

/// G1 · Job Hunt (Project): pipeline Stepper + StatusTable + todos.
const String _jobHunt = r'''
import core.widgets;
import bonsai.widgets;

widget root = Canvas(
  child: Column(
    crossAxisAlignment: "stretch",
    children: [
      AppBar(large: true, overline: "P · PROJECT", title: data.goal.title),
      Padding(
        padding: [16.0, 0.0, 16.0, 24.0],
        child: Column(
          crossAxisAlignment: "stretch",
          children: [
            Card(child: Row(children: [
              Ico(name: "target", size: 20.0),
              SizedBox(width: 10.0),
              Expanded(child: Txt(style: "body2", text: "Goal: a senior role on a product team that ships — offer signed by end of August.")),
            ])),
            SizedBox(height: 12.0),
            Card(child: Txt(style: "body", text: "\"The only way to do great work is to love what you do.\" — Steve Jobs")),
            SizedBox(height: 16.0),
            SectionHeader(title: "Pipeline"),
            SizedBox(height: 8.0),
            Stepper(children: [
              Step(label: "Applied", state: "done", n: "12"),
              Step(label: "Screens", state: "done", n: "6"),
              Step(label: "Tech round", state: "active", n: "3"),
              Step(label: "Onsite", state: "upcoming", n: "1"),
              Step(label: "Offer", state: "upcoming"),
            ]),
            SizedBox(height: 16.0),
            SectionHeader(title: "Active applications", action: "See all"),
            SizedBox(height: 8.0),
            Card(child: StatusTable(children: [
              StatusRow(item: "Lumina Health — onsite Tue", status: "actionable"),
              StatusRow(item: "Kite Systems — tech round Thu", status: "actionable"),
              StatusRow(item: "Orbit Robotics — silent for 12 days", status: "warning"),
              StatusRow(item: "Mapletree Pay — screen scheduled", status: "done"),
            ])),
            SizedBox(height: 16.0),
            SectionHeader(title: "This week's todos"),
            SizedBox(height: 4.0),
            CheckItem(label: "Prep system design: payments case study"),
            CheckItem(label: "Send thank-you note to the Kite panel", checked: true),
            CheckItem(label: "Follow up with Orbit's recruiter"),
            CheckItem(label: "Book a mock interview before the onsite"),
            SizedBox(height: 16.0),
            Button(label: "Save", variant: "contained", onPressed: event "save" { screen: "job-hunt" }),
          ],
        ),
      ),
    ],
  ),
);
''';

/// G2 · Career (Area): status KeyValues, linked project, strengths, edges,
/// skill graph, timeline, readiness ring.
const String _career = r'''
import core.widgets;
import bonsai.widgets;

widget root = Canvas(
  child: Column(
    crossAxisAlignment: "stretch",
    children: [
      AppBar(large: true, overline: "A · AREA", title: data.goal.title),
      Padding(
        padding: [16.0, 0.0, 16.0, 24.0],
        child: Column(
          crossAxisAlignment: "stretch",
          children: [
            Card(child: Column(crossAxisAlignment: "stretch", children: [
              KeyValue(label: "Role", value: "Senior Software Engineer"),
              KeyValue(label: "Experience", value: "8 years"),
              KeyValue(label: "Edge", value: "Distributed systems"),
              KeyValue(label: "Season", value: "Actively interviewing"),
            ])),
            SizedBox(height: 12.0),
            ProjectCard(
              category: "P · PROJECT", status: "actionable",
              title: "Job Hunt — Senior SWE",
              subtitle: "5 in pipeline · 2 interviews this week",
              progress: 0.45,
            ),
            SizedBox(height: 16.0),
            SectionHeader(title: "Strengths"),
            SizedBox(height: 8.0),
            Row(children: [
              Chip(label: "Systems design", selected: true),
              SizedBox(width: 8.0),
              Chip(label: "Incident command", selected: true),
              SizedBox(width: 8.0),
              Chip(label: "Mentoring", selected: true),
            ]),
            SizedBox(height: 16.0),
            SectionHeader(title: "Growth edges"),
            SizedBox(height: 8.0),
            Card(child: StatusTable(children: [
              StatusRow(item: "Salary negotiation", status: "warning"),
              StatusRow(item: "Public speaking", status: "warning"),
              StatusRow(item: "Visible writing", status: "blocked"),
            ])),
            SizedBox(height: 16.0),
            DependencyGraph(nodes: [
              DepNode(label: "senior scope", status: "done"),
              DepNode(label: "staff scope", status: "actionable"),
              DepNode(label: "negotiation", status: "blocker"),
              DepNode(label: "open-source visibility", status: "blocked"),
            ]),
            SizedBox(height: 16.0),
            Timeline(children: [
              TimeItem(title: "Joined Kite Systems, first backend role", time: "2019", status: "done"),
              TimeItem(title: "Senior promotion after the payments re-architecture", time: "2022", status: "done"),
              TimeItem(title: "Led incident program, cut MTTR 40%", time: "2025", status: "done"),
              TimeItem(title: "Hunting staff scope", time: "2026", status: "actionable"),
            ]),
            SizedBox(height: 8.0),
            Row(children: [
              ProgressRing(value: 0.7, size: 84.0, label: "70%"),
              SizedBox(width: 14.0),
              Txt(style: "body2", text: "Staff readiness"),
            ]),
          ],
        ),
      ),
    ],
  ),
);
''';

/// G3 · Health (Area): quote, current state, habit heatmap, sleep chart,
/// stats, wind-down reminder, morning mood.
const String _health = r'''
import core.widgets;
import bonsai.widgets;

widget root = Canvas(
  child: Column(
    crossAxisAlignment: "stretch",
    children: [
      AppBar(large: true, overline: "A · AREA", title: data.goal.title),
      Padding(
        padding: [16.0, 0.0, 16.0, 24.0],
        child: Column(
          crossAxisAlignment: "stretch",
          children: [
            Card(child: Txt(style: "body", text: "\"You only get one mind and one body. And it's got to last a lifetime.\" — Warren Buffett")),
            SizedBox(height: 12.0),
            Card(child: Row(children: [
              Ico(name: "leaf", size: 20.0),
              SizedBox(width: 10.0),
              Expanded(child: Txt(style: "body2", text: "One habit at a time: building a 10-minute morning stretch. Sleep and meditation hold steady; strength training waits in the queue.")),
            ])),
            SizedBox(height: 16.0),
            SectionHeader(title: "Habits · last 14 days"),
            SizedBox(height: 8.0),
            HabitHeatmap(rows: [
              HeatRow(label: "Sleep by 23:30", days: "d,d,m,d,d,d,m,d,d,d,d,m,d,t"),
              HeatRow(label: "Stretch 10 min", days: "e,e,e,e,e,e,e,d,d,m,d,d,d,t"),
              HeatRow(label: "Meditate", days: "d,d,d,d,m,d,d,d,d,d,m,d,d,t"),
              HeatRow(label: "10k steps", days: "m,d,d,m,d,d,d,m,m,d,d,d,m,t"),
            ]),
            SizedBox(height: 16.0),
            SectionHeader(title: "Sleep · this week"),
            SizedBox(height: 8.0),
            BarChart(values: "6.1,7.2,5.8,6.9,7.4,5.6,6.4", labels: "M,T,W,T,F,S,S"),
            SizedBox(height: 12.0),
            Row(children: [
              Expanded(child: Stat(label: "Avg sleep", value: "6h 29m", delta: "-18m")),
              SizedBox(width: 10.0),
              Expanded(child: Stat(label: "Meditation streak", value: "6 days", delta: "+6")),
            ]),
            SizedBox(height: 16.0),
            Alert(severity: "warning", text: "Under 6h on both interview eves."),
            SizedBox(height: 8.0),
            Card(child: Row(children: [
              Expanded(child: Txt(style: "body2", text: "Wind-down reminder · 22:45")),
              Switch(value: true),
            ])),
            SizedBox(height: 16.0),
            SectionHeader(title: "This morning"),
            SizedBox(height: 8.0),
            MoodPicker(options: [
              MoodOption(emoji: "😴", label: "low"),
              MoodOption(emoji: "🙂", label: "ok", selected: true),
              MoodOption(emoji: "😊", label: "good"),
            ]),
            SizedBox(height: 16.0),
            Button(label: "Save", variant: "contained", onPressed: event "save" { screen: "health" }),
          ],
        ),
      ),
    ],
  ),
);
''';

/// G4 · Daily Training (Project): streaks, session log, workout chart, todos.
const String _dailyTraining = r'''
import core.widgets;
import bonsai.widgets;

widget root = Canvas(
  child: Column(
    crossAxisAlignment: "stretch",
    children: [
      AppBar(large: true, overline: "P · PROJECT", title: data.goal.title),
      Padding(
        padding: [16.0, 0.0, 16.0, 24.0],
        child: Column(
          crossAxisAlignment: "stretch",
          children: [
            Card(child: Row(children: [
              Ico(name: "target", size: 20.0),
              SizedBox(width: 10.0),
              Expanded(child: Txt(style: "body2", text: "Goal: move every day — a 10-minute floor is always a win.")),
            ])),
            SizedBox(height: 12.0),
            Row(children: [
              Expanded(child: Stat(label: "Stretch streak", value: "7 days", delta: "+7")),
              SizedBox(width: 10.0),
              Expanded(child: Stat(label: "Sessions this week", value: "5", delta: "+2")),
            ]),
            SizedBox(height: 16.0),
            SectionHeader(title: "Movement · last 14 days"),
            SizedBox(height: 8.0),
            HabitHeatmap(rows: [
              HeatRow(label: "Stretch 10 min", days: "e,e,e,e,e,e,e,d,d,m,d,d,d,t"),
              HeatRow(label: "10k steps", days: "m,d,d,m,d,d,d,m,m,d,d,d,m,t"),
            ]),
            SizedBox(height: 16.0),
            SectionHeader(title: "Minutes moved · this week"),
            SizedBox(height: 8.0),
            BarChart(values: "22,35,10,40,28,15,30", labels: "M,T,W,T,F,S,S"),
            SizedBox(height: 16.0),
            SectionHeader(title: "Today"),
            SizedBox(height: 4.0),
            CheckItem(label: "Morning stretch — hips and shoulders", checked: true),
            CheckItem(label: "Walk after lunch, 20 minutes"),
            CheckItem(label: "Wind down by 23:00 — interview tomorrow"),
            SizedBox(height: 16.0),
            Button(label: "Save", variant: "contained", onPressed: event "save" { screen: "daily-training" }),
          ],
        ),
      ),
    ],
  ),
);
''';
