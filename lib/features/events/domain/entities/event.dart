/// Domain entity representing an MMA/combat sports event.
class Event {
  final String id;
  final String name;
  final String date;
  final String? location;
  final String? imageUrl;
  final bool isUpcoming;

  const Event({
    required this.id,
    required this.name,
    required this.date,
    this.location,
    this.imageUrl,
    this.isUpcoming = false,
  });
}
