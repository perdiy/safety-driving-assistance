import 'package:flutter/material.dart';
import 'package:safe/berita/beritalalulintas.dart';
import 'package:safe/detailspage/details1.dart';

class Tab1 extends StatelessWidget {
  const Tab1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: beritaList.length,
        itemBuilder: (context, index) {
          BeritaLaluLintas berita = beritaList[index];
          return InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Details1(berita)));
            },
            child: Container(
              margin: const EdgeInsets.all(12.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3.0,
                    ),
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      //let's add the height

                      image: DecorationImage(
                          image: NetworkImage(berita.imageUrl),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    berita.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    berita.sumber,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w200,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
