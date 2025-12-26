import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ProgrammeView extends StatefulWidget {
  const ProgrammeView({Key? key}) : super(key: key);

  @override
  State<ProgrammeView> createState() => _ProgrammeViewState();
}

class _ProgrammeViewState extends State<ProgrammeView> {
  // Variables d'état
  File? _selectedFile;
  bool _isUploading = false;
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  Timer? _generationTimer;

  // Données simulées
  final List<GeneratedProgram> _generatedPrograms = [];
  final Map<String, File> _uploadedFiles = {};

  // Monitoring
  bool _monitoringActive = false;

  @override
  void initState() {
    super.initState();
    _startMonitoringSimulation();
  }

  @override
  void dispose() {
    _monitoringActive = false;
    _generationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: isMobile ? _buildAppBar(theme) : null,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Générateur de Programme'),
      backgroundColor: theme.primaryColor,
      elevation: 2,
      actions: [
        if (_generatedPrograms.isNotEmpty)
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Actions"),
                  content: const Text("Options supplémentaires"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Fermer"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUploadSection(),
          const SizedBox(height: 20),

          if (_isGenerating) _buildGenerationProgress(),
          const SizedBox(height: 20),

          if (_isGenerating || _generatedPrograms.isNotEmpty)
            _buildGeneratedProgramsSection(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne gauche : Contenu principal
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildUploadSection(),
                const SizedBox(height: 20),

                if (_isGenerating) _buildGenerationProgress(),
                const SizedBox(height: 20),

                if (_isGenerating || _generatedPrograms.isNotEmpty)
                  _buildGeneratedProgramsSection(),
              ],
            ),
          ),
        ),

