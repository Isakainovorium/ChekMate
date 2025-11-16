import 'package:flutter/material.dart';
import 'package:flutter_chekmate/shared/ui/index.dart';
import 'package:widgetbook/widgetbook.dart';

/// Form Components Showcases
///
/// Interactive showcases for all form-related components:
/// 1. AppButton
/// 2. AppInput
/// 3. AppTextarea
/// 4. AppSelect
/// 5. AppCheckbox
/// 6. AppSwitch
/// 7. AppRadioGroup
/// 8. AppSlider
/// 9. AppInputOTP
/// 10. AppCalendar
/// 11. AppDatePicker
class FormComponentShowcases {
  static List<WidgetbookComponent> get showcases => [
        // AppButton
        WidgetbookComponent(
          name: 'AppButton',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppButton(
                onPressed: () {},
                child: Text(
                  context.knobs.string(
                    label: 'Text',
                    initialValue: 'Click Me',
                  ),
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'Variants',
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    onPressed: () {},
                    variant: AppButtonVariant.secondary,
                    child: const Text('Secondary'),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    onPressed: () {},
                    variant: AppButtonVariant.outline,
                    child: const Text('Outline'),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    onPressed: () {},
                    variant: AppButtonVariant.text,
                    child: const Text('Text'),
                  ),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'Sizes',
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    onPressed: () {},
                    size: AppButtonSize.sm,
                    child: const Text('Small'),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    onPressed: () {},
                    child: const Text('Medium'),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    onPressed: () {},
                    size: AppButtonSize.lg,
                    child: const Text('Large'),
                  ),
                ],
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icon',
              builder: (context) => AppButton(
                onPressed: () {},
                leadingIcon: const Icon(Icons.favorite),
                child: const Text('Like'),
              ),
            ),
            WidgetbookUseCase(
              name: 'Loading',
              builder: (context) => AppButton(
                onPressed: () {},
                isLoading: true,
                child: const Text('Loading...'),
              ),
            ),
            WidgetbookUseCase(
              name: 'Disabled',
              builder: (context) => const AppButton(
                onPressed: null,
                child: Text('Disabled'),
              ),
            ),
          ],
        ),

        // AppInput
        WidgetbookComponent(
          name: 'AppInput',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppInput(
                label: context.knobs.string(
                  label: 'Label',
                  initialValue: 'Email',
                ),
                hint: context.knobs.string(
                  label: 'Hint',
                  initialValue: 'Enter your email',
                ),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Icon',
              builder: (context) => const AppInput(
                label: 'Search',
                hint: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            WidgetbookUseCase(
              name: 'Password',
              builder: (context) => const AppInput(
                label: 'Password',
                hint: 'Enter password',
                obscureText: true,
                suffixIcon: Icon(Icons.visibility),
              ),
            ),
            WidgetbookUseCase(
              name: 'With Error',
              builder: (context) => const AppInput(
                label: 'Email',
                hint: 'Enter your email',
                errorText: 'Invalid email address',
              ),
            ),
            WidgetbookUseCase(
              name: 'Disabled',
              builder: (context) => const AppInput(
                label: 'Disabled',
                hint: 'Cannot edit',
                enabled: false,
              ),
            ),
          ],
        ),

        // AppCheckbox
        WidgetbookComponent(
          name: 'AppCheckbox',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppCheckbox(
                value: context.knobs.boolean(
                  label: 'Checked',
                ),
                onChanged: (value) {},
                label: 'Accept terms and conditions',
              ),
            ),
            WidgetbookUseCase(
              name: 'Checked',
              builder: (context) => AppCheckbox(
                value: true,
                onChanged: (value) {},
                label: 'Checked',
              ),
            ),
            WidgetbookUseCase(
              name: 'Disabled',
              builder: (context) => const AppCheckbox(
                value: false,
                onChanged: null,
                label: 'Disabled',
              ),
            ),
          ],
        ),

        // AppSwitch
        WidgetbookComponent(
          name: 'AppSwitch',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppSwitch(
                value: context.knobs.boolean(
                  label: 'Enabled',
                ),
                onChanged: (value) {},
                label: 'Enable notifications',
              ),
            ),
            WidgetbookUseCase(
              name: 'On',
              builder: (context) => AppSwitch(
                value: true,
                onChanged: (value) {},
                label: 'On',
              ),
            ),
            WidgetbookUseCase(
              name: 'Disabled',
              builder: (context) => const AppSwitch(
                value: false,
                onChanged: null,
                label: 'Disabled',
              ),
            ),
          ],
        ),

        // AppSlider
        WidgetbookComponent(
          name: 'AppSlider',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppSlider(
                value: context.knobs.double.slider(
                  label: 'Value',
                  initialValue: 50,
                  max: 100,
                ),
                onChanged: (value) {},
                max: 100,
                label: 'Volume',
              ),
            ),
            WidgetbookUseCase(
              name: 'With Divisions',
              builder: (context) => AppSlider(
                value: 50,
                onChanged: (value) {},
                max: 100,
                divisions: 10,
                label: 'Brightness',
              ),
            ),
          ],
        ),

        // AppSelect
        WidgetbookComponent(
          name: 'AppSelect',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppSelect<String>(
                label: 'Country',
                hint: 'Select country',
                items: const [
                  AppSelectItem(value: 'USA', label: 'USA'),
                  AppSelectItem(value: 'Canada', label: 'Canada'),
                  AppSelectItem(value: 'Mexico', label: 'Mexico'),
                  AppSelectItem(value: 'UK', label: 'UK'),
                  AppSelectItem(value: 'Germany', label: 'Germany'),
                ],
                onChanged: (value) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'With Value',
              builder: (context) => AppSelect<String>(
                label: 'Country',
                value: 'USA',
                items: const [
                  AppSelectItem(value: 'USA', label: 'USA'),
                  AppSelectItem(value: 'Canada', label: 'Canada'),
                  AppSelectItem(value: 'Mexico', label: 'Mexico'),
                ],
                onChanged: (value) {},
              ),
            ),
          ],
        ),

        // AppRadioGroup
        WidgetbookComponent(
          name: 'AppRadioGroup',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppRadioGroup<String>(
                title: 'Gender',
                value: 'male',
                items: const [
                  AppRadioItem(value: 'male', label: 'Male'),
                  AppRadioItem(value: 'female', label: 'Female'),
                  AppRadioItem(value: 'other', label: 'Other'),
                ],
                onChanged: (value) {},
              ),
            ),
          ],
        ),

        // AppInputOTP
        WidgetbookComponent(
          name: 'AppInputOTP',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppInputOTP(
                length: context.knobs.int.slider(
                  label: 'Length',
                  initialValue: 6,
                  min: 4,
                  max: 8,
                ),
                onCompleted: (value) {},
              ),
            ),
          ],
        ),

        // AppTimePicker
        WidgetbookComponent(
          name: 'AppTimePicker',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppTimePicker(
                label: context.knobs.string(
                  label: 'Label',
                  initialValue: 'Select Time',
                ),
                use24HourFormat: context.knobs.boolean(
                  label: '24 Hour Format',
                  initialValue: false,
                ),
                onTimeChanged: (time) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'With Initial Time',
              builder: (context) => AppTimePicker(
                initialTime: const TimeOfDay(hour: 14, minute: 30),
                label: 'Meeting Time',
                onTimeChanged: (time) {},
              ),
            ),
            WidgetbookUseCase(
              name: '24 Hour Format',
              builder: (context) => AppTimePicker(
                use24HourFormat: true,
                label: 'Time (24h)',
                onTimeChanged: (time) {},
              ),
            ),
          ],
        ),

        // AppColorPicker
        WidgetbookComponent(
          name: 'AppColorPicker',
          useCases: [
            WidgetbookUseCase(
              name: 'Default',
              builder: (context) => AppColorPicker(
                label: context.knobs.string(
                  label: 'Label',
                  initialValue: 'Select Color',
                ),
                showHexInput: context.knobs.boolean(
                  label: 'Show Hex Input',
                  initialValue: true,
                ),
                showSwatches: context.knobs.boolean(
                  label: 'Show Swatches',
                  initialValue: true,
                ),
                onColorChanged: (color) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'With Selected Color',
              builder: (context) => AppColorPicker(
                selectedColor: Colors.blue,
                label: 'Theme Color',
                onColorChanged: (color) {},
              ),
            ),
            WidgetbookUseCase(
              name: 'Minimal',
              builder: (context) => AppColorPicker(
                showHexInput: false,
                showSwatches: false,
                label: 'Color Picker',
                onColorChanged: (color) {},
              ),
            ),
          ],
        ),
      ];
}
