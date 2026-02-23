import 'user.dart';

class Ticket {
  final int id;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String ticketType;
  final String createdAt;
  final String updatedAt;
  final double otherCost;
  final String? notes;
  final int? areaId;
  final int? assignedTo;
  final int? createdBy;
  
  // Relations (only in detail view)
  final User? creator;
  final User? assignee;
  final Area? area;
  final List<Tag> tags;
  final List<TicketAttachment> attachments;
  final List<TicketComment> comments;
  final List<ResolutionNote> resolutionNotes;

  Ticket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.ticketType,
    required this.createdAt,
    required this.updatedAt,
    required this.otherCost,
    this.notes,
    this.areaId,
    this.assignedTo,
    this.createdBy,
    this.creator,
    this.assignee,
    this.area,
    this.tags = const [],
    this.attachments = const [],
    this.comments = const [],
    this.resolutionNotes = const [],
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    
    return Ticket(
      id: parseInt(json['id']) ?? 0,
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'normal',
      ticketType: json['ticket_type'] ?? 'hotel',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      otherCost: (json['other_cost'] is num) 
          ? (json['other_cost'] as num).toDouble()
          : (double.tryParse(json['other_cost']?.toString() ?? '0') ?? 0.0),
      notes: json['notes'],
      areaId: parseInt(json['area_id']),
      assignedTo: parseInt(json['assigned_to']),
      createdBy: parseInt(json['created_by']),
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      assignee: json['assignee'] != null ? User.fromJson(json['assignee']) : null,
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      tags: json['tags'] != null 
          ? (json['tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : [],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List).map((a) => TicketAttachment.fromJson(a)).toList()
          : [],
      comments: json['comments'] != null
          ? (json['comments'] as List).map((c) => TicketComment.fromJson(c)).toList()
          : [],
      resolutionNotes: json['resolution_notes'] != null
          ? (json['resolution_notes'] as List).map((r) => ResolutionNote.fromJson(r)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'ticket_type': ticketType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'other_cost': otherCost,
      'notes': notes,
      'area_id': areaId,
      'assigned_to': assignedTo,
      'created_by': createdBy,
    };
  }
}

class Area {
  final int id;
  final String name;
  final String fullPath;

  Area({
    required this.id,
    required this.name,
    required this.fullPath,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return Area(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      fullPath: json['full_path'] ?? json['name'] ?? '',
    );
  }
}

class Tag {
  final int id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return Tag(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
    );
  }
}

class TicketAttachment {
  final int id;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String uploadedAt;
  final User? uploader;

  TicketAttachment({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
    this.uploader,
  });

  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return TicketAttachment(
      id: parseInt(json['id']),
      fileName: json['file_name'] ?? '',
      fileSize: parseInt(json['file_size']),
      mimeType: json['mime_type'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      uploader: json['uploader'] != null ? User.fromJson(json['uploader']) : null,
    );
  }
}

class TicketComment {
  final int id;
  final String body;
  final String createdAt;
  final User? user;

  TicketComment({
    required this.id,
    required this.body,
    required this.createdAt,
    this.user,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return TicketComment(
      id: parseInt(json['id']),
      body: json['body'] ?? '',
      createdAt: json['created_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class ResolutionNote {
  final int id;
  final String note;
  final String? previousStatus;
  final String createdAt;
  final User? user;

  ResolutionNote({
    required this.id,
    required this.note,
    this.previousStatus,
    required this.createdAt,
    this.user,
  });

  factory ResolutionNote.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return ResolutionNote(
      id: parseInt(json['id']),
      note: json['note'] ?? '',
      previousStatus: json['previous_status'],
      createdAt: json['created_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
