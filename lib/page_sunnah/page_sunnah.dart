import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panduan_puasa/page_detail/detail_sunnah_page.dart';
import 'package:panduan_puasa/page_sunnah/model_sunnah.dart';

class SunnahPage extends StatefulWidget {
  final String strTitle;

  const SunnahPage({super.key, required this.strTitle});

  @override
  State<SunnahPage> createState() => SunnahState();
}

class SunnahState extends State<SunnahPage> {
  String? strTitle;

  @override
  initState() {
    super.initState();
    strTitle = widget.strTitle;
  }

  // Method to get data from Firebase
  Future<List<ModelSunnah>> readJsonData() async {
    final response = await http.get(Uri.parse(
        'https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/puasa_sunnah.json'));

    if (response.statusCode == 200) {
      final listData = json.decode(response.body) as List<dynamic>;
      return listData.map((e) => ModelSunnah.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
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
          strTitle.toString(),
          maxLines: 2,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: readJsonData(),
              builder: (context, data) {
                if (data.hasError) {
                  return Center(child: Text("${data.error}"));
                } else if (data.hasData) {
                  var items = data.data as List<ModelSunnah>;
                  return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailSunnahPage(
                                    strTitle: items[index].title.toString()),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(
                                "${index + 1}. ${items[index].title}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.black),
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
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