import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

String? _pendingLocation;

extension SafeNav on BuildContext {
  /// Oldinga o'tish: foydalanuvchi tugmani tez ikki marta bossa, bir xil sahifa
  /// ikki marta ochilmaydi (aks holda "orqaga" bir marta bosilganda o'sha sahifada qolardi).
  ///
  /// Ikki himoya: (1) navigatsiya hali ro'yxatga o'tmagan bo'lsa, shu kadr tugaguncha
  /// bir xil manzilga ikkinchi o'tish rad etiladi; (2) manzil allaqachon ochiq sahifa bo'lsa, rad etiladi.
  Future<T?> safePush<T extends Object?>(String location, {Object? extra}) {
    final router = GoRouter.of(this);
    final current = router.routerDelegate.currentConfiguration.uri.path;
    final target = Uri.parse(location).path;
    if (current == target || _pendingLocation == target) return Future<T?>.value(null);
    _pendingLocation = target;
    WidgetsBinding.instance.endOfFrame.then((_) => _pendingLocation = null);
    return router.push<T>(location, extra: extra);
  }
}
