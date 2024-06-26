/// HSV(HSB)/HSL Color Picker example
///
/// You can create your own layout by importing `picker.dart`.

library hsv_picker;

import 'package:flutter/material.dart';
import 'palette.dart';
import 'utils.dart';

/// The default layout of Color Picker.
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.pickerHsvColor,
    this.onHsvColorChanged,
    this.paletteType = PaletteType.hsvWithHue,
    this.enableAlpha = true,
    @Deprecated('Use empty list in [labelTypes] to disable label.') this.showLabel = true,
    this.labelTypes = const [ColorLabelType.rgb, ColorLabelType.hsv, ColorLabelType.hsl],
    @Deprecated('Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.') this.labelTextStyle,
    this.displayThumbColor = false,
    this.portraitOnly = false,
    required this.colorPickerWidth,
    this.pickerAreaHeightPercent = 1.0,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
    this.hexInputBar = false,
    this.hexInputController,
    this.colorHistory,
    this.onHistoryChanged,
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final HSVColor? pickerHsvColor;
  final ValueChanged<HSVColor>? onHsvColorChanged;
  final PaletteType paletteType;
  final bool enableAlpha;
  final bool showLabel;
  final List<ColorLabelType> labelTypes;
  final TextStyle? labelTextStyle;
  final bool displayThumbColor;
  final bool portraitOnly;
  final double colorPickerWidth;
  final double pickerAreaHeightPercent;
  final BorderRadius pickerAreaBorderRadius;
  final bool hexInputBar;

  /// Allows setting the color using text input, via [TextEditingController].
  ///
  /// Listens to [String] input and trying to convert it to the valid [Color].
  /// Contains basic validator, that requires final input to be provided
  /// in one of those formats:
  ///
  /// * RGB
  /// * #RGB
  /// * RRGGBB
  /// * #RRGGBB
  /// * AARRGGBB
  /// * #AARRGGBB
  ///
  /// Where: A stands for Alpha, R for Red, G for Green, and B for blue color.
  /// It will only accept 3/6/8 long HEXs with an optional hash (`#`) at the beginning.
  /// Allowed characters are Latin A-F case insensitive and numbers 0-9.
  /// It does respect the [enableAlpha] flag, so if alpha is disabled, all inputs
  /// with transparency are also converted to non-transparent color values.
  /// ```dart
  ///   MaterialButton(
  ///    elevation: 3.0,
  ///    onPressed: () {
  ///      // The initial value can be provided directly to the controller.
  ///      final textController =
  ///          TextEditingController(text: '#2F19DB');
  ///      showDialog(
  ///        context: context,
  ///        builder: (BuildContext context) {
  ///          return AlertDialog(
  ///            scrollable: true,
  ///            titlePadding: const EdgeInsets.all(0.0),
  ///            contentPadding: const EdgeInsets.all(0.0),
  ///            content: Column(
  ///              children: [
  ///                ColorPicker(
  ///                  pickerColor: currentColor,
  ///                  onColorChanged: changeColor,
  ///                  colorPickerWidth: 300.0,
  ///                  pickerAreaHeightPercent: 0.7,
  ///                  enableAlpha:
  ///                      true, // hexInputController will respect it too.
  ///                  displayThumbColor: true,
  ///                  showLabel: true,
  ///                  paletteType: PaletteType.hsv,
  ///                  pickerAreaBorderRadius: const BorderRadius.only(
  ///                    topLeft: const Radius.circular(2.0),
  ///                    topRight: const Radius.circular(2.0),
  ///                  ),
  ///                  hexInputController: textController, // <- here
  ///                  portraitOnly: true,
  ///                ),
  ///                Padding(
  ///                  padding: const EdgeInsets.all(16),
  ///                  /* It can be any text field, for example:
  ///                  * TextField
  ///                  * TextFormField
  ///                  * CupertinoTextField
  ///                  * EditableText
  ///                  * any text field from 3-rd party package
  ///                  * your own text field
  ///                  so basically anything that supports/uses
  ///                  a TextEditingController for an editable text.
  ///                  */
  ///                  child: CupertinoTextField(
  ///                    controller: textController,
  ///                    // Everything below is purely optional.
  ///                    prefix: Padding(
  ///                      padding: const EdgeInsets.only(left: 8),
  ///                      child: const Icon(Icons.tag),
  ///                    ),
  ///                    suffix: IconButton(
  ///                      icon:
  ///                          const Icon(Icons.content_paste_rounded),
  ///                      onPressed: () async =>
  ///                          copyToClipboard(textController.text),
  ///                    ),
  ///                    autofocus: true,
  ///                    maxLength: 9,
  ///                    inputFormatters: [
  ///                      // Any custom input formatter can be passed
  ///                      // here or use any Form validator you want.
  ///                      UpperCaseTextFormatter(),
  ///                      FilteringTextInputFormatter.allow(
  ///                          RegExp(kValidHexPattern)),
  ///                    ],
  ///                  ),
  ///                )
  ///              ],
  ///            ),
  ///          );
  ///        },
  ///      );
  ///    },
  ///    child: const Text('Change me via text input'),
  ///    color: currentColor,
  ///    textColor: useWhiteForeground(currentColor)
  ///        ? const Color(0xffffffff)
  ///        : const Color(0xff000000),
  ///  ),
  /// ```
  ///
  /// Do not forget to `dispose()` your [TextEditingController] if you creating
  /// it inside any kind of [StatefulWidget]'s [State].
  /// Reference: https://en.wikipedia.org/wiki/Web_colors#Hex_triplet
  final TextEditingController? hexInputController;
  final List<Color>? colorHistory;
  final ValueChanged<List<Color>>? onHistoryChanged;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);
  List<Color> colorHistory = [];

  @override
  void initState() {
    currentHsvColor = (widget.pickerHsvColor != null) ? widget.pickerHsvColor as HSVColor : HSVColor.fromColor(widget.pickerColor);
    // If there's no initial text in `hexInputController`,
    if (widget.hexInputController?.text.isEmpty == true) {
      // set it to the current's color HEX value.
      widget.hexInputController?.text = colorToHex(
        currentHsvColor.toColor(),
        enableAlpha: widget.enableAlpha,
      );
    }
    // Listen to the text input, If there is an `hexInputController` provided.
    widget.hexInputController?.addListener(colorPickerTextInputListener);
    if (widget.colorHistory != null && widget.onHistoryChanged != null) {
      colorHistory = widget.colorHistory ?? [];
    }
    super.initState();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = (widget.pickerHsvColor != null) ? widget.pickerHsvColor as HSVColor : HSVColor.fromColor(widget.pickerColor);
  }

  void colorPickerTextInputListener() {
    // It can't be null really, since it's only listening if the controller
    // is provided, but it may help to calm the Dart analyzer in the future.
    if (widget.hexInputController == null) return;
    // If a user is inserting/typing any text — try to get the color value from it,
    // and interpret its transparency, dependent on the widget's settings.
    final Color? color = colorFromHex(widget.hexInputController!.text, enableAlpha: widget.enableAlpha);
    // If it's the valid color:
    if (color != null) {
      // set it as the current color and
      setState(() => currentHsvColor = HSVColor.fromColor(color));
      // notify with a callback.
      widget.onColorChanged(color);
      if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
    }
  }

  @override
  void dispose() {
    widget.hexInputController?.removeListener(colorPickerTextInputListener);
    super.dispose();
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType,
      currentHsvColor,
      (HSVColor color) {
        // Update text in `hexInputController` if provided.
        widget.hexInputController?.text = colorToHex(color.toColor(), enableAlpha: widget.enableAlpha);
        setState(() => currentHsvColor = color);
        widget.onColorChanged(currentHsvColor.toColor());
        if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
      },
      displayThumbColor: widget.displayThumbColor,
    );
  }

  void onColorChanging(HSVColor color) {
    // Update text in `hexInputController` if provided.
    widget.hexInputController?.text = colorToHex(color.toColor(), enableAlpha: widget.enableAlpha);
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor());
    if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
  }

  Widget colorPicker() {
    return ClipRRect(
      borderRadius: widget.pickerAreaBorderRadius,
      child: Padding(
        padding: EdgeInsets.all(widget.paletteType == PaletteType.hueWheel ? 10 : 0),
        child: ColorPickerArea(currentHsvColor, onColorChanging, widget.paletteType),
      ),
    );
  }

  Widget sliderByPaletteType() {
    switch (widget.paletteType) {
      case PaletteType.hsv:
      case PaletteType.hsvWithHue:
      case PaletteType.hsl:
      case PaletteType.hslWithHue:
        return colorPickerSlider(TrackType.hue);
      case PaletteType.hsvWithValue:
      case PaletteType.hueWheel:
        return colorPickerSlider(TrackType.value);
      case PaletteType.hsvWithSaturation:
        return colorPickerSlider(TrackType.saturation);
      case PaletteType.hslWithLightness:
        return colorPickerSlider(TrackType.lightness);
      case PaletteType.hslWithSaturation:
        return colorPickerSlider(TrackType.saturationForHSL);
      case PaletteType.rgbWithBlue:
        return colorPickerSlider(TrackType.blue);
      case PaletteType.rgbWithGreen:
        return colorPickerSlider(TrackType.green);
      case PaletteType.rgbWithRed:
        return colorPickerSlider(TrackType.red);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: widget.colorPickerWidth,
          height: widget.colorPickerWidth,
          child: colorPicker(),
        ),
        SizedBox(height: 40.0, child: sliderByPaletteType()),
        // if (colorHistory.isNotEmpty)
        //   SizedBox(
        //     width: widget.colorPickerWidth,
        //     height: 50,
        //     child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
        //       for (Color color in colorHistory)
        //         Padding(
        //           key: Key(color.hashCode.toString()),
        //           padding: const EdgeInsets.fromLTRB(15, 0, 0, 10),
        //           child: Center(
        //             child: GestureDetector(
        //               onTap: () => onColorChanging(HSVColor.fromColor(color)),
        //               child: ColorIndicator(HSVColor.fromColor(color), width: 30, height: 30),
        //             ),
        //           ),
        //         ),
        //       const SizedBox(width: 15),
        //     ]),
        //   ),
        // if (widget.showLabel && widget.labelTypes.isNotEmpty)
        //   FittedBox(
        //     child: ColorPickerLabel(
        //       currentHsvColor,
        //       enableAlpha: widget.enableAlpha,
        //       textStyle: widget.labelTextStyle,
        //       colorLabelTypes: widget.labelTypes,
        //     ),
        //   ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hex', style: TextStyle(fontSize: 14, color: Color(0xFF3B3E43), fontWeight: FontWeight.w600)),
            Container(
              width: 106,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ColorIndicator(Color(int.parse('0xFF${currentHsvColor.toColor().value.toRadixString(16).substring(2)}'))),
                  const Spacer(),
                  const Text('#', style: TextStyle(fontSize: 16, color: Color(0xFF888888), fontWeight: FontWeight.w400)),
                  Text(
                    currentHsvColor.toColor().value.toRadixString(16).substring(2).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3B3E43),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // ColorPickerInput(
            //   currentHsvColor.toColor(),
            //       (Color color) {
            //     setState(() => currentHsvColor = HSVColor.fromColor(color));
            //     widget.onColorChanged(currentHsvColor.toColor());
            //     if (widget.onHsvColorChanged != null) widget.onHsvColorChanged!(currentHsvColor);
            //   },
            //   enableAlpha: widget.enableAlpha,
            //   embeddedText: false,
            // ),
          ],
        ),

        const SizedBox(height: 20.0),
      ],
    );
  }
}

