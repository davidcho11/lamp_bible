import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/bible_reading.dart';
import '../models/user_note.dart';
import '../providers/reading_history_provider.dart';
import '../services/database_helper.dart';

class ReadingDetailScreen extends StatefulWidget {
  final int year;
  final int month;
  final int day;
  final BibleReading? reading;

  const ReadingDetailScreen({
    super.key,
    required this.year,
    required this.month,
    required this.day,
    this.reading,
  });

  @override
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen> {
  final _verseController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isCompleted = false;
  UserNote? _existingNote;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _verseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final historyProvider = context.read<ReadingHistoryProvider>();
    _isCompleted = historyProvider.isCompleted(
      widget.year,
      widget.month,
      widget.day,
    );

    final db = await DatabaseHelper.instance.database;
    final notes = await db.query(
      'user_notes',
      where: 'year = ? AND month = ? AND day = ?',
      whereArgs: [widget.year, widget.month, widget.day],
    );

    if (notes.isNotEmpty) {
      _existingNote = UserNote.fromMap(notes.first);
      _verseController.text = _existingNote?.verseReference ?? '';
      _noteController.text = _existingNote?.noteContent ?? '';
    }

    setState(() {});
  }

  Future<void> _launchYouTube() async {
    if (widget.reading == null) return;

    final url = Uri.parse(widget.reading!.youtubeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('YouTube를 열 수 없습니다')),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('묵상 내용을 입력해주세요')),
      );
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;

      if (_existingNote != null) {
        await db.update(
          'user_notes',
          {
            'verse_reference': _verseController.text.trim(),
            'note_content': _noteController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [_existingNote!.id],
        );
      } else {
        await db.insert('user_notes', {
          'year': widget.year,
          'month': widget.month,
          'day': widget.day,
          'verse_reference': _verseController.text.trim(),
          'note_content': _noteController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('저장되었습니다'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  Future<void> _toggleCompleted() async {
    final historyProvider = context.read<ReadingHistoryProvider>();
    await historyProvider.markAsCompleted(
      widget.year,
      widget.month,
      widget.day,
      !_isCompleted,
    );
    setState(() {
      _isCompleted = !_isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.12,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: FittedBox(
                child: Text(
                  '${widget.year}년 ${widget.month}월 ${widget.day}일',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.reading != null) ...[
                    // 제목 카드
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.reading!.isSpecial
                              ? [Colors.purple.shade400, Colors.purple.shade600]
                              : [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: widget.reading!.isSpecial
                                ? Colors.purple.withOpacity(0.4)
                                : Colors.blue.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.reading!.isSpecial ? '🎵' : '📖',
                            style: TextStyle(fontSize: isSmallScreen ? 32 : 40),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Text(
                            widget.reading!.title,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.reading!.chapterInfo != null) ...[
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            Text(
                              widget.reading!.chapterInfo!,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // YouTube 재생 버튼
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _launchYouTube,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 14 : 18,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_filled,
                                  size: isSmallScreen ? 28 : 32,
                                  color: Colors.white,
                                ),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                Flexible(
                                  child: Text(
                                    widget.reading!.isSpecial
                                        ? '찬양 영상 보기'
                                        : 'YouTube 영상 재생',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.08),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.videocam_off_outlined,
                            size: isSmallScreen ? 48 : 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            '이 날짜에 대한 영상이 없습니다',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],

                  // 묵상 노트 섹션
                  Text(
                    '✍️ 나의 묵상 노트',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _verseController,
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          decoration: InputDecoration(
                            labelText: '성경 구절',
                            labelStyle:
                                TextStyle(fontSize: isSmallScreen ? 13 : 15),
                            hintText: '예: 창세기 1:1-3',
                            hintStyle:
                                TextStyle(fontSize: isSmallScreen ? 12 : 14),
                            prefixIcon: Icon(
                              Icons.bookmark_outline,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        TextField(
                          controller: _noteController,
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          decoration: InputDecoration(
                            labelText: '묵상 내용',
                            labelStyle:
                                TextStyle(fontSize: isSmallScreen ? 13 : 15),
                            hintText: '오늘 읽은 말씀에 대한 묵상을 기록해보세요',
                            hintStyle:
                                TextStyle(fontSize: isSmallScreen ? 12 : 14),
                            prefixIcon: Icon(
                              Icons.edit_outlined,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                          maxLines: isSmallScreen ? 6 : 8,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // 버튼들
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildButton(
                              onTap: _toggleCompleted,
                              icon: _isCompleted
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              label: _isCompleted ? '완료됨' : '완료 표시',
                              gradient: LinearGradient(
                                colors: _isCompleted
                                    ? [
                                        Colors.green.shade400,
                                        Colors.green.shade600
                                      ]
                                    : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade600
                                      ],
                              ),
                              isSmallScreen: isSmallScreen,
                            ),
                            const SizedBox(height: 12),
                            _buildButton(
                              onTap: _saveNote,
                              icon: Icons.save_outlined,
                              label: '저장',
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600
                                ],
                              ),
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildButton(
                                onTap: _toggleCompleted,
                                icon: _isCompleted
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                label: _isCompleted ? '완료됨' : '완료 표시',
                                gradient: LinearGradient(
                                  colors: _isCompleted
                                      ? [
                                          Colors.green.shade400,
                                          Colors.green.shade600
                                        ]
                                      : [
                                          Colors.grey.shade400,
                                          Colors.grey.shade600
                                        ],
                                ),
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildButton(
                                onTap: _saveNote,
                                icon: Icons.save_outlined,
                                label: '저장',
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600
                                  ],
                                ),
                                isSmallScreen: isSmallScreen,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Gradient gradient,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 12 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
