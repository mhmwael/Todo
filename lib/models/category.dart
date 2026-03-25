class Category {
  final int?
  id;
  final String
  name;

  Category({
    this.id,
    required this.name,
  });

  Map<
    String,
    dynamic
  >
  toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Category.fromMap(
    Map<
      String,
      dynamic
    >
    map,
  ) {
    return Category(
      id:
          map['id']
              as int?,
      name:
          map['name']
              as String,
    );
  }

  @override
  bool
  operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other
              is Category &&
          runtimeType ==
              other.runtimeType &&
          id ==
              other.id &&
          name ==
              other.name;

  @override
  int
  get hashCode =>
      id.hashCode ^
      name.hashCode;
}
