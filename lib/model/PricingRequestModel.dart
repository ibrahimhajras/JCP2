class PricingRequestModel {
  final int remainingRequests;
  final String sectionTitle;
  final String description;
  final String costPerRequest;
  final String paymentNumber;

  PricingRequestModel({
    required this.remainingRequests,
    required this.sectionTitle,
    required this.description,
    required this.costPerRequest,
    required this.paymentNumber,
  });

  factory PricingRequestModel.fromJson(Map<String, dynamic> json) {
    return PricingRequestModel(
      remainingRequests: json['remainingRequests'],
      sectionTitle: json['sectionTitle'],
      description: json['description'],
      costPerRequest: json['costPerRequest'],
      paymentNumber: json['paymentNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remainingRequests': remainingRequests,
      'sectionTitle': sectionTitle,
      'description': description,
      'costPerRequest': costPerRequest,
      'paymentNumber': paymentNumber,
    };
  }
}
