import 'package:astro_mukti/bloc/payOut/payOut_bloc.dart';
import 'package:astro_mukti/bloc/payOut/payOut_event.dart';
import 'package:astro_mukti/bloc/payOut/payOut_stats.dart';
import 'package:astro_mukti/view/widgets/appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/resources.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({super.key});

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayoutBloc>().add(PayOutGetEvent());
    });
    super.initState();
  }

  Future<void> _onRefresh() async {
    context.read<PayoutBloc>().add(PayOutGetEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarProfile(userName: 'Payout'),

      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocBuilder<PayoutBloc, PayoutStats>(
          builder: (context, state) {
            if (state is PayOutLoadingStats) {
              return Center(
                child: CircularProgressIndicator(
                  color: Resources.colors.blackColor,
                ),
              );
            } else if (state is PayoutGetStats) {
              final response = state.stats;
              final list = response.data;

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No Data Available',
                    style: Resources.styles.kTextStyle12(Colors.black),
                  ),
                );
              }

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Top Row (Vendor + Status)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.vendorDetails.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.status == "success"
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: item.status == "success"
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// Amount
                          Text(
                            "₹${item.amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// Date
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                formatDate(item.createdAt),
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// Payment Mode
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                item.paymentMode,
                                style: const TextStyle(fontSize: 14,color: Colors.black),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// Transaction ID
                          Row(
                            children: [
                              const Icon(Icons.receipt_long, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Txn ID: ${item.transactionId }",
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  );
                },
              );
            } else if (state is PayOutError) {
              return Center(
                child: Text(
                  state.error,
                  style: Resources.styles.kTextStyle14B(Colors.red),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
