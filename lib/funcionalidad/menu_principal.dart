import 'package:afermar3_tf_ipc/funcionalidad/pantallas/Home/pantalla_home.dart';
import 'package:afermar3_tf_ipc/funcionalidad/pantallas/pantalla_info_personal.dart';
import 'package:afermar3_tf_ipc/funcionalidad/pantallas/pantallanodispo.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/botonmenu.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuPrincipal();
}

class _MenuPrincipal extends State<Menu> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket();
  Widget currentTab = const Home();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PantallaNoDisponible()),
            );
          },
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TColor.primerG,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                  )
                ]),
            child: Icon(
              Icons.search,
              color: TColor.blanco,
              size: 35,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        decoration: BoxDecoration(color: TColor.blanco, boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(31, 91, 64, 188),
              blurRadius: 2,
              offset: Offset(0, -2))
        ]
        
        ),
        
        height: kToolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BotonMenu(
                icon: "assets/img/Home.png",
                selectIcon: "assets/img/Home-Active.png",
                isActive: selectTab == 0,
                onTap: () {
                  selectTab = 0;
                  currentTab = const Home();
                  if (mounted) {
                    setState(() {});
                  }
                }),
            const SizedBox(
              width: 10,
            ),
            BotonMenu(
                icon: "assets/img/Profile.png",
                selectIcon: "assets/img/Profile-Active.png",
                isActive: selectTab == 3,
                onTap: () {
                  selectTab = 3;
                  currentTab = Perfil();
                  if (mounted) {
                    setState(() {});
                  }
                })
          ],
        ),
      )),
    );
  }
}
