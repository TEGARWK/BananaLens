import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/scan_outcome.dart';
import '../../providers/scan_notifier.dart';
import '../widgets/fruitlens_app_bar.dart';
import '../widgets/result_state_views.dart';
import '../widgets/result_success_view.dart';

/// Screen presenting the scan inspection outcome and detailed fruit metadata.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isSaved = false;

  void _navigateBack() {
    ref.read(scanProvider.notifier).reset();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/scan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: FruitLensAppBar(
        title: 'Hasil Pindai',
        subtitle: state.isLoading
            ? 'Sedang memeriksa foto…'
            : 'Pemeriksaan selesai',
        showBackButton: true,
        onBackPressed: _navigateBack,
      ),
      body: state.when(
        loading: () => ResultLoadingView(
          imagePath: ref.read(scanProvider.notifier).pendingImagePath,
        ),
        error: (_, _) => ResultErrorView(
          message:
              'Terjadi kendala saat memeriksa foto. Coba ambil foto ulang ya.',
          onRetry: _navigateBack,
        ),
        data: (report) {
          if (report == null) {
            return const Center(child: Text('Belum ada hasil pindai.'));
          }
          final outcome = report.outcome;
          return switch (outcome) {
            ScanSuccess() => ResultSuccessView(
              report: report,
              outcome: outcome,
              isSaved: _isSaved,
              onSave: () async {
                setState(() => _isSaved = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tersimpan di riwayat!')),
                );
              },
            ),
            ScanUncertain() => ResultUncertainView(
              report: report,
              onRetake: _navigateBack,
            ),
            ScanFailure(:final message) => ResultErrorView(
              message: message,
              onRetry: _navigateBack,
            ),
          };
        },
      ),
    );
  }
}
