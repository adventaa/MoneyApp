import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:koin/pages/category_page.dart';
import 'package:koin/pages/home_page.dart';
import 'package:koin/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}): super(key: key);

  @override
  State <MainPage> createState() =>  _MainPageState();
}

class  _MainPageState extends State <MainPage> {
  late DateTime selectedDate;
  late List<Widget>_childeren;
  late int currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    updateView(0, DateTime.now());
    super.initState();
  }

  // untuk merubah tampilan utama sesuai dengan tanggal yang dipilih
  void updateView(int index, DateTime? date){
    setState(() {
      if (date != null){
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      currentIndex = index;
      _childeren = [
        HomePage(
          selectedDate: selectedDate, 
          ),
          CategoryPage()
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // kondisi ketika klik button home maka ada calender, jika klik button list maka calender hilang 
      appBar: (currentIndex == 0) ? CalendarAppBar(
        accent: Colors.blue,
        backButton: false,
        locale: 'id',
        onDateChanged: (value){
          // agar main page terupdate sesuai dengan tanggal yang dipilih
          setState(() {
            selectedDate = value;
            updateView(0, selectedDate);
          });
        },
        firstDate: DateTime.now().subtract(Duration(days: 140)),
        lastDate: DateTime.now(),
      ) 
      : PreferredSize(
          child: Container(child : Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            child: Text('Categories', 
              style: GoogleFonts.montserrat(fontSize: 20)),
          )), 
           preferredSize: Size.fromHeight(100)) ,

      floatingActionButton: Visibility(
        // kondisi ketika klik button home maka ada button add, jika klik button list maka button add hilang
        visible: (currentIndex == 0) ? true : false,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (context) => TransactionPage(transactionWithCategory: null,),
              ))
              .then((value){
                setState(() {});
              });
          }, 
          backgroundColor: Colors.blue, 
          child: Icon(Icons.add),
        ),
      ),

      body: _childeren[currentIndex],
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: 
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            onPressed: () {
              updateView(0, DateTime.now());
          }, 
          icon: Icon(Icons.home)),
          SizedBox(
            width:20,
            ),
          IconButton(
            onPressed: () {
              updateView(1, null);
          }, icon: Icon(Icons.list))
        ]),
      ));
  }
}

// index 0 = home page, index 1 = category page