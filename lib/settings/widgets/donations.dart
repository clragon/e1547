import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/identity/data/service.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DonationSummaryExtension on Donor {
  double totalForCurrency(String currency) {
    return donations
        .where((donation) => donation.currency == currency)
        .fold(0, (sum, donation) => sum + donation.amount);
  }

  String formattedAmounts() {
    Map<String, double> totals = {};
    for (final currency in donations.map((e) => e.currency).toSet()) {
      totals[currency] = totalForCurrency(currency);
    }

    return totals.entries
        .map((e) => NumberFormat.simpleCurrency(name: e.key).format(e.value))
        .join(', ');
  }
}

extension DonorSortingExtension on List<Donor> {
  List<Donor> sortByDonation({
    String preferredCurrency = 'USD',
  }) {
    List<Donor> sortedDonors = List.from(this);
    sortedDonors.sort((Donor a, Donor b) {
      double totalA = a.totalForCurrency(preferredCurrency);
      double totalB = b.totalForCurrency(preferredCurrency);

      if (totalA > 0 && totalB > 0) {
        return totalB.compareTo(totalA);
      } else if (totalA > 0) {
        return -1;
      } else if (totalB > 0) {
        return 1;
      } else {
        List<String> currenciesA =
            a.donations.map((donation) => donation.currency).toList()..sort();
        List<String> currenciesB =
            b.donations.map((donation) => donation.currency).toList()..sort();
        return currenciesA.first.compareTo(currenciesB.first);
      }
    });

    return sortedDonors;
  }
}

class Donors extends StatelessWidget {
  const Donors({
    super.key,
    required this.donors,
  });

  final List<Donor> donors;

  @override
  Widget build(BuildContext context) {
    String? username = context.watch<IdentitiesService>().identity.username;
    return Column(
      children: [
        ...donors.sortByDonation().map(
              (summary) => ListTile(
                selected:
                    username != null && summary.handles['e621'] == username,
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: summary.avatar != null
                      ? CachedNetworkImageProvider(summary.avatar!)
                      : null,
                  child:
                      summary.avatar == null ? const Icon(Icons.person) : null,
                ),
                title: Text(summary.name),
                subtitle: Text(summary.formattedAmounts()),
              ),
            ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            'Not on the list? contact us!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
