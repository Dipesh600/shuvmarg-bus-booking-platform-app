class SeatResponse {
  final bool status;
  final String message;
  final SeatData? data;

  SeatResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SeatResponse.fromJson(Map<String, dynamic> json) {
    return SeatResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? SeatData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class SeatData {
  final String id;
  final String tripId;
  final List<Seat> seata;
  final List<Seat> seatb;
  final List<Seat> seatc;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int v;
  final SeatConfig? seatConfig;

  SeatData({
    required this.id,
    required this.tripId,
    required this.seata,
    required this.seatb,
    required this.seatc,
    this.createdAt,
    this.updatedAt,
    required this.v,
    this.seatConfig,
  });

  factory SeatData.fromJson(Map<String, dynamic> json) {
    return SeatData(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      seata: (json['seata'] as List?)
              ?.where((item) => item != null)
              .map((item) => Seat.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      seatb: (json['seatb'] as List?)
              ?.where((item) => item != null)
              .map((item) => Seat.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      seatc: (json['seatc'] as List?)
              ?.where((item) => item != null)
              .map((item) => Seat.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      v: (json['__v'] ?? 0) is num ? (json['__v'] as num).toInt() : int.tryParse(json['__v']?.toString() ?? '0') ?? 0,
      seatConfig: json['seatConfig'] != null ? SeatConfig.fromJson(json['seatConfig']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tripId': tripId,
      'seata': seata.map((item) => item.toJson()).toList(),
      'seatb': seatb.map((item) => item.toJson()).toList(),
      'seatc': seatc.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
      'seatConfig': seatConfig?.toJson(),
    };
  }
}

class Seat {
  final String seatNo;
  final bool booked;
  final String? bookedBy;
  final DateTime? bookedAt;

  Seat({
    required this.seatNo,
    required this.booked,
    this.bookedBy,
    this.bookedAt,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatNo: json['seatNo']?.toString() ?? '',
      booked: json['booked'] == true || json['booked'] == 'true',
      bookedBy: json['bookedBy']?.toString(),
      bookedAt: json['bookedAt'] != null
          ? DateTime.tryParse(json['bookedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatNo': seatNo,
      'booked': booked,
      'bookedBy': bookedBy,
      'bookedAt': bookedAt?.toIso8601String(),
    };
  }
}

class SeatConfig {
  final String busShape;
  final String layoutVariant;
  final bool hasKaKha;
  final int totalColumns;
  final List<BusFloor> floors;

  SeatConfig({
    required this.busShape,
    required this.layoutVariant,
    required this.hasKaKha,
    required this.totalColumns,
    required this.floors,
  });

  factory SeatConfig.fromJson(Map<String, dynamic> json) {
    return SeatConfig(
      busShape: json['busShape']?.toString() ?? 'SINGLE_DECKER',
      layoutVariant: json['layoutVariant']?.toString() ?? '2x2',
      hasKaKha: json['hasKaKha'] == true || json['hasKaKha'] == 'true',
      totalColumns: json['totalColumns'] != null ? (json['totalColumns'] as num).toInt() : 5,
      floors: (json['floors'] as List?)
              ?.map((e) => BusFloor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busShape': busShape,
      'layoutVariant': layoutVariant,
      'hasKaKha': hasKaKha,
      'totalColumns': totalColumns,
      'floors': floors.map((e) => e.toJson()).toList(),
    };
  }
}

class BusFloor {
  final int floorIndex;
  final List<BusRow> rows;

  BusFloor({required this.floorIndex, required this.rows});

  factory BusFloor.fromJson(Map<String, dynamic> json) {
    return BusFloor(
      floorIndex: json['floorIndex'] != null ? (json['floorIndex'] as num).toInt() : 0,
      rows: (json['rows'] as List?)
              ?.map((e) => BusRow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'floorIndex': floorIndex,
      'rows': rows.map((e) => e.toJson()).toList(),
    };
  }
}

class BusRow {
  final int rowIndex;
  final String rowType;
  final String? rowLabel;
  final bool hasKaKha;
  final List<SeatCell> cells;

  BusRow({
    required this.rowIndex,
    required this.rowType,
    this.rowLabel,
    required this.hasKaKha,
    required this.cells,
  });

  factory BusRow.fromJson(Map<String, dynamic> json) {
    return BusRow(
      rowIndex: json['rowIndex'] != null ? (json['rowIndex'] as num).toInt() : 0,
      rowType: json['rowType']?.toString() ?? 'SEAT_ROW',
      rowLabel: json['rowLabel']?.toString(),
      hasKaKha: json['hasKaKha'] == true || json['hasKaKha'] == 'true',
      cells: (json['cells'] as List?)
              ?.map((e) => SeatCell.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rowIndex': rowIndex,
      'rowType': rowType,
      'rowLabel': rowLabel,
      'hasKaKha': hasKaKha,
      'cells': cells.map((e) => e.toJson()).toList(),
    };
  }
}

class SeatCell {
  final int colIndex;
  final String cellType;
  final String? seatId;
  final String? seatLabel;
  final String? labelScheme;
  final String seatType;
  final bool isActive;
  final String? zone;

  SeatCell({
    required this.colIndex,
    required this.cellType,
    this.seatId,
    this.seatLabel,
    this.labelScheme,
    required this.seatType,
    required this.isActive,
    this.zone,
  });

  factory SeatCell.fromJson(Map<String, dynamic> json) {
    return SeatCell(
      colIndex: json['colIndex'] != null ? (json['colIndex'] as num).toInt() : 0,
      cellType: json['cellType']?.toString() ?? 'SEAT',
      seatId: json['seatId']?.toString(),
      seatLabel: json['seatLabel']?.toString(),
      labelScheme: json['labelScheme']?.toString(),
      seatType: json['seatType']?.toString() ?? 'STANDARD',
      isActive: json['isActive'] != false && json['isActive'] != 'false',
      zone: json['zone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colIndex': colIndex,
      'cellType': cellType,
      'seatId': seatId,
      'seatLabel': seatLabel,
      'labelScheme': labelScheme,
      'seatType': seatType,
      'isActive': isActive,
      'zone': zone,
    };
  }
}
