class TicketRecord{

 final String ticket;
  final String datetime;

  TicketRecord({this.ticket, this.datetime});
}

class TicketUseRecord{

 final DateTime date;
 final int left;
 final int used;

 TicketUseRecord({this.date, this.left, this.used});
}