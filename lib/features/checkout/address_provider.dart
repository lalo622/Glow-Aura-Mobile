import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../checkout/services/address_service.dart';

final addressServiceProvider = Provider<AddressService>((ref) => AddressService());