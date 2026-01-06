import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_history_provider.dart';
import '../services/date_helper.dart';
import 'calendar_screen.dart';
import 'bible_books_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = context.read<ReadingHistoryProvider>();
      historyProvider.loadHistoryForYear(DateTime.now().year);
    });
  }

  String _getEncouragementIcon(double progress) {
    if (progress >= 100) return '🏆';
    if (progress >= 80) return '🎉';
    if (progress >= 60) return '⭐';
    if (progress >= 40) return '🔥';
    if (progress >= 20) return '💪';
    return '😊';
  }

  String _getEncouragementMessage(double progress) {
    if (progress >= 100) return '완독 축하합니다!';
    if (progress >= 80) return '거의 다 왔어요!';
    if (progress >= 60) return '정말 잘하고 있어요!';
    if (progress >= 40) return '절반을 넘었어요!';
    if (progress >= 20) return '힘내세요!';
    return '시작이 반입니다!';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return Colors.red;
    if (progress >= 80) return Colors.purple;
    if (progress >= 60) return Colors.amber;
    if (progress >= 40) return Colors.orange;
    if (progress >= 20) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('함께 성경 읽기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReadingHistoryProvider>(
        builder: (context, historyProvider, child) {
          final year = historyProvider.currentYear;
          final totalDays = DateHelper.getTotalDaysInYear(year);
          final completedDays = historyProvider.getCompletedCount(year);
          final uncompletedDays = historyProvider.getUncompletedCount(year);
          final streakDays = historyProvider.getStreakDays(year);
          final progress = historyProvider.getProgressPercentage(year);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 년도 표시
                Text(
                  '🗓️ ${year}년 성경 통독',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // 진행 현황 카드
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          '📊 진행 현황',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 프로그레스 바
                        LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 20,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(progress),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$completedDays / $totalDays일',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 통계
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('✅ 완료', '$completedDays일'),
                            _buildStatItem('⏳ 남은 날', '$uncompletedDays일'),
                            _buildStatItem('🔥 연속', '$streakDays일'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 격려 메시지
                Card(
                  elevation: 4,
                  color: _getProgressColor(progress).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Text(
                          _getEncouragementIcon(progress),
                          style: const TextStyle(fontSize: 60),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _getEncouragementMessage(progress),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(progress),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '계속 이어가세요!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 버튼들
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today, size: 28),
                    label: const Text(
                      '오늘의 성경 읽기',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BibleBooksScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.book, size: 28),
                    label: const Text(
                      '성경 66권 개요',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
