import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../model/Dealer_Model/dealer_login_model.dart';
import '../model/Retailer_model/retailer_team_model.dart';
import '../service/Dealer_service/dealer_login_service.dart';
import '../service/Dealer_service/dealer_discount_service.dart';
import '../service/Retailer_service/retailer_profile_service.dart';

/// Model representing an applied discount scheme for a Retailer
class RetailerDiscount {
  final String retailerId;
  final String businessName;
  final String personName;
  final String mobile;
  final String district;
  final String state;
  final double discountValue;
  final String discountType; // 'percent' or 'flat'
  final String reason;
  final double minOrderValue;
  final DateTime validUntil;
  final DateTime appliedAt;
  final String status; // 'Active', 'Expired'

  RetailerDiscount({
    required this.retailerId,
    required this.businessName,
    required this.personName,
    required this.mobile,
    required this.district,
    required this.state,
    required this.discountValue,
    this.discountType = 'percent',
    required this.reason,
    this.minOrderValue = 0.0,
    required this.validUntil,
    required this.appliedAt,
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() => {
        'retailerId': retailerId,
        'businessName': businessName,
        'personName': personName,
        'mobile': mobile,
        'district': district,
        'state': state,
        'discountValue': discountValue,
        'discountType': discountType,
        'reason': reason,
        'minOrderValue': minOrderValue,
        'validUntil': validUntil.toIso8601String(),
        'appliedAt': appliedAt.toIso8601String(),
        'status': status,
      };

  factory RetailerDiscount.fromJson(Map<String, dynamic> json) => RetailerDiscount(
        retailerId: json['retailerId']?.toString() ?? '',
        businessName: json['businessName']?.toString() ?? '',
        personName: json['personName']?.toString() ?? '',
        mobile: json['mobile']?.toString() ?? '',
        district: json['district']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        discountValue: (json['discountValue'] is num)
            ? (json['discountValue'] as num).toDouble()
            : double.tryParse(json['discountValue']?.toString() ?? '0') ?? 0.0,
        discountType: json['discountType']?.toString() ?? 'percent',
        reason: json['reason']?.toString() ?? 'Standard Discount',
        minOrderValue: (json['minOrderValue'] is num)
            ? (json['minOrderValue'] as num).toDouble()
            : double.tryParse(json['minOrderValue']?.toString() ?? '0') ?? 0.0,
        validUntil: DateTime.tryParse(json['validUntil']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 30)),
        appliedAt: DateTime.tryParse(json['appliedAt']?.toString() ?? '') ?? DateTime.now(),
        status: json['status']?.toString() ?? 'Active',
      );

  bool get isExpired => DateTime.now().isAfter(validUntil);
}

class DiscountApplyScreen extends StatefulWidget {
  final String? dealerId;

  const DiscountApplyScreen({
    super.key,
    this.dealerId,
  });

  @override
  State<DiscountApplyScreen> createState() => _DiscountApplyScreenState();
}

class _DiscountApplyScreenState extends State<DiscountApplyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DealerModel? _dealer;
  String _effectiveDealerId = '';

  List<RetailerItem> _allRetailers = [];
  List<RetailerItem> _filteredRetailers = [];
  final Map<String, RetailerDiscount> _appliedDiscounts = {};

  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedDistrictFilter = 'All';
  List<String> _districtsList = ['All'];

  // Multi-selection state for Bulk Discount
  bool _isSelectionMode = false;
  final Set<String> _selectedRetailerIds = {};

  final TextEditingController _searchController = TextEditingController();

  static const String _storageKey = 'dealer_applied_retailer_discounts';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Load Dealer Details
      _dealer = await DealerService.getSavedDealer();
      _effectiveDealerId = widget.dealerId ?? _dealer?.dealerId ?? '';

      // 2. Load Saved Discounts from Storage
      await _loadSavedDiscounts();

      // 3. Fetch All Retailers from API
      final response = await RetailerProfileService.getAllRetailers();
      _allRetailers = response.data;

      // Extract unique districts for filtering
      final Set<String> dists = {'All'};
      for (final r in _allRetailers) {
        if (r.district != null && r.district!.trim().isNotEmpty) {
          dists.add(r.district!.trim());
        }
      }
      _districtsList = dists.toList()..sort((a, b) => a == 'All' ? -1 : a.compareTo(b));

