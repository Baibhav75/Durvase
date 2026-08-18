import 'package:flutter/material.dart';
import '../utils/theme_constants.dart';

class DeliveryAddressSection extends StatelessWidget {
  final VoidCallback onTap;
  
  const DeliveryAddressSection({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Material(
        color: ThemeConstants.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: ThemeConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: ThemeConstants.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deliver to User - Mumbai 400001', // Dynamic value later
                        style: ThemeConstants.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeConstants.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: ThemeConstants.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
