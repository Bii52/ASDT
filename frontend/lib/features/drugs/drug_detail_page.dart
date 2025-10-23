import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'drug_provider.dart';
import 'drug.dart';

class DrugDetailPage extends ConsumerWidget {
  final String id;
  const DrugDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drug = ref.watch(drugsProvider).firstWhere((e) => e.id == id);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget? optSection(String title, String? content, {IconData? icon}) {
      if (content == null || content.trim().isEmpty) return null;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withOpacity(0.12),
                  ),
                  child: Icon(icon, color: cs.primary, size: 18),
                ),
              if (icon != null) const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(drug.name)),
      body: Stack(
        children: [
          // Nền gradient nhẹ
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.06),
                    cs.secondaryContainer.withOpacity(0.18),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // ===== Header card (ảnh + tên + rating + giá + categories)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: Image.network(
                              drug.imageUrl,
                              width: 120, height: 120, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120, height: 120,
                                color: cs.surfaceVariant,
                                child: const Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Thông tin
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    drug.name,
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 6),
                                  // Rating + Giá
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded, size: 20, color: Colors.amber.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${drug.ratingAvg.toStringAsFixed(1)} (${drug.ratingCount})',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${drug.price.toStringAsFixed(0)} ${drug.currency}',
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Categories (tối đa 3)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: -6,
                                    children: drug.categories.take(3).map((cat) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: cs.primary.withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: cs.primary.withOpacity(0.25)),
                                        ),
                                        child: Text(cat, style: theme.textTheme.labelSmall?.copyWith(color: cs.primary)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Công dụng (uses) — hiển thị nổi bật
                if (drug.uses.trim().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary.withOpacity(0.12)),
                          child: Icon(Icons.local_hospital_outlined, color: cs.primary, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Công dụng', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(drug.uses),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Hoạt chất / NSX (nếu có)
                if ((drug.activeIngredient ?? '').isNotEmpty || (drug.manufacturer ?? '').isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thông tin sản phẩm', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        if ((drug.activeIngredient ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.science_outlined, size: 18),
                                const SizedBox(width: 6),
                                Expanded(child: Text('Hoạt chất: ${drug.activeIngredient}')),
                              ],
                            ),
                          ),
                        if ((drug.manufacturer ?? '').isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.factory_outlined, size: 18),
                              const SizedBox(width: 6),
                              Expanded(child: Text('Nhà sản xuất: ${drug.manufacturer}')),
                            ],
                          ),
                      ],
                    ),
                  ),

                // Các mục chuyên môn (nếu có)
                ...[
                  optSection('Chỉ định', drug.indications, icon: Icons.check_circle_outline),
                  optSection('Chống chỉ định', drug.contraindications, icon: Icons.block_outlined),
                  optSection('Liều dùng - Cách dùng', drug.dosage, icon: Icons.schedule_outlined),
                  optSection('Tác dụng phụ', drug.sideEffects, icon: Icons.warning_amber_outlined),
                  optSection('Lưu ý', drug.notes, icon: Icons.info_outline),
                ].whereType<Widget>(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
