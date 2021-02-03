class Record {
  final String date;
  final int total;
  final List<String> users;
  final bool isClosed;

  Record({this.date, this.total, this.users, this.isClosed});

  String getIndex(int index) {
    switch (index) {
      case 0:
        return date;
      case 1:
        return total.toString();
      case 2:
        return users.toString();
    }
    return '';
  }
}