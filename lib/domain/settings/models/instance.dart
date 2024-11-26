import 'dart:convert';


//--------PIPED INSTANCE MODEL--------//

class Instance {
  final String name;
  final String api;
  final String locations;
  Instance({
    required this.name,
    required this.api,
    required this.locations,
  });

  Instance copyWith({
    String? name,
    String? api,
    String? locations,
    String? cdn,
  }) {
    return Instance(
      name: name ?? this.name,
      api: api ?? this.api,
      locations: locations ?? this.locations,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'api': api,
      'locations': locations,
    };
  }

  factory Instance.fromMap(Map<String, dynamic> map) {
    return Instance(
      name: map['name'] as String,
      api: map['api'] as String,
      locations: map['locations'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Instance.fromJson(String source) =>
      Instance.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Instance(name: $name, api: $api, locations: $locations,)';
  }

  @override
  bool operator ==(covariant Instance other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.api == api &&
        other.locations == locations;
  }

  @override
  int get hashCode {
    return name.hashCode ^ api.hashCode ^ locations.hashCode;
  }
}
