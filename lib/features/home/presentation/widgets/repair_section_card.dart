// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../../../core/constants/asset_constants.dart';
// import '../../../../core/theme/app_colors.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/route_names.dart';

// class RepairSectionCard extends StatelessWidget {
//   const RepairSectionCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => context.push(RouteNames.repairCategories),
//       child: Container(
//         constraints: const BoxConstraints(minHeight: 150),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               AppColors.repairGradientStart,
//               AppColors.repairGradientEnd,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'REPAIR',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Electrical, CCTV,\nTech & more',
//                     style: TextStyle(
//                       color: Colors.white.withAlpha(210),
//                       fontSize: 13,
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       'Book Service',
//                       style: TextStyle(
//                         color: AppColors.repairGradientStart,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SvgPicture.asset(
//               AssetConstants.repairIcon,
//               width: 72,
//               height: 72,
//               colorFilter: ColorFilter.mode(
//                 Colors.white.withAlpha(76),
//                 BlendMode.srcIn,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class RepairSectionCard extends StatelessWidget {
  const RepairSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.repairCategories),
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.repairGradientStart,
              AppColors.repairGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'REPAIR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Electrical, CCTV,\nTech & more',
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Book Service',
                      style: TextStyle(
                        color: AppColors.repairGradientStart,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(AssetConstants.repairIcon, width: 80, height: 80),
          ],
        ),
      ),
    );
  }
}
