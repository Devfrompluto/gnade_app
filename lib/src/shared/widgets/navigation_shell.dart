import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
  });
  final dynamic icon;
  final String label;
}

const _navItems = [
  _NavItem(
    icon: HugeIcons.strokeRoundedHome01,
    label: 'Home',
  ),
  _NavItem(
    icon: HugeIcons.strokeRoundedReceiptDollar,
    label: 'Sales',
  ),
  _NavItem(
    icon: HugeIcons.strokeRoundedPackage,
    label: 'Products',
  ),
  _NavItem(
    icon: HugeIcons.strokeRoundedUserGroup,
    label: 'Customers',
  ),
  _NavItem(
    icon: HugeIcons.strokeRoundedMenu01,
    label: 'More',
  ),
];

// ─── Bar ─────────────────────────────────────────────────────────────────────

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? colorScheme.surface : Colors.white;
    final shadowColor = isDark ? Colors.black45 : Colors.black12;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.h,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              return Expanded(
                child: _NavBarItem(
                  item: _navItems[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Item ─────────────────────────────────────────────────────────────────────

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    final pillColor = colorScheme.primary.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Pill + icon ──────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 14.w : 10.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: isActive ? pillColor : Colors.transparent,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: AppIcon(
              icon: item.icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22.sp,
            ),
          ),

          SizedBox(height: 3.h),

          // ── Label ────────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Inter VariableFont Opsz,Wght',
              fontSize: 10.5.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
              letterSpacing: isActive ? 0.1 : 0,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}
