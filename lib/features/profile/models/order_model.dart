class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String statusDescription;
  final String paymentStatus;
  final double totalAmount;
  final int itemCount;
  final String paymentMethod;
  final DateTime createdAt;
  final String customerName;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusDescription,
    required this.paymentStatus,
    required this.totalAmount,
    required this.itemCount,
    required this.paymentMethod,
    required this.createdAt,
    required this.customerName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String? ?? '',
        orderNumber: json['orderNumber'] as String? ?? '',
        status: json['status'] as String? ?? '',
        statusDescription: json['statusDescription'] as String? ?? '',
        paymentStatus: json['paymentStatus'] as String? ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
        paymentMethod: json['paymentMethod'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        customerName: json['customerName'] as String? ?? '',
      );
}