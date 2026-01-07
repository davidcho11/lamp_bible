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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = context.read<ReadingHistoryProvider>();
      historyProvider.loadHistoryForYear(DateTime.now().year);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    if (progress >= 100) return Colors.red.shade400;
    if (progress >= 80) return Colors.purple.shade400;
    if (progress >= 60) return Colors.amber.shade400;
    if (progress >= 40) return Colors.orange.shade400;
    if (progress >= 20) return Colors.green.shade400;
    return Colors.blue.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 반응형 크기 계산
    final isSmallScreen = screenWidth < 360;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final circleSize = screenWidth * 0.45 < 160 ? 160.0 : screenWidth * 0.45;
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
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '함께 성경 읽기',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Consumer<ReadingHistoryProvider>(
                builder: (context, historyProvider, child) {
                  final year = historyProvider.currentYear;
                  final totalDays = DateHelper.getTotalDaysInYear(year);
                  final completedDays = historyProvider.getCompletedCount(year);
                  final uncompletedDays =
                      historyProvider.getUncompletedCount(year);
                  final streakDays = historyProvider.getStreakDays(year);
                  final progress = historyProvider.getProgressPercentage(year);

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // 년도 표시
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getProgressColor(progress).withOpacity(0.2),
                                _getProgressColor(progress).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: FittedBox(
                            child: Text(
                              '📅 ${year}년 성경 통독',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 20,
                                fontWeight: FontWeight.bold,
                                color: _getProgressColor(progress),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // 진행 현황 카드
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [Colors.grey.shade900, Colors.grey.shade800]
                                  : [Colors.white, Colors.grey.shade50],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: _getProgressColor(progress)
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            child: Column(
                              children: [
                                Text(
                                  '📊 진행 현황',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),

                                // 원형 프로그레스
                                SizedBox(
                                  width: circleSize,
                                  height: circleSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: circleSize,
                                        height: circleSize,
                                        child: CircularProgressIndicator(
                                          value: progress / 100,
                                          strokeWidth: isSmallScreen ? 10 : 12,
                                          backgroundColor: Colors.grey.shade300,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            _getProgressColor(progress),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FittedBox(
                                            child: Text(
                                              '${progress.toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontSize: circleSize * 0.18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    _getProgressColor(progress),
                                              ),
                                            ),
                                          ),
                                          FittedBox(
                                            child: Text(
                                              '$completedDays / $totalDays일',
                                              style: TextStyle(
                                                fontSize: circleSize * 0.08,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),

                                // 통계 - 반응형
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Wrap(
                                      alignment: WrapAlignment.spaceAround,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildStatCard(
                                          '✅',
                                          '완료',
                                          '$completedDays일',
                                          Colors.green,
                                          isDark,
                                          isSmallScreen,
                                        ),
                                        _buildStatCard(
                                          '⏳',
                                          '남은 날',
                                          '$uncompletedDays일',
                                          Colors.orange,
                                          isDark,
                                          isSmallScreen,
                                        ),
                                        _buildStatCard(
                                          '🔥',
                                          '연속',
                                          '$streakDays일',
                                          Colors.red,
                                          isDark,
                                          isSmallScreen,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // 격려 메시지
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getProgressColor(progress).withOpacity(0.15),
                                _getProgressColor(progress).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getEncouragementIcon(progress),
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 48 : 56),
                              ),
                              const SizedBox(height: 12),
                              FittedBox(
                                child: Text(
                                  _getEncouragementMessage(progress),
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: _getProgressColor(progress),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '계속 이어가세요!',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 15,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // 버튼들
                        _buildActionButton(
                          context,
                          icon: Icons.calendar_today_rounded,
                          label: '오늘의 성경 읽기',
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CalendarScreen(),
                              ),
                            );
                          },
                          isSmallScreen: isSmallScreen,
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context,
                          icon: Icons.menu_book_rounded,
                          label: '성경 66권 개요',
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BibleBooksScreen(),
                              ),
                            );
                          },
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String icon,
    String label,
    String value,
    Color color,
    bool isDark,
    bool isSmallScreen,
  ) {
    return Container(
      constraints: BoxConstraints(
        minWidth: isSmallScreen ? 90 : 100,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: isSmallScreen ? 20 : 24)),
          SizedBox(height: isSmallScreen ? 4 : 6),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 14 : 18,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isSmallScreen ? 24 : 28, color: Colors.white),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Flexible(
                  child: Text(
                    label,
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
    );
  }
}
