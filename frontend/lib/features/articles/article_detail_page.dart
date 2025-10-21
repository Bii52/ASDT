import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'articles_provider.dart';

class ArticleDetailPage extends ConsumerWidget {
  final String id;
  const ArticleDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final art = ref.watch(articlesProvider).firstWhere((e) => e.id == id);
    return Scaffold(
      appBar: AppBar(title: Text(art.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(art.content ?? '—'),
      ),
    );
  }
}