      _applyFilters();
    } catch (e) {
      debugPrint("Error loading retailers for discount: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load retailers: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSavedDiscounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_storageKey}_$_effectiveDealerId';
      final rawJson = prefs.getString(key);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map<String, dynamic>) {
          _appliedDiscounts.clear();
          decoded.forEach((k, v) {
            if (v is Map<String, dynamic>) {
              _appliedDiscounts[k] = RetailerDiscount.fromJson(v);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error reading saved discounts: $e");
    }
  }

  Future<void> _saveDiscountsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_storageKey}_$_effectiveDealerId';
      final Map<String, dynamic> data = {};
      _appliedDiscounts.forEach((k, v) {
        data[k] = v.toJson();
      });
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving discounts to storage: $e");
    }
  }

  void _applyFilters() {
    List<RetailerItem> results = List.from(_allRetailers);

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      results = results.where((r) {
        final bName = (r.businessName ?? '').toLowerCase();
        final pName = (r.personName ?? r.name ?? '').toLowerCase();
        final mob = (r.mobile ?? '').toLowerCase();
        final dist = (r.district ?? '').toLowerCase();
        final vId = (r.visiterId ?? '').toLowerCase();
        return bName.contains(q) || pName.contains(q) || mob.contains(q) || dist.contains(q) || vId.contains(q);
      }).toList();
    }

    // District filter
    if (_selectedDistrictFilter != 'All') {
      results = results.where((r) => (r.district ?? '').trim().toLowerCase() == _selectedDistrictFilter.toLowerCase()).toList();
    }

    setState(() {
      _filteredRetailers = results;
    });
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
    });
    _applyFilters();
  }

  void _onDistrictSelected(String district) {
    setState(() {
      _selectedDistrictFilter = district;
    });
    _applyFilters();
  }

  // ============================================================
  // DISCOUNT APPLY DIALOG / BOTTOM SHEET
  // ============================================================
  void _showApplyDiscountSheet(RetailerItem retailer) {
    final String rId = retailer.effectiveVisiterId;
    final RetailerDiscount? existingDiscount = _appliedDiscounts[rId];

    final discountValueCtrl = TextEditingController(
      text: existingDiscount != null ? existingDiscount.discountValue.toStringAsFixed(0) : '10',
    );
    final reasonCtrl = TextEditingController(
      text: existingDiscount?.reason ?? 'Special Partner Discount',
    );
    final minOrderCtrl = TextEditingController(
      text: existingDiscount != null && existingDiscount.minOrderValue > 0 ? existingDiscount.minOrderValue.toStringAsFixed(0) : '0',
    );

    String discountType = existingDiscount?.discountType ?? 'percent';
    int validityDays = 30;
    DateTime validUntil = existingDiscount?.validUntil ?? DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double val = double.tryParse(discountValueCtrl.text.trim()) ?? 0.0;
            final double sampleOrder = 10000.0;
            final double calculatedSavings = discountType == 'percent' ? (sampleOrder * (val / 100)) : val;
            final double sampleFinal = (sampleOrder - calculatedSavings) > 0 ? (sampleOrder - calculatedSavings) : 0;

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Header Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.percent_rounded, color: AppColors.primaryGreen, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existingDiscount != null ? "Update Retailer Discount" : "Apply Discount Scheme",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                "Configure customized margins for this retailer",
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Retailer Info Pill
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.creamBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                retailer.displayName.isNotEmpty ? retailer.displayName[0].toUpperCase() : 'R',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  retailer.displayName,
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "ID: ${retailer.displayId} • ${retailer.displayLocation}",
                                  style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Discount Type Selector (Percentage vs Flat)
                    Text(
                      "Discount Type",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() => discountType = 'percent');
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: discountType == 'percent' ? AppColors.primaryGreen : AppColors.creamBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: discountType == 'percent' ? AppColors.primaryGreen : Colors.grey.shade300,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Percentage Discount (%)",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: discountType == 'percent' ? Colors.white : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() => discountType = 'flat');
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: discountType == 'flat' ? AppColors.primaryGreen : AppColors.creamBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: discountType == 'flat' ? AppColors.primaryGreen : Colors.grey.shade300,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Flat Discount (₹)",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: discountType == 'flat' ? Colors.white : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Discount Value Input & Preset Chips
                    Text(
                      discountType == 'percent' ? "Discount Percentage (%)" : "Flat Discount Amount (₹)",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: discountValueCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          discountType == 'percent' ? Icons.percent : Icons.currency_rupee,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                        hintText: discountType == 'percent' ? "e.g. 15" : "e.g. 500",
                        filled: true,
                        fillColor: AppColors.creamBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),

                    if (discountType == 'percent') ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [5, 10, 15, 20, 25, 30].map((rate) {
                          final isSelected = discountValueCtrl.text.trim() == rate.toString();
                          return ActionChip(
                            label: Text("$rate%"),
                            backgroundColor: isSelected ? AppColors.primaryGreen : AppColors.creamBackground,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.primaryGreen,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              setModalState(() {
                                discountValueCtrl.text = rate.toString();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Scheme / Reason Input
                    Text(
                      "Scheme / Reason Description",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.campaign_outlined, color: AppColors.primaryGreen, size: 20),
                        hintText: "e.g. Festival Season Offer, Loyalty Bonus",
                        filled: true,
                        fillColor: AppColors.creamBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      style: GoogleFonts.poppins(fontSize: 13.5),
                    ),

                    const SizedBox(height: 16),

                    // Validity Period
                    Text(
                      "Validity Period",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildValidityChip("7 Days", 7, validityDays, (days) {
                          setModalState(() {
                            validityDays = days;
                            validUntil = DateTime.now().add(Duration(days: days));
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildValidityChip("30 Days", 30, validityDays, (days) {
                          setModalState(() {
                            validityDays = days;
                            validUntil = DateTime.now().add(Duration(days: days));
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildValidityChip("90 Days", 90, validityDays, (days) {
                          setModalState(() {
                            validityDays = days;
                            validUntil = DateTime.now().add(Duration(days: days));
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildValidityChip("1 Year", 365, validityDays, (days) {
                          setModalState(() {
                            validityDays = days;
                            validUntil = DateTime.now().add(Duration(days: days));
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Live Order Savings Preview Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calculate_outlined, color: AppColors.primaryGreen, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Live Margin Calculation Preview (₹10,000 Order)",
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Retailer Savings:", style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary)),
                              Text("₹${calculatedSavings.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Payable to Dealer:", style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                              Text("₹${sampleFinal.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Action Buttons (Save / Revoke)
                    Row(
                      children: [
                        if (existingDiscount != null) ...[
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _removeDiscount(rId, retailer.displayName);
                              },
                              child: Text(
                                "Remove",
                                style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            onPressed: () {
                              if (val <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter a valid discount amount.")),
                                );
                                return;
                              }

                              final discount = RetailerDiscount(
                                retailerId: rId,
                                businessName: retailer.displayName,
                                personName: retailer.personName ?? retailer.name ?? '',
                                mobile: retailer.displayMobile,
                                district: retailer.district ?? '',
                                state: retailer.state ?? '',
                                discountValue: val,
                                discountType: discountType,
                                reason: reasonCtrl.text.trim().isNotEmpty ? reasonCtrl.text.trim() : 'Special Scheme',
                                minOrderValue: double.tryParse(minOrderCtrl.text.trim()) ?? 0.0,
                                validUntil: validUntil,
                                appliedAt: DateTime.now(),
                              );

                              Navigator.pop(ctx);
                              _applyDiscount(discount);
                            },
                            child: Text(
                              existingDiscount != null ? "Update Discount" : "Apply Discount",
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildValidityChip(String label, int days, int currentDays, Function(int) onSelected) {
    final isSelected = days == currentDays;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(days),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.creamBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BULK DISCOUNT BOTTOM SHEET
  // ============================================================
  void _showBulkDiscountSheet() {
    if (_selectedRetailerIds.isEmpty) return;

    final discountValueCtrl = TextEditingController(text: '10');
    final reasonCtrl = TextEditingController(text: 'Bulk Regional Scheme');
    String discountType = 'percent';
    DateTime validUntil = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final selectedCount = _selectedRetailerIds.length;

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Apply Bulk Discount to $selectedCount Retailers",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: discountValueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Discount Percentage (%)",
                      prefixIcon: const Icon(Icons.percent, color: AppColors.primaryGreen),
                      filled: true,
                      fillColor: AppColors.creamBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonCtrl,
                    decoration: InputDecoration(
                      labelText: "Scheme Title",
                      prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primaryGreen),
                      filled: true,
                      fillColor: AppColors.creamBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final val = double.tryParse(discountValueCtrl.text.trim()) ?? 0.0;
                        if (val <= 0) return;

                        Navigator.pop(ctx);

                        // Show progress dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => Center(
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              margin: const EdgeInsets.symmetric(horizontal: 40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(color: AppColors.primaryGreen),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Applying Bulk Discount...",
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Updating items for $selectedCount retailers",
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        int successCount = 0;
                        for (final rId in _selectedRetailerIds) {
                          final apiResult = await DealerDiscountService.applyProductOfferDiscount(
                            retailerId: rId,
                            discountPercentage: val,
                          );

                          if (apiResult['status'] == true) {
                            successCount++;
                            final retailer = _allRetailers.firstWhere(
                              (r) => r.effectiveVisiterId == rId,
                              orElse: () => RetailerItem(id: 0, visiterId: rId, businessName: 'Retailer'),
                            );
                            _appliedDiscounts[rId] = RetailerDiscount(
                              retailerId: rId,
                              businessName: retailer.displayName,
                              personName: retailer.personName ?? '',
                              mobile: retailer.displayMobile,
                              district: retailer.district ?? '',
                              state: retailer.state ?? '',
                              discountValue: val,
                              discountType: discountType,
                              reason: reasonCtrl.text.trim(),
                              validUntil: validUntil,
                              appliedAt: DateTime.now(),
                            );
                          }
                        }

                        if (!mounted) return;
                        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading

                        await _saveDiscountsToStorage();
                        setState(() {
                          _isSelectionMode = false;
                          _selectedRetailerIds.clear();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Applied $val% discount to $successCount of $selectedCount retailers!"),
                            backgroundColor: successCount > 0 ? AppColors.primaryGreen : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Text(
                        "Apply to All Selected",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _applyDiscount(RetailerDiscount discount) async {
    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Container(
          padding: const EdgeInsets.all(22),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              Text(
                "Saving Discount...",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                "Updating selling prices in database",
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );

    // Validate Retailer / Visitor ID
    if (discount.retailerId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Visiter ID for this retailer."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Call API: POST https://durvasaayurved.com/api/VisiterOfferDiscount
    final result = await DealerDiscountService.applyProductOfferDiscount(
      retailerId: discount.retailerId,
      discountPercentage: discount.discountValue,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss Loading Dialog

    if (result['status'] == true) {
      setState(() {
        _appliedDiscounts[discount.retailerId] = discount;
      });
      await _saveDiscountsToStorage();

      final String message = result['message'] ??
          "Discount ${discount.discountType == 'percent' ? '${discount.discountValue.toStringAsFixed(0)}%' : '₹${discount.discountValue.toStringAsFixed(0)}'} applied to ${discount.businessName}!";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.secondaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result['message'] ?? 'Failed to apply discount.',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _removeDiscount(String retailerId, String name) {
    setState(() {
      _appliedDiscounts.remove(retailerId);
    });
    _saveDiscountsToStorage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Discount removed for $name"),
        backgroundColor: AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _appliedDiscounts.values.where((d) => !d.isExpired).length;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          "Retailer Discount Schemes",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist_rtl_rounded, color: Colors.white),
            tooltip: _isSelectionMode ? 'Cancel Selection' : 'Multi-Select',
            onPressed: () {
              setState(() {
                _isSelectionMode = !_isSelectionMode;
                _selectedRetailerIds.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _initializeData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text("All Retailers (${_allRetailers.length})"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_offer_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text("Active Schemes ($activeCount)"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: ALL RETAILERS
                    _buildAllRetailersTab(),

                    // TAB 2: ACTIVE DISCOUNTS
                    _buildActiveDiscountsTab(),
                  ],
                ),
      bottomNavigationBar: _isSelectionMode && _selectedRetailerIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Text(
                      "${_selectedRetailerIds.length} Selected",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _showBulkDiscountSheet,
                      icon: const Icon(Icons.percent_rounded, color: Colors.white, size: 18),
                      label: Text("Apply Bulk Discount", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // ============================================================
  // TAB 1: ALL RETAILERS
  // ============================================================
  Widget _buildAllRetailersTab() {
    return Column(
      children: [
        // 1. Search Bar & Summary
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          color: AppColors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search by Shop Name, Person, Mobile, District...",
                  hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.creamBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.15)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // District Filter Chips
              if (_districtsList.length > 1)
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _districtsList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dist = _districtsList[index];
                      final isSelected = dist == _selectedDistrictFilter;
                      return ChoiceChip(
                        label: Text(dist),
                        selected: isSelected,
                        onSelected: (_) => _onDistrictSelected(dist),
                        selectedColor: AppColors.primaryGreen,
                        backgroundColor: AppColors.creamBackground,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // 2. Retailers List
        Expanded(
          child: _filteredRetailers.isEmpty
              ? _buildEmptySearchState()
              : RefreshIndicator(
                  onRefresh: _initializeData,
                  color: AppColors.primaryGreen,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: _filteredRetailers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final retailer = _filteredRetailers[index];
                      final rId = retailer.effectiveVisiterId;
                      final discount = _appliedDiscounts[rId];
                      final isSelected = _selectedRetailerIds.contains(rId);

                      return _buildRetailerCard(retailer, discount, isSelected);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRetailerCard(RetailerItem retailer, RetailerDiscount? discount, bool isSelected) {
    final hasActiveDiscount = discount != null && !discount.isExpired;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryGreen
              : (hasActiveDiscount ? AppColors.primaryGold.withOpacity(0.6) : Colors.black.withOpacity(0.04)),
          width: isSelected || hasActiveDiscount ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Avatar + Name + Checkbox/Discount Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSelectionMode)
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedRetailerIds.add(retailer.effectiveVisiterId);
                      } else {
                        _selectedRetailerIds.remove(retailer.effectiveVisiterId);
                      }
                    });
                  },
                ),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.5), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    retailer.displayName.isNotEmpty ? retailer.displayName[0].toUpperCase() : 'R',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      retailer.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (retailer.personName != null && retailer.personName!.isNotEmpty && retailer.personName != retailer.displayName) ...[
                      Text(
                        "Prop: ${retailer.personName}",
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "ID: ${retailer.displayId}",
                            style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (retailer.displayMobile != 'N/A')
                          Text(
                            retailer.displayMobile,
                            style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.creamBackground),
          const SizedBox(height: 10),

          // Location & Address Row
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primaryGold),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  retailer.displayLocation,
                  style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Active Discount Status Card or Apply Prompt
          if (hasActiveDiscount) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.leafGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.secondaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${discount.discountType == 'percent' ? '${discount.discountValue.toStringAsFixed(0)}%' : '₹${discount.discountValue.toStringAsFixed(0)}'} Margin Discount Active",
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen),
                        ),
                        Text(
                          "Scheme: ${discount.reason} • Exp: ${DateFormat('dd MMM yy').format(discount.validUntil)}",
                          style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showApplyDiscountSheet(retailer),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Edit",
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => _showApplyDiscountSheet(retailer),
                icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primaryGreen),
                label: Text(
                  "Apply Custom Discount Scheme",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: ACTIVE DISCOUNTS
  // ============================================================
  Widget _buildActiveDiscountsTab() {
    final activeDiscounts = _appliedDiscounts.values.where((d) => !d.isExpired).toList();

    if (activeDiscounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_offer_outlined, size: 54, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 16),
              Text(
                "No Active Discount Schemes",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                "You haven't assigned any customized margins or discounts to retailers yet. Switch to 'All Retailers' tab to apply.",
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _tabController.animateTo(0),
                icon: const Icon(Icons.storefront, size: 18, color: Colors.white),
                label: Text("Browse Retailers", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: activeDiscounts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final discount = activeDiscounts[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discount.businessName,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "ID: ${discount.retailerId} • ${discount.district}",
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      discount.discountType == 'percent'
                          ? "${discount.discountValue.toStringAsFixed(0)}% OFF"
                          : "₹${discount.discountValue.toStringAsFixed(0)} OFF",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.creamBackground),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Scheme: ${discount.reason}",
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
                  ),
                  Text(
                    "Valid till ${DateFormat('dd MMM yyyy').format(discount.validUntil)}",
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _removeDiscount(discount.retailerId, discount.businessName);
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                    label: Text("Revoke", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              "No retailers matching '$_searchQuery'",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              "Try searching with another keyword or reset the district filter.",
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          Text(
            "Loading authorized retailers...",
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              "Unable to load retailers",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(_errorMessage, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: _initializeData,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: Text("Retry", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
