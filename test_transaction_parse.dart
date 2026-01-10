// ignore_for_file: avoid_print
import 'dart:convert';

void main() {
  final jsonStr = '''
{
  "id": "86811a13-fe33-4727-98a9-287378a3bae6",
  "transactionCode": "TRX-20260108-UA81",
  "userId": "ae3b351b-bf4f-46e4-98ea-314e929def38",
  "subtotal": 23000,
  "tax": 2530,
  "discount": 0,
  "total": 25530,
  "status": "PAID",
  "paymentMethod": "CASH",
  "createdAt": "2026-01-08T04:10:36.909Z",
  "items": [
    {
      "id": "9d5e771b-7c4c-4cc8-9755-4136e422e0c1",
      "transactionId": "86811a13-fe33-4727-98a9-287378a3bae6",
      "productId": "0d598a60-ce70-4b21-bb74-e283f396e014",
      "productName": "Nasi Padang",
      "quantity": 1,
      "price": 23000,
      "category": "FOOD"
    }
  ],
  "user": {"id": "ae3b351b-bf4f-46e4-98ea-314e929def38", "name": "Admin User"}
}
''';

  try {
    final json = jsonDecode(jsonStr);
    print('Parsed JSON: $json');

    // Test extracting key fields
    print('id: ${json['id']}');
    print('transactionCode: ${json['transactionCode']}');
    print('total: ${json['total']}');
    print('items: ${json['items']}');
    print('items[0].productId: ${json['items'][0]['productId']}');
    print('items[0].productName: ${json['items'][0]['productName']}');
    print('items[0].quantity: ${json['items'][0]['quantity']}');
    print('items[0].price: ${json['items'][0]['price']}');
    print('items[0].category: ${json['items'][0]['category']}');

    print('\n✅ All fields parsed successfully!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
