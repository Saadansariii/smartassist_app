// // import 'package:flutter/material.dart';

// // class AppFont {

// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_launcher_icons/xml_templates.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_assist/config/component/color/colors.dart';

// class AppFont {
//   static TextStyle dropDown({
//     double fontSize = 14,
//     Color color = Colors.grey,
//     FontWeight fontWeight = FontWeight.w500,
//   }) {
//     return GoogleFonts.poppins(
//       fontSize: fontSize,
//       color: color,
//       fontWeight: fontWeight,
//     );
//   }

//   static TextStyle dropDowmLabel({
//     double fontSize = 14,
//     Color color = Colors.black,
//   }) {
//     return GoogleFonts.poppins(
//       fontSize: fontSize,
//       color: color,
//       fontWeight: FontWeight.w500,
//     );
//   }

//   static TextStyle bold({
//     double fontSize = 14,
//     Color color = Colors.black,
//   }) {
//     return GoogleFonts.poppins(
//       fontSize: fontSize,
//       color: color,
//       fontWeight: FontWeight.bold,
//     );
//   }

//   static TextStyle popupTitle({
//     double fontSize = 20,
//     Color color = AppColors.colorsBlue,
//   }) {
//     return GoogleFonts.poppins(
//       fontSize: fontSize,
//       color: color,
//       fontWeight: FontWeight.w600,
//     );
//   }

//    static TextStyle popupTitleBlack({
//     double fontSize = 20,
//     Color color = AppColors.fontBlack,
//   }) {
//     return GoogleFonts.poppins(
//       fontSize: fontSize,
//       color: color,
//       fontWeight: FontWeight.w600,
//     );
//   }

//   static TextStyle calanderDayName({
//     double fontSize = 12,
//     Color color = Colors.black,
//   }) {
//     return GoogleFonts.poppins(
//       fontSize: fontSize,
//       color: color,
//       fontWeight: FontWeight.w500,
//     );
//   }

//   static TextStyle buttons({
//     double fontSize = 16,
//     Color color = Colors.white,
//   }) {
//     return GoogleFonts.poppins(
//         fontSize: fontSize, color: color, fontWeight: FontWeight.w700);
//   }

//   static TextStyle appbarfontWhite({
//     double fontSize = 18,
//     Color color = Colors.white,
//   }) {
//     return GoogleFonts.poppins(
//         fontSize: fontSize, color: color, fontWeight: FontWeight.w500);
//   }

//   static TextStyle appbarfontgrey({
//     double fontSize = 18,
//     Color color = const Color(0xff767676),
//   }) {
//     return GoogleFonts.poppins(
//         fontSize: fontSize, color: color, fontWeight: FontWeight.w500);
//   }

//   static TextStyle searchFontTitle({
//     double fontSize = 12,
//     Color color = AppColors.fontBlack,
//   }) {
//     return GoogleFonts.poppins(
//         fontSize: fontSize, color: color, fontWeight: FontWeight.w500);
//   }

//   static TextStyle searchFontSubtitle({
//     double fontSize = 12,
//     Color color = const Color(0xff767676),
//   }) {
//     return GoogleFonts.poppins(
//         fontSize: fontSize, color: color, fontWeight: FontWeight.w400);
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_assist/config/component/color/colors.dart';

class AppFont {
  // ✅ Utility function to scale font dynamically based on device type
  static double scaleFont(BuildContext context, double baseSize) {
    // Get the text scale factor from the system settings
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Optionally, you can limit the scale factor to prevent extreme text scaling
    textScaleFactor = textScaleFactor > 1.5
        ? 1.5
        : textScaleFactor; // Limiting max scaling factor

    double screenWidth = MediaQuery.of(context).size.width;

    // Scale font based on screen width (you already had this logic)
    double scaledFont = baseSize * textScaleFactor;

    if (screenWidth < 360) {
      return scaledFont * 0.85; // Smaller screens
    } else if (screenWidth >= 360 && screenWidth <= 480) {
      return scaledFont * 1.0; // Standard screens
    } else if (screenWidth > 480 && screenWidth <= 720) {
      return scaledFont * 1.2; // Tablets
    } else {
      return scaledFont * 1.5; // Large screens
    }
  }

  static TextStyle dropDown(
    BuildContext context, {
    double fontSize = 14,
    Color color = Colors.grey,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle dropDowmLabel(
    BuildContext context, {
    double fontSize = 14,
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  // static TextStyle labelWhite14(
  //   BuildContext context, {
  //   double fontSize = 14,
  //   Color color = Colors.white,
  //   Color backgroundColor = Colors.red,
  // }) {
  //   return GoogleFonts.poppins(
  //     background: backgroundColor,
  //     fontSize: scaleFont(context, fontSize),
  //     color: color,
  //     fontWeight: FontWeight.w500,
  //   );
  // }

  static TextStyle dashboardName(
    BuildContext context, {
    double fontSize = 16,
    Color color = const Color.fromRGBO(78, 78, 78, 1),
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle dashboardCarName(
    BuildContext context, {
    double fontSize = 12,
    Color color = const Color.fromRGBO(78, 78, 78, 1),
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle smallText(
    BuildContext context, {
    double fontSize = 12,
    Color color = const Color.fromRGBO(78, 78, 78, 1),
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle mediumText14(
    BuildContext context, {
    double fontSize = 14,
    Color color = const Color.fromRGBO(78, 78, 78, 1),
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle tinyText(
    BuildContext context, {
    double fontSize = 8,
    Color color = const Color.fromRGBO(78, 78, 78, 1),
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle buttonwhite(
    BuildContext context, {
    double fontSize = 12,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle smallTextBold(
    BuildContext context, {
    double fontSize = 12,
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle tinytext(
    BuildContext context, {
    double fontSize = 10,
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle bold(
    BuildContext context, {
    double fontSize = 14,
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle popupTitle(
    BuildContext context, {
    double fontSize = 20,
    Color color = AppColors.colorsBlue,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle popupTitleBlack(
    BuildContext context, {
    double fontSize = 20,
    Color color = AppColors.fontBlack,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle popupTitleWhite(
    BuildContext context, {
    double fontSize = 20,
    Color color = Colors.white,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle calanderDayName(
    BuildContext context, {
    double fontSize = 12,
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle buttons(
    BuildContext context, {
    double fontSize = 16,
    Color color = AppColors.white,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle appbarfontWhite(
    BuildContext context, {
    double fontSize = 18,
    Color color = Colors.white,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle appbarfontgrey(
    BuildContext context, {
    double fontSize = 18,
    Color color = AppColors.fontColor,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle searchFontTitle(
    BuildContext context, {
    double fontSize = 12,
    Color color = AppColors.fontBlack,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle searchFontSubtitle(
    BuildContext context, {
    double fontSize = 12,
    Color color = const Color(0xff767676),
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle threeBtn(
    BuildContext context, {
    double fontSize = 11,
    Color color = const Color(0xff767676),
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle validationtxt(
    BuildContext context, {
    double fontSize = 10,
    Color color = Colors.redAccent,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.poppins(
      fontSize: scaleFont(context, fontSize),
      color: color,
      fontWeight: fontWeight,
    );
  }
}

 
