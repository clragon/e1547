import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PopularPage extends StatefulWidget {
  const PopularPage({super.key});

  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeScale = 'week';
  DateTime? _selectedDate;

  final Map<String, String> _timeScales = {
    'day': 'Day',
    'week': 'Week',
    'month': 'Month',
    'year': 'Year',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _timeScales.length,
      vsync: this,
      initialIndex: 1, // Default to 'week'
    );
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    String newTimeScale = _timeScales.keys.elementAt(_tabController.index);
    if (newTimeScale != _selectedTimeScale) {
      setState(() {
        _selectedTimeScale = newTimeScale;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2007), // e621 was founded in 2007
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDateForDisplay() {
    if (_selectedDate == null) return '';
    
    switch (_selectedTimeScale) {
      case 'day':
        return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      case 'week':
        DateTime weekStart = _selectedDate!.subtract(Duration(days: _selectedDate!.weekday - 1));
        DateTime weekEnd = weekStart.add(const Duration(days: 6));
        return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}';
      case 'month':
        const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${monthNames[_selectedDate!.month - 1]} ${_selectedDate!.year}';
      case 'year':
        return '${_selectedDate!.year}';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<PopularPage>(
      child: _PopularPostProvider(
        key: ValueKey('${_selectedTimeScale}_${_selectedDate?.millisecondsSinceEpoch}'),
        timeScale: _selectedTimeScale,
        date: _selectedDate,
        child: Consumer<PostController>(
          builder: (context, controller, child) {
            return PostsControllerHistoryConnector(
              controller: controller,
              child: DefaultTabController(
                length: _timeScales.length,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Popular'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                        tooltip: 'Select Date',
                      ),
                      const ContextDrawerButton(),
                    ],
                    bottom: TabBar(
                      controller: _tabController,
                      onTap: (_) => _onTabChanged(),
                      isScrollable: true,
                      tabs: _timeScales.values.map((name) => Tab(text: name)).toList(),
                    ),
                  ),
                  drawer: const RouterDrawer(),
                  endDrawer: ContextDrawer(
                    title: const Text('Popular'),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: const Text('Time Period'),
                        subtitle: Text(_formatDateForDisplay()),
                        onTap: _selectDate,
                      ),
                      const Divider(),
                      DrawerTagCounter(controller: controller),
                    ],
                  ),
                  body: LimitedWidthLayout(
                    child: TileLayout(
                      child: RefreshableDataPage.builder(
                        controller: controller,
                        builder: (context, child) => child,
                        child: (context) => CustomScrollView(
                          primary: true,
                          slivers: [
                            SliverPadding(
                              padding: defaultActionListPadding,
                              sliver: PostSliverDisplay(
                                controller: controller,
                                displayType: PostDisplayType.grid,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PopularPostProvider extends StatelessWidget {
  const _PopularPostProvider({
    super.key,
    required this.timeScale,
    required this.date,
    required this.child,
  });

  final String timeScale;
  final DateTime? date;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PostProvider.builder(
      create: (context, domain) => PopularPostController(
        domain: domain,
        timeScale: timeScale,
        date: date,
      ),
      child: child,
    );
  }
}
