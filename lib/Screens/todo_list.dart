import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_sql_lite/Models/todo.dart';
import 'package:todo_list_sql_lite/Utilites/database_helper.dart';

class TodoList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
  
}

class TodoListState extends State<TodoList> {
  
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<Todo> todoList;
  int count = 0;
  final TextEditingController _textFieldController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    
    if(todoList == null) {
      todoList = <Todo>[];
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      body: getTodoListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          _addNewItem(context);
        },
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getTodoListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {

        final String item = todoList[position].id.toString();

        return Dismissible(
          key: Key(item),
          onDismissed: (direction) {
            _delete(context, todoList[position]);
          },
          child: itemCard(todoList[position]),
        );
        
        
      },
    );
  }

  Widget itemCard(Todo todo) {
    return Card(
        color: Colors.white,
        elevation: 2.0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.amber,
            child: Text(
              getFirstLetters(todo.title, lettersCount: 1), 
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          title: Text(todo.title, style: TextStyle(fontWeight: FontWeight.bold)),            
          subtitle: Text(todo.date),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Builder(
                builder: (context) => GestureDetector(
                  child: Icon(Icons.delete,color: Colors.red,),
                  onTap: () {
                    debugPrint('Delete Tapped');
                    _delete(context, todo);
                  },
                )
              ),
            ],
          ),
          onTap: () {
            debugPrint('ListTile Tapped');
          },
        ),
      );
  }

  Future<void> updateListView() async {
    final List<Todo> todoList = await databaseHelper.getTodoList();
    setState(() {
      this.todoList = todoList;
      count = todoList.length;
    });
  }

  String getFirstLetters(String title, {int lettersCount = 2}) {
    return title.substring(0, lettersCount);
  }

  Future<void> _delete(BuildContext context, Todo todo) async {
    final int result = await databaseHelper.deleteTodo(todo.id);
    if (result != 0) {
      _showSnackBar(context, 'Todo Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    Scaffold.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _addNewItem(BuildContext context) {
    showDialog<void> (
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Write new action todo'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: 'Todo action'),
          ),
          actions: <Widget>[
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  _textFieldController.clear();
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text('ADD'),
                onPressed: () async {
                  if(_textFieldController.text.isNotEmpty) {
                    final Todo newTodo = Todo(_textFieldController.text, DateFormat.yMMMd().format(DateTime.now()));
                    final int newTodoId  = await databaseHelper.insertTodo(newTodo);
                    newTodo.id = newTodoId;
                    setState(() {
                      todoList.add(newTodo);
                      count = todoList.length;
                    });
                    _textFieldController.clear();
                  }
                  Navigator.of(context).pop();
                },
              )
          ],
        );
      }
    );
  }

}