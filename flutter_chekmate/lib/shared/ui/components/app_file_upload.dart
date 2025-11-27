import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppFileUpload - File selection with drag-drop, progress, and preview
class AppFileUpload extends StatefulWidget {
  const AppFileUpload({
    super.key,
    this.onFilesSelected,
    this.allowMultiple = false,
    this.acceptedTypes = const [],
    this.maxFileSize,
    this.maxFiles,
    this.showPreview = true,
    this.enabled = true,
    this.placeholder = 'Drag and drop files here, or click to browse',
    this.uploadText = 'Upload Files',
    this.browseText = 'Browse',
  });

  final void Function(List<AppUploadFile>)? onFilesSelected;
  final bool allowMultiple;
  final List<String> acceptedTypes; // e.g., ['jpg', 'png', 'pdf']
  final int? maxFileSize; // in bytes
  final int? maxFiles;
  final bool showPreview;
  final bool enabled;
  final String placeholder;
  final String uploadText;
  final String browseText;

  @override
  State<AppFileUpload> createState() => _AppFileUploadState();
}

class _AppFileUploadState extends State<AppFileUpload> {
  final List<AppUploadFile> _files = [];
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload area
        GestureDetector(
          onTap: widget.enabled ? _selectFiles : null,
          child: DragTarget<List<String>>(
            onWillAcceptWithDetails: (data) => widget.enabled,
            onAcceptWithDetails: (data) => _handleDroppedFiles(data.data),
            onMove: (_) => setState(() => _isDragOver = true),
            onLeave: (_) => setState(() => _isDragOver = false),
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isDragOver
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: _isDragOver ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _isDragOver
                      ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                      : widget.enabled
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: widget.enabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.placeholder,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: widget.enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: widget.enabled ? _selectFiles : null,
                      icon: const Icon(Icons.folder_open),
                      label: Text(widget.browseText),
                    ),
                    if (widget.acceptedTypes.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Accepted formats: ${widget.acceptedTypes.join(', ')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (widget.maxFileSize != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Max file size: ${_formatFileSize(widget.maxFileSize!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        
        // File list
        if (_files.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ...(_files.map((file) => _FileItem(
            file: file,
            showPreview: widget.showPreview,
            onRemove: () => _removeFile(file),
          ),)),
        ],
      ],
    );
  }

  Future<void> _selectFiles() async {
    try {
      // Note: In a real implementation, you would use file_picker package
      // For now, this is a placeholder that simulates file selection
      
      // Simulated file selection - replace with actual file picker
      final selectedFiles = <AppUploadFile>[];
      
      // Example of how it would work with file_picker:
      // final result = await FilePicker.platform.pickFiles(
      //   allowMultiple: widget.allowMultiple,
      //   type: widget.acceptedTypes.isNotEmpty ? FileType.custom : FileType.any,
      //   allowedExtensions: widget.acceptedTypes.isNotEmpty ? widget.acceptedTypes : null,
      // );
      
      // if (result != null) {
      //   selectedFiles = result.files.map((file) => AppUploadFile(
      //     name: file.name,
      //     size: file.size,
      //     path: file.path,
      //     bytes: file.bytes,
      //   )).toList();
      // }
      
      _addFiles(selectedFiles);
    } on Exception catch (e) {
      _showError('Failed to select files: $e');
    }
  }

  void _handleDroppedFiles(List<String> filePaths) {
    final droppedFiles = filePaths.map((path) {
      final file = File(path);
      return AppUploadFile(
        name: file.path.split('/').last,
        size: file.lengthSync(),
        path: path,
      );
    }).toList();
    
    _addFiles(droppedFiles);
  }

  void _addFiles(List<AppUploadFile> newFiles) {
    final validFiles = <AppUploadFile>[];
    
    for (final file in newFiles) {
      // Validate file type
      if (widget.acceptedTypes.isNotEmpty) {
        final extension = file.name.split('.').last.toLowerCase();
        if (!widget.acceptedTypes.contains(extension)) {
          _showError('File type not allowed: ${file.name}');
          continue;
        }
      }
      
      // Validate file size
      if (widget.maxFileSize != null && file.size > widget.maxFileSize!) {
        _showError('File too large: ${file.name}');
        continue;
      }
      
      validFiles.add(file);
    }
    
    // Check max files limit
    if (widget.maxFiles != null) {
      final totalFiles = _files.length + validFiles.length;
      if (totalFiles > widget.maxFiles!) {
        _showError('Too many files. Maximum ${widget.maxFiles} allowed.');
        return;
      }
    }
    
    setState(() {
      if (widget.allowMultiple) {
        _files.addAll(validFiles);
      } else {
        _files.clear();
        if (validFiles.isNotEmpty) {
          _files.add(validFiles.first);
        }
      }
    });
    
    widget.onFilesSelected?.call(_files);
  }

  void _removeFile(AppUploadFile file) {
    setState(() {
      _files.remove(file);
    });
    widget.onFilesSelected?.call(_files);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _FileItem extends StatelessWidget {
  const _FileItem({
    required this.file,
    required this.showPreview,
    required this.onRemove,
  });

  final AppUploadFile file;
  final bool showPreview;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // File icon/preview
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(),
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatFileSize(file.size),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (file.uploadProgress != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value: file.uploadProgress! / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ],
              ],
            ),
          ),
          
          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    final extension = file.name.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Data class for uploaded files
class AppUploadFile {
  const AppUploadFile({
    required this.name,
    required this.size,
    this.path,
    this.bytes,
    this.uploadProgress,
    this.error,
  });

  final String name;
  final int size;
  final String? path;
  final Uint8List? bytes;
  final double? uploadProgress; // 0-100
  final String? error;

  AppUploadFile copyWith({
    String? name,
    int? size,
    String? path,
    Uint8List? bytes,
    double? uploadProgress,
    String? error,
  }) {
    return AppUploadFile(
      name: name ?? this.name,
      size: size ?? this.size,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error ?? this.error,
    );
  }
}
