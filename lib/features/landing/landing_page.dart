import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/brand_mark.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _LandingHeader(),
            _HeroSection(),
            _HowItWorksSection(),
            _TrustSection(),
            _LandingFooter(),
          ],
        ),
      ),
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader();

  @override
  Widget build(BuildContext context) {
    return _PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showLinks = constraints.maxWidth >= 760;
            return Row(
              children: [
                BrandMark(showWordmark: constraints.maxWidth >= 500),
                const Spacer(),
                if (showLinks) ...[
                  TextButton(
                    onPressed: () {},
                    child: const Text('So funktioniert’s'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(onPressed: () {}, child: const Text('Sicherheit')),
                  const SizedBox(width: AppSpacing.md),
                ],
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.overview),
                  child: const Text('Demo öffnen'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.green50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _PageWidth(
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl,
            bottom: AppSpacing.section,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              if (wide) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 11, child: _HeroCopy(wide: true)),
                    SizedBox(width: AppSpacing.xxl),
                    Expanded(flex: 9, child: _DocumentPreview()),
                  ],
                );
              }
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCopy(wide: false),
                  SizedBox(height: AppSpacing.xxl),
                  _DocumentPreview(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.green100,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: const Text(
            'Dokumente verstehen. Fristen im Blick.',
            style: TextStyle(
              color: AppColors.green700,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Weniger Papierkram.\nMehr Klarheit.',
          style: wide
              ? Theme.of(context).textTheme.displayLarge
              : Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Lade ein Schreiben hoch und erhalte eine verständliche Analyse, '
          'wichtige Fristen und eine strukturierte Vorbereitung für deine Antwort.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.overview),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Demo ansehen'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Ablauf entdecken'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AppColors.green700,
            ),
            SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                'Privat gedacht · transparent aufgebaut',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.navy950,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy950.withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PreviewIcon(icon: Icons.description_outlined),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Musterbescheid.pdf',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Analyse abgeschlossen',
                        style: TextStyle(
                          color: AppColors.green700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: AppColors.green600),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            _PreviewResult(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Kurz erklärt',
              value: 'Das Schreiben bittet um zusätzliche Unterlagen.',
            ),
            SizedBox(height: AppSpacing.md),
            _PreviewResult(
              icon: Icons.event_outlined,
              label: 'Wichtige Frist',
              value: 'Antwort bis 14. August',
              highlighted: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  const _PreviewIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.navy50,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Icon(icon, color: AppColors.navy900),
    );
  }
}

class _PreviewResult extends StatelessWidget {
  const _PreviewResult({
    required this.icon,
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.green50 : AppColors.navy50,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: highlighted ? AppColors.green700 : AppColors.navy800,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  static const steps = [
    (
      Icons.upload_file_outlined,
      'Upload',
      'Füge ein Schreiben als Ausgangspunkt für deine Übersicht hinzu.',
    ),
    (
      Icons.manage_search_outlined,
      'Analyse',
      'Die wichtigsten Aussagen werden klar und verständlich geordnet.',
    ),
    (
      Icons.event_available_outlined,
      'Fristen',
      'Relevante Termine werden sichtbar und bleiben im Blick.',
    ),
    (
      Icons.edit_note_outlined,
      'Antwortvorbereitung',
      'Nächste Schritte helfen dir, eine eigene Antwort vorzubereiten.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
        child: Column(
          children: [
            Text(
              'Vom Schreiben zum nächsten Schritt',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ein klarer Ablauf für unübersichtliche Dokumente.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 980
                    ? 4
                    : constraints.maxWidth >= 620
                    ? 2
                    : 1;
                const gap = AppSpacing.md;
                final width =
                    (constraints.maxWidth - (gap * (columns - 1))) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (var index = 0; index < steps.length; index++)
                      SizedBox(
                        width: width,
                        child: _StepCard(
                          number: index + 1,
                          icon: steps[index].$1,
                          title: steps[index].$2,
                          copy: steps[index].$3,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.copy,
  });

  final int number;
  final IconData icon;
  final String title;
  final String copy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(icon, color: AppColors.green700),
                ),
                const Spacer(),
                Text(
                  number.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppColors.navy100,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(copy, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _TrustSection extends StatelessWidget {
  const _TrustSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navy950,
      child: _PageWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.green600,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(
                  Icons.balance_outlined,
                  size: 32,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Klarheit mit klaren Grenzen.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Paperwork Assistant bereitet Informationen verständlich '
                      'auf und unterstützt bei der Strukturierung. Die Anwendung '
                      'ersetzt keine Rechts-, Steuer- oder sonstige professionelle Beratung.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.navy100),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingFooter extends StatelessWidget {
  const _LandingFooter();

  @override
  Widget build(BuildContext context) {
    return const _PageWidth(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.md,
          children: [BrandMark(), Text('Produktgerüst · Keine Beratung')],
        ),
      ),
    );
  }
}

class _PageWidth extends StatelessWidget {
  const _PageWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
