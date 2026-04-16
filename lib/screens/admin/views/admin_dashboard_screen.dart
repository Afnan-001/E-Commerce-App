import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/config/cloudinary_config.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/route_constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLoad) return;
    final authProvider = context.read<AuthProvider>();
    final adminProvider = context.read<AdminProvider>();
    if (!authProvider.isAdmin || adminProvider.hasLoadedData || adminProvider.isLoading) {
      return;
    }

    _requestedLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminProvider>().loadAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin panel')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text(
              'This area is only available for admin accounts.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final totalProducts = adminProvider.products.length;
    final totalOrders = adminProvider.orders.length;
    final pendingOrders = adminProvider.orders
        .where(
          (order) =>
              order.orderStatus == OrderStatus.placed ||
              order.orderStatus == OrderStatus.confirmed ||
              order.orderStatus == OrderStatus.shipped,
        )
        .length;
    final completedOrders = adminProvider.orders
        .where(
          (order) =>
              order.orderStatus == OrderStatus.delivered ||
              order.orderStatus == OrderStatus.cancelled,
        )
        .length;
    final activeProducts = adminProvider.products
        .where((product) => product.isActive)
        .length;
    final hiddenProducts = totalProducts - activeProducts;
    final featuredProducts = adminProvider.products
        .where((product) => product.isFeatured)
        .length;
    final activeBanners = adminProvider.homeBanners.where((item) => item.isActive).length;
    final totalRevenue = adminProvider.orders.fold<double>(
      0,
      (sum, order) => sum + order.totalPrice,
    );

    final productByCategory = <String, int>{};
    for (final product in adminProvider.products) {
      final key = product.category.trim().isEmpty
          ? 'Unassigned'
          : product.category;
      productByCategory[key] = (productByCategory[key] ?? 0) + 1;
    }

    final chartEntries = productByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin panel'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleMedium?.color,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminProvider>().loadAdminData(),
        child: adminProvider.isLoading && !adminProvider.hasLoadedData
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  defaultPadding,
                  defaultPadding / 2,
                  defaultPadding,
                  defaultPadding * 1.5,
                ),
                children: [
                  _HeroHeader(
                    totalOrders: totalOrders,
                    totalRevenue: totalRevenue,
                    pendingOrders: pendingOrders,
                    activeBanners: activeBanners,
                  ),
                  const SizedBox(height: defaultPadding),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: defaultPadding,
                    mainAxisSpacing: defaultPadding,
                    childAspectRatio: 1.0,
                    children: [
                      _StatCard(
                        label: 'Products',
                        value: '$totalProducts',
                        helper: '$activeProducts active',
                        icon: Icons.inventory_2_outlined,
                        accent: const Color(0xFF285943),
                      ),
                      _StatCard(
                        label: 'Orders',
                        value: '$totalOrders',
                        helper: '$pendingOrders pending',
                        icon: Icons.receipt_long_outlined,
                        accent: const Color(0xFF7A4B32),
                      ),
                      _StatCard(
                        label: 'Categories',
                        value: '${adminProvider.categories.length}',
                        helper: '$featuredProducts featured',
                        icon: Icons.category_outlined,
                        accent: const Color(0xFF3A5E9F),
                      ),
                      _StatCard(
                        label: 'Cloudinary',
                        value: CloudinaryConfig.isConfigured
                            ? 'Ready'
                            : 'Setup',
                        helper: 'Shared shop uploads',
                        icon: Icons.cloud_upload_outlined,
                        accent: const Color(0xFF7A4BB7),
                      ),
                      _StatCard(
                        label: 'Banners',
                        value: '$activeBanners',
                        helper: 'Live in carousel',
                        icon: Icons.view_carousel_outlined,
                        accent: const Color(0xFFCC8C2E),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  _SectionCard(
                    title: 'Order status',
                    subtitle: 'Quick view of pending vs completed orders',
                    child: Row(
                      children: [
                        _RingChart(
                          pendingOrders: pendingOrders,
                          completedOrders: completedOrders,
                        ),
                        const SizedBox(width: defaultPadding),
                        Expanded(
                          child: Column(
                            children: [
                              _LegendTile(
                                color: const Color(0xFFEF8F5A),
                                label: 'Pending',
                                value: '$pendingOrders',
                              ),
                              const SizedBox(height: defaultPadding / 2),
                              _LegendTile(
                                color: const Color(0xFF3EA66B),
                                label: 'Completed',
                                value: '$completedOrders',
                              ),
                              const SizedBox(height: defaultPadding / 2),
                              _LegendTile(
                                color: const Color(0xFF7A4BB7),
                                label: 'Total revenue',
                                value: 'Rs ${totalRevenue.toStringAsFixed(0)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  _SectionCard(
                    title: 'Catalog breakdown',
                    subtitle: 'Products by category across the whole shop',
                    child: chartEntries.isEmpty
                        ? const _EmptyChartMessage(
                            message:
                                'Add products and category bars will appear here.',
                          )
                        : Column(
                            children: chartEntries
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: defaultPadding * 0.75,
                                    ),
                                    child: _HorizontalBar(
                                      label: entry.key,
                                      value: entry.value,
                                      total: totalProducts == 0
                                          ? 1
                                          : totalProducts,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: defaultPadding),
                  _SectionCard(
                    title: 'Inventory mix',
                    subtitle:
                        'Track visible vs hidden products for the shared shop',
                    child: Column(
                      children: [
                        _InventoryRow(
                          label: 'Visible in store',
                          value: activeProducts,
                          color: const Color(0xFF285943),
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        _InventoryRow(
                          label: 'Hidden from store',
                          value: hiddenProducts,
                          color: const Color(0xFFB05252),
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        _InventoryRow(
                          label: 'Featured on home',
                          value: featuredProducts,
                          color: const Color(0xFF3A5E9F),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  _SectionCard(
                    title: 'System status',
                    subtitle: 'Single-shop setup health',
                    child: Column(
                      children: [
                        _StatusTile(
                          title: 'Firebase',
                          message: adminProvider.errorMessage == null
                              ? 'Firestore access is working for this admin account.'
                              : adminProvider.errorMessage!,
                          isHealthy: adminProvider.errorMessage == null,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        _StatusTile(
                          title: 'Cloudinary',
                          message: CloudinaryConfig.isConfigured
                              ? 'Cloudinary is configured for product image uploads.'
                              : 'Add your cloud name and unsigned upload preset to enable uploads.',
                          isHealthy: CloudinaryConfig.isConfigured,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              adminProductsScreenRoute,
                            );
                          },
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: const Text('Products'),
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              adminOrdersScreenRoute,
                            );
                          },
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Orders'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, adminCategoriesScreenRoute);
                    },
                    icon: const Icon(Icons.category_outlined),
                    label: const Text('Manage categories'),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, adminHomeBannerScreenRoute);
                    },
                    icon: const Icon(Icons.view_carousel_outlined),
                    label: const Text('Manage home banners'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.activeBanners,
  });

  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final int activeBanners;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Single shop control room',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track shared catalog activity, order progress, and storefront health for every admin account.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: defaultPadding),
          Wrap(
            spacing: defaultPadding,
            runSpacing: defaultPadding,
            children: [
              SizedBox(
                width: 132,
                child: _HeroMetric(
                  label: 'Revenue',
                  value: 'Rs ${totalRevenue.toStringAsFixed(0)}',
                ),
              ),
              SizedBox(
                width: 132,
                child: _HeroMetric(
                  label: 'Orders',
                  value: '$totalOrders total',
                ),
              ),
              SizedBox(
                width: 132,
                child: _HeroMetric(
                  label: 'Pending',
                  value: '$pendingOrders open',
                ),
              ),
              SizedBox(
                width: 132,
                child: _HeroMetric(
                  label: 'Banners',
                  value: '$activeBanners live',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox.shrink(),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B1D22);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.86)
        : const Color(0xFF505463);
    final helperColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xFF727788);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(Radius.circular(14)),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: titleColor,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            helper,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: helperColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B1D22);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.82)
        : const Color(0xFF5A5F70);
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 16)),
          const SizedBox(height: defaultPadding),
          child,
        ],
      ),
    );
  }
}

class _RingChart extends StatelessWidget {
  const _RingChart({
    required this.pendingOrders,
    required this.completedOrders,
  });

  final int pendingOrders;
  final int completedOrders;

  @override
  Widget build(BuildContext context) {
    final total = math.max(1, pendingOrders + completedOrders);
    final completedSweep = completedOrders / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: completedSweep),
            duration: const Duration(milliseconds: 700),
            builder: (context, value, child) {
              return CustomPaint(
                size: const Size.square(116),
                painter: _RingPainter(progress: value, isDark: isDark),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Text('orders'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = isDark ? const Color(0xFF2A3140) : const Color(0xFFECE7DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final completedPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3EA66B), Color(0xFF1B7F4B)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final pendingPaint = Paint()
      ..color = const Color(0xFFEF8F5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    final startAngle = -math.pi / 2;
    final completedAngle = progress * 2 * math.pi;
    final pendingAngle = (1 - progress) * 2 * math.pi;

    if (completedAngle > 0.02) {
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        completedAngle,
        false,
        completedPaint,
      );
    }

    if (pendingAngle > 0.02) {
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle + completedAngle,
        pendingAngle,
        false,
        pendingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

class _LegendTile extends StatelessWidget {
  const _LegendTile({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final valueColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF22252E);
    final labelColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.88)
        : const Color(0xFF4E5465);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(color: labelColor)),
        ),
        Text(
          value,
          style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({
    required this.label,
    required this.value,
    required this.total,
  });

  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : value / total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2A2D36);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '$value',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: isDark
                ? const Color(0xFF2A3140)
                : const Color(0xFFECE7DB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3A5E9F)),
          ),
        ),
      ],
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF2A2D36);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(color: textColor)),
          ),
          Text(
            '$value',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.title,
    required this.message,
    required this.isHealthy,
  });

  final String title;
  final String message;
  final bool isHealthy;

  @override
  Widget build(BuildContext context) {
    final color = isHealthy ? const Color(0xFF2D8F59) : errorColor;
    final titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF20232B);
    final messageColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF4F5565);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHealthy ? Icons.verified_outlined : Icons.warning_amber_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: messageColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1E28) : const Color(0xFFF8F6F0),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(message),
    );
  }
}
