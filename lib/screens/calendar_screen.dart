import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/bible_reading_provider.dart';
import '../providers/reading_history_provider.dart';
import '../services/date_helper.dart';
import 'reading_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BibleReadingProvider>().loadAllReadings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('성경 읽기 캘린더'),
      ),
      body: Column(
        children: [
          Consumer2<ReadingHistoryProvider, BibleReadingProvider>(
            builder: (context, historyProvider, readingProvider, child) {
              return TableCalendar(
                firstDay: DateTime(_focusedDay.year, 1, 1),
                lastDay: DateTime(_focusedDay.year, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // 날짜 상세 화면으로 이동
                    final reading = await readingProvider.getReadingByDate(
                      selectedDay.month,
                      selectedDay.day,
                    );

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReadingDetailScreen(
                            year: selectedDay.year,
                            month: selectedDay.month,
                            day: selectedDay.day,
                            reading: reading,
                          ),
                        ),
                      );
                    }
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final isCompleted = historyProvider.isCompleted(
                      date.year,
                      date.month,
                      date.day,
                    );

                    final isToday = DateHelper.isToday(
                      date.year,
                      date.month,
                      date.day,
                    );

                    // 2월 29일 윤년 체크
                    if (date.month == 2 && date.day == 29) {
                      if (DateHelper.isLeapYear(date.year)) {
                        return const Positioned(
                          right: 1,
                          bottom: 1,
                          child: Text('🎵', style: TextStyle(fontSize: 16)),
                        );
                      }
                    }

                    if (isCompleted) {
                      return const Positioned(
                        right: 1,
                        bottom: 1,
                        child: Text('✅', style: TextStyle(fontSize: 16)),
                      );
                    }

                    if (isToday) {
                      return const Positioned(
                        right: 1,
                        bottom: 1,
                        child: Text('⭕', style: TextStyle(fontSize: 16)),
                      );
                    }

                    return null;
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // 범례
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend('✅', '완료'),
                _buildLegend('⭕', '오늘'),
                _buildLegend('⬜', '미완료'),
                if (DateHelper.isLeapYear(_focusedDay.year))
                  _buildLegend('🎵', '찬양'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegend(String icon, String label) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
