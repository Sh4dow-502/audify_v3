import 'package:audify_v3/providers/song_provider.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';

class FilterComponent extends StatelessWidget {
  const FilterComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = context.watch<SongProvider>().filters;
    final currentFilter = context.watch<SongProvider>().filter;

    return Padding(
      // padding: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            ...filters.map((filter) {
              return FButton(
                onPress: () {
                  context.read<SongProvider>().applyFilter(filter);
                },
                variant: currentFilter.toLowerCase() == filter.toLowerCase()
                    ? FButtonVariant.primary
                    : FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,

                    color: currentFilter.toLowerCase() == filter.toLowerCase()
                        ? context.theme.colors.primaryForeground
                        : context.theme.colors.mutedForeground,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
