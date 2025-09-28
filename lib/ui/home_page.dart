import 'package:flutter/material.dart';
import '../shared/responsive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final padding = EdgeInsets.all(Responsive.responsivePadding(context));
    final gap = SizedBox(height: Responsive.responsiveGap(context));

    return Scaffold(
      appBar: AppBar(title: const Text('Fit You Natação')),
      body: SingleChildScrollView(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Seja feliz, seja saudável, seja Fit You! ',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                gap,
                Text(
                  'Aplicativo simples e intuitivo para alunos de natação. ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                gap,
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.start,
                  children: [
                    _FeatureCard(
                      title: 'Agendar Aula',
                      icon: Icons.calendar_today,
                      onTap: () {},
                      width: isTablet ? 300 : double.infinity,
                    ),
                    _FeatureCard(
                      title: 'Horários',
                      icon: Icons.access_time,
                      onTap: () {},
                      width: isTablet ? 300 : double.infinity,
                    ),
                    _FeatureCard(
                      title: 'Planos',
                      icon: Icons.price_change,
                      onTap: () {},
                      width: isTablet ? 300 : double.infinity,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.width,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
