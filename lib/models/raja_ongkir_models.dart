class City {
  final int id;
  final String name;
  final String type;
  final String postalCode;
  final String province;
  final String label;
  final String cityName;
  final String districtName;
  final String subdistrictName;
  final String zipCode;
  final String provinceName;

  City({
    required this.id,
    required this.name,
    required this.type,
    required this.postalCode,
    required this.province,
    this.label = '',
    this.cityName = '',
    this.districtName = '',
    this.subdistrictName = '',
    this.zipCode = '',
    this.provinceName = '',
  });

  factory City.fromJson(Map<String, dynamic> json) {
    // Handle format respons dari API yang terlihat di gambar
    if (json.containsKey('label')) {
      return City(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['city_name'] ?? '',
        type: '',
        postalCode: json['zip_code'] ?? '',
        province: json['province_name'] ?? '',
        label: json['label'] ?? '',
        cityName: json['city_name'] ?? '',
        districtName: json['district_name'] ?? '',
        subdistrictName: json['subdistrict_name'] ?? '',
        zipCode: json['zip_code'] ?? '',
        provinceName: json['province_name'] ?? '',
      );
    }
    
    // Format lama tetap dipertahankan untuk kompatibilitas
    return City(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      postalCode: json['postal_code'] ?? '',
      province: json['province'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'postal_code': postalCode,
      'province': province,
      'label': label,
      'city_name': cityName,
      'district_name': districtName,
      'subdistrict_name': subdistrictName,
      'zip_code': zipCode,
      'province_name': provinceName,
    };
  }
}

class ShippingCost {
  final String code;
  final String name;
  final List<ShippingService> services;

  ShippingCost({
    required this.code,
    required this.name,
    required this.services,
  });

  factory ShippingCost.fromJson(Map<String, dynamic> json) {
    // Jika data sudah dalam format ShippingService (seperti pada response yang ditampilkan)
    if (json.containsKey('service') && json.containsKey('cost')) {
      return ShippingCost(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        services: [ShippingService.fromJson(json)],
      );
    }
    
    // Format normal dengan services sebagai array
    return ShippingCost(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      services: (json['services'] as List?)
          ?.map((service) => ShippingService.fromJson(service))
          .toList() ?? [],
    );
  }
}

class ShippingService {
  final String service;
  final String description;
  final int cost;
  final String etd;

  ShippingService({
    required this.service,
    required this.description,
    required this.cost,
    required this.etd,
  });

  factory ShippingService.fromJson(Map<String, dynamic> json) {
    // Format baru: cost dan etd langsung sebagai properti
    if (json.containsKey('cost')) {
      // Handle jika cost adalah int
      if (json['cost'] is int) {
        return ShippingService(
          service: json['service'] ?? '',
          description: json['description'] ?? '',
          cost: json['cost'],
          etd: json['etd']?.toString() ?? '',
        );
      } 
      // Handle jika cost adalah string
      else if (json['cost'] is String) {
        return ShippingService(
          service: json['service'] ?? '',
          description: json['description'] ?? '',
          cost: int.tryParse(json['cost']) ?? 0,
          etd: json['etd']?.toString() ?? '',
        );
      }
      // Handle jika cost adalah double
      else if (json['cost'] is double) {
        return ShippingService(
          service: json['service'] ?? '',
          description: json['description'] ?? '',
          cost: json['cost'].toInt(),
          etd: json['etd']?.toString() ?? '',
        );
      }
    }
    
    // Format lama: cost sebagai array dengan objek yang memiliki value dan etd
    if (json['cost'] is List) {
      final costData = json['cost'] as List;
      if (costData.isEmpty) {
        return ShippingService(
          service: json['service'] ?? '',
          description: json['description'] ?? '',
          cost: 0,
          etd: '',
        );
      }
      
      // Akses elemen pertama dengan pengecekan tipe yang lebih aman
      if (costData.isNotEmpty && costData.first is Map) {
        final costDetails = costData.first as Map;
        var costValue = 0;
        
        // Handle berbagai tipe data untuk 'value'
        if (costDetails['value'] is int) {
          costValue = costDetails['value'];
        } else if (costDetails['value'] is String) {
          costValue = int.tryParse(costDetails['value']) ?? 0;
        } else if (costDetails['value'] is double) {
          costValue = costDetails['value'].toInt();
        }
        
        return ShippingService(
          service: json['service'] ?? '',
          description: json['description'] ?? '',
          cost: costValue,
          etd: costDetails['etd']?.toString() ?? '',
        );
      }
    }
    
    // Fallback jika format tidak dikenali
    return ShippingService(
      service: json['service'] ?? '',
      description: json['description'] ?? '',
      cost: 0,
      etd: '',
    );
  }
}