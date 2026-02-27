import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../model/task_model.dart';
import '../provider/task_provider.dart';
import '../utils/app_theme.dart';
import '../screens/add_task_screen.dart';

// ── Status constants ──────────────────────────────────────────────────────────
enum TaskFilter { all, pending, inProgress, completed }

extension TaskFilterExt on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:        return 'All';
      case TaskFilter.pending:    return 'Pending';
      case TaskFilter.inProgress: return 'In Progress';
      case TaskFilter.completed:  return 'Completed';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskFilter.all:        return Icons.grid_view_rounded;
      case TaskFilter.pending:    return Icons.radio_button_unchecked_rounded;
      case TaskFilter.inProgress: return Icons.timelapse_rounded;
      case TaskFilter.completed:  return Icons.check_circle_outline_rounded;
    }
  }

  /// Maps to the string stored in Task.status
  String? get statusKey {
    switch (this) {
      case TaskFilter.all:        return null;           // no filter
      case TaskFilter.pending:    return 'pending';
      case TaskFilter.inProgress: return 'in_progress';
      case TaskFilter.completed:  return 'completed';
    }
  }

  Color get activeColor {
    switch (this) {
      case TaskFilter.all:        return Colors.white;
      case TaskFilter.pending:    return const Color(0xFFFFD166);
      case TaskFilter.inProgress: return const Color(0xFF74B9FF);
      case TaskFilter.completed:  return const Color(0xFF55EFC4);
    }
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskFilter _activeFilter = TaskFilter.all;
  DateTime   _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<DateTime> get _weekDays {
    final now     = DateTime.now();
    final sunday  = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  List<Task> _getFilteredTasks(List<Task> all) {
    final dateStr = _selectedDate.toIso8601String().split('T')[0];

    return all.where((t) {
      final matchesDate   = t.dueDate == dateStr;
      final matchesStatus = _activeFilter.statusKey == null ||
          t.status == _activeFilter.statusKey;
      return matchesDate && matchesStatus;
    }).toList();
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  void _openAddTask() =>
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddTaskScreen()));

  void _openEditTask(Task task) {
    HapticFeedback.mediumImpact();
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)));
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        title: const Text('Delete Task',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to delete this task?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(AppTheme.radiusMedium)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final taskProvider   = Provider.of<TaskProvider>(context);
    final filteredTasks  = _getFilteredTasks(taskProvider.tasks);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: AppTheme.surface,
        onRefresh: () async => await taskProvider.refreshTasks(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildWeekCalendar()),
            SliverToBoxAdapter(
                child: _buildSectionLabel(filteredTasks.length)),
            if (taskProvider.isLoading && taskProvider.tasks.isEmpty)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: Colors.white)),
              )
            else if (filteredTasks.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildTaskCard(filteredTasks[i], i),
                    childCount: filteredTasks.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 6,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(taskProvider.tasks),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Icon(Icons.menu_rounded,
                  color: AppTheme.textPrimary, size: 26),
            ],
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Manage\nyour tasks 🖊️',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.1,
                letterSpacing: -1.2,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceVariant,
              border:
              Border.all(color: const Color(0xFF3A3A3A), width: 1.5),
            ),
            child: const Icon(Icons.person_rounded,
                size: 20, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final days     = _weekDays;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final selStr   = _selectedDate.toIso8601String().split('T')[0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final day    = days[i];
          final dayStr = day.toIso8601String().split('T')[0];
          final isSel  = dayStr == selStr;
          final isTod  = dayStr == todayStr;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNames[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSel
                          ? Colors.black
                          : const Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSel
                          ? Colors.black
                          : isTod
                          ? Colors.white
                          : const Color(0xFF888888),
                    ),
                  ),
                  if (isTod && !isSel) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 4, height: 4,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                  ] else
                    const SizedBox(height: 8),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionLabel(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _activeFilter == TaskFilter.all
                ? 'Tasks for this day'
                : '${_activeFilter.label} tasks',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count tasks',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    final isBlueCard  = index % 2 == 0;
    final isCompleted = task.status == 'completed';

    // ── colour palettes ──
    const blueBg        = AppTheme.cardBlue;
    const blueBadgeBg   = Color(0xFFCDD8E8);
    const blueBadgeText = Color(0xFF4A5568);
    const blueTitle     = Color(0xFF1A1A2E);
    const blueDesc      = Color(0xFF4A5568);
    const blueDate      = Color(0xFF6B7280);
    const blueDivider   = Color(0xFFA8BBCF);
    const blueIcon      = Color(0xFF4A5568);

    const darkBg        = AppTheme.cardDark;
    const darkBadgeBg   = Color(0xFF2A2A2A);
    const darkBadgeText = Color(0xFF9E9E9E);
    const darkTitle     = AppTheme.textPrimary;
    const darkDesc      = AppTheme.textSecondary;
    const darkDate      = Color(0xFF6B7280);
    const darkDivider   = Color(0xFF2A2A2A);
    const darkIcon      = Color(0xFF9E9E9E);

    final bg        = isBlueCard ? blueBg        : darkBg;
    final badgeBg   = isBlueCard ? blueBadgeBg   : darkBadgeBg;
    final badgeText = isBlueCard ? blueBadgeText : darkBadgeText;
    final titleClr  = isBlueCard ? blueTitle     : darkTitle;
    final descClr   = isBlueCard ? blueDesc      : darkDesc;
    final dateClr   = isBlueCard ? blueDate      : darkDate;
    final divClr    = isBlueCard ? blueDivider   : darkDivider;
    final iconClr   = isBlueCard ? blueIcon      : darkIcon;

    // ── derive badge label from actual status ──
    String statusLabel;
    Color  statusBadgeBg;
    Color  statusBadgeTxt;
    switch (task.status) {
      case 'completed':
        statusLabel    = 'Completed';
        statusBadgeBg  = isBlueCard
            ? const Color(0xFFB7EACB)
            : const Color(0xFF1A3D2B);
        statusBadgeTxt = isBlueCard
            ? const Color(0xFF1A7A40)
            : const Color(0xFF55EFC4);
        break;
      case 'in_progress':
        statusLabel    = 'In Progress';
        statusBadgeBg  = isBlueCard
            ? const Color(0xFFBDD9F2)
            : const Color(0xFF1A2D3D);
        statusBadgeTxt = isBlueCard
            ? const Color(0xFF2A6496)
            : const Color(0xFF74B9FF);
        break;
      default: // pending
        statusLabel    = 'Pending';
        statusBadgeBg  = badgeBg;
        statusBadgeTxt = badgeText;
    }

    return GestureDetector(
      onLongPress: () => _openEditTask(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── top row: badge + actions ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBadgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusBadgeTxt,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.ios_share_rounded,
                      size: 18, color: iconClr),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => _confirmDelete(task.id),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: isBlueCard
                        ? const Color(0xFF8B3A3A)
                        : AppTheme.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── title ──
            Text(
              task.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: titleClr,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 6),

            // ── description ──
            Text(
              task.description,
              style:
              TextStyle(fontSize: 13, color: descClr, height: 1.45),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 14),
            Divider(color: divClr, height: 1),
            const SizedBox(height: 10),

            // ── footer: date ──
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12, color: dateClr),
                const SizedBox(width: 5),
                Text(
                  task.dueDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: dateClr,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: AppTheme.surfaceVariant, shape: BoxShape.circle),
            child: const Icon(Icons.task_alt_rounded,
                size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _activeFilter == TaskFilter.all
                ? 'No tasks for this day'
                : 'No ${_activeFilter.label.toLowerCase()} tasks',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add a task',
            style:
            TextStyle(fontSize: 13, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav with status filters ────────────────────────────────────────

  /// Returns the count of tasks for a given filter on the selected date.
  int _countFor(List<Task> all, TaskFilter f) {
    final dateStr = _selectedDate.toIso8601String().split('T')[0];
    return all.where((t) {
      final matchDate   = t.dueDate == dateStr;
      final matchStatus =
          f.statusKey == null || t.status == f.statusKey;
      return matchDate && matchStatus;
    }).length;
  }

  Widget _buildBottomNav(List<Task> allTasks) {
    final filters = TaskFilter.values; // all, pending, inProgress, completed

    return BottomAppBar(
      color: const Color(0xFF1A1A1A),
      elevation: 0,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left two items
            _buildFilterNavItem(filters[0], allTasks),
            _buildFilterNavItem(filters[1], allTasks),

            // Centre gap for FAB
            const SizedBox(width: 48),

            // Right two items
            _buildFilterNavItem(filters[2], allTasks),
            _buildFilterNavItem(filters[3], allTasks),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterNavItem(TaskFilter filter, List<Task> allTasks) {
    final isActive = _activeFilter == filter;
    final count    = _countFor(allTasks, filter);
    final color    = isActive ? filter.activeColor : const Color(0xFF555555);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeFilter = filter);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
          color: filter.activeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(filter.icon, color: color, size: 22),
                // Badge showing count (hidden when zero)
                if (count > 0)
                  Positioned(
                    top: -5,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: filter.activeColor,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}