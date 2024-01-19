import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koin/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // default berwarna merah
  bool isExpense = true;

  //tipe nya 2 yaitu pengeluaran atau expanse
  int type =2;

  final AppDb database = AppDb();

  // fungsi untuk controller 
  TextEditingController categoryNameController = TextEditingController();

  // untuk menambahkan isi di dalam box dialog
  Future insert (String name, int type) async{
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
      CategoriesCompanion.insert(
        name: name, type: type, createdAt: now, updatedAt: now));
    print('masuk :' + row.toString());
  }

  // fungsi untuk memanggil function yang sudah dibuat di database
  Future<List<Category>> getAllCategory(int type) async{
    return await database.getAllCategoryRepo(type);
  }

  Future update (int categoryId, String newName) async{
    return await database.updateCategoryRepo(categoryId, newName);
  }

  // box dialog ketika klik icon + 
  void openDialog(Category? category){

    // jika category = null maka tambah, jika tidak maka edit
    if (category != null){
      categoryNameController.text = category.name;
    }
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(
                    (isExpense) ? "Add Expense" : "Add Income", 
                    style: GoogleFonts.montserrat(
                      fontSize: 18, 
                      color: (isExpense) ? Colors.red : Colors.green),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: categoryNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Name"),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(onPressed: () {

                    // untuk menyimpan perubahan yang sudah di edit
                    if (category == null){
                      insert(
                        categoryNameController.text, isExpense ? 2 : 1);
                    }else{
                      update(category.id, categoryNameController.text);
                    }

                    // tipe variabel isExpanse jika true maka 2, jika false maka 1
                    insert(categoryNameController.text, isExpense ? 2 : 1);

                    // ketika klik save maka pop up akan hilang
                    Navigator.of(context, rootNavigator: true)
                      .pop('dialog');
                    setState(() {});

                    // setelah klik save maka inputan sebelumnya akan hilang di textbox
                    categoryNameController.clear();
                  }, 
                  child: Text("Save"))
                ],
              ),),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Switch(
              value: isExpense, 
              onChanged: (bool value){
                setState(() {
                  isExpense = value;
                  type = value ? 2 : 1;
                });
              }, 
              inactiveTrackColor: Colors.green[200], 
              inactiveThumbColor: Colors.green,
              activeColor: Colors.red,
              ),
              IconButton(
                onPressed: (){
                  openDialog(null);
                }, 
                icon:Icon(Icons.add))
          ],),
        ),

        FutureBuilder<List<Category>>(
          future : getAllCategory(type),
          builder : (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
                );
            }else {
              if (snapshot.hasData){
                if (snapshot.data!.length > 0){
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 10,
                          child: ListTile(
                            // jika isExpense false = income, jika true = expense
                            leading: (isExpense)
                                ? Icon(Icons.upload, color: Colors.red) 
                                : Icon(Icons.download, color: Colors.green),
                            title: Text(
                              snapshot.data![index].name
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () {
                                  database.deleteCategoryRepo(
                                    snapshot.data![index].id);
                                    setState(() {});
                                }, icon: Icon(Icons.delete)),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(onPressed: () {
                                  openDialog(snapshot.data![index]);
                                }, icon: Icon(Icons.edit))
                              ],
                            ),
                          ),
                        ),
                      );
                  });
                }else{
                  return Center(
                    child: Text("No has data"),
                  );
                }
              }else{
                return Center(
                  child: Text("No has data"),
                );
              }
            }
          }
        ),
      ],
    ));
  }
}