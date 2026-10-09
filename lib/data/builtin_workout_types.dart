/// Built-in workout types (spec 4.4). Fixed ids so they are identical on
/// every device and never need syncing as user data.
class BuiltinType {
  const BuiltinType(this.id, this.name, this.iconKey);
  final String id;
  final String name;
  final String iconKey;
}

const builtinWorkoutTypes = [
  BuiltinType('builtin-yoga', 'Yoga', 'yoga'),
  BuiltinType('builtin-zumba', 'Zumba', 'zumba'),
  BuiltinType('builtin-walk', 'Walk', 'walk'),
  BuiltinType('builtin-run', 'Run', 'run'),
  BuiltinType('builtin-weights', 'Weights', 'weights'),
  BuiltinType('builtin-legs', 'Legs', 'legs'),
  BuiltinType('builtin-arms', 'Arms', 'arms'),
  BuiltinType('builtin-chest', 'Chest', 'chest'),
  BuiltinType('builtin-back', 'Back', 'back'),
  BuiltinType('builtin-stability', 'Stability', 'stability'),
  BuiltinType('builtin-flexibility', 'Flexibility', 'flexibility'),
  BuiltinType('builtin-other', 'Other', 'other'),
];
