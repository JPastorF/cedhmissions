// lib/screens/mission_plans_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_plan_provider.dart';
import 'mission_detail_screen.dart';
import '../models/mission_plan.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:convert';

class MissionPlansScreen extends StatefulWidget {
  const MissionPlansScreen({super.key});

  @override
  State<MissionPlansScreen> createState() => _MissionPlansScreenState();
}

class _MissionPlansScreenState extends State<MissionPlansScreen> {
  final TextEditingController _planNameController = TextEditingController();

  Future<void> _importMissionPlan() async {
    final provider = Provider.of<MissionPlanProvider>(context, listen: false);

    try {
      // 1. Abrir el diálogo para seleccionar un archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          // 2. Leer el contenido del archivo como una cadena
          File file = File(filePath);
          String jsonContent = await file.readAsString();

          // 3. Decodificar el JSON a un mapa de Dart
          Map<String, dynamic> jsonData = jsonDecode(jsonContent);

          // 4. Crear un objeto MissionPlan usando el constructor de fábrica
          MissionPlan newPlan = MissionPlan.fromJson(jsonData);

          // 5. Añadir el nuevo plan al proveedor
          provider.importMissionPlan(newPlan);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Plan "${newPlan.name}" importado con éxito.'),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Importación cancelada.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar el archivo: $e')),
        );
      }
    }
  }

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

  // Nuevo método para mostrar el diálogo de confirmación
  void _showDeleteConfirmationDialog(String planId) {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<MissionPlanProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este plan de misión? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                provider.removeMissionPlan(planId);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
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
          IconButton(
            icon: const Icon(Icons.download_for_offline),
            tooltip: 'Importar plan de misiones',
            onPressed: _importMissionPlan,
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
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.deepOrangeAccent,
                        ),
                        tooltip: 'Eliminar plan',
                        // Se actualiza el onPressed para llamar al nuevo método
                        onPressed: () => _showDeleteConfirmationDialog(plan.id),
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
