import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'home_tab.dart';
import 'products/products_tab.dart';
import 'map/map_tab.dart';
import 'gallery/gallery_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ProductsTab(),
    const MapTab(),
    const GalleryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.textSilver.withOpacity(0.1), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers),
              label: 'Próbnik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa Studiów',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_outlined),
              activeIcon: Icon(Icons.photo_library),
              label: 'Galeria',
            ),
          ],
        ),
      ),
    );
  }
}
