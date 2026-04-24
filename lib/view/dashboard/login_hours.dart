import 'package:flutter/material.dart';
import '../../repository/repository.dart';
import '../../resources/resources.dart';

class LoginHours extends StatefulWidget {
  const LoginHours({super.key});

  @override
  State<LoginHours> createState() => _LoginHoursState();
}

class _LoginHoursState extends State<LoginHours> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DailyLoginHours(),
    WeeklyLoginHours(),
    MonthlyLoginHours(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Login Hours",
          style: Resources.styles.kTextStyle16B(Colors.black),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                final labels = ["Daily", "Weekly", "Monthly"];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Card(
                    elevation: 4,
                    color: _selectedIndex == index
                        ? Resources.colors.buttonColor
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .28,
                      child: Center(
                        child: Text(
                          labels[index],
                          style: Resources.styles.kTextStyle12B(
                            _selectedIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          /// Page
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class LoginHoursWidget extends StatefulWidget {
  final String type;
  final IconData icon;
  final Color iconColor;
  final String emptyText;

  const LoginHoursWidget({
    super.key,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.emptyText,
  });

  @override
  State<LoginHoursWidget> createState() => _LoginHoursWidgetState();
}

class _LoginHoursWidgetState extends State<LoginHoursWidget> {
  List<dynamic> allData = [];
  List<dynamic> data = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() => _isLoading = true);
    final value = await Repository().getLoginHour(widget.type);
    allData = value ?? [];
    _applyDateFilter();
    setState(() => _isLoading = false);
  }

  void _applyDateFilter() {
    if (_startDate != null && _endDate != null) {
      data = allData.where((item) {
        final date = DateTime.parse(item["date"]);
        return !date.isBefore(_startDate!) && !date.isAfter(_endDate!);
      }).toList();
    } else {
      data = allData;
    }
  }

  /// 🔥 SAFE CONVERSION
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String formatDecimalHours(double hoursDecimal) {
    final hours = hoursDecimal.floor();
    final minutes = ((hoursDecimal - hours) * 60).floor();
    final seconds = (((hoursDecimal - hours) * 60 - minutes) * 60).round();

    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(hours)}:${two(minutes)}:${two(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDatePickers(),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          )
        else if (data.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(widget.emptyText),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: Icon(widget.icon, color: widget.iconColor),
                    title: Text(
                      formatDecimalHours(_toDouble(item["totalTimeSpent"])),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Text(
                      item["date"] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDatePickers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _datePicker(
            "Start Date",
            _startDate,
            (d) {
              setState(() => _startDate = d);
              _applyDateFilter();
            },
            () {
              setState(() => _startDate = null);
              _applyDateFilter();
            },
          ),
          _datePicker(
            "End Date",
            _endDate,
            (d) {
              setState(() => _endDate = d);
              _applyDateFilter();
            },
            () {
              setState(() => _endDate = null);
              _applyDateFilter();
            },
          ),
        ],
      ),
    );
  }

  Widget _datePicker(
    String label,
    DateTime? date,
    Function(DateTime) onPick,
    VoidCallback onClear,
  ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) onPick(picked);
            },
            child: Text(
              date == null ? label : "${date.day}-${date.month}-${date.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (date != null)
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(Icons.clear, size: 18, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

class DailyLoginHours extends StatelessWidget {
  const DailyLoginHours({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginHoursWidget(
      type: "daily",
      icon: Icons.access_time,
      iconColor: Colors.blue,
      emptyText: "No daily records found",
    );
  }
}

class WeeklyLoginHours extends StatelessWidget {
  const WeeklyLoginHours({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginHoursWidget(
      type: "weekly",
      icon: Icons.calendar_view_week,
      iconColor: Colors.green,
      emptyText: "No weekly records found",
    );
  }
}

class MonthlyLoginHours extends StatelessWidget {
  const MonthlyLoginHours({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginHoursWidget(
      type: "monthly",
      icon: Icons.calendar_month,
      iconColor: Colors.purple,
      emptyText: "No monthly records found",
    );
  }
}