/// The Color Picker with sliders only. Support HSV, HSL and RGB color model.
class SlidePicker extends StatefulWidget {
  const SlidePicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.colorModel = ColorModel.rgb,
    this.enableAlpha = true,
    this.sliderSize = const Size(260, 40),
    this.showSliderText = true,
    @Deprecated('Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.') this.sliderTextStyle,
    this.showParams = true,
    @Deprecated('Use empty list in [labelTypes] to disable label.') this.showLabel = true,
    this.labelTypes = const [],
    @Deprecated('Use Theme.of(context).textTheme.bodyText1 & 2 to alter text style.') this.labelTextStyle,
    this.showIndicator = true,
    this.indicatorSize = const Size(280, 50),
    this.indicatorAlignmentBegin = const Alignment(-1.0, -3.0),
    this.indicatorAlignmentEnd = const Alignment(1.0, 3.0),
    this.displayThumbColor = true,
    this.indicatorBorderRadius = const BorderRadius.all(Radius.zero),
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final ColorModel colorModel;
  final bool enableAlpha;
  final Size sliderSize;
  final bool showSliderText;
  final TextStyle? sliderTextStyle;
  final bool showLabel;
  final bool showParams;
  final List<ColorLabelType> labelTypes;
  final TextStyle? labelTextStyle;
  final bool showIndicator;
  final Size indicatorSize;
  final AlignmentGeometry indicatorAlignmentBegin;
  final AlignmentGeometry indicatorAlignmentEnd;
  final bool displayThumbColor;
  final BorderRadius indicatorBorderRadius;

