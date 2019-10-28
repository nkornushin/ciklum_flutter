class Todo {

  Todo(this._title, this.date, [this._description]);

  Todo.withId(this.id, this._title, this.date, [this._description]);

  // Extract a Note object from a Map object
	Todo.fromMapObject(Map<String, dynamic> map) {
		id = map['id'];
		_title = map['title'];
		_description = map['description'];
		date = map['date'];
	}

  int id;
  String _title;
  String _description;
  String date;

  String get title => _title;
  String get description => _description;

  set title(String title) {
    if(title.length <= 255) {
      _title = title;
    }
  }

  set description(String description) {
    if(description.length <= 255) {
      _description = description;
    }
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if(id != null) {
      map['id'] = id;
    }

    map['title'] = _title;
		map['description'] = _description;
		map['date'] = date;

    return map;
  }

}