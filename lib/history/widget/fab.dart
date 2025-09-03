import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class HistorySearchFab extends StatelessWidget {
  const HistorySearchFab({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final params = context.watch<HistoryParams>();

    return QueryBuilder(
      query: domain.histories.useDays(),
      builder: (context, state) => FloatingActionButton(
        onPressed: state.isLoading
            ? null
            : () async {
                Locale locale = Localizations.localeOf(context);

                final days = state.data ?? [];
                List<DateTime> availableDays = days.isEmpty
                    ? [DateTime.now()]
                    : days;

                if (!context.mounted) return;

                DateTime? result = await showDatePicker(
                  context: context,
                  initialDate: params.date ?? DateTime.now(),
                  firstDate: availableDays.first,
                  lastDate: availableDays.last,
                  locale: locale,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  selectableDayPredicate: (value) =>
                      availableDays.any((e) => DateUtils.isSameDay(value, e)),
                );

                if (!context.mounted) return;
                ScrollController scrollController = PrimaryScrollController.of(
                  context,
                );

                if (result != params.date) {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      0,
                      duration: defaultAnimationDuration,
                      curve: Curves.easeInOut,
                    );
                  }

                  params.date = result;
                }
              },
        child: const Icon(Icons.search),
      ),
    );
  }
}
