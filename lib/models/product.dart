class Product {
  final String id; // SKU like RT-10
  final String name; // Arabic short name
  final String tagline; // short subtitle
  final String description; // long description
  final List<String> features;
  final int priceYer; // price in Yemeni Rial
  final String image; // asset path
  final String category; // category id

  const Product({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.features,
    required this.priceYer,
    required this.image,
    required this.category,
  });
}

class Category {
  final String id;
  final String name;
  final String iconAsset; // optional, currently using Material icons
  const Category({required this.id, required this.name, this.iconAsset = ''});
}
