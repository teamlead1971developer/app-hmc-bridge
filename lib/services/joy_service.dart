import 'package:flutter/foundation.dart';

import '../models/joy_coupon.dart';
import '../models/joy_member.dart';
import '../models/joy_point_transaction.dart';
import '../models/joy_privilege.dart';
import 'user_service.dart';

/// The Joy loyalty programme — member card, privileges, and coupons.
// TODO: replace mock data with loyalty API.
class JoyService extends ChangeNotifier {
  JoyService._();

  static final instance = JoyService._();

  static const couponTags = [
    JoyCouponTag(id: 'all', label: 'All'),
    JoyCouponTag(id: 'store', label: 'Store'),
    JoyCouponTag(id: 'cafe', label: 'Café'),
    JoyCouponTag(id: 'partner', label: 'Partner'),
  ];

  JoyMember? _member;
  final List<JoyPrivilege> _privileges = [];
  final List<JoyCoupon> _coupons = [];
  final List<JoyPointTransaction> _pointTransactions = [];
  bool _loaded = false;

  JoyMember? get member => _member;
  bool get isLoaded => _loaded;

  List<JoyPrivilege> privileges({JoyPrivilegeStatus? status}) {
    final items = List<JoyPrivilege>.from(_privileges);
    if (status != null) {
      return items.where((p) => p.status == status).toList();
    }
    return items;
  }

  List<JoyPrivilege> get availablePrivileges =>
      privileges(status: JoyPrivilegeStatus.available);

  List<JoyPrivilege> get inactivePrivileges => _privileges
      .where(
        (p) =>
            p.status == JoyPrivilegeStatus.expired ||
            p.status == JoyPrivilegeStatus.used,
      )
      .toList();

  List<JoyCoupon> coupons({String? tagId, JoyCouponStatus? status}) {
    var items = List<JoyCoupon>.from(_coupons);
    if (tagId != null && tagId != 'all') {
      items = items.where((c) => c.tagId == tagId).toList();
    }
    if (status != null) {
      items = items.where((c) => c.status == status).toList();
    }
    return items;
  }

  JoyPrivilege? privilegeById(String id) {
    for (final item in _privileges) {
      if (item.id == id) return item;
    }
    return null;
  }

