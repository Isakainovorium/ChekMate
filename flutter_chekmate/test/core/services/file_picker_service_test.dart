import 'dart:io';

import 'package:flutter_chekmate/core/services/file_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilePickerService', () {
    group('File Extension Detection', () {
      test('getFileExtension should return correct extension', () {
        expect(FilePickerService.getFileExtension(File('test.pdf')), 'pdf');
        expect(FilePickerService.getFileExtension(File('image.jpg')), 'jpg');
        expect(FilePickerService.getFileExtension(File('video.mp4')), 'mp4');
        expect(
            FilePickerService.getFileExtension(File('document.DOCX')), 'docx',);
      });

      test('getFileExtension should return empty string for no extension', () {
        expect(FilePickerService.getFileExtension(File('noextension')), '');
      });

      test('getFileExtension should handle multiple dots', () {
        expect(FilePickerService.getFileExtension(File('my.file.pdf')), 'pdf');
      });
    });

    group('File Type Checking', () {
      test('isImage should return true for image files', () {
        expect(FilePickerService.isImage(File('photo.jpg')), true);
        expect(FilePickerService.isImage(File('image.jpeg')), true);
        expect(FilePickerService.isImage(File('picture.png')), true);
        expect(FilePickerService.isImage(File('animation.gif')), true);
        expect(FilePickerService.isImage(File('bitmap.bmp')), true);
        expect(FilePickerService.isImage(File('web.webp')), true);
      });

      test('isImage should return false for non-image files', () {
        expect(FilePickerService.isImage(File('document.pdf')), false);
        expect(FilePickerService.isImage(File('video.mp4')), false);
        expect(FilePickerService.isImage(File('audio.mp3')), false);
      });

      test('isVideo should return true for video files', () {
        expect(FilePickerService.isVideo(File('video.mp4')), true);
        expect(FilePickerService.isVideo(File('clip.mov')), true);
        expect(FilePickerService.isVideo(File('movie.avi')), true);
        expect(FilePickerService.isVideo(File('film.mkv')), true);
        expect(FilePickerService.isVideo(File('flash.flv')), true);
        expect(FilePickerService.isVideo(File('windows.wmv')), true);
      });

      test('isVideo should return false for non-video files', () {
        expect(FilePickerService.isVideo(File('document.pdf')), false);
        expect(FilePickerService.isVideo(File('image.jpg')), false);
        expect(FilePickerService.isVideo(File('audio.mp3')), false);
      });

      test('isDocument should return true for document files', () {
        expect(FilePickerService.isDocument(File('document.pdf')), true);
        expect(FilePickerService.isDocument(File('report.doc')), true);
        expect(FilePickerService.isDocument(File('essay.docx')), true);
        expect(FilePickerService.isDocument(File('spreadsheet.xls')), true);
        expect(FilePickerService.isDocument(File('data.xlsx')), true);
        expect(FilePickerService.isDocument(File('presentation.ppt')), true);
        expect(FilePickerService.isDocument(File('slides.pptx')), true);
        expect(FilePickerService.isDocument(File('notes.txt')), true);
      });

      test('isDocument should return false for non-document files', () {
        expect(FilePickerService.isDocument(File('image.jpg')), false);
        expect(FilePickerService.isDocument(File('video.mp4')), false);
        expect(FilePickerService.isDocument(File('audio.mp3')), false);
      });

      test('file type checks should be case-insensitive', () {
        expect(FilePickerService.isImage(File('photo.JPG')), true);
        expect(FilePickerService.isVideo(File('video.MP4')), true);
        expect(FilePickerService.isDocument(File('document.PDF')), true);
      });
    });

    group('File Picker Exception', () {
      test('FilePickerException should have correct message', () {
        const exception = FilePickerException('Test error');
        expect(exception.message, 'Test error');
        expect(exception.toString(), 'FilePickerException: Test error');
      });
    });
  });
}
