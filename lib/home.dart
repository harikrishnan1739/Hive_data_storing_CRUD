import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //------------------------------------Controllers---------------------
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quatityController = TextEditingController();
  //----------------------------------------item-stored-type--------
  List<Map<String, dynamic>> _items = [];
//----------------------------------------##---------------------------------------------start---------
//--------------------------------------------------initilize------------------------------------------
  final _shoppingBox = Hive.box('shoping_box');
  //----------------------------------_refreshItems--------------------
  void _refreshItems() {
    // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
    final data = _shoppingBox.keys.map((Key) {
      final item = _shoppingBox.get(Key);
      return {"key": Key, "name": item['name'], "quantity": item['quantity']};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
    });
  }

  //-------------------------create new item---------------------------
  Future<void> _createitem(Map<String, dynamic> newitem) async {
    await _shoppingBox.add(newitem);
    _refreshItems();
  }

  // ---------------------------------Update item----------------------
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItems();
  }

  //---------------------------------delete item-----------------------
  Future<void> _deleteitem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();
  }

//---------------------------------------##----------------------------------------------end----------
  void _showForm(BuildContext ctx, int? itemKey) async {
    //-----------validation-----------
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _quatityController.text = existingItem['quantity'];
    }
    //---------validation-end---------

    //-----------------------model-showModalBottomSheet-------------
    showModalBottomSheet(
      //-----------Bottomsheet shape-----------
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      //----------------------------------------
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15),
//-----------------------------------------------------------
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //------------TextFormField------
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0)),
              ),
            ),
            //------------TextFormField------end--
            const SizedBox(
              height: 10,
            ),
            //------------TextFormField------
            TextField(
              controller: _quatityController,
              decoration: InputDecoration(
                hintText: 'Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
            //------------TextFormField------end--
            const SizedBox(
              height: 10,
            ),
            //----------------------------ElevatedButton-------------------Create--/--Update------
            FloatingActionButton.extended(
              elevation: 10,
              label:
                  Text(itemKey == null ? 'Create new' : 'Update'), // <-- Text
              backgroundColor: const Color.fromARGB(255, 122, 33, 247),
              icon: const Icon(
                Icons.check,
                size: 24.0,
              ),
              onPressed: () async {
                if (itemKey == null) {
                  _createitem({
                    "name": _nameController.text,
                    "quantity": _quatityController.text
                  });
                }
                if (itemKey != null) {
                  _updateItem(itemKey, {
                    "name": _nameController.text.trim(),
                    "quantity": _quatityController.text.trim(),
                  });
                }
                _nameController.text = '';
                _quatityController.text = '';
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            //----------------------------End------------------------------------create--/--Update----
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 224, 253),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 103, 21, 236),
        title: const Center(
            child: Text(
          'Hive',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        )),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final currentItem = _items[index];
          return Card(
            color: const Color.fromARGB(255, 206, 186, 239),
            margin: const EdgeInsets.all(14),
            elevation: 3,
            child: ListTile(
              title: Text(currentItem['name']),
              subtitle: Text(currentItem['quantity'].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //---------------- Edit button--------------
                  IconButton(
                      onPressed: () => _showForm(context, currentItem['key']),
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 19, 110, 255),
                      )),
                  //----------------- Delete button-------------
                  IconButton(
                      onPressed: () => _deleteitem(currentItem['key']),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ))
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 98, 0, 255),
        elevation: 10,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        // ignore: avoid_returning_null_for_void
        onPressed: () => _showForm(context, null),
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}
