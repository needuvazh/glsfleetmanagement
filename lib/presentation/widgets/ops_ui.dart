import 'package:flutter/material.dart';

class OpsSectionCard extends StatelessWidget {
  const OpsSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent = const Color(0xFF0EA5E9),
    required this.child,
    this.trailing,
    this.expandChild = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accent;
  final Widget child;
  final Widget? trailing;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    final border = accent.withValues(alpha: 0.26);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
        ),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B1A33),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, size: 16, color: accent),
                  ),
                if (icon != null) const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            if (expandChild) Expanded(child: child) else child,
          ],
        ),
      ),
    );
  }
}

class OpsPill extends StatelessWidget {
  const OpsPill({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class OpsTableActionMenuItem {
  const OpsTableActionMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.destructive = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final bool destructive;
}

class OpsTableActions extends StatelessWidget {
  const OpsTableActions({
    super.key,
    this.onView,
    this.onEdit,
    this.onMoreSelected,
    this.moreItems = const [],
    this.viewTooltip = 'View',
    this.editTooltip = 'Edit',
    this.moreTooltip = 'More',
  });

  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final ValueChanged<String>? onMoreSelected;
  final List<OpsTableActionMenuItem> moreItems;
  final String viewTooltip;
  final String editTooltip;
  final String moreTooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onView != null) ...[
            Tooltip(
              message: viewTooltip,
              child: IconButton(
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined, size: 20),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (onEdit != null) ...[
            Tooltip(
              message: editTooltip,
              child: IconButton(
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (moreItems.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: moreTooltip,
              onSelected: onMoreSelected,
              itemBuilder: (context) => [
                for (final item in moreItems)
                  PopupMenuItem<String>(
                    value: item.value,
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 18,
                          color: item.destructive
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.label,
                          style: item.destructive
                              ? TextStyle(color: colorScheme.error)
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.more_vert, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
