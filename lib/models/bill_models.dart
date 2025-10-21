class ConsumerDetails {
  final String name;
  final String consumerNo;
  final String address;
  final String mobile;
  final String purpose;

  ConsumerDetails({
    required this.name,
    required this.consumerNo,
    required this.address,
    required this.mobile,
    required this.purpose,
  });

  factory ConsumerDetails.fromJson(Map<String, dynamic> json) {
    return ConsumerDetails(
      name: json['name'] ?? '',
      consumerNo: json['consumerNo'] ?? '',
      address: json['address'] ?? '',
      mobile: json['mobile'] ?? '',
      purpose: json['purpose'] ?? '',
    );
  }
}

class MonthlyData {
  final String billMonth;
  final String consumption;

  MonthlyData({required this.billMonth, required this.consumption});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      billMonth: json['billMonth'] ?? '',
      consumption: json['consumption'] ?? '0',
    );
  }
}

class BillAnalysis {
  final int totalBills;
  final List<MonthlyData> last6MonthsData;
  final double averageConsumption;
  final double averageBill;
  final double totalConsumption;
  final double totalAmount;

  BillAnalysis({
    required this.totalBills,
    required this.last6MonthsData,
    required this.averageConsumption,
    required this.averageBill,
    required this.totalConsumption,
    required this.totalAmount,
  });

  factory BillAnalysis.fromJson(Map<String, dynamic> json) {
    return BillAnalysis(
      totalBills: json['totalBills'] ?? 0,
      last6MonthsData:
          (json['last6MonthsData'] as List<dynamic>?)
              ?.map((item) => MonthlyData.fromJson(item))
              .toList() ??
          [],
      averageConsumption: (json['averageConsumption'] ?? 0).toDouble(),
      averageBill: (json['averageBill'] ?? 0).toDouble(),
      totalConsumption: (json['totalConsumption'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class Savings {
  final double monthlyBillSavings;
  final double annualSavings;
  final double paybackPeriod;

  Savings({
    required this.monthlyBillSavings,
    required this.annualSavings,
    required this.paybackPeriod,
  });

  factory Savings.fromJson(Map<String, dynamic> json) {
    return Savings(
      monthlyBillSavings: (json['monthlyBillSavings'] ?? 0).toDouble(),
      annualSavings: (json['annualSavings'] ?? 0).toDouble(),
      paybackPeriod: (json['paybackPeriod'] ?? 0).toDouble(),
    );
  }
}

class SolarRecommendation {
  final double dailyRequirement;
  final double requiredSystemSize;
  final double recommendedSystemSize;
  final String reasonForRecommendation;
  final Savings savings;

  SolarRecommendation({
    required this.dailyRequirement,
    required this.requiredSystemSize,
    required this.recommendedSystemSize,
    required this.reasonForRecommendation,
    required this.savings,
  });

  factory SolarRecommendation.fromJson(Map<String, dynamic> json) {
    return SolarRecommendation(
      dailyRequirement: (json['dailyRequirement'] ?? 0).toDouble(),
      requiredSystemSize: (json['requiredSystemSize'] ?? 0).toDouble(),
      recommendedSystemSize: (json['recommendedSystemSize'] ?? 0).toDouble(),
      reasonForRecommendation: json['reasonForRecommendation'] ?? '',
      savings: Savings.fromJson(json['savings'] ?? {}),
    );
  }
}

class BillData {
  final ConsumerDetails consumerDetails;
  final BillAnalysis billAnalysis;
  final SolarRecommendation solarRecommendation;

  BillData({
    required this.consumerDetails,
    required this.billAnalysis,
    required this.solarRecommendation,
  });

  factory BillData.fromJson(Map<String, dynamic> json) {
    return BillData(
      consumerDetails: ConsumerDetails.fromJson(json['consumerDetails'] ?? {}),
      billAnalysis: BillAnalysis.fromJson(json['billAnalysis'] ?? {}),
      solarRecommendation: SolarRecommendation.fromJson(
        json['solarRecommendation'] ?? {},
      ),
    );
  }
}

class ApiResponse {
  final bool success;
  final BillData? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? BillData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}
