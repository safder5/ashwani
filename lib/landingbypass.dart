import 'package:ashwani/src/Screens/bom/productions.dart';
import 'package:ashwani/src/Screens/home.dart';
import 'package:ashwani/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'src/Screens/purchase.dart';
import 'src/Screens/sales.dart';
// import 'Services/NetworkService/network_service.dart';

class LandingBypass extends StatefulWidget {
  const LandingBypass({super.key});

  @override
  State<LandingBypass> createState() => _LandingBypassState();
}

class _LandingBypassState extends State<LandingBypass> {
  @override
  Widget build(BuildContext context) {
    PersistentTabController controller;
    controller = PersistentTabController(initialIndex: 0);
    List<Widget> buildScreens() {
      return [
        const Reports(),
        // const Masters(),
        const SalesPage(),
        const PurchasePage(),
        const Production(),
      ];
    } // const BOM()

    List<PersistentBottomNavBarItem> navBarItems() {
      return [
        PersistentBottomNavBarItem(
            inactiveIcon: SvgPicture.asset('lib/icons/home.svg'),
            icon: SvgPicture.asset('lib/icons/home_active.svg'),
            title: 'Masters',
            textStyle: const TextStyle(fontWeight: FontWeight.w300),
            activeColorPrimary: blue,
            activeColorSecondary: blue),
        //  PersistentBottomNavBarItem(
        // inactiveIcon: SvgPicture.asset('lib/icons/home.svg'),
        // icon: SvgPicture.asset('lib/icons/home_active.svg'),
        // title: 'Masters',
        // textStyle: const TextStyle(fontWeight: FontWeight.w300),
        // activeColorPrimary: blue,
        // activeColorSecondary: blue),
        PersistentBottomNavBarItem(
            inactiveIcon: SvgPicture.asset('lib/icons/sales.svg'),
            icon: SvgPicture.asset('lib/icons/sales_active.svg'),
            title: 'Sales',
            textStyle: const TextStyle(fontWeight: FontWeight.w300),
            activeColorPrimary: blue,
            activeColorSecondary: blue),
        PersistentBottomNavBarItem(
            inactiveIcon: SvgPicture.asset('lib/icons/purchase.svg'),
            icon: SvgPicture.asset('lib/icons/purchase_active.svg'),
            title: 'Purchase',
            textStyle: const TextStyle(fontWeight: FontWeight.w300),
            activeColorPrimary: blue,
            activeColorSecondary: blue),
        PersistentBottomNavBarItem(
            inactiveIcon: SvgPicture.asset('lib/icons/bom.svg'),
            icon: SvgPicture.asset('lib/icons/bom_active.svg'),
            title: 'Production',
            textStyle: const TextStyle(fontWeight: FontWeight.w300),
            activeColorPrimary: blue,
            activeColorSecondary: blue)
      ];
    }

    return PersistentTabView(
      onItemSelected: (value) {
        setState(() {
          value;
        });
      },
      stateManagement: true,
      context,
      screens: buildScreens(),
      controller: controller,
      items: navBarItems(),
      backgroundColor: Colors.white,
      confineInSafeArea: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardShows: true,
      navBarHeight: 66,
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        duration: Duration(milliseconds: 400),
      ),
      decoration: const NavBarDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0))),
      navBarStyle: NavBarStyle.style3,
    );
  }
}
