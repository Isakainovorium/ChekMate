import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';

/// AppColorPicker - Color selection with swatches, hex input, and eyedropper
class AppColorPicker extends StatefulWidget {
  const AppColorPicker({
    super.key,
    this.selectedColor,
    this.onColorChanged,
    this.showHexInput = true,
    this.showSwatches = true,
    this.showEyedropper = false,
    this.swatchColors,
    this.label,
  });

  final Color? selectedColor;
  final ValueChanged<Color>? onColorChanged;
  final bool showHexInput;
  final bool showSwatches;
  final bool showEyedropper;
  final List<Color>? swatchColors;
  final String? label;

  @override
  State<AppColorPicker> createState() => _AppColorPickerState();
}

class _AppColorPickerState extends State<AppColorPicker> {
  late Color _selectedColor;
  final TextEditingController _hexController = TextEditingController();
  
  static const List<Color> _defaultSwatches = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor ?? Colors.blue;
    _updateHexInput();
  }

  @override
  void didUpdateWidget(AppColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor && 
        widget.selectedColor != null) {
      _selectedColor = widget.selectedColor!;
      _updateHexInput();
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateHexInput() {
    _hexController.text = _colorToHex(_selectedColor);
  }

  void _onColorChanged(Color color) {
    setState(() {
      _selectedColor = color;
    });
    _updateHexInput();
    widget.onColorChanged?.call(color);
  }

  void _onHexChanged(String hex) {
    final color = _hexToColor(hex);
    if (color != null) {
      _onColorChanged(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        
        // Current color display
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Color',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _colorToHex(_selectedColor),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showEyedropper)
              IconButton(
                onPressed: _showEyedropper,
                icon: const Icon(Icons.colorize),
                tooltip: 'Pick color from screen',
              ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Hex input
        if (widget.showHexInput) ...[
          TextFormField(
            controller: _hexController,
            decoration: InputDecoration(
              labelText: 'Hex Color',
              prefixText: '#',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () => _onHexChanged(_hexController.text),
                icon: const Icon(Icons.check),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: _onHexChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        
        // Color swatches
        if (widget.showSwatches) ...[
          Text(
            'Color Swatches',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ColorSwatches(
            colors: widget.swatchColors ?? _defaultSwatches,
            selectedColor: _selectedColor,
            onColorSelected: _onColorChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        
        // HSV Color Picker
        Text(
          'Custom Color',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _HSVColorPicker(
          selectedColor: _selectedColor,
          onColorChanged: _onColorChanged,
        ),
      ],
    );
  }

  void _showEyedropper() {
    // Note: Eyedropper functionality would require platform-specific implementation
    // This is a placeholder for the UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eyedropper functionality requires platform-specific implementation'),
      ),
    );
  }

  String _colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }

  Color? _hexToColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
    } on Exception {
      // Invalid hex color
    }
    return null;
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches({
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: colors.map((color) {
        final isSelected = color.value == selectedColor.value;
        
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: _getContrastColor(color),
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use white or black text
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class _HSVColorPicker extends StatefulWidget {
  const _HSVColorPicker({
    required this.selectedColor,
    required this.onColorChanged,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<_HSVColorPicker> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.selectedColor);
  }

  @override
  void didUpdateWidget(_HSVColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor) {
      _hsvColor = HSVColor.fromColor(widget.selectedColor);
    }
  }

  void _updateColor(HSVColor newColor) {
    setState(() {
      _hsvColor = newColor;
    });
    widget.onColorChanged(_hsvColor.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hue slider
        _ColorSlider(
          label: 'Hue',
          value: _hsvColor.hue,
          max: 360,
          onChanged: (value) => _updateColor(_hsvColor.withHue(value)),
          gradient: LinearGradient(
            colors: [
              for (int i = 0; i <= 360; i += 60)
                HSVColor.fromAHSV(1.0, i.toDouble(), 1.0, 1.0).toColor(),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Saturation slider
        _ColorSlider(
          label: 'Saturation',
          value: _hsvColor.saturation,
          max: 1.0,
          onChanged: (value) => _updateColor(_hsvColor.withSaturation(value)),
          gradient: LinearGradient(
            colors: [
              _hsvColor.withSaturation(0.0).toColor(),
              _hsvColor.withSaturation(1.0).toColor(),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Value/Brightness slider
        _ColorSlider(
          label: 'Brightness',
          value: _hsvColor.value,
          max: 1.0,
          onChanged: (value) => _updateColor(_hsvColor.withValue(value)),
          gradient: LinearGradient(
            colors: [
              _hsvColor.withValue(0.0).toColor(),
              _hsvColor.withValue(1.0).toColor(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.gradient,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              max == 1.0 
                  ? '${(value * 100).round()}%'
                  : value.round().toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 30,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 30,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
