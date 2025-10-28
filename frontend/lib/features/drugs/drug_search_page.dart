import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'drug_provider.dart';
import 'drug.dart';

class DrugSearchPage extends ConsumerWidget {
  const DrugSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final list = ref.watch(filteredDrugsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu thuốc'),
        actions: [
          IconButton(
            onPressed: () => context.push('/dashboard'),
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Về Dashboard',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Nền gradient nhẹ
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.06),
                    theme.colorScheme.secondaryContainer.withOpacity(0.18),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const _SearchBar(),
                const SizedBox(height: 12),
                const _FilterBar(),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  const _EmptyState()
                else
                  ...list.map((d) => _DrugTile(d: d)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(drugSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (v) => ref.read(drugSearchQueryProvider.notifier).state = v,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tên thuốc, hoạt chất, công dụng...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _controller.clear();
                  ref.read(drugSearchQueryProvider.notifier).state = '';
                },
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Xoá',
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);
    final selected = ref.watch(selectedCategoriesProvider);
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hàng đầu: tiêu đề + Clear + Sort
        Row(
          children: [
            Text('Bộ lọc', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            if (selected.isNotEmpty)
              TextButton.icon(
                onPressed: () => ref.read(selectedCategoriesProvider.notifier).state = <String>{},
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Xoá bộ lọc'),
              ),
            const SizedBox(width: 8),
            _SortDropdown(), // pill sắp xếp bên phải
          ],
        ),
        const SizedBox(height: 8),

        // Hàng thứ 2: chip danh mục
        _Pill(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.category_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Danh mục', style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Wrap(
                  spacing: 8,
                  children: categories.map((cat) {
                    final isSelected = selected.contains(cat);
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        final set = {...selected};
                        isSelected ? set.remove(cat) : set.add(cat);
                        ref.read(selectedCategoriesProvider.notifier).state = set;
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ========== Helpers ==========

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.child,
    this.padding,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.outlineVariant.withOpacity(0.5)),
      ),
      child: child,
    );
  }
}

class _SortDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(sortByProvider);
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    IconData iconOf(DrugSortBy v) {
      switch (v) {
        case DrugSortBy.priceAsc:  return Icons.south_east_rounded;
        case DrugSortBy.priceDesc: return Icons.north_east_rounded;
        case DrugSortBy.ratingDesc:return Icons.star_rounded;
        default: return Icons.sort_rounded;
      }
    }

    String labelOf(DrugSortBy v) {
      switch (v) {
        case DrugSortBy.priceAsc:  return 'Giá ↑';
        case DrugSortBy.priceDesc: return 'Giá ↓';
        case DrugSortBy.ratingDesc:return 'Rating ↓';
        default: return 'Liên quan';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.outlineVariant.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DrugSortBy>(
          value: sortBy,
          onChanged: (v) {
            if (v != null) ref.read(sortByProvider.notifier).state = v;
          },
          items: DrugSortBy.values.map((v) {
            return DropdownMenuItem(
              value: v,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconOf(v), size: 18, color: c.primary),
                  const SizedBox(width: 6),
                  Text(labelOf(v), style: t.bodyMedium),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (ctx) {
            return DrugSortBy.values.map((v) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconOf(sortBy), size: 18, color: c.primary),
                  const SizedBox(width: 6),
                  Text(labelOf(sortBy), style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}



/// ======================= List item =======================

class _DrugTile extends StatelessWidget {
  final Drug d;
  const _DrugTile({required this.d});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.push('/drugs/${d.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: c.surface.withOpacity(0.75),
          border: Border.all(color: c.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            // Ảnh
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                d.imageUrl,
                width: 100, height: 100, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100, height: 100,
                  color: c.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Nội dung
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      d.uses,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text('${d.ratingAvg.toStringAsFixed(1)} (${d.ratingCount})', style: t.bodySmall),
                        const SizedBox(width: 12),
                        Text(
                          '${d.price.toStringAsFixed(0)} ${d.currency}',
                          style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Hiển thị category (tối đa 2)
                    Wrap(
                      spacing: 6,
                      runSpacing: -6,
                      children: d.categories.take(2).map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: c.primary.withOpacity(0.25)),
                          ),
                          child: Text(cat, style: t.labelSmall?.copyWith(color: c.primary)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================= Empty =======================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.outlineVariant.withOpacity(0.5)),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_outlined, size: 42),
          SizedBox(height: 8),
          Text('Không tìm thấy kết quả phù hợp'),
          SizedBox(height: 4),
          Text('Hãy thử từ khoá khác hoặc thay đổi bộ lọc'),
        ],
      ),
    );
  }
}
