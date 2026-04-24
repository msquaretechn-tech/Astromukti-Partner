import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:astro_mukti/repository/repository.dart';

import '../../../resources/resources.dart';

class ExpertiseScreen extends StatelessWidget {
  ExpertiseScreen({super.key});

  /// Multi select state (STF friendly)
  final ValueNotifier<Set<int>> selectedIndexes = ValueNotifier<Set<int>>({});

  final List<Category> categories = const [
    Category(icon: Icons.favorite_border, label: 'Love'),
    Category(icon: Icons.work_outline, label: 'Career'),
    Category(icon: Icons.cast_for_education, label: 'Education'),
    Category(icon: Icons.volunteer_activism_outlined, label: 'Choice'),
    Category(icon: Icons.book_outlined, label: 'Psychic Reading'),
  ];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Select Category',
            style: Resources.styles.kTextStyle16B(Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 12),

            /// GRID
            Expanded(
              child: ValueListenableBuilder<Set<int>>(
                valueListenable: selectedIndexes,
                builder: (context, selected, _) {
                  return GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: List.generate(categories.length, (index) {
                      final category = categories[index];
                      final isSelected = selected.contains(index);

                      return GestureDetector(
                        onTap: () {
                          final updated = Set<int>.from(selected);
                          if (isSelected) {
                            updated.remove(index);
                          } else {
                            updated.add(index);
                          }
                          selectedIndexes.value = updated;
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Resources.colors.themeColor.withOpacity(
                                        .2,
                                      )
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Resources.colors.themeColor
                                      : Colors.grey,
                                  width: isSelected ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category.icon,
                                color: isSelected
                                    ? Resources.colors.themeColor
                                    : Colors.grey,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.label,
                              style: Resources.styles.kTextStyle12B(
                                Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            /// BUTTON
            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, _) {
                return ValueListenableBuilder<Set<int>>(
                  valueListenable: selectedIndexes,
                  builder: (context, selected, _) {
                    final isEnabled = selected.isNotEmpty && !loading;

                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: isEnabled
                            ? () async {
                                final selectedLabels = selected
                                    .map((i) => categories[i].label)
                                    .toList();
                                final expertString = selectedLabels.join(',');
                                isLoading.value = true;

                                try {
                                  final response = await Repository()
                                      .updateProfile({
                                        "expertise": expertString,
                                      }, []);

                                  Navigator.pop(context);
                                  log('expert Response: $response');
                                } catch (e) {
                                  log('Error: $e');
                                } finally {
                                  isLoading.value = false;
                                }
                              }
                            : null,

                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            :  Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 55,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40), // pill shape
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFF9E076),
                                Color(0xFFD4AF37),
                                Color(0xFFF9E076),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Colors.white70, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'Submit',
                              style: Resources.styles.kTextStyle16B(Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final IconData icon;
  final String label;
  const Category({required this.icon, required this.label});
}
