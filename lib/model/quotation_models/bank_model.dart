class BankListModel {
  final List<BankModel>? data;
  final int? count;

  BankListModel({
    this.data,
    this.count,
  });

  factory BankListModel.fromJson(Map<String, dynamic> json) {
    return BankListModel(
      data: (json['data'] as List?)
          ?.map(
            (e) => BankModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

class BankModel {
  final int? id;
  final String? label;
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String? ifsc;
  final String? branch;

  BankModel({
    this.id,
    this.label,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.ifsc,
    this.branch,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'],
      label: json['label'],
      bankName: json['bank_name'],
      accountName: json['account_name'],
      accountNumber: json['account_number'],
      ifsc: json['ifsc'],
      branch: json['branch'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
      'ifsc': ifsc,
      'branch': branch,
    };
  }
}