import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/scan_outcome.dart';
import '../../providers/scan_notifier.dart';
import '../widgets/result_state_views.dart';
import '../widgets/result_success_view.dart';

/// Screen presenting the scan inspection outcome and detailed fruit metadata.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isFavorite = false;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(AppDimens.s8),
          child: IconButton(
            onPressed: () {
              ref.read(scanProvider.notifier).reset();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: harvest.primarySoft,
              foregroundColor: theme.colorScheme.primary,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Hasil Pindai',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              state.isLoading
                  ? 'Sedang memeriksa foto…'
                  : 'Pemeriksaan selesai',
              style: theme.textTheme.labelSmall?.copyWith(
                color: harvest.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          if (state.asData?.value?.outcome is ScanSuccess) ...[
            IconButton(
              tooltip: 'Simpan Favorit',
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isFavorite
                          ? 'Ditambahkan ke favorit!'
                          : 'Dihapus dari favorit.',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavorite
                    ? (theme.brightness == Brightness.dark
                          ? const Color(0xFFFF6B70)
                          : const Color(0xFFE5484D))
                    : harvest.muted,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimens.s8),
          ],
        ],
      ),
      body: state.when(
        loading: () => const ResultLoadingView(),
        error: (_, _) => ResultErrorView(
          message:
              'Terjadi kendala saat memeriksa foto. Coba ambil foto ulang ya.',
          onRetry: () => context.pop(),
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
            ScanUncertain() => ResultUncertainView(report: report),
            ScanFailure(:final message) => ResultErrorView(
              message: message,
              onRetry: () => context.pop(),
            ),
          };
        },
      ),
    );
  }
}