  @override
  State<StatefulWidget> createState() => _SlidePickerState();
}

class _SlidePickerState extends State<SlidePicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);

  @override
  void initState() {
    super.initState();
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  @override
  void didUpdateWidget(SlidePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType,
      currentHsvColor,
      (HSVColor color) {
        setState(() => currentHsvColor = color);
        widget.onColorChanged(currentHsvColor.toColor());
      },
      displayThumbColor: widget.displayThumbColor,
      fullThumbColor: true,
    );
  }

  Widget indicator() {
    return ClipRRect(
      borderRadius: widget.indicatorBorderRadius,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GestureDetector(
        onTap: () {
          setState(() => currentHsvColor = HSVColor.fromColor(widget.pickerColor));
          widget.onColorChanged(currentHsvColor.toColor());
        },
        child: Container(
          width: widget.indicatorSize.width,
          height: widget.indicatorSize.height,
          margin: const EdgeInsets.only(bottom: 15.0),
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.pickerColor,
                widget.pickerColor,
                currentHsvColor.toColor(),
                currentHsvColor.toColor(),
              ],
              begin: widget.indicatorAlignmentBegin,
              end: widget.indicatorAlignmentEnd,
              stops: const [0.0, 0.5, 0.5, 1.0],
            ),
          ),
          child: const CustomPaint(painter: CheckerPainter()),
        ),
      ),
    );
  }

  String getColorParams(int pos) {
    assert(pos >= 0 && pos < 4);
    if (widget.colorModel == ColorModel.rgb) {
      final Color color = currentHsvColor.toColor();
      return [
        color.red.toString(),
        color.green.toString(),
        color.blue.toString(),
        '${(color.opacity * 100).round()}',
      ][pos];
    } else if (widget.colorModel == ColorModel.hsv) {
      return [
        currentHsvColor.hue.round().toString(),
        (currentHsvColor.saturation * 100).round().toString(),
        (currentHsvColor.value * 100).round().toString(),
        (currentHsvColor.alpha * 100).round().toString(),
      ][pos];
    } else if (widget.colorModel == ColorModel.hsl) {
      HSLColor hslColor = hsvToHsl(currentHsvColor);
      return [
        hslColor.hue.round().toString(),
        (hslColor.saturation * 100).round().toString(),
        (hslColor.lightness * 100).round().toString(),
        (currentHsvColor.alpha * 100).round().toString(),
      ][pos];
    } else {
      return '??';
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 14;
    if (widget.labelTextStyle != null && widget.labelTextStyle?.fontSize != null) {
      fontSize = widget.labelTextStyle?.fontSize ?? 14;
    }
    final List<TrackType> trackTypes = [
      if (widget.colorModel == ColorModel.hsv) ...[TrackType.hue, TrackType.saturation, TrackType.value],
      if (widget.colorModel == ColorModel.hsl) ...[TrackType.hue, TrackType.saturationForHSL, TrackType.lightness],
      if (widget.colorModel == ColorModel.rgb) ...[TrackType.red, TrackType.green, TrackType.blue],
      if (widget.enableAlpha) ...[TrackType.alpha],
    ];
    List<SizedBox> sliders = [
      for (TrackType trackType in trackTypes)
        SizedBox(
          width: widget.sliderSize.width,
          height: widget.sliderSize.height,
          child: Row(
            children: <Widget>[
              if (widget.showSliderText)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    trackType.toString().split('.').last[0].toUpperCase(),
                    style: widget.sliderTextStyle ?? Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              Expanded(child: colorPickerSlider(trackType)),
              if (widget.showParams)
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: fontSize * 2 + 5),
                  child: Text(
                    getColorParams(trackTypes.indexOf(trackType)),
                    style: widget.sliderTextStyle ?? Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
        ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.showIndicator) indicator(),
        if (!widget.showIndicator) const SizedBox(height: 20),
        ...sliders,
        const SizedBox(height: 20.0),
        if (widget.showLabel && widget.labelTypes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ColorPickerLabel(
              currentHsvColor,
              enableAlpha: widget.enableAlpha,
              textStyle: widget.labelTextStyle,
              colorLabelTypes: widget.labelTypes,
            ),
          ),
      ],
    );
  }
}

