import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panduan_puasa/page_detail/detail_penjelasan_page.dart';
import 'package:panduan_puasa/page_ramadhan/model_ramadhan.dart';

class RamadhanPage extends StatefulWidget {
  final String strTitle;

  const RamadhanPage({super.key, required this.strTitle});

  @override
  State<RamadhanPage> createState() => DetailRamadhanState();
}

class DetailRamadhanState extends State<RamadhanPage> {
  String? strTitle;

  @override
  void initState() {
    super.initState();
    strTitle = widget.strTitle;
  }

  // Method to fetch data from API
  Future<List<ModelRamadhan>> fetchData() async {
    final response = await http.get(
      Uri.parse('https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_ramadhan.json'),
    );
    final listData = json.decode(response.body) as List<dynamic>;
    return listData.map((e) => ModelRamadhan.fromJson(e)).toList();
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
          strTitle ?? 'Detail Ramadhan',
          maxLines: 2,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  );
                } else if (snapshot.hasData) {
                  var items = snapshot.data as List<ModelRamadhan>;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPenjelasanPage(
                                strTitle: items[index].title ?? 'No Title',
                                strContent: items[index].description ?? 'No Description',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              "${index + 1}. ${items[index].title ?? 'No Title'}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.black),
                    ),
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
