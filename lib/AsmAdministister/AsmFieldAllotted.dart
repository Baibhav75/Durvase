import 'package:flutter/material.dart';
import '../model/TodoModel.dart';
import '../model/amr_assine_field_model.dart';
import '../service/api_service.dart';

class AmrAssineFieldPage extends StatefulWidget {
  final TodoModel? userData;
  final String? empId;

  const AmrAssineFieldPage({
    super.key,
    this.userData,
    this.empId,
  });

  @override
  State<AmrAssineFieldPage> createState() =>
      _AmrAssineFieldPageState();
}

class _AmrAssineFieldPageState extends State<AmrAssineFieldPage> {
  final ApiService _service = ApiService();

  List<AmrAssineField> _allAreaList = [];
  List<AmrAssineField> _filteredList = [];

  bool _isLoading = true;
  String? _errorMessage;

  // ============================================================
  // EMPLOYEE ID
  // ============================================================

  String get _resolvedEmpId {
    // 1. Explicit empId
    if (widget.empId != null &&
        widget.empId!.trim().isNotEmpty) {
      return widget.empId!.trim();
    }

    // 2. UserData empId
    if (widget.userData != null) {
      final id = widget.userData!.empId;

      if (id != null && id.trim().isNotEmpty) {
        return id.trim();
      }
    }

    // 3. UserData asmId as fallback
    if (widget.userData != null) {
      final id = widget.userData!.asmId;

      if (id != null && id.trim().isNotEmpty) {
        return id.trim();
      }
    }

    return '';
  }

  String get _displayName {
    return widget.userData?.name ?? 'ASM Member';
  }

  @override
  void initState() {
    super.initState();
    _loadAssignedArea();
  }

  // ============================================================
  // LOAD ASSIGNED AREA
  // ============================================================

  Future<void> _loadAssignedArea() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final empId = _resolvedEmpId;

      debugPrint(
        '========================================',
      );
      debugPrint(
        'ASM ASSIGNED AREA API',
      );
      debugPrint(
        'Employee ID: $empId',
      );
      debugPrint(
        '========================================',
      );

      if (empId.isEmpty) {
        throw Exception(
          'Employee ID is missing. Unable to fetch assigned area.',
        );
      }

      final result = await ApiService.getASM(empId);

      if (!mounted) return;

      setState(() {
        _allAreaList = result.datas2;
        _filteredList = List.from(_allAreaList);
        _isLoading = false;
      });

      debugPrint(
        'Assigned Area Count: ${result.datas2.length}',
      );
    } catch (e) {
      debugPrint(
        'Assigned Area Error: $e',
      );

      if (!mounted) return;

      setState(() {
        _errorMessage = e
            .toString()
            .replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assigned Area',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadAssignedArea,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _loadAssignedArea,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                12,
              ),
              child: _buildSummaryHeader(),
            ),
          ),

          if (_filteredList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmpty(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                30,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item = _filteredList[index];

                    return _buildAreaCard(item);
                  },
                  childCount: _filteredList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY HEADER
  // ============================================================

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B5D3B),
            Color(0xFF168A58),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Emp ID: $_resolvedEmpId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.80),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            color: Colors.white24,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _summaryItem(
                icon: Icons.location_on_outlined,
                label: 'Assigned Areas',
                value: '${_allAreaList.length}',
              ),

              Container(
                height: 35,
                width: 1,
                color: Colors.white24,
              ),

              _summaryItem(
                icon: Icons.check_circle_outline,
                label: 'Active',
                value:
                '${_allAreaList.where((e) => e.status.toLowerCase() == 'active').length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.white,
          ),

          const SizedBox(width: 7),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AREA CARD
  // ============================================================

  Widget _buildAreaCard(
      AmrAssineField item,
      ) {
    final bool isActive =
        item.status.toLowerCase() == 'active';

    final String districtName =
    item.districtName.trim().isEmpty
        ? 'District Not Available'
        : item.districtName.trim();

    final String stateName =
    item.stateName.trim().isEmpty
        ? 'State Not Available'
        : item.stateName.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD9B44A)
              .withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF168A58)
                        .withOpacity(0.08),
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF168A58),
                    size: 26,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        districtName,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202020),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        stateName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusBadge(
                  item.status,
                  isActive,
                ),
              ],
            ),

            const SizedBox(height: 15),

            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),

            const SizedBox(height: 14),

            _infoRow(
              icon: Icons.person_outline,
              title: 'Employee',
              value: item.empName.isEmpty
                  ? 'Not Available'
                  : item.empName,
            ),

            const SizedBox(height: 11),

            _infoRow(
              icon: Icons.badge_outlined,
              title: 'Emp ID',
              value: item.empId.isEmpty
                  ? _resolvedEmpId
                  : item.empId,
            ),

            const SizedBox(height: 11),

            _infoRow(
              icon: Icons.map_outlined,
              title: 'State',
              value: stateName,
            ),

            const SizedBox(height: 11),

            _infoRow(
              icon: Icons.location_city_outlined,
              title: 'District',
              value: districtName,
            ),

            const SizedBox(height: 11),

            _infoRow(
              icon: Icons.tag,
              title: 'District ID',
              value: item.districtId.toString(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 9),

        SizedBox(
          width: 78,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF252525),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
      String status,
      bool isActive,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.10)
            : Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.30)
              : Colors.red.withOpacity(0.30),
        ),
      ),
      child: Text(
        status.trim().isEmpty
            ? 'UNKNOWN'
            : status.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: isActive
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF168A58)
                    .withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 52,
                color: Color(0xFF168A58),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'No Assigned Area',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'No assigned field found for $_resolvedEmpId.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: Colors.orange,
            ),

            const SizedBox(height: 14),

            const Text(
              'Unable to load assigned area',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              _errorMessage ??
                  'Something went wrong while fetching data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadAssignedArea,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF168A58),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}