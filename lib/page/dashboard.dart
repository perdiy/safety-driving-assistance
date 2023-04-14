import 'package:safe/consttants.dart';
import 'package:safe/widgets/reading_card_list.dart';

import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bb.png"),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: size.height * .1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Selamat datang di \naplikasi ",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w300),
                          ),
                          TextSpan(
                            text: "Safety Driving",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                "\nDaily task is waiting for you and have a safe trip",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        ReadingListCard(
                          image: "assets/images/cek.png",
                          title: "Cek Tekanan angin ban kendaraan anda",
                          auth: "",
                          rating: 4.9,
                          pressRead: () {
                            showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                      title: Text(
                                          'Manfaat Rutin Periksa Tekanan Angin Ban Kendaraan'),
                                      content: Text(
                                          '1. Memperpanjang Usia Ban Mobil Jika sering diperiksa maka ban akan lebih awet dan tidak mudah sobek. Hal ini karena ban yang kurang tekanan angin bisa cepat retak serta sobek sisi sampingnya lantaran beban berlebih tapi mobil terus dipacu dengan kondisi kempis.\n\n2. Meminimalisir Risiko Kecelakaan\nTekanan ban berlebih atau kurang akan mengakibatkan ban kendaraan cepat pecah. Oleh karena itu usahakan untuk menjaga tekanan ban kendaraan sesuai buku petunjuk pemilik kendaraan.\n\n3. Menghemat bahan bakar\nBan yang mempunyai tekanan angin pas akan mengurangi beban mesin kendaraan. Jika angin dalam ban kurang maka permukaan ban yang bergesekan dengan tanah bertambah lebar. Akibatnya beban mesin akan bertambah dan konsumsi bahan bakar juga meningkat.'),
                                    ));
                          },
                          pressDetails: () {},
                        ),
                        ReadingListCard(
                          image: "assets/images/lamp.png",
                          title:
                              "Periksa kelistrikan kendaraan yang akan digunakan ",
                          auth: "k",
                          rating: 4.9,
                          pressRead: () {
                            showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                      title: Text(
                                          'mengapa sistem kelistrikan itu sangat penting?'),
                                      content: Text(
                                          'contoh kecilnya adalah Sistem kelistrikan bisa menambah kenyamanan kamu berkendara. Membantu busi menyala, sehingga mesin bensin bisa bekerja. Untuk sistem keamanan dan keselamatan mesin.'),
                                    ));
                          },
                          pressDetails: () {},
                        ),
                        ReadingListCard(
                          image: "assets/images/helm.png",
                          title: "Gunakan Helm saat berkendara",
                          auth: "",
                          rating: 4.9,
                          pressRead: () {
                            showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                      title: Text(
                                          'Apa manfaat memakai helm saat mengendari sepeda motor?'),
                                      content: Text(
                                          '1.Melindungi Kepala dari Benturan Saat Kecelakaan.\n\n2.Melindungi Mata dari Angin, Debu dan Kotoran serta Benda Keras Lainnya.\n\n3.Melindungi Kepala dari Panasnya Terik Matahari.\n\n4.Melindungi Kepala dari Basah Air Hujan.\n\n5.Mencegah Tilang Polisi Lalu Lintas.'),
                                    ));
                          },
                          pressDetails: () {},
                        ),
                        ReadingListCard(
                          image: "assets/images/sim.png",
                          title: "Bawa selelu SIM anda",
                          auth: "",
                          rating: 4.9,
                          pressRead: () {
                            showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                      title: Text(
                                          'kenapa harus membawa surat-surat kendaraan?'),
                                      content: Text(
                                          '1.Sebagai bukti kompetensi mengemudi\n\n2. Sebagai registrasi pengemudi kendaraan bermotor yang memuat keterangan identitas lengkap pengemudi\n\n3. Untuk mendukung kegiatan penyelidikan, penyidikan dan identifikasi forensik Kepolisian.'),
                                    ));
                          },
                          pressDetails: () {},
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        bestOfTheDayCard(size, context),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(text: "Continue "),
                              TextSpan(
                                text: "reading...",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container bestOfTheDayCard(Size size, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      height: 245,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                top: 60,
                right: size.width * .35,
              ),
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAEA).withOpacity(.45),
                borderRadius: BorderRadius.circular(29),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: const Text(
                      "Perdalam Informasi & Wawasan Seputar Lalu Lintas.",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const Text(
                    "Lihat dan tandai lokasi rawan kecelakaan",
                    style: TextStyle(
                        fontSize: 10,
                        color: kLightBlackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10.0),
                    child: Row(
                      children: const <Widget>[],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              "assets/images/bnr.png",
              width: size.width * .40,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              width: size.width * .1,
            ),
          ),
        ],
      ),
    );
  }
}
