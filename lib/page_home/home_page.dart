import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panduan_puasa/page_detail/detail_penjelasan_page.dart';
import 'package:panduan_puasa/page_ramadhan/page_ramadhan.dart';
import 'package:panduan_puasa/page_sunnah/page_sunnah.dart';
import 'package:panduan_puasa/profil/profile_page.dart';
import 'package:panduan_puasa/search/search_page.dart';
import 'model_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const ProfilePage(),
    const SearchPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Panduan Puasa",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Pencarian",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // Mengambil data dari URL API
  Future<List<ModelHome>> fetchData() async {
    final response = await http.get(Uri.parse('https://puasa-broo-default-rtdb.asia-southeast1.firebasedatabase.app/penjelasan_puasa.json'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((data) => ModelHome.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const Image(
                height: 220,
                image: AssetImage('assets/images/pic_puasa.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 0, 10),
            child: Text(
              "Penjelasan Puasa",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          FutureBuilder(
            future: fetchData(),
            builder: (context, data) {
              if (data.hasError) {
                return Center(
                  child: Text("${data.error}"),
                );
              } else if (data.hasData) {
                var items = data.data as List<ModelHome>;
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        String strTitle = items[index].title ?? '';
                        String strContent = items[index].description ?? '';

                        if (items[index].title == 'Puasa Ramadhan') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RamadhanPage(
                                strTitle: strTitle,
                              ),
                            ),
                          );
                        } else if (items[index].title == 'Puasa Sunnah') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SunnahPage(
                                strTitle: strTitle,
                              ),
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
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            "${index + 1}. ${items[index].title}",
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
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
