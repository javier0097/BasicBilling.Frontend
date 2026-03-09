class Payment {
  final int id;
  final int billId;
  final double amount;
  final String paymentDate;
  final String? serviceType;
  final String? period;
  final String? status;

  Payment({
    required this.id,
    required this.billId,
    required this.amount,
    required this.paymentDate,
    this.serviceType,
    this.period,
    this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      billId: json['billId'] as int,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: json['paymentDate'] as String,
      serviceType: json['serviceType'] as String?,
      period: json['period'] as String?,
      status: json['status'] as String?,
    );
  }
}
