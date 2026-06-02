import 'dart:convert';

void main() {
  String jsonString = '''{
    "status": true,
    "message": "Successfully fetched seats!",
    "data": {
      "_id": "6a0566848ebd7314d3e82ac2",
      "tripId": "6a0566848ebd7314d3e82abf",
      "seata": [
        {
          "seatNo": "A1",
          "booked": false,
          "bookedBy": null,
          "bookedAt": null,
          "seatClass": "window",
          "blockedFor": "none"
        }
      ],
      "seatb": [],
      "seatc": [],
      "createdAt": "2026-05-14T06:07:00.312Z",
      "updatedAt": "2026-05-14T06:07:00.312Z",
      "__v": 0
    }
  }''';

  final jsonMap = jsonDecode(jsonString);
  try {
    final status = jsonMap['status'] as bool;
    final message = jsonMap['message'] as String;
    final data = jsonMap['data'];
    
    final id = data['_id'] as String;
    final tripId = data['tripId'] as String;
    
    final seata = (data['seata'] as List?)?.map((item) {
      return item['seatNo'] as String;
    }).toList();
    
    final v = data['__v'] as int;
    print("Success: id=$id, v=$v, seata=$seata");
  } catch (e) {
    print("Error: $e");
  }
}