        // Colonne droite : Panel d'information
        Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(left: BorderSide(color: Colors.grey[300]!)),
          ),
          child: _buildInfoPanel(),
        ),
      ],
    );
  }

  // ============================================
  // SECTION UPLOAD
  // ============================================

  Widget _buildUploadSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload, color: Color(0xFF6BA5BD)),
                const SizedBox(width: 12),
                const Text(
                  "Upload du Programme",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Sélectionnez un fichier PDF contenant les informations du cours.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            if (_isUploading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Upload en cours...",
                  style: TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildFileDropZone(),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedFile != null && !_isUploading
                    ? _simulateUploadProcess
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BA5BD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isUploading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : const Icon(Icons.send, size: 20),
                label: _isUploading
                    ? const Text("ENVOI EN COURS...")
                    : const Text("ENVOYER À L'IA"),
              ),
            ),

            if (_selectedFile != null && !_isUploading) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                  });
                },
                icon: const Icon(Icons.close, size: 18),
                label: const Text("ANNULER LA SÉLECTION"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileDropZone() {
    final borderColor = _selectedFile != null ? Colors.green : Colors.grey[300]!;
    final backgroundColor = _selectedFile != null ? Colors.green[50] : Colors.grey[50];

    return GestureDetector(
      onTap: _isUploading ? null : _pickPDFFile,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: _selectedFile == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                "Cliquez pour sélectionner un PDF",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                "Format accepté : .pdf",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _selectedFile!.path.split('/').last,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Prêt à être envoyé à l'IA",
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // PROGRESSION DE GÉNÉRATION
  // ============================================

  Widget _buildGenerationProgress() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, color: Color(0xFF6BA5BD)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "IA en action...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${(_generationProgress * 100).toInt()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6BA5BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _generationProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6BA5BD)),
              borderRadius: BorderRadius.circular(10),
              minHeight: 10,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getGenerationStep(_generationProgress),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  _getEstimatedTime(_generationProgress),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGenerationStep(double progress) {
    if (progress < 0.3) return "📖 Analyse du PDF...";
    if (progress < 0.6) return "🤖 Traitement par l'IA...";
    if (progress < 0.9) return "✏️ Génération du programme...";
    return "✅ Finalisation...";
  }

  String _getEstimatedTime(double progress) {
    final remaining = ((1 - progress) * 30).toInt();
    return "Environ $remaining secondes";
  }

  // ============================================
  // LISTE DES PROGRAMMES GÉNÉRÉS
  // ============================================

  Widget _buildGeneratedProgramsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.library_books, color: Color(0xFF6BA5BD)),
                const SizedBox(width: 12),
                const Text(
                  "Programmes Générés",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                if (_generatedPrograms.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BA5BD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_generatedPrograms.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6BA5BD),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_generatedPrograms.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: _generatedPrograms.map(_buildProgramCard).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucun programme généré",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Les programmes générés par l'IA apparaîtront ici",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(GeneratedProgram program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6BA5BD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: Color(0xFF6BA5BD),
          ),
        ),
        title: Text(
          program.fileName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Généré le ${_formatDateTime(program.generatedAt)}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (program.description != null) ...[
              const SizedBox(height: 4),
              Text(
                program.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _viewProgramDetails(program),
              icon: const Icon(Icons.visibility),
              tooltip: "Voir les détails",
              color: const Color(0xFF6BA5BD),
            ),
            IconButton(
              onPressed: () => _deleteProgram(program),
              icon: const Icon(Icons.delete_outline),
              tooltip: "Supprimer",
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PANEL D'INFORMATIONS
  // ============================================

  Widget _buildInfoPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📋 Comment ça marche",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6BA5BD),
          ),
        ),
        const SizedBox(height: 20),

        _buildInfoStep(
          icon: Icons.cloud_upload,
          title: "1. Upload PDF",
          description: "Sélectionnez votre fichier PDF",
        ),

        const SizedBox(height: 20),

        _buildInfoStep(
          icon: Icons.smart_toy,
          title: "2. Analyse IA",
          description: "Notre IA analyse le contenu",
        ),

        const SizedBox(height: 20),

        _buildInfoStep(
          icon: Icons.download,
          title: "3. Téléchargement",
          description: "Récupérez le programme optimisé",
        ),

        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6BA5BD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "💡 Conseil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6BA5BD),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Votre PDF doit contenir :\n• Objectifs pédagogiques\n• Contenu du cours\n• Durée estimée",
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6BA5BD), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // LOGIQUE MÉTIER
  // ============================================

  Future<void> _pickPDFFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          setState(() {
            _selectedFile = File(filePath);
          });
        }
      }
    } catch (e) {
      _showMessage("Erreur de sélection: $e", isError: true);
    }
  }

  Future<void> _simulateUploadProcess() async {
    if (_selectedFile == null) return;

    setState(() => _isUploading = true);

    // Simuler un délai d'upload
    await Future.delayed(const Duration(seconds: 2));

    // Stocker le fichier (simulation)
    final fileName = _selectedFile!.path.split('/').last;
    _uploadedFiles[fileName] = _selectedFile!;

    // Démarrer la génération
    _startGenerationProcess(fileName);

    setState(() {
      _isUploading = false;
      _selectedFile = null;
    });

    _showMessage("PDF envoyé à l'IA avec succès !");
  }

  void _startGenerationProcess(String fileName) {
    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
    });

    // Annuler le timer précédent
    _generationTimer?.cancel();

    // Simuler la progression
    const totalSteps = 100;
    int currentStep = 0;

    _generationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      currentStep++;
      setState(() {
        _generationProgress = currentStep / totalSteps;
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        _completeGeneration(fileName);
      }
    });
  }

  void _completeGeneration(String originalFileName) {
    // Générer un nom pour le fichier produit
    final baseName = originalFileName.replaceAll('.pdf', '');
    final generatedName = 'programme_${baseName}_generated_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // Ajouter aux programmes générés
    final newProgram = GeneratedProgram(
      fileName: generatedName,
      generatedAt: DateTime.now(),
      description: "Programme généré par IA",
    );

    setState(() {
      _generatedPrograms.insert(0, newProgram);
      _isGenerating = false;
      _generationProgress = 0.0;
    });

    _showMessage("✅ Programme généré avec succès !");
  }

  void _startMonitoringSimulation() {
    _monitoringActive = true;

    // Simuler la surveillance périodique
    Future.delayed(const Duration(seconds: 30), () {
      if (_monitoringActive && mounted) {
        // Pourrait simuler la détection de nouveaux fichiers
        _startMonitoringSimulation();
      }
    });
  }

  void _viewProgramDetails(GeneratedProgram program) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Détails du Programme",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Fichier:", program.fileName),
              _buildDetailRow("Date:", _formatDateTime(program.generatedAt)),
              _buildDetailRow("Statut:", "Complété"),
              if (program.description != null)
                _buildDetailRow("Description:", program.description!),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showMessage("Téléchargement simulé");
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BA5BD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("TÉLÉCHARGER LE PROGRAMME"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _deleteProgram(GeneratedProgram program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le programme"),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer \"${program.fileName}\" ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _generatedPrograms.remove(program);
                _uploadedFiles.removeWhere(
                      (key, value) => key.contains(program.fileName),
                );
              });
              Navigator.pop(context);
              _showMessage("Programme supprimé");
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("SUPPRIMER"),
          ),
        ],
      ),
    );
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF6BA5BD),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ============================================
// MODÈLE DE DONNÉES
// ============================================

class GeneratedProgram {
  final String fileName;
  final DateTime generatedAt;
  final String? description;

  GeneratedProgram({
    required this.fileName,
    required this.generatedAt,
    this.description,
  });
}