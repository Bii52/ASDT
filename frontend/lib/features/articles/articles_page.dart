import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'articles_provider.dart';

class ArticlesPage extends ConsumerWidget {
  const ArticlesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(articlesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bài viết sức khỏe')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (_, i) {
          final a = items[i];
          return ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(a.title),
            subtitle: Text(a.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => context.push('/articles/${a.id}'),
          );
        },
      ),
    );
  }
}
