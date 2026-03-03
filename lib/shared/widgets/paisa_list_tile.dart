import 'package:flutter/material.dart';

class PaisaListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? amount;
  final Color? amountColor;
  final IconData icon;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? trailingSubtitle;
  final Color? trailingSubtitleColor;

  const PaisaListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.amount,
    this.amountColor,
    required this.icon,
    required this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
    this.trailing,
    this.trailingSubtitle,
    this.trailingSubtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: onTap,
      leading: Container(
        width: 44, 
        height: 44,
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 16,
            letterSpacing: 0.2, // Subtle tracking for readability
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8), // Softer subtitle
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ?? (amount != null ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount!,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          if (trailingSubtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              trailingSubtitle!,
              style: TextStyle(
                color: trailingSubtitleColor ?? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ) : null),
    );
  }
}
