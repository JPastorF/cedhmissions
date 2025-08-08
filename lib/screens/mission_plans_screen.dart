// lib/screens/mission_plans_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_plan_provider.dart';
import 'mission_detail_screen.dart';

class MissionPlansScreen extends StatefulWidget {
  const MissionPlansScreen({super.key});

  @override
  State<MissionPlansScreen> createState() => _MissionPlansScreenState();
}

class _MissionPlansScreenState extends State<MissionPlansScreen> {
  final TextEditingController _planNameController = TextEditingController();

  void _showAddEditPlanDialog({String? planId, String? currentName}) {
    _planNameController.text = currentName ?? '';
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<MissionPlanProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          title: Text(currentName == null ? 'Crear Nuevo Plan' : 'Editar Plan'),
          content: TextField(
            controller: _planNameController,
            decoration: const InputDecoration(hintText: 'Nombre del plan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_planNameController.text.isNotEmpty) {
                  if (planId == null) {
                    provider.addMissionPlan(_planNameController.text);
                  } else {
                    provider.updateMissionPlanName(
                      planId,
                      _planNameController.text,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(planId == null ? 'Crear' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _planNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Misiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear nuevo plan',
            onPressed: () => _showAddEditPlanDialog(),
          ),
        ],
      ),
      body: Consumer<MissionPlanProvider>(
        builder: (context, provider, child) {
          if (provider.missionPlans.isEmpty) {
            return const Center(
              child: Text('No hay planes de misiones. Crea uno para empezar.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 56.0),
            itemCount: provider.missionPlans.length,
            itemBuilder: (context, index) {
              final plan = provider.missionPlans[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(plan.name),
                  subtitle: Text('${plan.missions.length} misiones'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar nombre del plan',
                        onPressed: () => _showAddEditPlanDialog(
                          planId: plan.id,
                          currentName: plan.name,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Eliminar plan',
                        onPressed: () => provider.removeMissionPlan(plan.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        tooltip: 'Ver/editar misiones',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MissionDetailScreen(missionPlanId: plan.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
