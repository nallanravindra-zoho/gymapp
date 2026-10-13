/// Curated wellness tips (spec 7.7). Written for this app, so their source
/// label is "Original". Each is tied to the insight that can trigger it.
///
/// Rules for adding tips: calm and brief, no exclamation marks, no extreme
/// goals or numbers, no medical claims, no guilt. The app shows every tip with
/// the footer "General wellness suggestion. Not medical advice."
class SeedTip {
  const SeedTip(this.id, this.triggerKey, this.text);
  final String id;
  final String triggerKey;
  final String text;
}

const seedTipSource = 'Original';

const tipFooter = 'General wellness suggestion. Not medical advice.';

const seedTips = <SeedTip>[
  // stretch_on_workout_days
  SeedTip(
    'tip-stretch-1',
    'stretch_on_workout_days',
    'Pairing a stretch with something you already do, like a workout or a phone call, can make it easier to keep.',
  ),
  SeedTip(
    'tip-stretch-2',
    'stretch_on_workout_days',
    'A short stretch after sitting for a while is a small habit that is easy to repeat.',
  ),
  SeedTip(
    'tip-stretch-3',
    'stretch_on_workout_days',
    'On days without a workout, a one-minute stretch can keep the routine going.',
  ),

  // active_days_change
  SeedTip(
    'tip-active-1',
    'active_days_change',
    'Small, regular sessions are often easier to keep than occasional long ones.',
  ),
  SeedTip(
    'tip-active-2',
    'active_days_change',
    'A short walk counts as an active day. Regularity matters more than intensity.',
  ),
  SeedTip(
    'tip-active-3',
    'active_days_change',
    'Choosing the next session in advance can make it easier to start.',
  ),

  // longest_gap
  SeedTip(
    'tip-gap-1',
    'longest_gap',
    'After a few quiet days, a short walk or stretch is an easy way to begin again.',
  ),
  SeedTip(
    'tip-gap-2',
    'longest_gap',
    'Planning the next session while you are still finishing one can make restarting simpler.',
  ),
  SeedTip(
    'tip-gap-3',
    'longest_gap',
    'Rest days are part of a routine. Marking them helps you see what was planned.',
  ),

  // water_consistency
  SeedTip(
    'tip-water-1',
    'water_consistency',
    'Keeping a glass of water within reach can make regular sips easier through the day.',
  ),
  SeedTip(
    'tip-water-2',
    'water_consistency',
    'Linking a glass of water to a routine, like a meal or a break, can help it stick.',
  ),

  // sleep_consistency
  SeedTip(
    'tip-sleep-1',
    'sleep_consistency',
    'A similar bedtime and wake time across the week can make evenings easier to plan.',
  ),
  SeedTip(
    'tip-sleep-2',
    'sleep_consistency',
    'A short wind-down before bed, such as stretching or reading, can work as a helpful cue.',
  ),
  SeedTip(
    'tip-sleep-3',
    'sleep_consistency',
    'Keeping the room dim in the last part of the evening can help signal that the day is ending.',
  ),

  // screen_time_late
  SeedTip(
    'tip-screen-1',
    'screen_time_late',
    'A short screen break in the evening can be an easy way to wind down.',
  ),
  SeedTip(
    'tip-screen-2',
    'screen_time_late',
    'Leaving the phone to charge away from the bed can make it easier to put it down.',
  ),
  SeedTip(
    'tip-screen-3',
    'screen_time_late',
    'Choosing a time to stop using screens each evening is easier to follow than deciding each night.',
  ),
];

// --- Healthy Habits recommendation cards (R4) --------------------------------

/// The sentence every habit recommendation card must end with.
const recommendationDisclaimer =
    'General wellness information only; not medical advice.';

/// A general, non-prescriptive suggestion shown on the Healthy Habits screen.
///
/// The source is kept here, in the tip library, with its link. Cards make no
/// personalised medical claims and give no fixed amounts of water.
class HabitRecommendation {
  const HabitRecommendation({
    required this.id,
    required this.habitKind,
    required this.title,
    required this.text,
    required this.sourceLabel,
    required this.sourceUrl,
  });

  final String id;

  /// The [HabitKind] name this card is about: `water`, `stand` or `stretch`.
  final String habitKind;
  final String title;

  /// Ends with [recommendationDisclaimer].
  final String text;
  final String sourceLabel;
  final String sourceUrl;
}

const habitRecommendations = <HabitRecommendation>[
  HabitRecommendation(
    id: 'rec-water-1',
    habitKind: 'water',
    title: 'Drink water regularly',
    text:
        'Sipping water regularly through the day is a simple habit, and a glass within reach can make it easier. $recommendationDisclaimer',
    sourceLabel: 'NHS: Water, drinks and hydration',
    sourceUrl: 'https://www.nhs.uk/live-well/eat-well/food-guidelines-and-food-labels/water-drinks-nutrition/',
  ),
  HabitRecommendation(
    id: 'rec-stand-1',
    habitKind: 'stand',
    title: 'Break up long sitting',
    text:
        'If you sit for long stretches, a short, gentle movement break now and then is an easy way to change position. $recommendationDisclaimer',
    sourceLabel: 'Mayo Clinic: Sitting risks and movement',
    sourceUrl: 'https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/sitting/art-20043914',
  ),
  HabitRecommendation(
    id: 'rec-stretch-1',
    habitKind: 'stretch',
    title: 'Stretch when you have been sitting',
    text:
        'A gentle stretch during a long spell of sitting can be a calm way to take a break. Move at a comfortable pace. $recommendationDisclaimer',
    sourceLabel: 'Mayo Clinic: Sitting risks and movement',
    sourceUrl: 'https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/sitting/art-20043914',
  ),
];
