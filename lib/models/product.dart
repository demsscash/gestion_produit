import 'category.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final List<Category> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Category> categoriesList = [];
    if (json['categories'] != null) {
      categoriesList = List<Category>.from(
        json['categories'].map((category) => Category.fromJson(category)),
      );
    }

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price:
          json['price'] is int
              ? json['price'].toDouble()
              : double.parse(json['price'].toString()),
      stock: json['stock'],
      categories: categoriesList,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    };

    if (categories.isNotEmpty) {
      data['categories'] = categories.map((category) => category.id).toList();
    }

    return data;
  }

  // Crée une copie du produit avec des propriétés modifiées
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    List<Category>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
