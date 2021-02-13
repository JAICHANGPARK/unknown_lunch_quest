class Record {
  final String date;
  final int total;
  final List<String> users;
  final bool isClosed;
  final int used; // 사용된 티켓 수량
  final int leftTicket; // 잔여 티켓 수량
  Record({this.date, this.total, this.users, this.isClosed, this.used, this.leftTicket});

  String getIndex(int index) {
    switch (index) {
      case 0:
        return date;
      case 1:
        return total.toString();
      case 2:
        return leftTicket == null ? "-" : leftTicket.toString();
      case 3:
        return users.toString();
    }
    return '';
  }
}