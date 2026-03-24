import 'package:flutter/material.dart';

/// A widget for capturing and managing media (images/videos) for pickups and drops
class MediaCaptureWidget extends StatefulWidget {
  const MediaCaptureWidget({
    super.key,
    required this.title,
    required this.onMediaAdded,
    required this.onMediaRemoved,
    this.maxFiles = 5,
    this.mediaList = const [],
  });

  final String title;
  final Function(String) onMediaAdded;
  final Function(String) onMediaRemoved;
  final int maxFiles;
  final List<String> mediaList;

  @override
  State<MediaCaptureWidget> createState() => _MediaCaptureWidgetState();
}

class _MediaCaptureWidgetState extends State<MediaCaptureWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canAddMore = widget.mediaList.length < widget.maxFiles;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.mediaList.length}/${widget.maxFiles}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.mediaList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No media captured yet',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.mediaList.length,
                itemBuilder: (context, index) {
                  return _MediaThumbnail(
                    mediaPath: widget.mediaList[index],
                    onRemove: () => widget.onMediaRemoved(widget.mediaList[index]),
                  );
                },
              ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canAddMore
                        ? () {
                            // TODO: Implement camera capture
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Camera capture - Coming soon')),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Capture Photo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canAddMore
                        ? () {
                            // TODO: Implement gallery picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gallery picker - Coming soon')),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('From Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  const _MediaThumbnail({
    required this.mediaPath,
    required this.onRemove,
  });

  final String mediaPath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 32,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.error,
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: colorScheme.onError, size: 16),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ),
      ],
    );
  }
}

/// A pre-trip checklist widget
class PreTripChecklistWidget extends StatefulWidget {
  const PreTripChecklistWidget({
    super.key,
    required this.onChecklistComplete,
    this.initialChecklist = const {},
  });

  final Function(Map<String, bool>) onChecklistComplete;
  final Map<String, bool> initialChecklist;

  @override
  State<PreTripChecklistWidget> createState() => _PreTripChecklistWidgetState();
}

class _PreTripChecklistWidgetState extends State<PreTripChecklistWidget> {
  late Map<String, bool> _checklist;

  @override
  void initState() {
    super.initState();
    _checklist = {
      'Vehicle Lights': widget.initialChecklist['Vehicle Lights'] ?? false,
      'Tire Pressure': widget.initialChecklist['Tire Pressure'] ?? false,
      'Brake System': widget.initialChecklist['Brake System'] ?? false,
      'Windshield & Wipers': widget.initialChecklist['Windshield & Wipers'] ?? false,
      'Horn': widget.initialChecklist['Horn'] ?? false,
      'Mirrors': widget.initialChecklist['Mirrors'] ?? false,
      'Fuel Level': widget.initialChecklist['Fuel Level'] ?? false,
      'Emergency Kit': widget.initialChecklist['Emergency Kit'] ?? false,
    };
  }

  void _updateChecklistItem(String key, bool value) {
    setState(() {
      _checklist[key] = value;
    });
    widget.onChecklistComplete(_checklist);
  }

  bool get _allChecked => _checklist.values.every((v) => v);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pre-Trip Safety Checklist',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_allChecked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outlined, size: 16, color: colorScheme.tertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Complete',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _checklist.values.where((v) => v).length / _checklist.length,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_checklist.values.where((v) => v).length}/${_checklist.length} items checked',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Checklist Items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _checklist.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final key = _checklist.keys.elementAt(index);
                final value = _checklist[key] ?? false;

                return CheckboxListTile(
                  value: value,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      _updateChecklistItem(key, newValue);
                    }
                  },
                  title: Text(
                    key,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  checkColor: colorScheme.onTertiary,
                  fillColor: WidgetStateProperty.all(colorScheme.tertiary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
