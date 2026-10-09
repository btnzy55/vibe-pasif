class Client {
  String? id;
  String name;
  int qty;

  Client(this.name, this.qty, {this.id});

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
      };

  factory Client.fromMap(Map<String, dynamic> map, {String? id}) => Client(
        map['name'] as String? ?? '',
        (map['qty'] as num?)?.toInt() ?? 0,
        id: id ?? map['id'] as String?,
      );
}
