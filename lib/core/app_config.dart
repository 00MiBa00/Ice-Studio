import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AppConfig {
//========================= App Serrings =========================//

  static const String appsFlyerDevKey = 'PKSqH6REeXFopLCqL6Za7c';
  static const String appsFlyerAppId = '6758608947'; // Для iOS'
  static const String bundleId = 'com.piettecom.appstudio'; // Для iOS'
  static const String locale = 'en'; // Для iOS'
  static const String os = 'iOS'; // Для iOS'
  static const String endpoint = 'https://icestuddio.com'; // Для iOS'

  static const String logoPath = 'assets/images/Logo.png';
  static const String pushRequestLogoPath = 'assets/images/Logo.png';

  static const String pushRequestBackgroundPath =
      'assets/images/SplashBackground.png';
  static const String splashBackgroundPath =
      'assets/images/SplashBackground.png';
  static const String errorBackgroundPath =
      'assets/images/SplashBackground.png';

//========================= UI Settings =========================//

  //========================= Splash Screen ====================//
  static const Decoration splashDecoration = const BoxDecoration(
    //закоментировать если не нужен градиент
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF7F3CCA),
        Color(0xFF23003C),
      ],
    ),

    //закоментировать если не нужен фон из изображения
    image: DecorationImage(
      image: AssetImage(AppConfig.splashBackgroundPath),
      fit: BoxFit.cover,
    ),
  );

  static const Color loadingTextColor = Color(0xFFFFFFFF);
  static const Color spinerColor = Color(0xFCFFFFFF);

  //========================= Push Request Screen ====================//

  static const Decoration pushRequestDecoration = const BoxDecoration(
    //закоментировать если не нужен градиент
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF7F3CCA),
        Color(0xFF23003C),
      ],
    ),

    //закоментировать если не нужен фон из изображения
    image: DecorationImage(
      image: AssetImage(AppConfig.pushRequestBackgroundPath),
      fit: BoxFit.cover,
    ),
  );

  static const Gradient pushRequestFadeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color.fromARGB(135, 0, 0, 0),
    ],
  );
  static const Color titleTextColor = Color(0xFFFFFFFF);
  static const Color subtitleTextColor = Color(0x80FDFDFD);

  static const Color yesButtonColor = Color(0xFFFFB301);
  static const Color yesButtonShadowColor = Color(0xFF8B3619);
  static const Color yesButtonTextColor = Color(0xFFFFFFFF);
  static const Color skipTextColor = Color(0x7DF9F9F9);

  //========================= Error Screen ====================//
  static const Decoration errorScreenDecoration = const BoxDecoration(
    //закоментировать если не нужен градиент
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF7F3CCA),
        Color(0xFF23003C),
      ],
    ),

    //закоментировать если не нужен фон из изображения
    image: DecorationImage(
      image: AssetImage(AppConfig.errorBackgroundPath),
      fit: BoxFit.cover,
    ),
  );

  static const Color errorScreenTextColor = Color(0xFFFFFFFF);
  static const Color errorScreenIconColor = Color(0xFCFFFFFF);
}
