import 'package:arted/project_workspace_page.dart';
import 'package:flutter/material.dart';
import 'editor_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const bgColor = Color(0xFF121212);
  static const panelColor = Color(0xFF1E1E1E);
  static const cardColor = Color(0xFF242424);
  static const textGrey = Colors.grey;

  final List<Project> projects = [
    Project(
      name: "Sample project",
      description: "Example encyclopedia project",
      createdAt: DateTime(2025, 11, 7),
    ),
  ];

  /// ---------------- NEW PROJECT DIALOG ----------------
  void _showNewProjectDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: panelColor,
          title: const Text(
            "New Project",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Project Name",
                    labelStyle: TextStyle(color: textGrey),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(color: textGrey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: textGrey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                setState(() {
                  projects.add(
                    Project(
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
                });

                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          /// ---------------- SIDEBAR ----------------
          Container(
            width: 240,
            color: panelColor,
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  "Encyclopaedia",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Article Creation Tool",
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
                SizedBox(height: 32),
                ListTile(
                  leading: Icon(Icons.dashboard, color: Colors.white),
                  title: Text(
                    "Dashboard",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          /// ---------------- MAIN CONTENT ----------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Encyclopaedia",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Create and manage your article projects",
                            style: TextStyle(color: textGrey, fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 220,
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Search projects...",
                                hintStyle: const TextStyle(color: textGrey),
                                filled: true,
                                fillColor: cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _showNewProjectDialog,
                            icon: const Icon(Icons.add),
                            label: const Text("New Project"),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// STATS
                  Row(
                    children: [
                      _statCard(
                        projects.length.toString(),
                        "Total Projects",
                        Icons.folder,
                      ),
                      _statCard("0", "Total Articles", Icons.description),
                      _statCard("0", "Words Written", Icons.trending_up),
                      _statCard(
                        _formatDate(projects.last.createdAt),
                        "Last Updated",
                        Icons.schedule,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// PROJECT LIST
                  Text(
                    "Your Projects (${projects.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: projects.map(_projectCard).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- STAT CARD ----------------
  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: textGrey)),
          ],
        ),
      ),
    );
  }

  /// ---------------- PROJECT CARD ----------------
  Widget _projectCard(Project project) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectWorkspacePage(project: project),
          ),
        );
      },
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: const TextStyle(color: textGrey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              _formatDate(project.createdAt),
              style: const TextStyle(color: textGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
}

/// ---------------- PROJECT MODEL ----------------
class Project {
  final String name;
  final String description;
  final DateTime createdAt;

  Project({
    required this.name,
    required this.description,
    required this.createdAt,
  });
}
