import 'package:flutter/material.dart';
import 'package:sumarg/utils/color_constants.dart';
import 'package:sumarg/views/widgets/by_route_widget.dart';
import 'package:sumarg/views/widgets/by_bus_number_widget.dart';

class RunningStatusScreen extends StatefulWidget {
  const RunningStatusScreen({super.key});

  @override
  State<RunningStatusScreen> createState() =>
      _RunningStatusScreenState();
}

class _RunningStatusScreenState extends State<RunningStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Running Status",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.route),
              text: 'By Route',
            ),
            Tab(
              icon: Icon(Icons.directions_bus),
              text: 'By Bus Number',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ByRouteTab(),
          ByBusNumberTab(),
        ],
      ),
    );
  }
}
