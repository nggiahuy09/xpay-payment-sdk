import 'package:flutter/material.dart';
import 'package:xpay_payment_sdk/xpay_payment_sdk.dart';

final class XPayDemoSectionTitle extends StatelessWidget {
  const XPayDemoSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

final class XPayDemoResultCard extends StatelessWidget {
  const XPayDemoResultCard({super.key, required this.result});

  final XPayPaymentResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rows = <(String, String)>[
      ('Status', result.status.name),
      if (result.message case final String value) ('Message', value),
      if (result.authId case final String value) ('Auth ID', value),
      if (result.captureId case final String value) ('Capture ID', value),
      if (result.bookingRef case final String value) ('Booking ref', value),
      if (result.externalRef case final String value) ('External ref', value),
      if (result.amount case final int value) ('Amount', '$value ${result.currency ?? ''}'.trim()),
      if (result.declineCode case final String value) ('Decline code', value),
      if (result.errorCode case final String value) ('Error code', value),
      if (result.createdAt case final DateTime value) ('Created at', value.toIso8601String()),
    ];

    return Card(
      color: result.isSuccessful ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            for (final (label, value) in rows)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112.0,
                    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: SelectableText(value)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

final class XPayDemoLogTile extends StatelessWidget {
  const XPayDemoLogTile({super.key, required this.event});

  final XPayLogEvent event;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    dense: true,
    leading: Icon(switch (event.level) {
      XPayLogLevel.info => Icons.info_outline,
      XPayLogLevel.warn => Icons.warning_amber_outlined,
      XPayLogLevel.error => Icons.error_outline,
    }),
    title: Text('${event.feature} · ${event.action}'),
    subtitle: Text([event.reason, event.errorCode, if (event.input.isNotEmpty) event.input.toString()].nonNulls.join('\n')),
  );
}
