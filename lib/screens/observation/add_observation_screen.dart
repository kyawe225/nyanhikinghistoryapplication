import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiking_app_one/database/entities.dart';
import 'package:hiking_app_one/providers/observation_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // new import for nicer date formatting
import 'package:uuid/uuid.dart';

class AddObservationScreen extends ConsumerStatefulWidget {
  final String hikingHistoryId;
  final Observation? existing; // optional existing observation for edit
  const AddObservationScreen({super.key, required this.hikingHistoryId, this.existing});

  @override
  ConsumerState<AddObservationScreen> createState() => _AddObservationScreenState();
}

class _AddObservationScreenState extends ConsumerState<AddObservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _commentsController = TextEditingController();
  final _dateController = TextEditingController();
  // default must be one of the items in _types
  String _type = 'Text';
  String? _imageBase64;
  Uint8List? _imagePreviewBytes;
  DateTime _date = DateTime.now();

  final List<String> _types = ['Text', 'Image'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? file;
      if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        file = await picker.pickImage(source: ImageSource.gallery);
      } else {
        file = await picker.pickImage(source: ImageSource.camera);
      }
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBase64 = base64Encode(bytes);
          _imagePreviewBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _type = e.observationType;
      _date = e.observationDate;
      _dateController.text = DateFormat.yMd().format(_date);
      _commentsController.text = e.additionalComments;
      if (_type.toLowerCase() == 'image' && (e.observation.isNotEmpty)) {
        try {
          final bytes = base64Decode(e.observation);
          _imageBase64 = e.observation;
          _imagePreviewBytes = bytes;
        } catch (_) {
          // not base64 - ignore or leave preview empty
        }
      } else {
        _textController.text = e.observation;
      }
    } else {
      _dateController.text = DateFormat.yMd().format(_date);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _commentsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // If image type, require image; otherwise validate form text.
    if (_type == 'Image') {
      if (_imageBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick/take an image')));
        return;
      }
    } else {
      // Ensure the Form is present and valid
      final valid = _formKey.currentState?.validate() ?? false;
      if (!valid) {
        // Provide a clearer message if validation failed
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an observation')));
        return;
      }
    }

    // store base64 string for images, plain text for text observations
    final obsText = (_type == 'Image') ? (_imageBase64 ?? '') : _textController.text.trim();

    final obs = Observation(
      id: widget.existing?.id ?? const Uuid().v4(),
      hikingHistoryId: widget.hikingHistoryId,
      observationDate: _date,
      additionalComments: _commentsController.text.trim(),
      observation: obsText,
      observationType: _type,
    );

    try {
      final notifier = ref.read(observationsProvider(widget.hikingHistoryId).notifier);
      if (widget.existing != null) {
        // try update; if provider doesn't expose updateObservation this will show error in console
        await notifier.updateObservation(obs);
      } else {
        await notifier.addObservation(obs);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save observation: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Observation' : 'Add Observation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Observation Type *'),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _type = v ?? _types.first),
              ),
              const SizedBox(height: 12),
              // Date field presented as a read-only TextFormField to match other inputs
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Observation Date *'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
                      _dateController.text = DateFormat.yMd().format(_date);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              if (_type == 'Image') ...[
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Pick / Take Photo *'),
                ),
                if (_imagePreviewBytes != null) Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.memory(_imagePreviewBytes!, height: 200),
                ),
              ] else ...[
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Observation Text *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter observation' : null,
                  maxLines: null,
                ),
              ],

              // Additional comments should always be visible (image or text)
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(labelText: 'Additional Comments'),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
