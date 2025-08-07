import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_plan_provider.dart';
import '../models/mission.dart';

class MissionDetailScreen extends StatefulWidget {
  final String missionPlanId;

  const MissionDetailScreen({super.key, required this.missionPlanId});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  MissionType _selectedType = MissionType.multiple;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _showAddEditMissionDialog({Mission? mission}) {
    _nameController.text = mission?.name ?? '';
    _descriptionController.text = mission?.description ?? '';
    _pointsController.text = mission?.points.toString() ?? '';
    _selectedType = mission?.type ?? MissionType.multiple;

    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<MissionPlanProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          title: Text(mission == null ? 'Añadir Misión' : 'Editar Misión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Misión',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Puntos'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<MissionType>(
                value: _selectedType,
                onChanged: (MissionType? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                items: MissionType.values.map((MissionType type) {
                  return DropdownMenuItem<MissionType>(
                    value: type,
                    child: Text(
                      type == MissionType.multiple ? 'Múltiple' : 'Única',
                    ),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Tipo de Misión'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _pointsController.text.isNotEmpty) {
                  if (mission == null) {
                    provider.addMissionToPlan(
                      widget.missionPlanId,
                      _nameController.text,
                      _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      int.parse(_pointsController.text),
                      _selectedType,
                    );
                  } else {
                    provider.updateMissionInPlan(
                      widget.missionPlanId,
                      mission.id,
                      _nameController.text,
                      _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      int.parse(_pointsController.text),
                      _selectedType,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(mission == null ? 'Añadir' : 'Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MissionPlanProvider>(
      builder: (context, provider, child) {
        final plan = provider.missionPlans.firstWhere(
          (p) => p.id == widget.missionPlanId,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text('Misiones de ${plan.name}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Añadir nueva misión',
                onPressed: () => _showAddEditMissionDialog(),
              ),
            ],
          ),
          body: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              provider.reorderMissionsInPlan(
                widget.missionPlanId,
                oldIndex,
                newIndex,
              );
            },
            itemCount: plan.missions.length,
            itemBuilder: (context, index) {
              final mission = plan.missions[index];
              return Dismissible(
                key: Key(mission.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  provider.removeMissionFromPlan(
                    widget.missionPlanId,
                    mission.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Misión "${mission.name}" eliminada'),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  child: ListTile(
                    title: Text(mission.name),
                    subtitle: Text(
                      '${mission.points} puntos - Tipo: ${mission.type == MissionType.multiple ? 'Múltiple' : 'Única'}\n${mission.description != null && mission.description!.isNotEmpty ? 'Descripción: ${mission.description}' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showAddEditMissionDialog(mission: mission),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
