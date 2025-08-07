// lib/screens/mission_detail_screen.dart
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

  void _showDeleteConfirmationDialog(Mission mission) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<MissionPlanProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          title: const Text('Eliminar Misión'),
          content: Text(
            '¿Estás seguro de que quieres eliminar la misión "${mission.name}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.removeMissionFromPlan(
                  widget.missionPlanId,
                  mission.id,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Misión "${mission.name}" eliminada')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
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
          body: plan.missions.isEmpty
              ? const Center(child: Text('Añade misiones a este plan'))
              : ReorderableListView.builder(
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
                    return Card(
                      key: Key(mission.id),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          8,
                          0,
                        ), // Ajuste de padding a la derecha
                        title: Text(mission.name),
                        subtitle: Text(
                          '${mission.points} puntos - Tipo: ${mission.type == MissionType.multiple ? 'Múltiple' : 'Única'}\n${mission.description != null && mission.description!.isNotEmpty ? 'Descripción: ${mission.description}' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              visualDensity:
                                  VisualDensity.compact, // Ícono más compacto
                              onPressed: () =>
                                  _showAddEditMissionDialog(mission: mission),
                            ),
                            const SizedBox(
                              width: 4,
                            ), // Espacio reducido entre iconos
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              visualDensity:
                                  VisualDensity.compact, // Ícono más compacto
                              onPressed: () =>
                                  _showDeleteConfirmationDialog(mission),
                            ),
                          ],
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
