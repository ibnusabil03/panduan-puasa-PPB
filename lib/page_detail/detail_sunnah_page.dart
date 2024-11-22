import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panduan_puasa/page_detail/detail_penjelasan_page.dart';
import 'package:panduan_puasa/page_detail/model_detail_sunnah.dart';

class DetailSunnahPage extends StatefulWidget {
  final String strTitle;

  const DetailSunnahPage({super.key, required this.strTitle});

  @override
  State<DetailSunnahPage> createState() => DetailSunnahPageState();
}

class DetailSunnahPageState extends State<DetailSunnahPage> {
  String? strTitle;

  @override
  initState() {
    super.initState();
    strTitle = widget.strTitle;
  }

  // Mendapatkan URL sesuai dengan judul
  String _getUrlForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'puasa arafah':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_arafah.json';
      case 'puasa asyura dan tasu\'a':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_asyura_dan_tasu\'a.json';
      case 'puasa ayyamul bidh':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_ayyamul_bidh.json';
      case 'puasa daud':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_daud.json';
      case 'puasa di bulan sya\'ban':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_di_bulan_sya\'ban.json';
      case 'puasa dzulhijjah':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_dzulhijjah.json';
      case 'puasa senin kamis':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_senin_kamis.json';
      case 'puasa syawal':
        return 'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_syawal.json';
      default:
        throw Exception("URL tidak ditemukan untuk judul: $title");
    }
  }

  // Method untuk mengambil data dari URL
  Future<List<ModelDetailSunnah>> fetchData() async {
    try {
      final url = _getUrlForTitle(strTitle!);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final listData = json.decode(response.body) as List<dynamic>;
        return listData.map((e) => ModelDetailSunnah.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          strTitle ?? '',
          maxLines: 2,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ModelDetailSunnah>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}")
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  var items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPenjelasanPage(
                                strTitle: items[index].title ?? '',
                                strContent: items[index].description ?? '',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 15,
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              "${index + 1}. ${items[index].title}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: const Icon(
                                Icons.arrow_forward_ios, color: Colors.black),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("No data available",
                        style: TextStyle(color: Colors.black)),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
