import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:koin/models/database.dart';
import 'package:koin/models/transaction_with_category.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory ? transactionWithCategory;
  const TransactionPage({Key? key, required this.transactionWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDb database = AppDb();
  bool isExpense = true;
  late int type;
  List<String> list = ['Makan dan Jajan', 'Nonton'];
  late String dropDownValue = list.first;
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  // untuk memilih isi dari menu dropdown
  Category? selectedCategory;

  // untuk menambahkan isi
  Future insert(int amount, DateTime date, String nameDetail, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
      TransactionsCompanion.insert(
        name: nameDetail,
        category_id: categoryId,
        transcation_date: date,
        amount: amount,
        createdAt: now,
        updatedAt: now));
  print('add data lagi : ' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async{
    return await database.getAllCategoryRepo(type);
  }

  Future update (int transactionId, int amount, int categoryId, DateTime transactionDate, String nameDetail) async{
    return await database.updateTransactionRepo(
      transactionId, amount, categoryId, transactionDate, nameDetail );
  }

  @override
  void initState(){
    if (widget.transactionWithCategory != null){
      updateTransactionView(widget.transactionWithCategory!);
    } else{
      type = 2;
    }
    super.initState();
  }

  // untuk menampilkan isi - isi transaksi jika di klik edit pada menu homepage
  void updateTransactionView (TransactionWithCategory transactionWithCategory){
    amountController.text = 
      transactionWithCategory.transaction.amount.toString(); 
    detailController.text =
      transactionWithCategory.transaction.name;
    dateController.text =
      DateFormat("yyyy-MM-dd").format(transactionWithCategory.transaction.transcation_date);
    type = transactionWithCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            children: [
            Switch(
              value: isExpense, 
              onChanged: (bool value){
                setState(() {
                  isExpense = value;
                  type = (isExpense) ? 2 : 1;
                  selectedCategory = null;
                });
              }, 
              inactiveTrackColor: Colors.green[200], 
              inactiveThumbColor: Colors.green,
              activeColor: Colors.red,
              ),
              Text(
                isExpense ? 'Expanse' : 'Income', 
                style : GoogleFonts.montserrat(fontSize: 14),
              )
            ],
          ),

          // untuk membuat inputan text 
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: UnderlineInputBorder(), labelText: "Amount"),
            ),
          ),

          // untuk membuat text category
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Category', 
              style : GoogleFonts.montserrat(fontSize: 16),
            ),
          ),

          FutureBuilder<List<Category>>(
            future: getAllCategory(type),
            builder:(context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }else{
                if (snapshot.hasData){
                  if (snapshot.data!.length > 0){
                    selectedCategory = (selectedCategory == null)
                       ? snapshot.data!.first
                       : selectedCategory;
                    print('ada data : '+ snapshot.toString());
                    // untuk membuat tampilan menu drpodown button
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal : 16),
                      child: DropdownButton<Category>(

                        // untuk menampilkan category sesuai pilihan di menu dropdown 
                        value : (selectedCategory == null) 
                            ? snapshot.data!.first 
                            : selectedCategory,
                        isExpanded: true,
                        icon : Icon(Icons.arrow_downward),
                        items: snapshot.data!.map((Category item){
                          return DropdownMenuItem<Category>(
                            value: item,
                            child: Text(item.name),
                          );
                        }).toList(),
                      onChanged: (Category? value){
                        setState(() {
                          selectedCategory = value;
                        });
                        selectedCategory = value;
                      }),
                    );
                  }else{
                    return Center(
                      child: Text("Data kosong"),
                    );
                  }
                }else{
                  return Center(
                    child: Text("Tidak ada data"),
                  );
                }
              }
            }),

          // untuk membuat input date
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              readOnly: true,
              controller: dateController,
              decoration: InputDecoration(labelText: "Enter Date"),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(), 
                  firstDate: DateTime(2020), 
                  lastDate: DateTime(2099));
            
                if(pickedDate != null){
                  String formattedDate = 
                    DateFormat('yyyy-MM-dd').format(pickedDate);
            
                  dateController.text = formattedDate;
                }
              },
            ),
          ),

          // untuk text detail
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: detailController,
              decoration: InputDecoration(
                border: UnderlineInputBorder(), labelText: "Deskripsi"),
            ),
          ),

          // untuk membuat tombol save
          SizedBox(height: 25),
          Center(child: ElevatedButton(
            onPressed: () async {
              (widget.transactionWithCategory == null) 
                  ? insert(
                    int.parse(amountController.text),
                    DateTime.parse(dateController.text),
                    detailController.text,
                    selectedCategory!.id) 
                  : await update(
                    widget.transactionWithCategory!.transaction.id,
                    int.parse(amountController.text),
                    selectedCategory!.id,
                    DateTime.parse(dateController.text),
                    detailController.text);

            // untuk kembali ke halaman utama setelah save
            Navigator.pop(context, true);
          },
          child: Text("Save")))
        ],
      ))),
    );
  }
}