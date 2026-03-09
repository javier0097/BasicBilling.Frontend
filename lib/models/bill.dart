class Bill {
  final int id;
  final int clientId;
  final String serviceType;
  final String period;
  final double amount;
  final String status;

  Bill({
    required this.id,
    required this.clientId,
    required this.serviceType,
    required this.period,
    required this.amount,
    required this.status,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as int,
      clientId: json['clientId'] as int,
      serviceType: json['serviceType'] as String,
      period: json['period'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}
