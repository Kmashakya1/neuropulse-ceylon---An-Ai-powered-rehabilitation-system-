import 'package:flutter/material.dart';

import '../features/i18n.dart';

import '../routes.dart';
import 'tokens.dart';

/// Primary navigation.
///
/// Labels are always visible: icon-only tabs are a recognition problem for users
/// with cognitive fatigue, and the labels give the Sinhala and Tamil translations
/// somewhere to live later. The active tab is marked by a tinted pill plus a
/// weight change, not colour alone.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.active});

  final String active;

  // Not const: the labels are looked up per build so switching language
  // re-reads them rather than baking in whatever was set at first render.
  static List<(String, String, IconData, String)> get _tabs => [
    ('home', t('nav.home'), Icons.home, Routes.dashboard),
    ('plan', t('nav.plan'), Icons.calendar_month, Routes.myPlan),
    ('progress', t('nav.progress'), Icons.show_chart, Routes.progress),
    ('care', t('nav.care'), Icons.shield, Routes.care),
    ('me', t('nav.me'), Icons.account_circle, Routes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: Space.sm, bottom: Space.xs),
      decoration: const BoxDecoration(
        color: AppColor.canvas,
        border: Border(top: BorderSide(color: AppColor.border)),
      ),
      child: Row(
        children: _tabs
            .map((tab) {
              final (key, label, icon, route) = tab;
              final selected = key == active;

              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  child: InkWell(
                    onTap: selected
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil(route, (r) => r.isFirst),
                    child: SizedBox(
                      height: Sizes.target,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Space.base,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColor.brandTint
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(Radii.pill),
                            ),
                            child: Icon(
                              icon,
                              size: 22,
                              color: selected
                                  ? AppColor.brandText
                                  : AppColor.inkSubtle,
                            ),
                          ),
                          // Sinhala and Tamil labels run longer than the English,
                          // and a five-slot tab strip has no room to wrap. Shrink to
                          // fit rather than clipping the descenders.
                          // A gutter each side so long Tamil labels shrink instead of
                          // butting up against the neighbouring tab.
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  style: AppText.caption.copyWith(
                                    color: selected
                                        ? AppColor.brandText
                                        : AppColor.inkSubtle,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
