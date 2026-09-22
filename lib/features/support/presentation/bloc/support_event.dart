abstract class SupportEvent {}

class LoadTicketsEvent extends SupportEvent {
  final int userId;
  LoadTicketsEvent(this.userId);
}


class AddTicketEvent extends SupportEvent {
  final String title;
  final String body;
  final int userId;
  
  AddTicketEvent({
    required this.title, 
    required this.body, 
    required this.userId,
  });
}


class UpdateTicketEvent extends SupportEvent {
  final int ticketId;
  final String newTitle;
  final String newBody;
  
  UpdateTicketEvent({
    required this.ticketId, 
    required this.newTitle, 
    required this.newBody,
  });
}

class DeleteTicketEvent extends SupportEvent {
  final int ticketId;
  DeleteTicketEvent(this.ticketId);
}

class LoadTicketCommentsEvent extends SupportEvent {
  final int ticketId;
  LoadTicketCommentsEvent(this.ticketId);
}

class ChangeTicketStatusEvent extends SupportEvent {
  final int ticketId;
  final String newStatus;
  ChangeTicketStatusEvent(this.ticketId, this.newStatus);
}


class AddCommentEvent extends SupportEvent {
  final String body;
  final int ticketId;
  final int userId;
  
  AddCommentEvent({
    required this.body, 
    required this.ticketId, 
    required this.userId,
  });
}


class UpdateCommentEvent extends SupportEvent {
  final int ticketId;
  final int commentId;
  final String newBody;
  
  UpdateCommentEvent({
    required this.ticketId, 
    required this.commentId, 
    required this.newBody,
  });
}


class DeleteCommentEvent extends SupportEvent {
  final int ticketId;
  final int commentId;
  
  DeleteCommentEvent({
    required this.ticketId, 
    required this.commentId,
  });
}