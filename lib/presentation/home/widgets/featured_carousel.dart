import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:asaan_rent/data/models/property_model.dart';

class FeaturedCarousel extends StatelessWidget {
  final List<Property> featuredProperties;
  final Function(String propertyId) onPropertyTap;

  const FeaturedCarousel({
    super.key,
    required this.featuredProperties,
    required this.onPropertyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (featuredProperties.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("No featured properties."),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: featuredProperties.map((property) {
        final imageUrl = (property.images != null && property.images!.isNotEmpty)
            ? property.images![0]
            : null;

        final propertyId = property.id;

        return GestureDetector(
          onTap: () => onPropertyTap(propertyId),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 1000,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.grey, size: 40)),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 40)),
                  ),
          ),
        );
      }).toList(),
    );
  }
}