  JoyCoupon? couponById(String id) {
    for (final item in _coupons) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<JoyPointTransaction> pointTransactions({
    required int year,
    int? month,
    JoyPointTransactionType? type,
  }) {
    final items = _pointTransactions.where((item) {
      if (item.date.year != year) return false;
      if (month != null && item.date.month != month) return false;
      if (type != null && item.type != type) return false;
      return true;
    }).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final user = await UserService.instance.fetchCurrentUser();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final prevMonthEnd = DateTime(now.year, now.month, 0);
    final twoMonthsAgoStart = DateTime(now.year, now.month - 2, 1);
    final twoMonthsAgoEnd = DateTime(now.year, now.month - 1, 0);
    final threeMonthsAgoStart = DateTime(now.year, now.month - 3, 1);
    final threeMonthsAgoEnd = DateTime(now.year, now.month - 2, 0);

    _member = JoyMember(
      memberId: 'JOY-${user.employeeId}',
      name: user.name,
      nickname: user.nickname,
      tel: user.phone,
      email: user.email,
      birthday: DateTime(1992, 5, 18),
      tier: JoyStaffTier.staff3,
      pointBalance: 2480,
      expiringPoints: 320,
      expiringPointsDate: DateTime(now.year, 12, 31),
      memberCode: 'JOY${user.employeeId.replaceAll('-', '')}',
      since: DateTime(2024, 3, 15),
    );

    _privileges.addAll([
      JoyPrivilege(
        id: 'priv-1',
        name: '20% Discount Coupon',
        code: 'JOY-STAFF-20-A-${now.month}${now.year}',
        status: JoyPrivilegeStatus.available,
        validFrom: monthStart,
        validUntil: monthEnd,
        summary: 'One-time staff discount at participating stores.',
        conditions: const [
          'Valid at BRIDGE-affiliated storefronts only.',
          'Present member code or QR at checkout.',
          'Cannot be combined with other promotions.',
          'One redemption per coupon.',
        ],
      ),
      JoyPrivilege(
        id: 'priv-2',
        name: '20% Discount Coupon',
        code: 'JOY-STAFF-20-B-${now.month}${now.year}',
        status: JoyPrivilegeStatus.available,
        validFrom: monthStart,
        validUntil: monthEnd,
        summary: 'Second monthly staff discount entitlement.',
        conditions: const [
          'Valid at BRIDGE-affiliated storefronts only.',
          'Present member code or QR at checkout.',
          'Cannot be combined with other promotions.',
          'One redemption per coupon.',
        ],
      ),
      JoyPrivilege(
        id: 'priv-3',
        name: '20% Discount Coupon',
        code: 'JOY-STAFF-20-A-${prevMonthStart.month}${prevMonthStart.year}',
        status: JoyPrivilegeStatus.used,
        validFrom: prevMonthStart,
        validUntil: prevMonthEnd,
        usedAt: DateTime(prevMonthStart.year, prevMonthStart.month, 18),
        summary: 'Redeemed at BRIDGE HQ café.',
        conditions: const [
          'Valid at BRIDGE-affiliated storefronts only.',
          'Present member code or QR at checkout.',
        ],
      ),
      JoyPrivilege(
        id: 'priv-4',
        name: '20% Discount Coupon',
        code: 'JOY-STAFF-20-B-${twoMonthsAgoStart.month}${twoMonthsAgoStart.year}',
        status: JoyPrivilegeStatus.expired,
        validFrom: twoMonthsAgoStart,
        validUntil: twoMonthsAgoEnd,
        summary: 'Expired without redemption.',
        conditions: const [
          'Valid at BRIDGE-affiliated storefronts only.',
          'Present member code or QR at checkout.',
        ],
      ),
    ]);

    _coupons.addAll([
      JoyCoupon(
        id: 'cpn-1',
        name: 'Free drip coffee',
        code: 'JOY-CAFE-DRIP-01',
        status: JoyCouponStatus.available,
        tagId: 'cafe',
        validFrom: monthStart,
        validUntil: monthEnd,
        summary: 'One complimentary drip coffee.',
        conditions: const [
          'Valid at The Joy café counters.',
          'One drink per voucher.',
          'Not valid on bottled or retail items.',
        ],
      ),
      JoyCoupon(
        id: 'cpn-2',
        name: '฿100 store voucher',
        code: 'JOY-STORE-100-02',
        status: JoyCouponStatus.available,
        tagId: 'store',
        validFrom: monthStart,
        validUntil: monthEnd,
        summary: 'Spend at participating lifestyle stores.',
        conditions: const [
          'Minimum spend ฿500 before discount.',
          'Single use only.',
          'Change not given on unused value.',
        ],
      ),
      JoyCoupon(
        id: 'cpn-3',
        name: 'Partner spa 15% off',
        code: 'JOY-PARTNER-SPA-03',
        status: JoyCouponStatus.available,
        tagId: 'partner',
        validFrom: monthStart,
        validUntil: DateTime(now.year, now.month + 2, 0),
        summary: 'Wellness partner offer.',
        conditions: const [
          'Advance booking required.',
          'Valid Monday–Thursday only.',
          'Show voucher code at reception.',
        ],
      ),
      JoyCoupon(
        id: 'cpn-4',
        name: 'Birthday pastry',
        code: 'JOY-CAFE-PAST-04',
        status: JoyCouponStatus.used,
        tagId: 'cafe',
        validFrom: prevMonthStart,
        validUntil: monthEnd,
        usedAt: DateTime(now.year, now.month, 2),
        conditions: const [
          'Valid during birthday month.',
          'One pastry per member.',
        ],
      ),
      JoyCoupon(
        id: 'cpn-5',
        name: 'Seasonal tote bag',
        code: 'JOY-STORE-TOTE-05',
        status: JoyCouponStatus.expired,
        tagId: 'store',
        validFrom: threeMonthsAgoStart,
        validUntil: threeMonthsAgoEnd,
        conditions: const [
          'While stocks last.',
          'Collect at BRIDGE HQ store desk.',
        ],
      ),
    ]);

    _pointTransactions.addAll([
      JoyPointTransaction(
        id: 'pt-1',
        type: JoyPointTransactionType.earn,
        points: 120,
        date: DateTime(now.year, now.month, 4),
        description: 'Store purchase — Siam Paragon',
      ),
      JoyPointTransaction(
        id: 'pt-2',
        type: JoyPointTransactionType.burn,
        points: 80,
        date: DateTime(now.year, now.month, 6),
        description: 'Coupon redemption — Café pastry',
      ),
      JoyPointTransaction(
        id: 'pt-3',
        type: JoyPointTransactionType.earn,
        points: 50,
        date: DateTime(now.year, now.month, 12),
        description: 'Monthly staff bonus',
      ),
      JoyPointTransaction(
        id: 'pt-4',
        type: JoyPointTransactionType.burn,
        points: 150,
        date: DateTime(now.year, now.month, 18),
        description: 'Privilege — 20% discount',
      ),
      JoyPointTransaction(
        id: 'pt-5',
        type: JoyPointTransactionType.earn,
        points: 200,
        date: DateTime(now.year, now.month - 1, 22),
        description: 'Partner promotion — Wellness day',
      ),
      JoyPointTransaction(
        id: 'pt-6',
        type: JoyPointTransactionType.burn,
        points: 60,
        date: DateTime(now.year, now.month - 1, 8),
        description: 'Voucher — Seasonal tote bag',
      ),
      JoyPointTransaction(
        id: 'pt-7',
        type: JoyPointTransactionType.earn,
        points: 90,
        date: DateTime(now.year, now.month - 2, 15),
        description: 'Store purchase — Central World',
      ),
    ]);

    _loaded = true;
    notifyListeners();
  }

  /// Re-load member, privileges, coupons, and point history.
  Future<void> refresh() async {
    _loaded = false;
    _member = null;
    _privileges.clear();
    _coupons.clear();
    _pointTransactions.clear();
    await ensureLoaded();
  }
}

String formatJoyDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatJoyMonthYear(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
