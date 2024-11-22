import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panduan_puasa/page_home/model_home.dart';
import 'package:panduan_puasa/page_detail/detail_penjelasan_page.dart';
import 'package:panduan_puasa/page_ramadhan/page_ramadhan.dart';
import 'package:panduan_puasa/page_sunnah/page_sunnah.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<ModelHome> _allData = [];
  List<ModelHome> _filteredData = [];
  bool _isLoading = true;

  Future<void> fetchData() async {
    try {
      List<String> urls = [
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_arafah.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_asyura_dan_tasu\'a.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_ayyamul_bidh.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_daud.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_di_bulan_sya\'ban.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_dzulhijjah.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_senin_kamis.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_syawal.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_sunnah.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_ramadhan.json',
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/penjelasan_puasa.json',
      ];

      for (var url in urls) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final listData = json.decode(response.body) as List<dynamic>;
          _allData.addAll(listData.map((e) => ModelHome.fromJson(e)).toList());
        } else {
          throw Exception('Failed to load data from $url');
        }
      }

      setState(() {
        _filteredData = _allData; // Inisialisasi dengan semua data
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false; // Set loading ke false jika terjadi error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = []; // Set filteredData menjadi kosong jika query kosong
      } else {
        _filteredData = _allData.where((item) =>
        item.title!.toLowerCase().contains(query.toLowerCase()) ||
            item.description!.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _navigateToDetailPage(BuildContext context, ModelHome item) {
    String strTitle = item.title!;
    String strContent = item.description!;

    if (item.title == 'Puasa Ramadhan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RamadhanPage(strTitle: strTitle),
        ),
      );
    } else if (item.title == 'Puasa Sunnah') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SunnahPage(strTitle: strTitle),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPenjelasanPage(
            strTitle: strTitle,
            strContent: strContent,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pencarian"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _filterData(value),
              decoration: InputDecoration(
                hintText: "Cari...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : _filteredData.isNotEmpty // Hanya menampilkan daftar jika ada hasil pencarian
              ? Expanded(
            child: ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _navigateToDetailPage(context, _filteredData[index]),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        "${index + 1}. ${_filteredData[index].title}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              : const Center(
            child: Text("Tidak ada hasil"), // Menampilkan pesan jika tidak ada hasil
          ),
        ],
      ),
    );
  }
}
