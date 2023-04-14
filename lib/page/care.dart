import 'package:flutter/material.dart';
import 'package:safe/tabbarpage/tab3.dart';
import 'package:safe/tabbarpage/tab4.dart';

class Care extends StatefulWidget {
  const Care({Key? key}) : super(key: key);

  @override
  State<Care> createState() => _CareState();
}

class _CareState extends State<Care> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Care',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  // height: 50,
                  width: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: TabBar(
                          unselectedLabelColor: Colors.white,
                          labelColor: Colors.black,
                          indicatorColor: Colors.white,
                          indicatorWeight: 0,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          controller: tabController,
                          tabs: const [
                            Tab(
                              text: 'Motor',
                            ),
                            Tab(
                              text: 'Mobil',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: const [
                      Tab3(),
                      Tab4(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
