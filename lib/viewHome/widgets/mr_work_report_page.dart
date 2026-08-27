import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../model/TodoModel.dart';
import '../../model/mr_work_report_model.dart';
import '../../service/api_service.dart';
import '../../service/session_manager.dart';

class MrWorkReportPage extends StatefulWidget {
  final TodoModel? userData;

  const MrWorkReportPage({
    super.key,
    this.userData,
  });

  @override
  State<MrWorkReportPage> createState() => _MrWorkReportPageState();
}

class _MrWorkReportPageState extends State<MrWorkReportPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String? empId;
  String? empName;
  bool isLoading = true;
  bool isSubmitting = false;

  // Form Controllers
  final TextEditingController employeeCodeController = TextEditingController();
  final TextEditingController reportDateController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zoneController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController workingAreaController = TextEditingController();

  final TextEditingController doctorVisitsController = TextEditingController();
  final TextEditingController chemistVisitsController = TextEditingController();
  final TextEditingController stockistVisitsController = TextEditingController();

  final TextEditingController primaryOrderController = TextEditingController();
  final TextEditingController secondaryOrderController = TextEditingController();

  final TextEditingController dailyExpenseController = TextEditingController();
  final TextEditingController expenseRemarksController = TextEditingController();

  final TextEditingController workDetailsController = TextEditingController();

  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Live Calculated Stats
  int get totalVisitsCount {
    final doc = int.tryParse(doctorVisitsController.text.trim()) ?? 0;
    final chem = int.tryParse(chemistVisitsController.text.trim()) ?? 0;
    final stock = int.tryParse(stockistVisitsController.text.trim()) ?? 0;
    return doc + chem + stock;
  }

  double get totalOrderValue {
    final primary = double.tryParse(primaryOrderController.text.trim()) ?? 0.0;
    final secondary = double.tryParse(secondaryOrderController.text.trim()) ?? 0.0;
    return primary + secondary;
  }

  double get dailyExpenseValue {
    return double.tryParse(dailyExpenseController.text.trim()) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    reportDateController.text = _todayDate();
    _attachLiveCalculations();
    _loadEmployeeData();
  }

  void _attachLiveCalculations() {
    final list = [
      doctorVisitsController,
      chemistVisitsController,
      stockistVisitsController,
      primaryOrderController,
      secondaryOrderController,
      dailyExpenseController,
    ];
    for (final controller in list) {
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    employeeCodeController.dispose();
    reportDateController.dispose();
    stateController.dispose();
    zoneController.dispose();
    blockController.dispose();
    workingAreaController.dispose();
    doctorVisitsController.dispose();
    chemistVisitsController.dispose();
    stockistVisitsController.dispose();
    primaryOrderController.dispose();
    secondaryOrderController.dispose();
    dailyExpenseController.dispose();
    expenseRemarksController.dispose();
    workDetailsController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  String _todayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    try {
      if (reportDateController.text.isNotEmpty) {
        initial = DateTime.parse(reportDateController.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        reportDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _loadEmployeeData() async {
    try {
      String? id = widget.userData?.empId;
      String? name = widget.userData?.name;

      if (id == null || id.isEmpty) {
        id = await SessionManager.getEmpId();
      }
      if (name == null || name.isEmpty) {
        name = await SessionManager.getName();
      }

      if (!mounted) return;

      setState(() {
        empId = id;
        empName = name;
        employeeCodeController.text = id ?? '';
        isLoading = false;
      });

      if (id == null || id.isEmpty) {
        _showMessage(
          'Employee ID not found. Please log in again.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('❌ Session Error: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Unable to load employee details.', isError: true);
    }
  }

  Future<void> _submitWorkReport() async {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fill all required fields correctly.', isError: true);
      return;
    }

    if (empId == null || empId!.trim().isEmpty) {
      _showMessage('Employee ID not found. Please login again.', isError: true);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final report = MRWorkReportModel(
        empId: empId!,
        employeeCode: employeeCodeController.text.trim(),
        reportDate: reportDateController.text.trim(),
        state: stateController.text.trim(),
        zone: zoneController.text.trim(),
        block: blockController.text.trim(),
        totalDoctorVisits: doctorVisitsController.text.trim(),
        totalChemistVisits: chemistVisitsController.text.trim(),
        totalStockistVisits: stockistVisitsController.text.trim(),
        primaryOrderValue: primaryOrderController.text.trim(),
        secondaryOrderValue: secondaryOrderController.text.trim(),
        workingArea: workingAreaController.text.trim(),
        latitude: latitudeController.text.trim(),
        longitude: longitudeController.text.trim(),
        dailyExpense: dailyExpenseController.text.trim(),
        expenseRemarks: expenseRemarksController.text.trim(),
        workDetails: workDetailsController.text.trim(),
      );

      final result = await _apiService.submitMRWorkReport(report);

      if (!mounted) return;

      if (result) {
        _showSuccessDialog();
        _clearForm();
      } else {
        _showMessage('Failed to submit MR work report. Please try again.', isError: true);
      }
    } catch (e) {
      debugPrint('❌ MR Work Report Submit Error: $e');
      if (!mounted) return;
      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                'Report Submitted!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your MR daily work report has been successfully recorded.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    stateController.clear();
    zoneController.clear();
    blockController.clear();
    workingAreaController.clear();
    doctorVisitsController.clear();
    chemistVisitsController.clear();
    stockistVisitsController.clear();
    primaryOrderController.clear();
    secondaryOrderController.clear();
    dailyExpenseController.clear();
    expenseRemarksController.clear();
    workDetailsController.clear();
    latitudeController.clear();
    longitudeController.clear();

    reportDateController.text = _todayDate();
    employeeCodeController.text = empId ?? '';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION CONTAINER CARD
  // ------------------------------------------------------------
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CUSTOM TEXT FIELD BUILDER
  // ------------------------------------------------------------
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool required = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: readOnly ? AppColors.textSecondary : AppColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: hint ?? 'Enter $label',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : AppColors.creamBackground.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error, width: 1),
              ),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TOP SUMMARY HERO BANNER
  // ------------------------------------------------------------
  Widget _buildTopHeroBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                      'MR Daily Work Report',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${empName ?? 'MR Employee'} • ID: ${empId ?? 'N/A'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        reportDateController.text,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 14),

          // 3 Live Metric Strip
          Row(
            children: [
              _buildMetricItem('Total Calls/Visits', '$totalVisitsCount', Icons.medical_services_outlined),
              _buildDivider(),
              _buildMetricItem('Orders Booked', '₹${totalOrderValue.toStringAsFixed(0)}', Icons.shopping_bag_outlined, color: AppColors.primaryGold),
              _buildDivider(),
              _buildMetricItem('Daily Expense', '₹${dailyExpenseValue.toStringAsFixed(0)}', Icons.receipt_long_outlined, color: AppColors.leafGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, {Color color = AppColors.white}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MR Work Report',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.primaryGold),
            tooltip: 'Clear Form',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    'Clear Form?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to reset all work report fields?',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearForm();
                      },
                      child: Text('Reset', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Live Summary Hero Banner
                    _buildTopHeroBanner(),

                    // 1. Territory & Coverage Section
                    _buildSectionCard(
                      title: 'Territory & Coverage',
                      icon: Icons.map_outlined,
                      children: [
                        _buildCustomTextField(
                          controller: employeeCodeController,
                          label: 'Employee Code',
                          icon: Icons.badge_outlined,
                          readOnly: true,
                          suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                        ),
                        _buildCustomTextField(
                          controller: reportDateController,
                          label: 'Report Date',
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: _pickDate,
                          suffixIcon: const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.primaryGreen),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomTextField(
                                controller: stateController,
                                label: 'State',
                                icon: Icons.location_city_outlined,
                                hint: 'e.g. Uttar Pradesh',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCustomTextField(
                                controller: zoneController,
                                label: 'Zone',
                                icon: Icons.explore_outlined,
                                hint: 'e.g. North Zone',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomTextField(
                                controller: blockController,
                                label: 'Block',
                                icon: Icons.domain_outlined,
                                hint: 'e.g. North Block',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCustomTextField(
                                controller: workingAreaController,
                                label: 'Working Area / HQ',
                                icon: Icons.location_on_outlined,
                                hint: 'e.g. Lucknow HQ',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 2. Visit Summary Section
                    _buildSectionCard(
                      title: 'MR Calls & Field Visits',
                      icon: Icons.medical_services_outlined,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Total: $totalVisitsCount Calls',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      children: [
                        _buildCustomTextField(
                          controller: doctorVisitsController,
                          label: 'Total Doctor Visits',
                          icon: Icons.person_search_outlined,
                          hint: 'Number of doctors met today',
                          keyboardType: TextInputType.number,
                        ),
                        _buildCustomTextField(
                          controller: chemistVisitsController,
                          label: 'Total Chemist Visits',
                          icon: Icons.local_pharmacy_outlined,
                          hint: 'Number of chemist counters visited',
                          keyboardType: TextInputType.number,
                        ),
                        _buildCustomTextField(
                          controller: stockistVisitsController,
                          label: 'Total Stockist Visits',
                          icon: Icons.inventory_2_outlined,
                          hint: 'Number of stockist meetings',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    // 3. Order Summary Section
                    _buildSectionCard(
                      title: 'Order Booking & Revenue',
                      icon: Icons.shopping_bag_outlined,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.deepGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Total: ₹${totalOrderValue.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepGold,
                          ),
                        ),
                      ),
                      children: [
                        _buildCustomTextField(
                          controller: primaryOrderController,
                          label: 'Primary Order Value (₹)',
                          icon: Icons.shopping_cart_outlined,
                          hint: 'e.g. 45000',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        _buildCustomTextField(
                          controller: secondaryOrderController,
                          label: 'Secondary Order Value (₹)',
                          icon: Icons.storefront_outlined,
                          hint: 'e.g. 15000',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ],
                    ),

                    // 4. Expense Section
                    _buildSectionCard(
                      title: 'Daily Expenses & Allowances',
                      icon: Icons.receipt_long_outlined,
                      children: [
                        _buildCustomTextField(
                          controller: dailyExpenseController,
                          label: 'Daily Expense (₹)',
                          icon: Icons.currency_rupee_rounded,
                          hint: 'e.g. 500',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        _buildCustomTextField(
                          controller: expenseRemarksController,
                          label: 'Expense Remarks',
                          icon: Icons.notes_outlined,
                          hint: 'e.g. Travel and food allowance, fuel',
                          required: false,
                          maxLines: 2,
                        ),
                      ],
                    ),

                    // 5. Work Details Section
                    _buildSectionCard(
                      title: 'Work Details & Strategy Activity',
                      icon: Icons.description_outlined,
                      children: [
                        _buildCustomTextField(
                          controller: workDetailsController,
                          label: 'Detailed Activity Notes',
                          icon: Icons.edit_note_rounded,
                          hint: 'e.g. Successful meeting with major stockists regarding Ayurvedic product range promotion, new doctor detailing, and sample distribution.',
                          maxLines: 4,
                        ),
                      ],
                    ),

                    // 6. Location Coordinates (Optional)
                    _buildSectionCard(
                      title: 'GPS Coordinates (Optional)',
                      icon: Icons.gps_fixed_rounded,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomTextField(
                                controller: latitudeController,
                                label: 'Latitude',
                                icon: Icons.my_location_rounded,
                                hint: 'e.g. 26.8467',
                                required: false,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCustomTextField(
                                controller: longitudeController,
                                label: 'Longitude',
                                icon: Icons.explore_outlined,
                                hint: 'e.g. 80.9462',
                                required: false,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.darkGreen, AppColors.primaryGreen],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitWorkReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, color: AppColors.primaryGold, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Submit MR Work Report',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
