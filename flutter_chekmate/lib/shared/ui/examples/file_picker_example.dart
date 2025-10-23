import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/services/file_picker_service.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';

/// File Picker Example Page
///
/// Demonstrates file selection using FilePickerService.
/// Shows examples for images, videos, documents, and custom file types.
class FilePickerExamplePage extends StatefulWidget {
  const FilePickerExamplePage({super.key});

  @override
  State<FilePickerExamplePage> createState() => _FilePickerExamplePageState();
}

class _FilePickerExamplePageState extends State<FilePickerExamplePage> {
  File? _selectedFile;
  List<File> _selectedFiles = [];
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSectionHeader('Single File Selection'),
          const SizedBox(height: AppSpacing.sm),
          _buildSingleFileButtons(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Multiple File Selection'),
          const SizedBox(height: AppSpacing.sm),
          _buildMultipleFileButtons(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('Custom File Types'),
          const SizedBox(height: AppSpacing.sm),
          _buildCustomFileButtons(),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionHeader('File Validation'),
          const SizedBox(height: AppSpacing.sm),
          _buildFileValidationButtons(),
          const SizedBox(height: AppSpacing.lg),
          if (_statusMessage.isNotEmpty) ...[
            _buildSectionHeader('Status'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(_statusMessage),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (_selectedFile != null) ...[
            _buildSectionHeader('Selected File'),
            const SizedBox(height: AppSpacing.sm),
            _buildFileInfo(_selectedFile!),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (_selectedFiles.isNotEmpty) ...[
            _buildSectionHeader('Selected Files (${_selectedFiles.length})'),
            const SizedBox(height: AppSpacing.sm),
            ..._selectedFiles.map(
              (file) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildFileInfo(file),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSingleFileButtons() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            onPressed: _pickImage,
            child: const Text('Pick Image'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickVideo,
            child: const Text('Pick Video'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickAudio,
            child: const Text('Pick Audio'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickDocument,
            child: const Text('Pick Document'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickAnyFile,
            child: const Text('Pick Any File'),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleFileButtons() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            onPressed: _pickMultipleImages,
            child: const Text('Pick Multiple Images'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickMultipleVideos,
            child: const Text('Pick Multiple Videos'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickMultipleDocuments,
            child: const Text('Pick Multiple Documents'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickMultipleFiles,
            child: const Text('Pick Multiple Files'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomFileButtons() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            onPressed: _pickPdfOnly,
            child: const Text('Pick PDF Only'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickImageOrVideo,
            child: const Text('Pick Image or Video'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickTextFile,
            child: const Text('Pick Text File'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileValidationButtons() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            onPressed: _pickImageWithSizeLimit,
            child: const Text('Pick Image (Max 5MB)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            onPressed: _pickVideoWithSizeLimit,
            child: const Text('Pick Video (Max 50MB)'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo(File file) {
    final fileName = file.path.split('/').last;
    final extension = FilePickerService.getFileExtension(file);
    final isImage = FilePickerService.isImage(file);
    final isVideo = FilePickerService.isVideo(file);
    final isDoc = FilePickerService.isDocument(file);

    IconData icon;
    if (isImage) {
      icon = Icons.image;
    } else if (isVideo) {
      icon = Icons.video_file;
    } else if (isDoc) {
      icon = Icons.description;
    } else {
      icon = Icons.insert_drive_file;
    }

    return AppCard(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(fileName),
        subtitle: FutureBuilder<double>(
          future: FilePickerService.getFileSizeInMB(file),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                '${snapshot.data!.toStringAsFixed(2)} MB • $extension',
              );
            }
            return Text(extension);
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _selectedFile = null;
              _selectedFiles.remove(file);
            });
          },
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final file = await FilePickerService.pickImage();
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage = file != null ? 'Image selected' : 'No image selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final file = await FilePickerService.pickVideo();
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage = file != null ? 'Video selected' : 'No video selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick video: $e');
    }
  }

  Future<void> _pickAudio() async {
    try {
      final file = await FilePickerService.pickAudio();
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage = file != null ? 'Audio selected' : 'No audio selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick audio: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final file = await FilePickerService.pickDocument();
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage =
            file != null ? 'Document selected' : 'No document selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick document: $e');
    }
  }

  Future<void> _pickAnyFile() async {
    try {
      final file = await FilePickerService.pickFile();
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage = file != null ? 'File selected' : 'No file selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final files = await FilePickerService.pickImages(maxFiles: 10);
      setState(() {
        _selectedFile = null;
        _selectedFiles = files;
        _statusMessage = '${files.length} images selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick images: $e');
    }
  }

  Future<void> _pickMultipleVideos() async {
    try {
      final files = await FilePickerService.pickVideos(maxFiles: 5);
      setState(() {
        _selectedFile = null;
        _selectedFiles = files;
        _statusMessage = '${files.length} videos selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick videos: $e');
    }
  }

  Future<void> _pickMultipleDocuments() async {
    try {
      final files = await FilePickerService.pickDocuments(maxFiles: 10);
      setState(() {
        _selectedFile = null;
        _selectedFiles = files;
        _statusMessage = '${files.length} documents selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick documents: $e');
    }
  }

  Future<void> _pickMultipleFiles() async {
    try {
      final files = await FilePickerService.pickFiles(maxFiles: 10);
      setState(() {
        _selectedFile = null;
        _selectedFiles = files;
        _statusMessage = '${files.length} files selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick files: $e');
    }
  }

  Future<void> _pickPdfOnly() async {
    try {
      final file = await FilePickerService.pickFile(
        allowedExtensions: ['pdf'],
      );
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage = file != null ? 'PDF selected' : 'No PDF selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick PDF: $e');
    }
  }

  Future<void> _pickImageOrVideo() async {
    try {
      final file = await FilePickerService.pickFile(
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      );
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage =
            file != null ? 'Image/Video selected' : 'No file selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _pickTextFile() async {
    try {
      final file = await FilePickerService.pickFile(
        allowedExtensions: ['txt'],
      );
      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage =
            file != null ? 'Text file selected' : 'No text file selected';
      });
    } on Exception catch (e) {
      _showError('Failed to pick text file: $e');
    }
  }

  Future<void> _pickImageWithSizeLimit() async {
    try {
      final file = await FilePickerService.pickImage();
      if (file == null) {
        setState(() {
          _statusMessage = 'No image selected';
        });
        return;
      }

      final isValid = await FilePickerService.validateFileSize(file, 5);
      if (!isValid) {
        _showError('Image must be less than 5MB');
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage = 'Image selected (within size limit)';
      });
    } on Exception catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickVideoWithSizeLimit() async {
    try {
      final file = await FilePickerService.pickVideo();
      if (file == null) {
        setState(() {
          _statusMessage = 'No video selected';
        });
        return;
      }

      final isValid = await FilePickerService.validateFileSize(file, 50);
      if (!isValid) {
        _showError('Video must be less than 50MB');
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectedFiles = [];
        _statusMessage = 'Video selected (within size limit)';
      });
    } on Exception catch (e) {
      _showError('Failed to pick video: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _statusMessage = 'Error: $message';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
