import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/bible_books_provider.dart';
import 'book_detail_screen.dart';

class BibleBooksScreen extends StatefulWidget {
  const BibleBooksScreen({super.key});

  @override
  State<BibleBooksScreen> createState() => _BibleBooksScreenState();
}

class _BibleBooksScreenState extends State<BibleBooksScreen> {
  final _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BibleBooksProvider>().loadAllBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bibleOverview),
      ),
      body: Column(
        children: [
          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '성경책 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchKeyword = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
            ),
          ),

          // 성경책 리스트
          Expanded(
            child: Consumer<BibleBooksProvider>(
              builder: (context, provider, child) {
                final l10n = AppLocalizations.of(context)!;
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = _searchKeyword.isEmpty
                    ? provider.books
                    : provider.searchBooks(_searchKeyword);

                if (books.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noBooks,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final oldTestament =
                    books.where((b) => b.testament == 'OLD').toList();
                final newTestament =
                    books.where((b) => b.testament == 'NEW').toList();

                return ListView(
                  children: [
                    if (oldTestament.isNotEmpty) ...[
                      //_buildSectionHeader(l10n.oldTestament(oldTestament.length)),
                      _buildSectionHeader(l10n.oldTestament(39)),
                      ...oldTestament
                          .map((book) => _buildBookTile(book, context)),
                      const SizedBox(height: 20),
                    ],
                    if (newTestament.isNotEmpty) ...[
                      //_buildSectionHeader(l10n.newTestament(newTestament.length)),
                      _buildSectionHeader(l10n.newTestament(27)),
                      ...newTestament
                          .map((book) => _buildBookTile(book, context)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBookTile(book, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: book.testament == 'OLD' ? Colors.blue : Colors.red,
          child: Text(
            '${book.bookNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          book.koreanName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${l10n.chapters(book.chaptersCount)}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailScreen(book: book),
            ),
          );
        },
      ),
    );
  }
}
