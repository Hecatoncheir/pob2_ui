// This is a generated file - do not edit.
//
// Generated from pob2/v1/build.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ConfigValueType extends $pb.ProtobufEnum {
  static const ConfigValueType CONFIG_VALUE_TYPE_UNSPECIFIED =
      ConfigValueType._(
          0, _omitEnumNames ? '' : 'CONFIG_VALUE_TYPE_UNSPECIFIED');
  static const ConfigValueType CONFIG_VALUE_TYPE_BOOLEAN =
      ConfigValueType._(1, _omitEnumNames ? '' : 'CONFIG_VALUE_TYPE_BOOLEAN');
  static const ConfigValueType CONFIG_VALUE_TYPE_NUMBER =
      ConfigValueType._(2, _omitEnumNames ? '' : 'CONFIG_VALUE_TYPE_NUMBER');
  static const ConfigValueType CONFIG_VALUE_TYPE_STRING =
      ConfigValueType._(3, _omitEnumNames ? '' : 'CONFIG_VALUE_TYPE_STRING');

  static const $core.List<ConfigValueType> values = <ConfigValueType>[
    CONFIG_VALUE_TYPE_UNSPECIFIED,
    CONFIG_VALUE_TYPE_BOOLEAN,
    CONFIG_VALUE_TYPE_NUMBER,
    CONFIG_VALUE_TYPE_STRING,
  ];

  static final $core.List<ConfigValueType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ConfigValueType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConfigValueType._(super.value, super.name);
}

class CalculationStatus extends $pb.ProtobufEnum {
  static const CalculationStatus CALCULATION_STATUS_UNSPECIFIED =
      CalculationStatus._(
          0, _omitEnumNames ? '' : 'CALCULATION_STATUS_UNSPECIFIED');
  static const CalculationStatus CALCULATION_STATUS_COMPLETE =
      CalculationStatus._(
          1, _omitEnumNames ? '' : 'CALCULATION_STATUS_COMPLETE');
  static const CalculationStatus CALCULATION_STATUS_PARTIAL =
      CalculationStatus._(
          2, _omitEnumNames ? '' : 'CALCULATION_STATUS_PARTIAL');
  static const CalculationStatus CALCULATION_STATUS_UNSUPPORTED =
      CalculationStatus._(
          3, _omitEnumNames ? '' : 'CALCULATION_STATUS_UNSUPPORTED');

  static const $core.List<CalculationStatus> values = <CalculationStatus>[
    CALCULATION_STATUS_UNSPECIFIED,
    CALCULATION_STATUS_COMPLETE,
    CALCULATION_STATUS_PARTIAL,
    CALCULATION_STATUS_UNSUPPORTED,
  ];

  static final $core.List<CalculationStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static CalculationStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CalculationStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
