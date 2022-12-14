import 'package:flutter/material.dart';

import 'date_picker_constants.dart';
import 'date_picker_theme.dart';
import 'date_time_formatter.dart';
import 'i18n/date_picker_i18n.dart';
import 'widget/date_picker_widget.dart';
import 'widget/datetime_picker_widget.dart';
import 'widget/time_picker_widget.dart';

enum DateTimePickerMode {
  /// Display DatePicker
  date,

  /// Display TimePicker
  time,

  /// Display DateTimePicker
  datetime,
}

///
/// author: Dylan Wu
/// since: 2018/06/21
class DatePicker {
  /// Display date picker in bottom sheet.
  ///
  /// context: [BuildContext]
  /// minDateTime: [DateTime] minimum date time
  /// maxDateTime: [DateTime] maximum date time
  /// initialDateTime: [DateTime] initial date time for selected
  /// dateFormat: [String] date format pattern
  /// locale: [DateTimePickerLocale] internationalization
  /// pickerMode: [DateTimePickerMode] display mode: date(DatePicker)、time(TimePicker)、datetime(DateTimePicker)
  /// pickerTheme: [DateTimePickerTheme] the theme of date time picker
  /// onCancel: [DateVoidCallback] pressed title cancel widget event
  /// onClose: [DateVoidCallback] date picker closed event
  /// onChange: [DateValueCallback] selected date time changed event
  /// onConfirm: [DateValueCallback] pressed title confirm widget event
  static void showDatePicker(
    BuildContext context, {
    DateTime? minDateTime,
    DateTime? maxDateTime,
    DateTime? initialDateTime,
    String? dateFormat,
    DateTimePickerLocale locale = DATETIME_PICKER_LOCALE_DEFAULT,
    DateTimePickerMode pickerMode = DateTimePickerMode.date,
    DateTimePickerTheme pickerTheme = DateTimePickerTheme.Default,
    DateVoidCallback? onCancel,
    DateVoidCallback? onClose,
    DateValueCallback? onChange,
    DateValueCallback? onConfirm,
    int minuteDivider = 1,
  }) {
    // handle the range of datetime
    minDateTime ??= DateTime.parse(DATE_PICKER_MIN_DATETIME);
    maxDateTime ??= DateTime.parse(DATE_PICKER_MAX_DATETIME);

    // handle initial DateTime
    initialDateTime ??= DateTime.now();

    // Set value of date format
    dateFormat = DateTimeFormatter.generateDateFormat(dateFormat ?? "", pickerMode);

    Navigator.push(
      context,
      _DatePickerRoute(
        minDateTime: minDateTime,
        maxDateTime: maxDateTime,
        initialDateTime: initialDateTime,
        dateFormat: dateFormat,
        locale: locale,
        pickerMode: pickerMode,
        pickerTheme: pickerTheme,
        onCancel: onCancel,
        onChange: onChange,
        onConfirm: onConfirm,
        theme: Theme.of(context),
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        minuteDivider: minuteDivider,
      ),
    ).whenComplete(onClose ?? () => {});
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.minDateTime,
    this.maxDateTime,
    this.initialDateTime,
    this.dateFormat,
    this.locale,
    this.pickerMode,
    this.pickerTheme,
    this.onCancel,
    this.onChange,
    this.onConfirm,
    this.theme,
    this.barrierLabel,
    this.minuteDivider,
    RouteSettings? settings,
  }) : super(settings: settings);

  final DateTime? minDateTime, maxDateTime, initialDateTime;
  final String? dateFormat;
  final DateTimePickerLocale? locale;
  final DateTimePickerMode? pickerMode;
  final DateTimePickerTheme? pickerTheme;
  final VoidCallback? onCancel;
  final DateValueCallback? onChange;
  final DateValueCallback? onConfirm;
  final int? minuteDivider;

  final ThemeData? theme;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  late AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    _animationController = BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    double height = pickerTheme!.pickerHeight;
    if (pickerTheme!.showTitle) {
      height += pickerTheme!.titleHeight;
    }

    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(route: this, pickerHeight: height),
    );

    if (theme != null) {
      bottomSheet = Theme(data: theme!, child: bottomSheet);
    }
    return bottomSheet;
  }
}

class _DatePickerComponent extends StatelessWidget {
  final _DatePickerRoute route;
  final double _pickerHeight;

  const _DatePickerComponent({Key? key, required this.route, required pickerHeight}) : _pickerHeight = pickerHeight;

  @override
  Widget build(BuildContext context) {
    late Widget pickerWidget;
    switch (route.pickerMode) {
      case DateTimePickerMode.date:
        pickerWidget = DatePickerWidget(
          minDateTime: route.minDateTime,
          maxDateTime: route.maxDateTime,
          initialDateTime: route.initialDateTime,
          dateFormat: route.dateFormat ?? "",
          locale: route.locale!,
          pickerTheme: route.pickerTheme!,
          onCancel: route.onCancel,
          onChange: route.onChange,
          onConfirm: route.onConfirm,
        );
        break;
      case DateTimePickerMode.time:
        pickerWidget = TimePickerWidget(
          minDateTime: route.minDateTime,
          maxDateTime: route.maxDateTime,
          initDateTime: route.initialDateTime,
          dateFormat: route.dateFormat!,
          locale: route.locale!,
          pickerTheme: route.pickerTheme!,
          onCancel: route.onCancel,
          onChange: route.onChange,
          onConfirm: route.onConfirm,
          minuteDivider: route.minuteDivider!,
        );
        break;
      case DateTimePickerMode.datetime:
        pickerWidget = DateTimePickerWidget(
          minDateTime: route.minDateTime,
          maxDateTime: route.maxDateTime,
          initDateTime: route.initialDateTime,
          dateFormat: route.dateFormat!,
          locale: route.locale!,
          pickerTheme: route.pickerTheme!,
          onCancel: route.onCancel,
          onChange: route.onChange,
          onConfirm: route.onConfirm,
          minuteDivider: route.minuteDivider!,
        );
        break;
      default:
        pickerWidget = DatePickerWidget(
          minDateTime: route.minDateTime,
          maxDateTime: route.maxDateTime,
          initialDateTime: route.initialDateTime,
          dateFormat: route.dateFormat ?? "",
          locale: route.locale!,
          pickerTheme: route.pickerTheme!,
          onCancel: route.onCancel,
          onChange: route.onChange,
          onConfirm: route.onConfirm,
        );
        break;
    }
    return GestureDetector(
      child: AnimatedBuilder(
        animation: route.controller!,
        builder: (BuildContext context, Widget? child) {
          return ClipRRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(route.animation!.value, contentHeight: _pickerHeight + 60 + ScreenUtil.heightBottomSafeArea),
              child: pickerWidget,
            ),
          );
        },
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, {required this.contentHeight});

  final double progress;
  final double contentHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: contentHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}