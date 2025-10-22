import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mock_data.dart';
import 'article.dart';

final articlesProvider = Provider<List<Article>>((_) => mockArticles);
