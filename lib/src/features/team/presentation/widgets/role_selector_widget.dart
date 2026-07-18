import 'package:gnade_app/src/imports/imports.dart';

class RoleSelectorWidget extends StatelessWidget {
  final String selected;
  final void Function(String) onSelected;

  const RoleSelectorWidget({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleOption(
          role:       'manager',
          label:      'Manager',
          subtitle:   'Can view reports & manage inventory',
          icon:       Icons.manage_accounts_outlined,
          isSelected: selected == 'manager',
          onTap:      () => onSelected('manager'),
        ),
        const SizedBox(width: 12),
        _RoleOption(
          role:       'staff',
          label:      'Staff',
          subtitle:   'Can record sales only',
          icon:       Icons.badge_outlined,
          isSelected: selected == 'staff',
          onTap:      () => onSelected('staff'),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String role;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color:        isSelected ? primary.withValues(alpha: 0.07) : Colors.white,
            border:       Border.all(
              color:     isSelected ? primary : Colors.grey.shade200,
              width:     isSelected ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? primary : Colors.grey,
                size: 26,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isSelected ? primary : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
