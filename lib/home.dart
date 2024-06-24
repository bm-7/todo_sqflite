import 'package:flutter/material.dart';
import 'package:todo_sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> journels = [];
  bool isloading = true;

  final titlec = TextEditingController();
  final desc = TextEditingController();

  void refreashJournels() async {
    final data = await SqfliteHelper.getiteams();
    setState(() {
      journels = data;
      isloading = false;
    });
  }

  Future<void> update(int id) async {
    await SqfliteHelper.Update(id, titlec.text, desc.text);
    refreashJournels();
  }

  Future<void> Delete(int id) async {
    await SqfliteHelper.deleteitem(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Successfully Deleted")));
    refreashJournels();
  }

  @override
  void initState() {
    super.initState();
    refreashJournels();
    print(journels.length);
  }

  Future<void> additem() async {
    await SqfliteHelper.createiteams(titlec.text, desc.text);
    refreashJournels();
  }

  void showForm(int? id) async {
    if (id != null) {
      final existingdata =
          journels.firstWhere((element) => element["id"] == id);
      titlec.text = existingdata["title"];
      desc.text = existingdata["description"];
    } else {
      titlec.clear();
      desc.clear();
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titlec,
              decoration: const InputDecoration(hintText: "title"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: desc,
              decoration: const InputDecoration(hintText: "description"),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await additem();
                } else {
                  await update(id);
                }

                titlec.text = "";
                desc.text = "";
                Navigator.pop(context);
              },
              child: Text(id == null ? "Create new" : "Update"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(null),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("SQL"),
      ),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: journels.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.orange.shade50,
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: Text(journels[index]["title"]),
                    subtitle: Text(journels[index]["description"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => showForm(journels[index]["id"]),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => Delete(journels[index]["id"]),
                          icon: const Icon(Icons.delete),
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
