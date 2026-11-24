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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'build.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'build.pbenum.dart';

/// Лексическое значение сохраняется для точного повтора аргументов команды.
class ConfigValue extends $pb.GeneratedMessage {
  factory ConfigValue({
    ConfigValueType? type,
    $core.String? value,
  }) {
    final result = ConfigValue._();
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    return result;
  }

  ConfigValue._();

  factory ConfigValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfigValue()..mergeFromBuffer(data, registry);
  factory ConfigValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfigValue()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ConfigValue.$_createMessage)
    ..aE<ConfigValueType>(1, _omitFieldNames ? '' : 'type',
        enumValues: ConfigValueType.values)
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigValue copyWith(void Function(ConfigValue) updates) =>
      super.copyWith((message) => updates(message as ConfigValue))
          as ConfigValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConfigValue() / ConfigValue.new instead')
  static ConfigValue create() => ConfigValue._();
  static $pb.GeneratedMessage $_createMessage() => ConfigValue._();
  @$core.override
  ConfigValue createEmptyInstance() => ConfigValue._();
  @$core.pragma('dart2js:noInline')
  static ConfigValue getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfigValue>(
          ConfigValue.$_createMessage);
  static ConfigValue? _defaultInstance;

  @$pb.TagNumber(1)
  ConfigValueType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ConfigValueType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

class BuildIssue extends $pb.GeneratedMessage {
  factory BuildIssue({
    $core.String? code,
    $core.String? path,
    $core.String? message,
  }) {
    final result = BuildIssue._();
    if (code != null) result.code = code;
    if (path != null) result.path = path;
    if (message != null) result.message = message;
    return result;
  }

  BuildIssue._();

  factory BuildIssue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildIssue()..mergeFromBuffer(data, registry);
  factory BuildIssue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildIssue()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuildIssue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: BuildIssue.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'path')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildIssue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildIssue copyWith(void Function(BuildIssue) updates) =>
      super.copyWith((message) => updates(message as BuildIssue)) as BuildIssue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildIssue() / BuildIssue.new instead')
  static BuildIssue create() => BuildIssue._();
  static $pb.GeneratedMessage $_createMessage() => BuildIssue._();
  @$core.override
  BuildIssue createEmptyInstance() => BuildIssue._();
  @$core.pragma('dart2js:noInline')
  static BuildIssue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuildIssue>(BuildIssue.$_createMessage);
  static BuildIssue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get path => $_getSZ(1);
  @$pb.TagNumber(2)
  set path($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

class ActiveSets extends $pb.GeneratedMessage {
  factory ActiveSets({
    $core.int? skills,
    $core.int? items,
    $core.int? tree,
    $core.int? config,
  }) {
    final result = ActiveSets._();
    if (skills != null) result.skills = skills;
    if (items != null) result.items = items;
    if (tree != null) result.tree = tree;
    if (config != null) result.config = config;
    return result;
  }

  ActiveSets._();

  factory ActiveSets.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActiveSets()..mergeFromBuffer(data, registry);
  factory ActiveSets.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActiveSets()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActiveSets',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ActiveSets.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'skills', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'items', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'tree', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'config', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveSets clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActiveSets copyWith(void Function(ActiveSets) updates) =>
      super.copyWith((message) => updates(message as ActiveSets)) as ActiveSets;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActiveSets() / ActiveSets.new instead')
  static ActiveSets create() => ActiveSets._();
  static $pb.GeneratedMessage $_createMessage() => ActiveSets._();
  @$core.override
  ActiveSets createEmptyInstance() => ActiveSets._();
  @$core.pragma('dart2js:noInline')
  static ActiveSets getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActiveSets>(ActiveSets.$_createMessage);
  static ActiveSets? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get skills => $_getIZ(0);
  @$pb.TagNumber(1)
  set skills($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSkills() => $_has(0);
  @$pb.TagNumber(1)
  void clearSkills() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get items => $_getIZ(1);
  @$pb.TagNumber(2)
  set items($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasItems() => $_has(1);
  @$pb.TagNumber(2)
  void clearItems() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tree => $_getIZ(2);
  @$pb.TagNumber(3)
  set tree($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTree() => $_has(2);
  @$pb.TagNumber(3)
  void clearTree() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get config => $_getIZ(3);
  @$pb.TagNumber(4)
  set config($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfig() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfig() => $_clearField(4);
}

class BuildGem extends $pb.GeneratedMessage {
  factory BuildGem({
    $core.String? id,
    $core.String? name,
    $core.String? skillId,
    $core.String? variantId,
    $core.int? level,
    $core.int? quality,
    $core.bool? enabled,
    $core.int? statSet,
    $core.bool? corrupted,
  }) {
    final result = BuildGem._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (skillId != null) result.skillId = skillId;
    if (variantId != null) result.variantId = variantId;
    if (level != null) result.level = level;
    if (quality != null) result.quality = quality;
    if (enabled != null) result.enabled = enabled;
    if (statSet != null) result.statSet = statSet;
    if (corrupted != null) result.corrupted = corrupted;
    return result;
  }

  BuildGem._();

  factory BuildGem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildGem()..mergeFromBuffer(data, registry);
  factory BuildGem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildGem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuildGem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: BuildGem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'skillId')
    ..aOS(4, _omitFieldNames ? '' : 'variantId')
    ..aI(5, _omitFieldNames ? '' : 'level', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'quality', fieldType: $pb.PbFieldType.OU3)
    ..aOB(7, _omitFieldNames ? '' : 'enabled')
    ..aI(8, _omitFieldNames ? '' : 'statSet', fieldType: $pb.PbFieldType.OU3)
    ..aOB(9, _omitFieldNames ? '' : 'corrupted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildGem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildGem copyWith(void Function(BuildGem) updates) =>
      super.copyWith((message) => updates(message as BuildGem)) as BuildGem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildGem() / BuildGem.new instead')
  static BuildGem create() => BuildGem._();
  static $pb.GeneratedMessage $_createMessage() => BuildGem._();
  @$core.override
  BuildGem createEmptyInstance() => BuildGem._();
  @$core.pragma('dart2js:noInline')
  static BuildGem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuildGem>(BuildGem.$_createMessage);
  static BuildGem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get skillId => $_getSZ(2);
  @$pb.TagNumber(3)
  set skillId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSkillId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSkillId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get variantId => $_getSZ(3);
  @$pb.TagNumber(4)
  set variantId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVariantId() => $_has(3);
  @$pb.TagNumber(4)
  void clearVariantId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get level => $_getIZ(4);
  @$pb.TagNumber(5)
  set level($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get quality => $_getIZ(5);
  @$pb.TagNumber(6)
  set quality($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQuality() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuality() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get enabled => $_getBF(6);
  @$pb.TagNumber(7)
  set enabled($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEnabled() => $_has(6);
  @$pb.TagNumber(7)
  void clearEnabled() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get statSet => $_getIZ(7);
  @$pb.TagNumber(8)
  set statSet($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStatSet() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatSet() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get corrupted => $_getBF(8);
  @$pb.TagNumber(9)
  set corrupted($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCorrupted() => $_has(8);
  @$pb.TagNumber(9)
  void clearCorrupted() => $_clearField(9);
}

class SkillGroup extends $pb.GeneratedMessage {
  factory SkillGroup({
    $core.int? id,
    $core.String? label,
    $core.bool? enabled,
    $core.int? mainSkill,
    $core.Iterable<BuildGem>? gems,
  }) {
    final result = SkillGroup._();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    if (enabled != null) result.enabled = enabled;
    if (mainSkill != null) result.mainSkill = mainSkill;
    if (gems != null) result.gems.addAll(gems);
    return result;
  }

  SkillGroup._();

  factory SkillGroup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillGroup()..mergeFromBuffer(data, registry);
  factory SkillGroup.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillGroup()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SkillGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: SkillGroup.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'enabled')
    ..aI(4, _omitFieldNames ? '' : 'mainSkill', fieldType: $pb.PbFieldType.OU3)
    ..pPM<BuildGem>(5, _omitFieldNames ? '' : 'gems',
        subBuilder: BuildGem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillGroup copyWith(void Function(SkillGroup) updates) =>
      super.copyWith((message) => updates(message as SkillGroup)) as SkillGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SkillGroup() / SkillGroup.new instead')
  static SkillGroup create() => SkillGroup._();
  static $pb.GeneratedMessage $_createMessage() => SkillGroup._();
  @$core.override
  SkillGroup createEmptyInstance() => SkillGroup._();
  @$core.pragma('dart2js:noInline')
  static SkillGroup getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SkillGroup>(SkillGroup.$_createMessage);
  static SkillGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enabled => $_getBF(2);
  @$pb.TagNumber(3)
  set enabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get mainSkill => $_getIZ(3);
  @$pb.TagNumber(4)
  set mainSkill($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMainSkill() => $_has(3);
  @$pb.TagNumber(4)
  void clearMainSkill() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<BuildGem> get gems => $_getList(4);
}

class BuildItem extends $pb.GeneratedMessage {
  factory BuildItem({
    $core.int? id,
    $core.String? raw,
  }) {
    final result = BuildItem._();
    if (id != null) result.id = id;
    if (raw != null) result.raw = raw;
    return result;
  }

  BuildItem._();

  factory BuildItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildItem()..mergeFromBuffer(data, registry);
  factory BuildItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildItem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuildItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: BuildItem.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'raw')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildItem copyWith(void Function(BuildItem) updates) =>
      super.copyWith((message) => updates(message as BuildItem)) as BuildItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildItem() / BuildItem.new instead')
  static BuildItem create() => BuildItem._();
  static $pb.GeneratedMessage $_createMessage() => BuildItem._();
  @$core.override
  BuildItem createEmptyInstance() => BuildItem._();
  @$core.pragma('dart2js:noInline')
  static BuildItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuildItem>(BuildItem.$_createMessage);
  static BuildItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get raw => $_getSZ(1);
  @$pb.TagNumber(2)
  set raw($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRaw() => $_has(1);
  @$pb.TagNumber(2)
  void clearRaw() => $_clearField(2);
}

class BuildModel extends $pb.GeneratedMessage {
  factory BuildModel({
    $core.String? targetVersion,
    $core.String? treeVersion,
    $core.String? className,
    $core.int? classId,
    $core.String? ascendancy,
    $core.int? ascendancyId,
    $core.int? level,
    $core.int? mainGroup,
    $core.int? weaponSet,
    ActiveSets? activeSets,
    $core.Iterable<SkillGroup>? groups,
    $core.Iterable<BuildItem>? items,
    $core.Iterable<$core.MapEntry<$core.String, $core.int>>? slots,
    $core.Iterable<$core.int>? nodes,
    $core.Iterable<$core.MapEntry<$core.String, ConfigValue>>? config,
    $core.Iterable<BuildIssue>? issues,
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? passiveAttributes,
    $core.Iterable<$core.MapEntry<$core.int, $core.String>>? passiveAllocations,
    $core.Iterable<$core.MapEntry<$core.int, $core.int>>? passiveJewels,
  }) {
    final result = BuildModel._();
    if (targetVersion != null) result.targetVersion = targetVersion;
    if (treeVersion != null) result.treeVersion = treeVersion;
    if (className != null) result.className = className;
    if (classId != null) result.classId = classId;
    if (ascendancy != null) result.ascendancy = ascendancy;
    if (ascendancyId != null) result.ascendancyId = ascendancyId;
    if (level != null) result.level = level;
    if (mainGroup != null) result.mainGroup = mainGroup;
    if (weaponSet != null) result.weaponSet = weaponSet;
    if (activeSets != null) result.activeSets = activeSets;
    if (groups != null) result.groups.addAll(groups);
    if (items != null) result.items.addAll(items);
    if (slots != null) result.slots.addEntries(slots);
    if (nodes != null) result.nodes.addAll(nodes);
    if (config != null) result.config.addEntries(config);
    if (issues != null) result.issues.addAll(issues);
    if (passiveAttributes != null)
      result.passiveAttributes.addEntries(passiveAttributes);
    if (passiveAllocations != null)
      result.passiveAllocations.addEntries(passiveAllocations);
    if (passiveJewels != null) result.passiveJewels.addEntries(passiveJewels);
    return result;
  }

  BuildModel._();

  factory BuildModel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildModel()..mergeFromBuffer(data, registry);
  factory BuildModel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildModel()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuildModel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: BuildModel.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'targetVersion')
    ..aOS(2, _omitFieldNames ? '' : 'treeVersion')
    ..aOS(3, _omitFieldNames ? '' : 'className')
    ..aI(4, _omitFieldNames ? '' : 'classId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'ascendancy')
    ..aI(6, _omitFieldNames ? '' : 'ascendancyId',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'level', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'mainGroup', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'weaponSet', fieldType: $pb.PbFieldType.OU3)
    ..aOM<ActiveSets>(10, _omitFieldNames ? '' : 'activeSets',
        subBuilder: ActiveSets.$_createMessage)
    ..pPM<SkillGroup>(11, _omitFieldNames ? '' : 'groups',
        subBuilder: SkillGroup.$_createMessage)
    ..pPM<BuildItem>(12, _omitFieldNames ? '' : 'items',
        subBuilder: BuildItem.$_createMessage)
    ..m<$core.String, $core.int>(13, _omitFieldNames ? '' : 'slots',
        entryClassName: 'BuildModel.SlotsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OU3,
        packageName: const $pb.PackageName('pob2.v1'))
    ..p<$core.int>(14, _omitFieldNames ? '' : 'nodes', $pb.PbFieldType.KU3)
    ..m<$core.String, ConfigValue>(15, _omitFieldNames ? '' : 'config',
        entryClassName: 'BuildModel.ConfigEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: ConfigValue.$_createMessage,
        valueDefaultOrMaker: ConfigValue.getDefault,
        packageName: const $pb.PackageName('pob2.v1'))
    ..pPM<BuildIssue>(16, _omitFieldNames ? '' : 'issues',
        subBuilder: BuildIssue.$_createMessage)
    ..m<$core.int, $core.String>(17, _omitFieldNames ? '' : 'passiveAttributes',
        entryClassName: 'BuildModel.PassiveAttributesEntry',
        keyFieldType: $pb.PbFieldType.OU3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('pob2.v1'))
    ..m<$core.int, $core.String>(
        18, _omitFieldNames ? '' : 'passiveAllocations',
        entryClassName: 'BuildModel.PassiveAllocationsEntry',
        keyFieldType: $pb.PbFieldType.OU3,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('pob2.v1'))
    ..m<$core.int, $core.int>(19, _omitFieldNames ? '' : 'passiveJewels',
        entryClassName: 'BuildModel.PassiveJewelsEntry',
        keyFieldType: $pb.PbFieldType.OU3,
        valueFieldType: $pb.PbFieldType.OU3,
        packageName: const $pb.PackageName('pob2.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildModel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildModel copyWith(void Function(BuildModel) updates) =>
      super.copyWith((message) => updates(message as BuildModel)) as BuildModel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildModel() / BuildModel.new instead')
  static BuildModel create() => BuildModel._();
  static $pb.GeneratedMessage $_createMessage() => BuildModel._();
  @$core.override
  BuildModel createEmptyInstance() => BuildModel._();
  @$core.pragma('dart2js:noInline')
  static BuildModel getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuildModel>(BuildModel.$_createMessage);
  static BuildModel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetVersion($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get treeVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set treeVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTreeVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearTreeVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get className => $_getSZ(2);
  @$pb.TagNumber(3)
  set className($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasClassName() => $_has(2);
  @$pb.TagNumber(3)
  void clearClassName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get classId => $_getIZ(3);
  @$pb.TagNumber(4)
  set classId($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClassId() => $_has(3);
  @$pb.TagNumber(4)
  void clearClassId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get ascendancy => $_getSZ(4);
  @$pb.TagNumber(5)
  set ascendancy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAscendancy() => $_has(4);
  @$pb.TagNumber(5)
  void clearAscendancy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get ascendancyId => $_getIZ(5);
  @$pb.TagNumber(6)
  set ascendancyId($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAscendancyId() => $_has(5);
  @$pb.TagNumber(6)
  void clearAscendancyId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get level => $_getIZ(6);
  @$pb.TagNumber(7)
  set level($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLevel() => $_has(6);
  @$pb.TagNumber(7)
  void clearLevel() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get mainGroup => $_getIZ(7);
  @$pb.TagNumber(8)
  set mainGroup($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMainGroup() => $_has(7);
  @$pb.TagNumber(8)
  void clearMainGroup() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get weaponSet => $_getIZ(8);
  @$pb.TagNumber(9)
  set weaponSet($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWeaponSet() => $_has(8);
  @$pb.TagNumber(9)
  void clearWeaponSet() => $_clearField(9);

  @$pb.TagNumber(10)
  ActiveSets get activeSets => $_getN(9);
  @$pb.TagNumber(10)
  set activeSets(ActiveSets value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasActiveSets() => $_has(9);
  @$pb.TagNumber(10)
  void clearActiveSets() => $_clearField(10);
  @$pb.TagNumber(10)
  ActiveSets ensureActiveSets() => $_ensure(9);

  @$pb.TagNumber(11)
  $pb.PbList<SkillGroup> get groups => $_getList(10);

  @$pb.TagNumber(12)
  $pb.PbList<BuildItem> get items => $_getList(11);

  @$pb.TagNumber(13)
  $pb.PbMap<$core.String, $core.int> get slots => $_getMap(12);

  @$pb.TagNumber(14)
  $pb.PbList<$core.int> get nodes => $_getList(13);

  @$pb.TagNumber(15)
  $pb.PbMap<$core.String, ConfigValue> get config => $_getMap(14);

  @$pb.TagNumber(16)
  $pb.PbList<BuildIssue> get issues => $_getList(15);

  /// Сохранённые атрибуты назначенных узлов активной спецификации.
  @$pb.TagNumber(17)
  $pb.PbMap<$core.int, $core.String> get passiveAttributes => $_getMap(16);

  /// Режимы назначенных узлов в ветвях оружия активной спецификации.
  @$pb.TagNumber(18)
  $pb.PbMap<$core.int, $core.String> get passiveAllocations => $_getMap(17);

  /// ID предметов в гнёздах активной спецификации по ID узлов.
  @$pb.TagNumber(19)
  $pb.PbMap<$core.int, $core.int> get passiveJewels => $_getMap(18);
}

class AppliedModifier extends $pb.GeneratedMessage {
  factory AppliedModifier({
    $core.String? stat,
    $core.String? kind,
    $core.double? value,
    $core.String? source,
  }) {
    final result = AppliedModifier._();
    if (stat != null) result.stat = stat;
    if (kind != null) result.kind = kind;
    if (value != null) result.value = value;
    if (source != null) result.source = source;
    return result;
  }

  AppliedModifier._();

  factory AppliedModifier.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AppliedModifier()..mergeFromBuffer(data, registry);
  factory AppliedModifier.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AppliedModifier()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AppliedModifier',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: AppliedModifier.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'stat')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aD(3, _omitFieldNames ? '' : 'value')
    ..aOS(4, _omitFieldNames ? '' : 'source')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppliedModifier clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AppliedModifier copyWith(void Function(AppliedModifier) updates) =>
      super.copyWith((message) => updates(message as AppliedModifier))
          as AppliedModifier;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AppliedModifier() / AppliedModifier.new instead')
  static AppliedModifier create() => AppliedModifier._();
  static $pb.GeneratedMessage $_createMessage() => AppliedModifier._();
  @$core.override
  AppliedModifier createEmptyInstance() => AppliedModifier._();
  @$core.pragma('dart2js:noInline')
  static AppliedModifier getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AppliedModifier>(
          AppliedModifier.$_createMessage);
  static AppliedModifier? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stat => $_getSZ(0);
  @$pb.TagNumber(1)
  set stat($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStat() => $_has(0);
  @$pb.TagNumber(1)
  void clearStat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get kind => $_getSZ(1);
  @$pb.TagNumber(2)
  set kind($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get value => $_getN(2);
  @$pb.TagNumber(3)
  set value($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get source => $_getSZ(3);
  @$pb.TagNumber(4)
  set source($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSource() => $_has(3);
  @$pb.TagNumber(4)
  void clearSource() => $_clearField(4);
}

class CalculationResult extends $pb.GeneratedMessage {
  factory CalculationResult({
    CalculationStatus? status,
    $core.String? dataId,
    $core.String? dataSha256,
    $core.String? pobCommit,
    $core.String? inputSha256,
    $core.String? skill,
    $core.String? mode,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? stats,
    $core.Iterable<AppliedModifier>? modifiers,
    $core.Iterable<BuildIssue>? issues,
  }) {
    final result = CalculationResult._();
    if (status != null) result.status = status;
    if (dataId != null) result.dataId = dataId;
    if (dataSha256 != null) result.dataSha256 = dataSha256;
    if (pobCommit != null) result.pobCommit = pobCommit;
    if (inputSha256 != null) result.inputSha256 = inputSha256;
    if (skill != null) result.skill = skill;
    if (mode != null) result.mode = mode;
    if (stats != null) result.stats.addEntries(stats);
    if (modifiers != null) result.modifiers.addAll(modifiers);
    if (issues != null) result.issues.addAll(issues);
    return result;
  }

  CalculationResult._();

  factory CalculationResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculationResult()..mergeFromBuffer(data, registry);
  factory CalculationResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculationResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalculationResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CalculationResult.$_createMessage)
    ..aE<CalculationStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: CalculationStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'dataId')
    ..aOS(3, _omitFieldNames ? '' : 'dataSha256')
    ..aOS(4, _omitFieldNames ? '' : 'pobCommit')
    ..aOS(5, _omitFieldNames ? '' : 'inputSha256')
    ..aOS(6, _omitFieldNames ? '' : 'skill')
    ..aOS(7, _omitFieldNames ? '' : 'mode')
    ..m<$core.String, $core.double>(8, _omitFieldNames ? '' : 'stats',
        entryClassName: 'CalculationResult.StatsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('pob2.v1'))
    ..pPM<AppliedModifier>(9, _omitFieldNames ? '' : 'modifiers',
        subBuilder: AppliedModifier.$_createMessage)
    ..pPM<BuildIssue>(10, _omitFieldNames ? '' : 'issues',
        subBuilder: BuildIssue.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculationResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculationResult copyWith(void Function(CalculationResult) updates) =>
      super.copyWith((message) => updates(message as CalculationResult))
          as CalculationResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CalculationResult() / CalculationResult.new instead')
  static CalculationResult create() => CalculationResult._();
  static $pb.GeneratedMessage $_createMessage() => CalculationResult._();
  @$core.override
  CalculationResult createEmptyInstance() => CalculationResult._();
  @$core.pragma('dart2js:noInline')
  static CalculationResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CalculationResult>(
          CalculationResult.$_createMessage);
  static CalculationResult? _defaultInstance;

  @$pb.TagNumber(1)
  CalculationStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(CalculationStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get dataId => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get dataSha256 => $_getSZ(2);
  @$pb.TagNumber(3)
  set dataSha256($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDataSha256() => $_has(2);
  @$pb.TagNumber(3)
  void clearDataSha256() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get pobCommit => $_getSZ(3);
  @$pb.TagNumber(4)
  set pobCommit($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPobCommit() => $_has(3);
  @$pb.TagNumber(4)
  void clearPobCommit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get inputSha256 => $_getSZ(4);
  @$pb.TagNumber(5)
  set inputSha256($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInputSha256() => $_has(4);
  @$pb.TagNumber(5)
  void clearInputSha256() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get skill => $_getSZ(5);
  @$pb.TagNumber(6)
  set skill($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSkill() => $_has(5);
  @$pb.TagNumber(6)
  void clearSkill() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get mode => $_getSZ(6);
  @$pb.TagNumber(7)
  set mode($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMode() => $_has(6);
  @$pb.TagNumber(7)
  void clearMode() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $core.double> get stats => $_getMap(7);

  @$pb.TagNumber(9)
  $pb.PbList<AppliedModifier> get modifiers => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<BuildIssue> get issues => $_getList(9);
}

class BuildDocument extends $pb.GeneratedMessage {
  factory BuildDocument({
    $core.String? xml,
    $core.String? inputSha256,
    $fixnum.Int64? inputRevision,
    BuildModel? model,
    CalculationResult? calculation,
    $fixnum.Int64? calculatedFromRevision,
  }) {
    final result = BuildDocument._();
    if (xml != null) result.xml = xml;
    if (inputSha256 != null) result.inputSha256 = inputSha256;
    if (inputRevision != null) result.inputRevision = inputRevision;
    if (model != null) result.model = model;
    if (calculation != null) result.calculation = calculation;
    if (calculatedFromRevision != null)
      result.calculatedFromRevision = calculatedFromRevision;
    return result;
  }

  BuildDocument._();

  factory BuildDocument.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildDocument()..mergeFromBuffer(data, registry);
  factory BuildDocument.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildDocument()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuildDocument',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: BuildDocument.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xml')
    ..aOS(2, _omitFieldNames ? '' : 'inputSha256')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'inputRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<BuildModel>(4, _omitFieldNames ? '' : 'model',
        subBuilder: BuildModel.$_createMessage)
    ..aOM<CalculationResult>(5, _omitFieldNames ? '' : 'calculation',
        subBuilder: CalculationResult.$_createMessage)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'calculatedFromRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildDocument clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildDocument copyWith(void Function(BuildDocument) updates) =>
      super.copyWith((message) => updates(message as BuildDocument))
          as BuildDocument;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildDocument() / BuildDocument.new instead')
  static BuildDocument create() => BuildDocument._();
  static $pb.GeneratedMessage $_createMessage() => BuildDocument._();
  @$core.override
  BuildDocument createEmptyInstance() => BuildDocument._();
  @$core.pragma('dart2js:noInline')
  static BuildDocument getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildDocument>(
          BuildDocument.$_createMessage);
  static BuildDocument? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xml => $_getSZ(0);
  @$pb.TagNumber(1)
  set xml($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXml() => $_has(0);
  @$pb.TagNumber(1)
  void clearXml() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get inputSha256 => $_getSZ(1);
  @$pb.TagNumber(2)
  set inputSha256($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInputSha256() => $_has(1);
  @$pb.TagNumber(2)
  void clearInputSha256() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get inputRevision => $_getI64(2);
  @$pb.TagNumber(3)
  set inputRevision($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInputRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearInputRevision() => $_clearField(3);

  @$pb.TagNumber(4)
  BuildModel get model => $_getN(3);
  @$pb.TagNumber(4)
  set model(BuildModel value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasModel() => $_has(3);
  @$pb.TagNumber(4)
  void clearModel() => $_clearField(4);
  @$pb.TagNumber(4)
  BuildModel ensureModel() => $_ensure(3);

  @$pb.TagNumber(5)
  CalculationResult get calculation => $_getN(4);
  @$pb.TagNumber(5)
  set calculation(CalculationResult value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCalculation() => $_has(4);
  @$pb.TagNumber(5)
  void clearCalculation() => $_clearField(5);
  @$pb.TagNumber(5)
  CalculationResult ensureCalculation() => $_ensure(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get calculatedFromRevision => $_getI64(5);
  @$pb.TagNumber(6)
  set calculatedFromRevision($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCalculatedFromRevision() => $_has(5);
  @$pb.TagNumber(6)
  void clearCalculatedFromRevision() => $_clearField(6);
}

class LevelEdit extends $pb.GeneratedMessage {
  factory LevelEdit({
    $core.int? level,
  }) {
    final result = LevelEdit._();
    if (level != null) result.level = level;
    return result;
  }

  LevelEdit._();

  factory LevelEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LevelEdit()..mergeFromBuffer(data, registry);
  factory LevelEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LevelEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LevelEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: LevelEdit.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'level', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LevelEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LevelEdit copyWith(void Function(LevelEdit) updates) =>
      super.copyWith((message) => updates(message as LevelEdit)) as LevelEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LevelEdit() / LevelEdit.new instead')
  static LevelEdit create() => LevelEdit._();
  static $pb.GeneratedMessage $_createMessage() => LevelEdit._();
  @$core.override
  LevelEdit createEmptyInstance() => LevelEdit._();
  @$core.pragma('dart2js:noInline')
  static LevelEdit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LevelEdit>(LevelEdit.$_createMessage);
  static LevelEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get level => $_getIZ(0);
  @$pb.TagNumber(1)
  set level($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLevel() => $_clearField(1);
}

class ConfigEdit extends $pb.GeneratedMessage {
  factory ConfigEdit({
    $core.String? name,
    ConfigValue? value,
  }) {
    final result = ConfigEdit._();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    return result;
  }

  ConfigEdit._();

  factory ConfigEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfigEdit()..mergeFromBuffer(data, registry);
  factory ConfigEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConfigEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ConfigEdit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOM<ConfigValue>(2, _omitFieldNames ? '' : 'value',
        subBuilder: ConfigValue.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfigEdit copyWith(void Function(ConfigEdit) updates) =>
      super.copyWith((message) => updates(message as ConfigEdit)) as ConfigEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConfigEdit() / ConfigEdit.new instead')
  static ConfigEdit create() => ConfigEdit._();
  static $pb.GeneratedMessage $_createMessage() => ConfigEdit._();
  @$core.override
  ConfigEdit createEmptyInstance() => ConfigEdit._();
  @$core.pragma('dart2js:noInline')
  static ConfigEdit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigEdit>(ConfigEdit.$_createMessage);
  static ConfigEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// Отсутствие value удаляет условие.
  @$pb.TagNumber(2)
  ConfigValue get value => $_getN(1);
  @$pb.TagNumber(2)
  set value(ConfigValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
  @$pb.TagNumber(2)
  ConfigValue ensureValue() => $_ensure(1);
}

class GemInput extends $pb.GeneratedMessage {
  factory GemInput({
    $core.String? id,
    $core.int? level,
    $core.int? quality,
    $core.bool? enabled,
  }) {
    final result = GemInput._();
    if (id != null) result.id = id;
    if (level != null) result.level = level;
    if (quality != null) result.quality = quality;
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  GemInput._();

  factory GemInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GemInput()..mergeFromBuffer(data, registry);
  factory GemInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GemInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GemInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GemInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'level', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'quality', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GemInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GemInput copyWith(void Function(GemInput) updates) =>
      super.copyWith((message) => updates(message as GemInput)) as GemInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GemInput() / GemInput.new instead')
  static GemInput create() => GemInput._();
  static $pb.GeneratedMessage $_createMessage() => GemInput._();
  @$core.override
  GemInput createEmptyInstance() => GemInput._();
  @$core.pragma('dart2js:noInline')
  static GemInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GemInput>(GemInput.$_createMessage);
  static GemInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get level => $_getIZ(1);
  @$pb.TagNumber(2)
  set level($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLevel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLevel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get quality => $_getIZ(2);
  @$pb.TagNumber(3)
  set quality($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuality() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuality() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get enabled => $_getBF(3);
  @$pb.TagNumber(4)
  set enabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnabled() => $_clearField(4);
}

class GemsEdit extends $pb.GeneratedMessage {
  factory GemsEdit({
    $core.int? groupId,
    $core.String? label,
    $core.bool? enabled,
    $core.bool? delete,
    $core.Iterable<GemInput>? gems,
  }) {
    final result = GemsEdit._();
    if (groupId != null) result.groupId = groupId;
    if (label != null) result.label = label;
    if (enabled != null) result.enabled = enabled;
    if (delete != null) result.delete = delete;
    if (gems != null) result.gems.addAll(gems);
    return result;
  }

  GemsEdit._();

  factory GemsEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GemsEdit()..mergeFromBuffer(data, registry);
  factory GemsEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GemsEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GemsEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GemsEdit.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'groupId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'enabled')
    ..aOB(4, _omitFieldNames ? '' : 'delete')
    ..pPM<GemInput>(5, _omitFieldNames ? '' : 'gems',
        subBuilder: GemInput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GemsEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GemsEdit copyWith(void Function(GemsEdit) updates) =>
      super.copyWith((message) => updates(message as GemsEdit)) as GemsEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GemsEdit() / GemsEdit.new instead')
  static GemsEdit create() => GemsEdit._();
  static $pb.GeneratedMessage $_createMessage() => GemsEdit._();
  @$core.override
  GemsEdit createEmptyInstance() => GemsEdit._();
  @$core.pragma('dart2js:noInline')
  static GemsEdit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GemsEdit>(GemsEdit.$_createMessage);
  static GemsEdit? _defaultInstance;

  /// Ноль добавляет группу в конец выбранного набора.
  @$pb.TagNumber(1)
  $core.int get groupId => $_getIZ(0);
  @$pb.TagNumber(1)
  set groupId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enabled => $_getBF(2);
  @$pb.TagNumber(3)
  set enabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get delete => $_getBF(3);
  @$pb.TagNumber(4)
  set delete($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDelete() => $_has(3);
  @$pb.TagNumber(4)
  void clearDelete() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<GemInput> get gems => $_getList(4);
}

class EquipmentEdit extends $pb.GeneratedMessage {
  factory EquipmentEdit({
    $core.String? slot,
    $core.String? raw,
    $core.int? itemId,
  }) {
    final result = EquipmentEdit._();
    if (slot != null) result.slot = slot;
    if (raw != null) result.raw = raw;
    if (itemId != null) result.itemId = itemId;
    return result;
  }

  EquipmentEdit._();

  factory EquipmentEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EquipmentEdit()..mergeFromBuffer(data, registry);
  factory EquipmentEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EquipmentEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EquipmentEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: EquipmentEdit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'slot')
    ..aOS(2, _omitFieldNames ? '' : 'raw')
    ..aI(3, _omitFieldNames ? '' : 'itemId', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EquipmentEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EquipmentEdit copyWith(void Function(EquipmentEdit) updates) =>
      super.copyWith((message) => updates(message as EquipmentEdit))
          as EquipmentEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EquipmentEdit() / EquipmentEdit.new instead')
  static EquipmentEdit create() => EquipmentEdit._();
  static $pb.GeneratedMessage $_createMessage() => EquipmentEdit._();
  @$core.override
  EquipmentEdit createEmptyInstance() => EquipmentEdit._();
  @$core.pragma('dart2js:noInline')
  static EquipmentEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EquipmentEdit>(
          EquipmentEdit.$_createMessage);
  static EquipmentEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get slot => $_getSZ(0);
  @$pb.TagNumber(1)
  set slot($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  /// Без текста и ID предмет снимается.
  @$pb.TagNumber(2)
  $core.String get raw => $_getSZ(1);
  @$pb.TagNumber(2)
  set raw($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRaw() => $_has(1);
  @$pb.TagNumber(2)
  void clearRaw() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get itemId => $_getIZ(2);
  @$pb.TagNumber(3)
  set itemId($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasItemId() => $_has(2);
  @$pb.TagNumber(3)
  void clearItemId() => $_clearField(3);
}

class PassivesEdit extends $pb.GeneratedMessage {
  factory PassivesEdit({
    $core.Iterable<$core.int>? nodes,
  }) {
    final result = PassivesEdit._();
    if (nodes != null) result.nodes.addAll(nodes);
    return result;
  }

  PassivesEdit._();

  factory PassivesEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassivesEdit()..mergeFromBuffer(data, registry);
  factory PassivesEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassivesEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PassivesEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PassivesEdit.$_createMessage)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'nodes', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassivesEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassivesEdit copyWith(void Function(PassivesEdit) updates) =>
      super.copyWith((message) => updates(message as PassivesEdit))
          as PassivesEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PassivesEdit() / PassivesEdit.new instead')
  static PassivesEdit create() => PassivesEdit._();
  static $pb.GeneratedMessage $_createMessage() => PassivesEdit._();
  @$core.override
  PassivesEdit createEmptyInstance() => PassivesEdit._();
  @$core.pragma('dart2js:noInline')
  static PassivesEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PassivesEdit>(
          PassivesEdit.$_createMessage);
  static PassivesEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get nodes => $_getList(0);
}

class JewelEdit extends $pb.GeneratedMessage {
  factory JewelEdit({
    $core.int? nodeId,
    $core.int? itemId,
    $core.String? raw,
  }) {
    final result = JewelEdit._();
    if (nodeId != null) result.nodeId = nodeId;
    if (itemId != null) result.itemId = itemId;
    if (raw != null) result.raw = raw;
    return result;
  }

  JewelEdit._();

  factory JewelEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JewelEdit()..mergeFromBuffer(data, registry);
  factory JewelEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      JewelEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JewelEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: JewelEdit.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'nodeId', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'itemId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'raw')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JewelEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JewelEdit copyWith(void Function(JewelEdit) updates) =>
      super.copyWith((message) => updates(message as JewelEdit)) as JewelEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use JewelEdit() / JewelEdit.new instead')
  static JewelEdit create() => JewelEdit._();
  static $pb.GeneratedMessage $_createMessage() => JewelEdit._();
  @$core.override
  JewelEdit createEmptyInstance() => JewelEdit._();
  @$core.pragma('dart2js:noInline')
  static JewelEdit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JewelEdit>(JewelEdit.$_createMessage);
  static JewelEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nodeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  /// Выберите предмет из сборки либо передайте его текст. Без обоих полей самоцвет снимается.
  @$pb.TagNumber(2)
  $core.int get itemId => $_getIZ(1);
  @$pb.TagNumber(2)
  set itemId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasItemId() => $_has(1);
  @$pb.TagNumber(2)
  void clearItemId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get raw => $_getSZ(2);
  @$pb.TagNumber(3)
  set raw($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRaw() => $_has(2);
  @$pb.TagNumber(3)
  void clearRaw() => $_clearField(3);
}

class SelectionEdit extends $pb.GeneratedMessage {
  factory SelectionEdit({
    ActiveSets? sets,
    $core.int? mainGroup,
    $core.int? weaponSet,
  }) {
    final result = SelectionEdit._();
    if (sets != null) result.sets = sets;
    if (mainGroup != null) result.mainGroup = mainGroup;
    if (weaponSet != null) result.weaponSet = weaponSet;
    return result;
  }

  SelectionEdit._();

  factory SelectionEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SelectionEdit()..mergeFromBuffer(data, registry);
  factory SelectionEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SelectionEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SelectionEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: SelectionEdit.$_createMessage)
    ..aOM<ActiveSets>(1, _omitFieldNames ? '' : 'sets',
        subBuilder: ActiveSets.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'mainGroup', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'weaponSet', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectionEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SelectionEdit copyWith(void Function(SelectionEdit) updates) =>
      super.copyWith((message) => updates(message as SelectionEdit))
          as SelectionEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SelectionEdit() / SelectionEdit.new instead')
  static SelectionEdit create() => SelectionEdit._();
  static $pb.GeneratedMessage $_createMessage() => SelectionEdit._();
  @$core.override
  SelectionEdit createEmptyInstance() => SelectionEdit._();
  @$core.pragma('dart2js:noInline')
  static SelectionEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SelectionEdit>(
          SelectionEdit.$_createMessage);
  static SelectionEdit? _defaultInstance;

  @$pb.TagNumber(1)
  ActiveSets get sets => $_getN(0);
  @$pb.TagNumber(1)
  set sets(ActiveSets value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSets() => $_has(0);
  @$pb.TagNumber(1)
  void clearSets() => $_clearField(1);
  @$pb.TagNumber(1)
  ActiveSets ensureSets() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get mainGroup => $_getIZ(1);
  @$pb.TagNumber(2)
  set mainGroup($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMainGroup() => $_has(1);
  @$pb.TagNumber(2)
  void clearMainGroup() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get weaponSet => $_getIZ(2);
  @$pb.TagNumber(3)
  set weaponSet($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWeaponSet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeaponSet() => $_clearField(3);
}

class AddSupportEdit extends $pb.GeneratedMessage {
  factory AddSupportEdit({
    $core.String? supportId,
    $core.int? level,
    $core.int? quality,
  }) {
    final result = AddSupportEdit._();
    if (supportId != null) result.supportId = supportId;
    if (level != null) result.level = level;
    if (quality != null) result.quality = quality;
    return result;
  }

  AddSupportEdit._();

  factory AddSupportEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddSupportEdit()..mergeFromBuffer(data, registry);
  factory AddSupportEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddSupportEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddSupportEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: AddSupportEdit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'supportId')
    ..aI(2, _omitFieldNames ? '' : 'level', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'quality', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSupportEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSupportEdit copyWith(void Function(AddSupportEdit) updates) =>
      super.copyWith((message) => updates(message as AddSupportEdit))
          as AddSupportEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddSupportEdit() / AddSupportEdit.new instead')
  static AddSupportEdit create() => AddSupportEdit._();
  static $pb.GeneratedMessage $_createMessage() => AddSupportEdit._();
  @$core.override
  AddSupportEdit createEmptyInstance() => AddSupportEdit._();
  @$core.pragma('dart2js:noInline')
  static AddSupportEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddSupportEdit>(
          AddSupportEdit.$_createMessage);
  static AddSupportEdit? _defaultInstance;

  /// Идентификатор поддержки из каталога PoB.
  @$pb.TagNumber(1)
  $core.String get supportId => $_getSZ(0);
  @$pb.TagNumber(1)
  set supportId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSupportId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupportId() => $_clearField(1);

  /// Ноль означает первый уровень.
  @$pb.TagNumber(2)
  $core.int get level => $_getIZ(1);
  @$pb.TagNumber(2)
  set level($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLevel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLevel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get quality => $_getIZ(2);
  @$pb.TagNumber(3)
  set quality($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuality() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuality() => $_clearField(3);
}

class TreeNodeEdit extends $pb.GeneratedMessage {
  factory TreeNodeEdit({
    $core.int? nodeId,
    $core.String? action,
    $core.String? attribute,
    $core.String? allocationMode,
  }) {
    final result = TreeNodeEdit._();
    if (nodeId != null) result.nodeId = nodeId;
    if (action != null) result.action = action;
    if (attribute != null) result.attribute = attribute;
    if (allocationMode != null) result.allocationMode = allocationMode;
    return result;
  }

  TreeNodeEdit._();

  factory TreeNodeEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeNodeEdit()..mergeFromBuffer(data, registry);
  factory TreeNodeEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeNodeEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeNodeEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreeNodeEdit.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'nodeId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'action')
    ..aOS(3, _omitFieldNames ? '' : 'attribute')
    ..aOS(4, _omitFieldNames ? '' : 'allocationMode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeNodeEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeNodeEdit copyWith(void Function(TreeNodeEdit) updates) =>
      super.copyWith((message) => updates(message as TreeNodeEdit))
          as TreeNodeEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreeNodeEdit() / TreeNodeEdit.new instead')
  static TreeNodeEdit create() => TreeNodeEdit._();
  static $pb.GeneratedMessage $_createMessage() => TreeNodeEdit._();
  @$core.override
  TreeNodeEdit createEmptyInstance() => TreeNodeEdit._();
  @$core.pragma('dart2js:noInline')
  static TreeNodeEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreeNodeEdit>(
          TreeNodeEdit.$_createMessage);
  static TreeNodeEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nodeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  /// allocate, refund или set_attribute в активной спецификации.
  @$pb.TagNumber(2)
  $core.String get action => $_getSZ(1);
  @$pb.TagNumber(2)
  set action($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  /// strength, dexterity или intelligence. При allocate поле необязательно.
  @$pb.TagNumber(3)
  $core.String get attribute => $_getSZ(2);
  @$pb.TagNumber(3)
  set attribute($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAttribute() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttribute() => $_clearField(3);

  /// common, weapon_set_1 или weapon_set_2. Отсутствие сохраняет поведение 0.0.11.
  @$pb.TagNumber(4)
  $core.String get allocationMode => $_getSZ(3);
  @$pb.TagNumber(4)
  set allocationMode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAllocationMode() => $_has(3);
  @$pb.TagNumber(4)
  void clearAllocationMode() => $_clearField(4);
}

class TreeClassEdit extends $pb.GeneratedMessage {
  factory TreeClassEdit({
    $core.int? classId,
    $core.int? ascendancyId,
    $core.String? mode,
  }) {
    final result = TreeClassEdit._();
    if (classId != null) result.classId = classId;
    if (ascendancyId != null) result.ascendancyId = ascendancyId;
    if (mode != null) result.mode = mode;
    return result;
  }

  TreeClassEdit._();

  factory TreeClassEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeClassEdit()..mergeFromBuffer(data, registry);
  factory TreeClassEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeClassEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeClassEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreeClassEdit.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'classId', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'ascendancyId',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'mode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeClassEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeClassEdit copyWith(void Function(TreeClassEdit) updates) =>
      super.copyWith((message) => updates(message as TreeClassEdit))
          as TreeClassEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreeClassEdit() / TreeClassEdit.new instead')
  static TreeClassEdit create() => TreeClassEdit._();
  static $pb.GeneratedMessage $_createMessage() => TreeClassEdit._();
  @$core.override
  TreeClassEdit createEmptyInstance() => TreeClassEdit._();
  @$core.pragma('dart2js:noInline')
  static TreeClassEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreeClassEdit>(
          TreeClassEdit.$_createMessage);
  static TreeClassEdit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get classId => $_getIZ(0);
  @$pb.TagNumber(1)
  set classId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get ascendancyId => $_getIZ(1);
  @$pb.TagNumber(2)
  set ascendancyId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAscendancyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAscendancyId() => $_clearField(2);

  /// Пустой режим сохраняет путь. connect соединяет путь, reset сбрасывает узлы.
  @$pb.TagNumber(3)
  $core.String get mode => $_getSZ(2);
  @$pb.TagNumber(3)
  set mode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMode() => $_has(2);
  @$pb.TagNumber(3)
  void clearMode() => $_clearField(3);
}

class GetTreeGeometryRequest extends $pb.GeneratedMessage {
  factory GetTreeGeometryRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.bool? includeScene,
  }) {
    final result = GetTreeGeometryRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (includeScene != null) result.includeScene = includeScene;
    return result;
  }

  GetTreeGeometryRequest._();

  factory GetTreeGeometryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeGeometryRequest()..mergeFromBuffer(data, registry);
  factory GetTreeGeometryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeGeometryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreeGeometryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreeGeometryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(3, _omitFieldNames ? '' : 'includeScene')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeGeometryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeGeometryRequest copyWith(
          void Function(GetTreeGeometryRequest) updates) =>
      super.copyWith((message) => updates(message as GetTreeGeometryRequest))
          as GetTreeGeometryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetTreeGeometryRequest() / GetTreeGeometryRequest.new instead')
  static GetTreeGeometryRequest create() => GetTreeGeometryRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTreeGeometryRequest._();
  @$core.override
  GetTreeGeometryRequest createEmptyInstance() => GetTreeGeometryRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTreeGeometryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreeGeometryRequest>(
          GetTreeGeometryRequest.$_createMessage);
  static GetTreeGeometryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  /// Ноль читает дерево последнего снимка сессии.
  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeScene => $_getBF(2);
  @$pb.TagNumber(3)
  set includeScene($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeScene() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeScene() => $_clearField(3);
}

class GetTreeGeometryResponse extends $pb.GeneratedMessage {
  factory GetTreeGeometryResponse({
    $fixnum.Int64? revision,
    $core.String? version,
    $core.Iterable<TreeGeometryNode>? nodes,
    $core.Iterable<TreeGeometryEdge>? edges,
    TreeScene? scene,
  }) {
    final result = GetTreeGeometryResponse._();
    if (revision != null) result.revision = revision;
    if (version != null) result.version = version;
    if (nodes != null) result.nodes.addAll(nodes);
    if (edges != null) result.edges.addAll(edges);
    if (scene != null) result.scene = scene;
    return result;
  }

  GetTreeGeometryResponse._();

  factory GetTreeGeometryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeGeometryResponse()..mergeFromBuffer(data, registry);
  factory GetTreeGeometryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeGeometryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreeGeometryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreeGeometryResponse.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..pPM<TreeGeometryNode>(3, _omitFieldNames ? '' : 'nodes',
        subBuilder: TreeGeometryNode.$_createMessage)
    ..pPM<TreeGeometryEdge>(4, _omitFieldNames ? '' : 'edges',
        subBuilder: TreeGeometryEdge.$_createMessage)
    ..aOM<TreeScene>(5, _omitFieldNames ? '' : 'scene',
        subBuilder: TreeScene.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeGeometryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeGeometryResponse copyWith(
          void Function(GetTreeGeometryResponse) updates) =>
      super.copyWith((message) => updates(message as GetTreeGeometryResponse))
          as GetTreeGeometryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetTreeGeometryResponse() / GetTreeGeometryResponse.new instead')
  static GetTreeGeometryResponse create() => GetTreeGeometryResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTreeGeometryResponse._();
  @$core.override
  GetTreeGeometryResponse createEmptyInstance() => GetTreeGeometryResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTreeGeometryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreeGeometryResponse>(
          GetTreeGeometryResponse.$_createMessage);
  static GetTreeGeometryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revision => $_getI64(0);
  @$pb.TagNumber(1)
  set revision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevision() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<TreeGeometryNode> get nodes => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<TreeGeometryEdge> get edges => $_getList(3);

  @$pb.TagNumber(5)
  TreeScene get scene => $_getN(4);
  @$pb.TagNumber(5)
  set scene(TreeScene value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasScene() => $_has(4);
  @$pb.TagNumber(5)
  void clearScene() => $_clearField(5);
  @$pb.TagNumber(5)
  TreeScene ensureScene() => $_ensure(4);
}

class TreeGeometryNode extends $pb.GeneratedMessage {
  factory TreeGeometryNode({
    $core.int? id,
    $core.double? x,
    $core.double? y,
    $core.String? name,
    $core.String? kind,
    $core.String? icon,
    $core.bool? allocated,
    $core.bool? attribute,
    $core.int? allocationMode,
    $core.double? drawSize,
  }) {
    final result = TreeGeometryNode._();
    if (id != null) result.id = id;
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (icon != null) result.icon = icon;
    if (allocated != null) result.allocated = allocated;
    if (attribute != null) result.attribute = attribute;
    if (allocationMode != null) result.allocationMode = allocationMode;
    if (drawSize != null) result.drawSize = drawSize;
    return result;
  }

  TreeGeometryNode._();

  factory TreeGeometryNode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeGeometryNode()..mergeFromBuffer(data, registry);
  factory TreeGeometryNode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeGeometryNode()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeGeometryNode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreeGeometryNode.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aD(2, _omitFieldNames ? '' : 'x')
    ..aD(3, _omitFieldNames ? '' : 'y')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'kind')
    ..aOS(6, _omitFieldNames ? '' : 'icon')
    ..aOB(7, _omitFieldNames ? '' : 'allocated')
    ..aOB(8, _omitFieldNames ? '' : 'attribute')
    ..aI(9, _omitFieldNames ? '' : 'allocationMode',
        fieldType: $pb.PbFieldType.OU3)
    ..aD(10, _omitFieldNames ? '' : 'drawSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeGeometryNode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeGeometryNode copyWith(void Function(TreeGeometryNode) updates) =>
      super.copyWith((message) => updates(message as TreeGeometryNode))
          as TreeGeometryNode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreeGeometryNode() / TreeGeometryNode.new instead')
  static TreeGeometryNode create() => TreeGeometryNode._();
  static $pb.GeneratedMessage $_createMessage() => TreeGeometryNode._();
  @$core.override
  TreeGeometryNode createEmptyInstance() => TreeGeometryNode._();
  @$core.pragma('dart2js:noInline')
  static TreeGeometryNode getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreeGeometryNode>(
          TreeGeometryNode.$_createMessage);
  static TreeGeometryNode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get x => $_getN(1);
  @$pb.TagNumber(2)
  set x($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasX() => $_has(1);
  @$pb.TagNumber(2)
  void clearX() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get y => $_getN(2);
  @$pb.TagNumber(3)
  set y($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasY() => $_has(2);
  @$pb.TagNumber(3)
  void clearY() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get kind => $_getSZ(4);
  @$pb.TagNumber(5)
  set kind($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get icon => $_getSZ(5);
  @$pb.TagNumber(6)
  set icon($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIcon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIcon() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get allocated => $_getBF(6);
  @$pb.TagNumber(7)
  set allocated($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAllocated() => $_has(6);
  @$pb.TagNumber(7)
  void clearAllocated() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get attribute => $_getBF(7);
  @$pb.TagNumber(8)
  set attribute($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAttribute() => $_has(7);
  @$pb.TagNumber(8)
  void clearAttribute() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get allocationMode => $_getIZ(8);
  @$pb.TagNumber(9)
  set allocationMode($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAllocationMode() => $_has(8);
  @$pb.TagNumber(9)
  void clearAllocationMode() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get drawSize => $_getN(9);
  @$pb.TagNumber(10)
  set drawSize($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDrawSize() => $_has(9);
  @$pb.TagNumber(10)
  void clearDrawSize() => $_clearField(10);
}

class TreeGeometryEdge extends $pb.GeneratedMessage {
  factory TreeGeometryEdge({
    $core.int? fromNode,
    $core.int? toNode,
    $core.bool? hiddenInScene,
  }) {
    final result = TreeGeometryEdge._();
    if (fromNode != null) result.fromNode = fromNode;
    if (toNode != null) result.toNode = toNode;
    if (hiddenInScene != null) result.hiddenInScene = hiddenInScene;
    return result;
  }

  TreeGeometryEdge._();

  factory TreeGeometryEdge.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeGeometryEdge()..mergeFromBuffer(data, registry);
  factory TreeGeometryEdge.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeGeometryEdge()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeGeometryEdge',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreeGeometryEdge.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'fromNode', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'toNode', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'hiddenInScene')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeGeometryEdge clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeGeometryEdge copyWith(void Function(TreeGeometryEdge) updates) =>
      super.copyWith((message) => updates(message as TreeGeometryEdge))
          as TreeGeometryEdge;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreeGeometryEdge() / TreeGeometryEdge.new instead')
  static TreeGeometryEdge create() => TreeGeometryEdge._();
  static $pb.GeneratedMessage $_createMessage() => TreeGeometryEdge._();
  @$core.override
  TreeGeometryEdge createEmptyInstance() => TreeGeometryEdge._();
  @$core.pragma('dart2js:noInline')
  static TreeGeometryEdge getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreeGeometryEdge>(
          TreeGeometryEdge.$_createMessage);
  static TreeGeometryEdge? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get fromNode => $_getIZ(0);
  @$pb.TagNumber(1)
  set fromNode($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromNode() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromNode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get toNode => $_getIZ(1);
  @$pb.TagNumber(2)
  set toNode($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToNode() => $_has(1);
  @$pb.TagNumber(2)
  void clearToNode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hiddenInScene => $_getBF(2);
  @$pb.TagNumber(3)
  set hiddenInScene($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHiddenInScene() => $_has(2);
  @$pb.TagNumber(3)
  void clearHiddenInScene() => $_clearField(3);
}

class GetTreeNodeTooltipRequest extends $pb.GeneratedMessage {
  factory GetTreeNodeTooltipRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.int? nodeId,
    $core.bool? compare,
    $core.bool? includeScene,
  }) {
    final result = GetTreeNodeTooltipRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (nodeId != null) result.nodeId = nodeId;
    if (compare != null) result.compare = compare;
    if (includeScene != null) result.includeScene = includeScene;
    return result;
  }

  GetTreeNodeTooltipRequest._();

  factory GetTreeNodeTooltipRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeNodeTooltipRequest()..mergeFromBuffer(data, registry);
  factory GetTreeNodeTooltipRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeNodeTooltipRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreeNodeTooltipRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreeNodeTooltipRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'nodeId', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'compare')
    ..aOB(5, _omitFieldNames ? '' : 'includeScene')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeNodeTooltipRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeNodeTooltipRequest copyWith(
          void Function(GetTreeNodeTooltipRequest) updates) =>
      super.copyWith((message) => updates(message as GetTreeNodeTooltipRequest))
          as GetTreeNodeTooltipRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetTreeNodeTooltipRequest() / GetTreeNodeTooltipRequest.new instead')
  static GetTreeNodeTooltipRequest create() => GetTreeNodeTooltipRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GetTreeNodeTooltipRequest._();
  @$core.override
  GetTreeNodeTooltipRequest createEmptyInstance() =>
      GetTreeNodeTooltipRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTreeNodeTooltipRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreeNodeTooltipRequest>(
          GetTreeNodeTooltipRequest.$_createMessage);
  static GetTreeNodeTooltipRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get nodeId => $_getIZ(2);
  @$pb.TagNumber(3)
  set nodeId($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get compare => $_getBF(3);
  @$pb.TagNumber(4)
  set compare($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCompare() => $_has(3);
  @$pb.TagNumber(4)
  void clearCompare() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeScene => $_getBF(4);
  @$pb.TagNumber(5)
  set includeScene($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeScene() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeScene() => $_clearField(5);
}

class GetTreeNodeTooltipResponse extends $pb.GeneratedMessage {
  factory GetTreeNodeTooltipResponse({
    $fixnum.Int64? revision,
    $core.int? nodeId,
    $core.Iterable<TreeTooltipLine>? lines,
    $core.Iterable<$core.int>? path,
    $core.int? points,
    $core.String? note,
    $core.Iterable<$core.String>? recipe,
    TreeScene? scene,
  }) {
    final result = GetTreeNodeTooltipResponse._();
    if (revision != null) result.revision = revision;
    if (nodeId != null) result.nodeId = nodeId;
    if (lines != null) result.lines.addAll(lines);
    if (path != null) result.path.addAll(path);
    if (points != null) result.points = points;
    if (note != null) result.note = note;
    if (recipe != null) result.recipe.addAll(recipe);
    if (scene != null) result.scene = scene;
    return result;
  }

  GetTreeNodeTooltipResponse._();

  factory GetTreeNodeTooltipResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeNodeTooltipResponse()..mergeFromBuffer(data, registry);
  factory GetTreeNodeTooltipResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeNodeTooltipResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreeNodeTooltipResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreeNodeTooltipResponse.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(2, _omitFieldNames ? '' : 'nodeId', fieldType: $pb.PbFieldType.OU3)
    ..pPM<TreeTooltipLine>(3, _omitFieldNames ? '' : 'lines',
        subBuilder: TreeTooltipLine.$_createMessage)
    ..p<$core.int>(4, _omitFieldNames ? '' : 'path', $pb.PbFieldType.KU3)
    ..aI(5, _omitFieldNames ? '' : 'points', fieldType: $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'note')
    ..pPS(7, _omitFieldNames ? '' : 'recipe')
    ..aOM<TreeScene>(8, _omitFieldNames ? '' : 'scene',
        subBuilder: TreeScene.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeNodeTooltipResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeNodeTooltipResponse copyWith(
          void Function(GetTreeNodeTooltipResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetTreeNodeTooltipResponse))
          as GetTreeNodeTooltipResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetTreeNodeTooltipResponse() / GetTreeNodeTooltipResponse.new instead')
  static GetTreeNodeTooltipResponse create() => GetTreeNodeTooltipResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      GetTreeNodeTooltipResponse._();
  @$core.override
  GetTreeNodeTooltipResponse createEmptyInstance() =>
      GetTreeNodeTooltipResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTreeNodeTooltipResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreeNodeTooltipResponse>(
          GetTreeNodeTooltipResponse.$_createMessage);
  static GetTreeNodeTooltipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revision => $_getI64(0);
  @$pb.TagNumber(1)
  set revision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevision() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get nodeId => $_getIZ(1);
  @$pb.TagNumber(2)
  set nodeId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNodeId() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodeId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<TreeTooltipLine> get lines => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.int> get path => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get points => $_getIZ(4);
  @$pb.TagNumber(5)
  set points($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPoints() => $_has(4);
  @$pb.TagNumber(5)
  void clearPoints() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get note => $_getSZ(5);
  @$pb.TagNumber(6)
  set note($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNote() => $_has(5);
  @$pb.TagNumber(6)
  void clearNote() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get recipe => $_getList(6);

  @$pb.TagNumber(8)
  TreeScene get scene => $_getN(7);
  @$pb.TagNumber(8)
  set scene(TreeScene value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasScene() => $_has(7);
  @$pb.TagNumber(8)
  void clearScene() => $_clearField(8);
  @$pb.TagNumber(8)
  TreeScene ensureScene() => $_ensure(7);
}

class TreeTooltipLine extends $pb.GeneratedMessage {
  factory TreeTooltipLine({
    $core.double? size,
    $core.String? text,
    $core.bool? separator,
  }) {
    final result = TreeTooltipLine._();
    if (size != null) result.size = size;
    if (text != null) result.text = text;
    if (separator != null) result.separator = separator;
    return result;
  }

  TreeTooltipLine._();

  factory TreeTooltipLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeTooltipLine()..mergeFromBuffer(data, registry);
  factory TreeTooltipLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeTooltipLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeTooltipLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreeTooltipLine.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'size')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOB(3, _omitFieldNames ? '' : 'separator')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeTooltipLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeTooltipLine copyWith(void Function(TreeTooltipLine) updates) =>
      super.copyWith((message) => updates(message as TreeTooltipLine))
          as TreeTooltipLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreeTooltipLine() / TreeTooltipLine.new instead')
  static TreeTooltipLine create() => TreeTooltipLine._();
  static $pb.GeneratedMessage $_createMessage() => TreeTooltipLine._();
  @$core.override
  TreeTooltipLine createEmptyInstance() => TreeTooltipLine._();
  @$core.pragma('dart2js:noInline')
  static TreeTooltipLine getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreeTooltipLine>(
          TreeTooltipLine.$_createMessage);
  static TreeTooltipLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get size => $_getN(0);
  @$pb.TagNumber(1)
  set size($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get separator => $_getBF(2);
  @$pb.TagNumber(3)
  set separator($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeparator() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeparator() => $_clearField(3);
}

class GetBuildReportRequest extends $pb.GeneratedMessage {
  factory GetBuildReportRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
  }) {
    final result = GetBuildReportRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    return result;
  }

  GetBuildReportRequest._();

  factory GetBuildReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBuildReportRequest()..mergeFromBuffer(data, registry);
  factory GetBuildReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBuildReportRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBuildReportRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetBuildReportRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBuildReportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBuildReportRequest copyWith(
          void Function(GetBuildReportRequest) updates) =>
      super.copyWith((message) => updates(message as GetBuildReportRequest))
          as GetBuildReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetBuildReportRequest() / GetBuildReportRequest.new instead')
  static GetBuildReportRequest create() => GetBuildReportRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBuildReportRequest._();
  @$core.override
  GetBuildReportRequest createEmptyInstance() => GetBuildReportRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBuildReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBuildReportRequest>(
          GetBuildReportRequest.$_createMessage);
  static GetBuildReportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedRevision() => $_clearField(2);
}

class GetBuildReportResponse extends $pb.GeneratedMessage {
  factory GetBuildReportResponse({
    $fixnum.Int64? revision,
    $core.List<$core.int>? reportJson,
  }) {
    final result = GetBuildReportResponse._();
    if (revision != null) result.revision = revision;
    if (reportJson != null) result.reportJson = reportJson;
    return result;
  }

  GetBuildReportResponse._();

  factory GetBuildReportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBuildReportResponse()..mergeFromBuffer(data, registry);
  factory GetBuildReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBuildReportResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBuildReportResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetBuildReportResponse.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'reportJson', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBuildReportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBuildReportResponse copyWith(
          void Function(GetBuildReportResponse) updates) =>
      super.copyWith((message) => updates(message as GetBuildReportResponse))
          as GetBuildReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetBuildReportResponse() / GetBuildReportResponse.new instead')
  static GetBuildReportResponse create() => GetBuildReportResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBuildReportResponse._();
  @$core.override
  GetBuildReportResponse createEmptyInstance() => GetBuildReportResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBuildReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBuildReportResponse>(
          GetBuildReportResponse.$_createMessage);
  static GetBuildReportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revision => $_getI64(0);
  @$pb.TagNumber(1)
  set revision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevision() => $_clearField(1);

  /// UTF-8 JSON с полями штатного отчёта PoB II, включая целые ID форм и каталогов.
  @$pb.TagNumber(2)
  $core.List<$core.int> get reportJson => $_getN(1);
  @$pb.TagNumber(2)
  set reportJson($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReportJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearReportJson() => $_clearField(2);
}

class SkillChoiceEdit extends $pb.GeneratedMessage {
  factory SkillChoiceEdit({
    $core.String? control,
    $core.int? optionId,
  }) {
    final result = SkillChoiceEdit._();
    if (control != null) result.control = control;
    if (optionId != null) result.optionId = optionId;
    return result;
  }

  SkillChoiceEdit._();

  factory SkillChoiceEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillChoiceEdit()..mergeFromBuffer(data, registry);
  factory SkillChoiceEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillChoiceEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SkillChoiceEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: SkillChoiceEdit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'control')
    ..aI(2, _omitFieldNames ? '' : 'optionId', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillChoiceEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillChoiceEdit copyWith(void Function(SkillChoiceEdit) updates) =>
      super.copyWith((message) => updates(message as SkillChoiceEdit))
          as SkillChoiceEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SkillChoiceEdit() / SkillChoiceEdit.new instead')
  static SkillChoiceEdit create() => SkillChoiceEdit._();
  static $pb.GeneratedMessage $_createMessage() => SkillChoiceEdit._();
  @$core.override
  SkillChoiceEdit createEmptyInstance() => SkillChoiceEdit._();
  @$core.pragma('dart2js:noInline')
  static SkillChoiceEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SkillChoiceEdit>(
          SkillChoiceEdit.$_createMessage);
  static SkillChoiceEdit? _defaultInstance;

  /// groups, skills, parts или stat_sets.
  @$pb.TagNumber(1)
  $core.String get control => $_getSZ(0);
  @$pb.TagNumber(1)
  set control($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasControl() => $_has(0);
  @$pb.TagNumber(1)
  void clearControl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get optionId => $_getIZ(1);
  @$pb.TagNumber(2)
  set optionId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOptionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOptionId() => $_clearField(2);
}

class SkillGroupEdit extends $pb.GeneratedMessage {
  factory SkillGroupEdit({
    $core.int? groupId,
    $core.String? label,
    $core.bool? delete,
    $core.Iterable<SkillGroupGem>? gems,
  }) {
    final result = SkillGroupEdit._();
    if (groupId != null) result.groupId = groupId;
    if (label != null) result.label = label;
    if (delete != null) result.delete = delete;
    if (gems != null) result.gems.addAll(gems);
    return result;
  }

  SkillGroupEdit._();

  factory SkillGroupEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillGroupEdit()..mergeFromBuffer(data, registry);
  factory SkillGroupEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillGroupEdit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SkillGroupEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: SkillGroupEdit.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'groupId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'delete')
    ..pPM<SkillGroupGem>(4, _omitFieldNames ? '' : 'gems',
        subBuilder: SkillGroupGem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillGroupEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillGroupEdit copyWith(void Function(SkillGroupEdit) updates) =>
      super.copyWith((message) => updates(message as SkillGroupEdit))
          as SkillGroupEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SkillGroupEdit() / SkillGroupEdit.new instead')
  static SkillGroupEdit create() => SkillGroupEdit._();
  static $pb.GeneratedMessage $_createMessage() => SkillGroupEdit._();
  @$core.override
  SkillGroupEdit createEmptyInstance() => SkillGroupEdit._();
  @$core.pragma('dart2js:noInline')
  static SkillGroupEdit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SkillGroupEdit>(
          SkillGroupEdit.$_createMessage);
  static SkillGroupEdit? _defaultInstance;

  /// Ноль создаёт обычную группу. Положительный номер берётся из штатного отчёта.
  @$pb.TagNumber(1)
  $core.int get groupId => $_getIZ(0);
  @$pb.TagNumber(1)
  set groupId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get delete => $_getBF(2);
  @$pb.TagNumber(3)
  set delete($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDelete() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelete() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<SkillGroupGem> get gems => $_getList(3);
}

class SkillGroupGem extends $pb.GeneratedMessage {
  factory SkillGroupGem({
    $core.String? id,
    $core.int? level,
    $core.int? quality,
    $core.bool? enabled,
    $core.int? sourceIndex,
  }) {
    final result = SkillGroupGem._();
    if (id != null) result.id = id;
    if (level != null) result.level = level;
    if (quality != null) result.quality = quality;
    if (enabled != null) result.enabled = enabled;
    if (sourceIndex != null) result.sourceIndex = sourceIndex;
    return result;
  }

  SkillGroupGem._();

  factory SkillGroupGem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillGroupGem()..mergeFromBuffer(data, registry);
  factory SkillGroupGem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SkillGroupGem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SkillGroupGem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: SkillGroupGem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'level', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'quality', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'enabled')
    ..aI(5, _omitFieldNames ? '' : 'sourceIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillGroupGem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SkillGroupGem copyWith(void Function(SkillGroupGem) updates) =>
      super.copyWith((message) => updates(message as SkillGroupGem))
          as SkillGroupGem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SkillGroupGem() / SkillGroupGem.new instead')
  static SkillGroupGem create() => SkillGroupGem._();
  static $pb.GeneratedMessage $_createMessage() => SkillGroupGem._();
  @$core.override
  SkillGroupGem createEmptyInstance() => SkillGroupGem._();
  @$core.pragma('dart2js:noInline')
  static SkillGroupGem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SkillGroupGem>(
          SkillGroupGem.$_createMessage);
  static SkillGroupGem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get level => $_getIZ(1);
  @$pb.TagNumber(2)
  set level($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLevel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLevel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get quality => $_getIZ(2);
  @$pb.TagNumber(3)
  set quality($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuality() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuality() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get enabled => $_getBF(3);
  @$pb.TagNumber(4)
  set enabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnabled() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sourceIndex => $_getIZ(4);
  @$pb.TagNumber(5)
  set sourceIndex($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourceIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourceIndex() => $_clearField(5);
}

class GetTreePowerRequest extends $pb.GeneratedMessage {
  factory GetTreePowerRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.String? metric,
    $core.int? maxDistance,
    $core.String? allocation,
    $core.bool? includeScene,
  }) {
    final result = GetTreePowerRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (metric != null) result.metric = metric;
    if (maxDistance != null) result.maxDistance = maxDistance;
    if (allocation != null) result.allocation = allocation;
    if (includeScene != null) result.includeScene = includeScene;
    return result;
  }

  GetTreePowerRequest._();

  factory GetTreePowerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreePowerRequest()..mergeFromBuffer(data, registry);
  factory GetTreePowerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreePowerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreePowerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreePowerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'metric')
    ..aI(4, _omitFieldNames ? '' : 'maxDistance',
        fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'allocation')
    ..aOB(6, _omitFieldNames ? '' : 'includeScene')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreePowerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreePowerRequest copyWith(void Function(GetTreePowerRequest) updates) =>
      super.copyWith((message) => updates(message as GetTreePowerRequest))
          as GetTreePowerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use GetTreePowerRequest() / GetTreePowerRequest.new instead')
  static GetTreePowerRequest create() => GetTreePowerRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTreePowerRequest._();
  @$core.override
  GetTreePowerRequest createEmptyInstance() => GetTreePowerRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTreePowerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreePowerRequest>(
          GetTreePowerRequest.$_createMessage);
  static GetTreePowerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedRevision() => $_clearField(2);

  /// Пустая строка запрашивает каталог характеристик.
  @$pb.TagNumber(3)
  $core.String get metric => $_getSZ(2);
  @$pb.TagNumber(3)
  set metric($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMetric() => $_has(2);
  @$pb.TagNumber(3)
  void clearMetric() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get maxDistance => $_getIZ(3);
  @$pb.TagNumber(4)
  set maxDistance($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxDistance() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxDistance() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get allocation => $_getSZ(4);
  @$pb.TagNumber(5)
  set allocation($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAllocation() => $_has(4);
  @$pb.TagNumber(5)
  void clearAllocation() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get includeScene => $_getBF(5);
  @$pb.TagNumber(6)
  set includeScene($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIncludeScene() => $_has(5);
  @$pb.TagNumber(6)
  void clearIncludeScene() => $_clearField(6);
}

class GetTreePowerResponse extends $pb.GeneratedMessage {
  factory GetTreePowerResponse({
    $fixnum.Int64? revision,
    TreePowerMetric? metric,
    $core.Iterable<TreePowerMetric>? metrics,
    $core.Iterable<TreePowerEntry>? entries,
    TreeScene? scene,
  }) {
    final result = GetTreePowerResponse._();
    if (revision != null) result.revision = revision;
    if (metric != null) result.metric = metric;
    if (metrics != null) result.metrics.addAll(metrics);
    if (entries != null) result.entries.addAll(entries);
    if (scene != null) result.scene = scene;
    return result;
  }

  GetTreePowerResponse._();

  factory GetTreePowerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreePowerResponse()..mergeFromBuffer(data, registry);
  factory GetTreePowerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreePowerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreePowerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreePowerResponse.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<TreePowerMetric>(2, _omitFieldNames ? '' : 'metric',
        subBuilder: TreePowerMetric.$_createMessage)
    ..pPM<TreePowerMetric>(3, _omitFieldNames ? '' : 'metrics',
        subBuilder: TreePowerMetric.$_createMessage)
    ..pPM<TreePowerEntry>(4, _omitFieldNames ? '' : 'entries',
        subBuilder: TreePowerEntry.$_createMessage)
    ..aOM<TreeScene>(5, _omitFieldNames ? '' : 'scene',
        subBuilder: TreeScene.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreePowerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreePowerResponse copyWith(void Function(GetTreePowerResponse) updates) =>
      super.copyWith((message) => updates(message as GetTreePowerResponse))
          as GetTreePowerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetTreePowerResponse() / GetTreePowerResponse.new instead')
  static GetTreePowerResponse create() => GetTreePowerResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTreePowerResponse._();
  @$core.override
  GetTreePowerResponse createEmptyInstance() => GetTreePowerResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTreePowerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreePowerResponse>(
          GetTreePowerResponse.$_createMessage);
  static GetTreePowerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revision => $_getI64(0);
  @$pb.TagNumber(1)
  set revision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevision() => $_clearField(1);

  @$pb.TagNumber(2)
  TreePowerMetric get metric => $_getN(1);
  @$pb.TagNumber(2)
  set metric(TreePowerMetric value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMetric() => $_has(1);
  @$pb.TagNumber(2)
  void clearMetric() => $_clearField(2);
  @$pb.TagNumber(2)
  TreePowerMetric ensureMetric() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<TreePowerMetric> get metrics => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<TreePowerEntry> get entries => $_getList(3);

  @$pb.TagNumber(5)
  TreeScene get scene => $_getN(4);
  @$pb.TagNumber(5)
  set scene(TreeScene value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasScene() => $_has(4);
  @$pb.TagNumber(5)
  void clearScene() => $_clearField(5);
  @$pb.TagNumber(5)
  TreeScene ensureScene() => $_ensure(4);
}

class TreePowerMetric extends $pb.GeneratedMessage {
  factory TreePowerMetric({
    $core.String? id,
    $core.String? label,
  }) {
    final result = TreePowerMetric._();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    return result;
  }

  TreePowerMetric._();

  factory TreePowerMetric.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreePowerMetric()..mergeFromBuffer(data, registry);
  factory TreePowerMetric.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreePowerMetric()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreePowerMetric',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreePowerMetric.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreePowerMetric clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreePowerMetric copyWith(void Function(TreePowerMetric) updates) =>
      super.copyWith((message) => updates(message as TreePowerMetric))
          as TreePowerMetric;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreePowerMetric() / TreePowerMetric.new instead')
  static TreePowerMetric create() => TreePowerMetric._();
  static $pb.GeneratedMessage $_createMessage() => TreePowerMetric._();
  @$core.override
  TreePowerMetric createEmptyInstance() => TreePowerMetric._();
  @$core.pragma('dart2js:noInline')
  static TreePowerMetric getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreePowerMetric>(
          TreePowerMetric.$_createMessage);
  static TreePowerMetric? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);
}

class WatchTreePowerRequest extends $pb.GeneratedMessage {
  factory WatchTreePowerRequest({
    GetTreePowerRequest? query,
  }) {
    final result = WatchTreePowerRequest._();
    if (query != null) result.query = query;
    return result;
  }

  WatchTreePowerRequest._();

  factory WatchTreePowerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTreePowerRequest()..mergeFromBuffer(data, registry);
  factory WatchTreePowerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTreePowerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchTreePowerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchTreePowerRequest.$_createMessage)
    ..aOM<GetTreePowerRequest>(1, _omitFieldNames ? '' : 'query',
        subBuilder: GetTreePowerRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTreePowerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTreePowerRequest copyWith(
          void Function(WatchTreePowerRequest) updates) =>
      super.copyWith((message) => updates(message as WatchTreePowerRequest))
          as WatchTreePowerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WatchTreePowerRequest() / WatchTreePowerRequest.new instead')
  static WatchTreePowerRequest create() => WatchTreePowerRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchTreePowerRequest._();
  @$core.override
  WatchTreePowerRequest createEmptyInstance() => WatchTreePowerRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchTreePowerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchTreePowerRequest>(
          WatchTreePowerRequest.$_createMessage);
  static WatchTreePowerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GetTreePowerRequest get query => $_getN(0);
  @$pb.TagNumber(1)
  set query(GetTreePowerRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);
  @$pb.TagNumber(1)
  GetTreePowerRequest ensureQuery() => $_ensure(0);
}

enum WatchTreePowerResponse_Update { progress, result, notSet }

class WatchTreePowerResponse extends $pb.GeneratedMessage {
  factory WatchTreePowerResponse({
    $core.int? progress,
    GetTreePowerResponse? result,
  }) {
    final result$ = WatchTreePowerResponse._();
    if (progress != null) result$.progress = progress;
    if (result != null) result$.result = result;
    return result$;
  }

  WatchTreePowerResponse._();

  factory WatchTreePowerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTreePowerResponse()..mergeFromBuffer(data, registry);
  factory WatchTreePowerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTreePowerResponse()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WatchTreePowerResponse_Update>
      _WatchTreePowerResponse_UpdateByTag = {
    1: WatchTreePowerResponse_Update.progress,
    2: WatchTreePowerResponse_Update.result,
    0: WatchTreePowerResponse_Update.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchTreePowerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchTreePowerResponse.$_createMessage)
    ..oo(0, [1, 2])
    ..aI(1, _omitFieldNames ? '' : 'progress', fieldType: $pb.PbFieldType.OU3)
    ..aOM<GetTreePowerResponse>(2, _omitFieldNames ? '' : 'result',
        subBuilder: GetTreePowerResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTreePowerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTreePowerResponse copyWith(
          void Function(WatchTreePowerResponse) updates) =>
      super.copyWith((message) => updates(message as WatchTreePowerResponse))
          as WatchTreePowerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WatchTreePowerResponse() / WatchTreePowerResponse.new instead')
  static WatchTreePowerResponse create() => WatchTreePowerResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchTreePowerResponse._();
  @$core.override
  WatchTreePowerResponse createEmptyInstance() => WatchTreePowerResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchTreePowerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchTreePowerResponse>(
          WatchTreePowerResponse.$_createMessage);
  static WatchTreePowerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  WatchTreePowerResponse_Update whichUpdate() =>
      _WatchTreePowerResponse_UpdateByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearUpdate() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get progress => $_getIZ(0);
  @$pb.TagNumber(1)
  set progress($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProgress() => $_has(0);
  @$pb.TagNumber(1)
  void clearProgress() => $_clearField(1);

  @$pb.TagNumber(2)
  GetTreePowerResponse get result => $_getN(1);
  @$pb.TagNumber(2)
  set result(GetTreePowerResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasResult() => $_has(1);
  @$pb.TagNumber(2)
  void clearResult() => $_clearField(2);
  @$pb.TagNumber(2)
  GetTreePowerResponse ensureResult() => $_ensure(1);
}

class TreePowerEntry extends $pb.GeneratedMessage {
  factory TreePowerEntry({
    $core.int? id,
    $core.String? name,
    $core.String? kind,
    $core.bool? allocated,
    $core.int? distance,
    $core.double? power,
    $core.double? pathPower,
    $core.String? powerText,
    $core.String? pathPowerText,
  }) {
    final result = TreePowerEntry._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (allocated != null) result.allocated = allocated;
    if (distance != null) result.distance = distance;
    if (power != null) result.power = power;
    if (pathPower != null) result.pathPower = pathPower;
    if (powerText != null) result.powerText = powerText;
    if (pathPowerText != null) result.pathPowerText = pathPowerText;
    return result;
  }

  TreePowerEntry._();

  factory TreePowerEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreePowerEntry()..mergeFromBuffer(data, registry);
  factory TreePowerEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreePowerEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreePowerEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreePowerEntry.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'kind')
    ..aOB(4, _omitFieldNames ? '' : 'allocated')
    ..aI(5, _omitFieldNames ? '' : 'distance', fieldType: $pb.PbFieldType.OU3)
    ..aD(6, _omitFieldNames ? '' : 'power')
    ..aD(7, _omitFieldNames ? '' : 'pathPower')
    ..aOS(8, _omitFieldNames ? '' : 'powerText')
    ..aOS(9, _omitFieldNames ? '' : 'pathPowerText')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreePowerEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreePowerEntry copyWith(void Function(TreePowerEntry) updates) =>
      super.copyWith((message) => updates(message as TreePowerEntry))
          as TreePowerEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreePowerEntry() / TreePowerEntry.new instead')
  static TreePowerEntry create() => TreePowerEntry._();
  static $pb.GeneratedMessage $_createMessage() => TreePowerEntry._();
  @$core.override
  TreePowerEntry createEmptyInstance() => TreePowerEntry._();
  @$core.pragma('dart2js:noInline')
  static TreePowerEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreePowerEntry>(
          TreePowerEntry.$_createMessage);
  static TreePowerEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get kind => $_getSZ(2);
  @$pb.TagNumber(3)
  set kind($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get allocated => $_getBF(3);
  @$pb.TagNumber(4)
  set allocated($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAllocated() => $_has(3);
  @$pb.TagNumber(4)
  void clearAllocated() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get distance => $_getIZ(4);
  @$pb.TagNumber(5)
  set distance($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDistance() => $_has(4);
  @$pb.TagNumber(5)
  void clearDistance() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get power => $_getN(5);
  @$pb.TagNumber(6)
  set power($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPower() => $_has(5);
  @$pb.TagNumber(6)
  void clearPower() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get pathPower => $_getN(6);
  @$pb.TagNumber(7)
  set pathPower($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPathPower() => $_has(6);
  @$pb.TagNumber(7)
  void clearPathPower() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get powerText => $_getSZ(7);
  @$pb.TagNumber(8)
  set powerText($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPowerText() => $_has(7);
  @$pb.TagNumber(8)
  void clearPowerText() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get pathPowerText => $_getSZ(8);
  @$pb.TagNumber(9)
  set pathPowerText($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPathPowerText() => $_has(8);
  @$pb.TagNumber(9)
  void clearPathPowerText() => $_clearField(9);
}

class TreeScene extends $pb.GeneratedMessage {
  factory TreeScene({
    $core.double? width,
    $core.double? height,
    $core.double? scale,
    $core.double? offsetX,
    $core.double? offsetY,
    $core.Iterable<TreeDrawCommand>? commands,
    $core.String? assetId,
  }) {
    final result = TreeScene._();
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (scale != null) result.scale = scale;
    if (offsetX != null) result.offsetX = offsetX;
    if (offsetY != null) result.offsetY = offsetY;
    if (commands != null) result.commands.addAll(commands);
    if (assetId != null) result.assetId = assetId;
    return result;
  }

  TreeScene._();

  factory TreeScene.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeScene()..mergeFromBuffer(data, registry);
  factory TreeScene.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeScene()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeScene',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreeScene.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'width')
    ..aD(2, _omitFieldNames ? '' : 'height')
    ..aD(3, _omitFieldNames ? '' : 'scale')
    ..aD(4, _omitFieldNames ? '' : 'offsetX')
    ..aD(5, _omitFieldNames ? '' : 'offsetY')
    ..pPM<TreeDrawCommand>(6, _omitFieldNames ? '' : 'commands',
        subBuilder: TreeDrawCommand.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'assetId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeScene clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeScene copyWith(void Function(TreeScene) updates) =>
      super.copyWith((message) => updates(message as TreeScene)) as TreeScene;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreeScene() / TreeScene.new instead')
  static TreeScene create() => TreeScene._();
  static $pb.GeneratedMessage $_createMessage() => TreeScene._();
  @$core.override
  TreeScene createEmptyInstance() => TreeScene._();
  @$core.pragma('dart2js:noInline')
  static TreeScene getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreeScene>(TreeScene.$_createMessage);
  static TreeScene? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get width => $_getN(0);
  @$pb.TagNumber(1)
  set width($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get height => $_getN(1);
  @$pb.TagNumber(2)
  set height($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get scale => $_getN(2);
  @$pb.TagNumber(3)
  set scale($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScale() => $_has(2);
  @$pb.TagNumber(3)
  void clearScale() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get offsetX => $_getN(3);
  @$pb.TagNumber(4)
  set offsetX($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOffsetX() => $_has(3);
  @$pb.TagNumber(4)
  void clearOffsetX() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get offsetY => $_getN(4);
  @$pb.TagNumber(5)
  set offsetY($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOffsetY() => $_has(4);
  @$pb.TagNumber(5)
  void clearOffsetY() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<TreeDrawCommand> get commands => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get assetId => $_getSZ(6);
  @$pb.TagNumber(7)
  set assetId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAssetId() => $_has(6);
  @$pb.TagNumber(7)
  void clearAssetId() => $_clearField(7);
}

class TreeDrawCommand extends $pb.GeneratedMessage {
  factory TreeDrawCommand({
    $core.String? file,
    $core.int? index,
    $core.Iterable<$core.double>? positions,
    $core.Iterable<$core.double>? uv,
    $core.Iterable<$core.double>? color,
    $core.String? blend,
    $core.bool? clamp,
  }) {
    final result = TreeDrawCommand._();
    if (file != null) result.file = file;
    if (index != null) result.index = index;
    if (positions != null) result.positions.addAll(positions);
    if (uv != null) result.uv.addAll(uv);
    if (color != null) result.color.addAll(color);
    if (blend != null) result.blend = blend;
    if (clamp != null) result.clamp = clamp;
    return result;
  }

  TreeDrawCommand._();

  factory TreeDrawCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeDrawCommand()..mergeFromBuffer(data, registry);
  factory TreeDrawCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TreeDrawCommand()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreeDrawCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: TreeDrawCommand.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'file')
    ..aI(2, _omitFieldNames ? '' : 'index', fieldType: $pb.PbFieldType.OU3)
    ..p<$core.double>(3, _omitFieldNames ? '' : 'positions', $pb.PbFieldType.KD)
    ..p<$core.double>(4, _omitFieldNames ? '' : 'uv', $pb.PbFieldType.KD)
    ..p<$core.double>(5, _omitFieldNames ? '' : 'color', $pb.PbFieldType.KD)
    ..aOS(6, _omitFieldNames ? '' : 'blend')
    ..aOB(7, _omitFieldNames ? '' : 'clamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeDrawCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreeDrawCommand copyWith(void Function(TreeDrawCommand) updates) =>
      super.copyWith((message) => updates(message as TreeDrawCommand))
          as TreeDrawCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TreeDrawCommand() / TreeDrawCommand.new instead')
  static TreeDrawCommand create() => TreeDrawCommand._();
  static $pb.GeneratedMessage $_createMessage() => TreeDrawCommand._();
  @$core.override
  TreeDrawCommand createEmptyInstance() => TreeDrawCommand._();
  @$core.pragma('dart2js:noInline')
  static TreeDrawCommand getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TreeDrawCommand>(
          TreeDrawCommand.$_createMessage);
  static TreeDrawCommand? _defaultInstance;

  /// Путь текстуры внутри установки PoB. Пустой путь задаёт однотонный цвет.
  @$pb.TagNumber(1)
  $core.String get file => $_getSZ(0);
  @$pb.TagNumber(1)
  set file($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(1);
  @$pb.TagNumber(2)
  set index($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.double> get positions => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get uv => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.double> get color => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get blend => $_getSZ(5);
  @$pb.TagNumber(6)
  set blend($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlend() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlend() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get clamp => $_getBF(6);
  @$pb.TagNumber(7)
  set clamp($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasClamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearClamp() => $_clearField(7);
}

class GetTreeTextureRequest extends $pb.GeneratedMessage {
  factory GetTreeTextureRequest({
    $core.String? file,
    $core.int? index,
    $core.int? targetSize,
  }) {
    final result = GetTreeTextureRequest._();
    if (file != null) result.file = file;
    if (index != null) result.index = index;
    if (targetSize != null) result.targetSize = targetSize;
    return result;
  }

  GetTreeTextureRequest._();

  factory GetTreeTextureRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeTextureRequest()..mergeFromBuffer(data, registry);
  factory GetTreeTextureRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeTextureRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreeTextureRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreeTextureRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'file')
    ..aI(2, _omitFieldNames ? '' : 'index', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'targetSize', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeTextureRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeTextureRequest copyWith(
          void Function(GetTreeTextureRequest) updates) =>
      super.copyWith((message) => updates(message as GetTreeTextureRequest))
          as GetTreeTextureRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetTreeTextureRequest() / GetTreeTextureRequest.new instead')
  static GetTreeTextureRequest create() => GetTreeTextureRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTreeTextureRequest._();
  @$core.override
  GetTreeTextureRequest createEmptyInstance() => GetTreeTextureRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTreeTextureRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreeTextureRequest>(
          GetTreeTextureRequest.$_createMessage);
  static GetTreeTextureRequest? _defaultInstance;

  /// Ссылка из команды отрисовки. Пустое поле возвращает белый пиксель.
  @$pb.TagNumber(1)
  $core.String get file => $_getSZ(0);
  @$pb.TagNumber(1)
  set file($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);

  /// Слой DDS, начиная с единицы.
  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(1);
  @$pb.TagNumber(2)
  set index($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get targetSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set targetSize($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetSize() => $_clearField(3);
}

class GetTreeTextureResponse extends $pb.GeneratedMessage {
  factory GetTreeTextureResponse({
    $core.int? width,
    $core.int? height,
    $core.int? mipLevel,
    $core.List<$core.int>? png,
  }) {
    final result = GetTreeTextureResponse._();
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (mipLevel != null) result.mipLevel = mipLevel;
    if (png != null) result.png = png;
    return result;
  }

  GetTreeTextureResponse._();

  factory GetTreeTextureResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeTextureResponse()..mergeFromBuffer(data, registry);
  factory GetTreeTextureResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTreeTextureResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreeTextureResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetTreeTextureResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'mipLevel', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'png', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeTextureResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreeTextureResponse copyWith(
          void Function(GetTreeTextureResponse) updates) =>
      super.copyWith((message) => updates(message as GetTreeTextureResponse))
          as GetTreeTextureResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetTreeTextureResponse() / GetTreeTextureResponse.new instead')
  static GetTreeTextureResponse create() => GetTreeTextureResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTreeTextureResponse._();
  @$core.override
  GetTreeTextureResponse createEmptyInstance() => GetTreeTextureResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTreeTextureResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreeTextureResponse>(
          GetTreeTextureResponse.$_createMessage);
  static GetTreeTextureResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get width => $_getIZ(0);
  @$pb.TagNumber(1)
  set width($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get mipLevel => $_getIZ(2);
  @$pb.TagNumber(3)
  set mipLevel($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMipLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearMipLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get png => $_getN(3);
  @$pb.TagNumber(4)
  set png($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPng() => $_has(3);
  @$pb.TagNumber(4)
  void clearPng() => $_clearField(4);
}

enum GetEquipmentDetailsRequest_Item { itemId, raw, notSet }

class GetEquipmentDetailsRequest extends $pb.GeneratedMessage {
  factory GetEquipmentDetailsRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.String? slot,
    $core.int? itemId,
    $core.String? raw,
    $core.bool? compare,
  }) {
    final result = GetEquipmentDetailsRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (slot != null) result.slot = slot;
    if (itemId != null) result.itemId = itemId;
    if (raw != null) result.raw = raw;
    if (compare != null) result.compare = compare;
    return result;
  }

  GetEquipmentDetailsRequest._();

  factory GetEquipmentDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEquipmentDetailsRequest()..mergeFromBuffer(data, registry);
  factory GetEquipmentDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEquipmentDetailsRequest()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetEquipmentDetailsRequest_Item>
      _GetEquipmentDetailsRequest_ItemByTag = {
    4: GetEquipmentDetailsRequest_Item.itemId,
    5: GetEquipmentDetailsRequest_Item.raw,
    0: GetEquipmentDetailsRequest_Item.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetEquipmentDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetEquipmentDetailsRequest.$_createMessage)
    ..oo(0, [4, 5])
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'slot')
    ..aI(4, _omitFieldNames ? '' : 'itemId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'raw')
    ..aOB(6, _omitFieldNames ? '' : 'compare')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEquipmentDetailsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEquipmentDetailsRequest copyWith(
          void Function(GetEquipmentDetailsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetEquipmentDetailsRequest))
          as GetEquipmentDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetEquipmentDetailsRequest() / GetEquipmentDetailsRequest.new instead')
  static GetEquipmentDetailsRequest create() => GetEquipmentDetailsRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GetEquipmentDetailsRequest._();
  @$core.override
  GetEquipmentDetailsRequest createEmptyInstance() =>
      GetEquipmentDetailsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetEquipmentDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEquipmentDetailsRequest>(
          GetEquipmentDetailsRequest.$_createMessage);
  static GetEquipmentDetailsRequest? _defaultInstance;

  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  GetEquipmentDetailsRequest_Item whichItem() =>
      _GetEquipmentDetailsRequest_ItemByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearItem() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get slot => $_getSZ(2);
  @$pb.TagNumber(3)
  set slot($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlot() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlot() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get itemId => $_getIZ(3);
  @$pb.TagNumber(4)
  set itemId($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasItemId() => $_has(3);
  @$pb.TagNumber(4)
  void clearItemId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get raw => $_getSZ(4);
  @$pb.TagNumber(5)
  set raw($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRaw() => $_has(4);
  @$pb.TagNumber(5)
  void clearRaw() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get compare => $_getBF(5);
  @$pb.TagNumber(6)
  set compare($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCompare() => $_has(5);
  @$pb.TagNumber(6)
  void clearCompare() => $_clearField(6);
}

class GetEquipmentDetailsResponse extends $pb.GeneratedMessage {
  factory GetEquipmentDetailsResponse({
    $fixnum.Int64? revision,
    $core.List<$core.int>? detailsJson,
  }) {
    final result = GetEquipmentDetailsResponse._();
    if (revision != null) result.revision = revision;
    if (detailsJson != null) result.detailsJson = detailsJson;
    return result;
  }

  GetEquipmentDetailsResponse._();

  factory GetEquipmentDetailsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEquipmentDetailsResponse()..mergeFromBuffer(data, registry);
  factory GetEquipmentDetailsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetEquipmentDetailsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetEquipmentDetailsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetEquipmentDetailsResponse.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'detailsJson', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEquipmentDetailsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEquipmentDetailsResponse copyWith(
          void Function(GetEquipmentDetailsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetEquipmentDetailsResponse))
          as GetEquipmentDetailsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetEquipmentDetailsResponse() / GetEquipmentDetailsResponse.new instead')
  static GetEquipmentDetailsResponse create() =>
      GetEquipmentDetailsResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      GetEquipmentDetailsResponse._();
  @$core.override
  GetEquipmentDetailsResponse createEmptyInstance() =>
      GetEquipmentDetailsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetEquipmentDetailsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEquipmentDetailsResponse>(
          GetEquipmentDetailsResponse.$_createMessage);
  static GetEquipmentDetailsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revision => $_getI64(0);
  @$pb.TagNumber(1)
  set revision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevision() => $_clearField(1);

  /// UTF-8 JSON с подсказкой, подходящими слотами и строками сравнения PoB.
  @$pb.TagNumber(2)
  $core.List<$core.int> get detailsJson => $_getN(1);
  @$pb.TagNumber(2)
  set detailsJson($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDetailsJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetailsJson() => $_clearField(2);
}

enum BuildEdit_Operation {
  level,
  config,
  gems,
  equipment,
  passives,
  selection,
  addSupport,
  treeNode,
  jewel,
  treeClass,
  skillChoice,
  skillGroup,
  notSet
}

class BuildEdit extends $pb.GeneratedMessage {
  factory BuildEdit({
    LevelEdit? level,
    ConfigEdit? config,
    GemsEdit? gems,
    EquipmentEdit? equipment,
    PassivesEdit? passives,
    SelectionEdit? selection,
    AddSupportEdit? addSupport,
    TreeNodeEdit? treeNode,
    JewelEdit? jewel,
    TreeClassEdit? treeClass,
    SkillChoiceEdit? skillChoice,
    SkillGroupEdit? skillGroup,
  }) {
    final result = BuildEdit._();
    if (level != null) result.level = level;
    if (config != null) result.config = config;
    if (gems != null) result.gems = gems;
    if (equipment != null) result.equipment = equipment;
    if (passives != null) result.passives = passives;
    if (selection != null) result.selection = selection;
    if (addSupport != null) result.addSupport = addSupport;
    if (treeNode != null) result.treeNode = treeNode;
    if (jewel != null) result.jewel = jewel;
    if (treeClass != null) result.treeClass = treeClass;
    if (skillChoice != null) result.skillChoice = skillChoice;
    if (skillGroup != null) result.skillGroup = skillGroup;
    return result;
  }

  BuildEdit._();

  factory BuildEdit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildEdit()..mergeFromBuffer(data, registry);
  factory BuildEdit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildEdit()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, BuildEdit_Operation>
      _BuildEdit_OperationByTag = {
    1: BuildEdit_Operation.level,
    2: BuildEdit_Operation.config,
    3: BuildEdit_Operation.gems,
    4: BuildEdit_Operation.equipment,
    5: BuildEdit_Operation.passives,
    6: BuildEdit_Operation.selection,
    7: BuildEdit_Operation.addSupport,
    8: BuildEdit_Operation.treeNode,
    9: BuildEdit_Operation.jewel,
    10: BuildEdit_Operation.treeClass,
    11: BuildEdit_Operation.skillChoice,
    12: BuildEdit_Operation.skillGroup,
    0: BuildEdit_Operation.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuildEdit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: BuildEdit.$_createMessage)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
    ..aOM<LevelEdit>(1, _omitFieldNames ? '' : 'level',
        subBuilder: LevelEdit.$_createMessage)
    ..aOM<ConfigEdit>(2, _omitFieldNames ? '' : 'config',
        subBuilder: ConfigEdit.$_createMessage)
    ..aOM<GemsEdit>(3, _omitFieldNames ? '' : 'gems',
        subBuilder: GemsEdit.$_createMessage)
    ..aOM<EquipmentEdit>(4, _omitFieldNames ? '' : 'equipment',
        subBuilder: EquipmentEdit.$_createMessage)
    ..aOM<PassivesEdit>(5, _omitFieldNames ? '' : 'passives',
        subBuilder: PassivesEdit.$_createMessage)
    ..aOM<SelectionEdit>(6, _omitFieldNames ? '' : 'selection',
        subBuilder: SelectionEdit.$_createMessage)
    ..aOM<AddSupportEdit>(7, _omitFieldNames ? '' : 'addSupport',
        subBuilder: AddSupportEdit.$_createMessage)
    ..aOM<TreeNodeEdit>(8, _omitFieldNames ? '' : 'treeNode',
        subBuilder: TreeNodeEdit.$_createMessage)
    ..aOM<JewelEdit>(9, _omitFieldNames ? '' : 'jewel',
        subBuilder: JewelEdit.$_createMessage)
    ..aOM<TreeClassEdit>(10, _omitFieldNames ? '' : 'treeClass',
        subBuilder: TreeClassEdit.$_createMessage)
    ..aOM<SkillChoiceEdit>(11, _omitFieldNames ? '' : 'skillChoice',
        subBuilder: SkillChoiceEdit.$_createMessage)
    ..aOM<SkillGroupEdit>(12, _omitFieldNames ? '' : 'skillGroup',
        subBuilder: SkillGroupEdit.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildEdit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildEdit copyWith(void Function(BuildEdit) updates) =>
      super.copyWith((message) => updates(message as BuildEdit)) as BuildEdit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildEdit() / BuildEdit.new instead')
  static BuildEdit create() => BuildEdit._();
  static $pb.GeneratedMessage $_createMessage() => BuildEdit._();
  @$core.override
  BuildEdit createEmptyInstance() => BuildEdit._();
  @$core.pragma('dart2js:noInline')
  static BuildEdit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuildEdit>(BuildEdit.$_createMessage);
  static BuildEdit? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  BuildEdit_Operation whichOperation() =>
      _BuildEdit_OperationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  void clearOperation() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  LevelEdit get level => $_getN(0);
  @$pb.TagNumber(1)
  set level(LevelEdit value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLevel() => $_clearField(1);
  @$pb.TagNumber(1)
  LevelEdit ensureLevel() => $_ensure(0);

  @$pb.TagNumber(2)
  ConfigEdit get config => $_getN(1);
  @$pb.TagNumber(2)
  set config(ConfigEdit value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasConfig() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfig() => $_clearField(2);
  @$pb.TagNumber(2)
  ConfigEdit ensureConfig() => $_ensure(1);

  @$pb.TagNumber(3)
  GemsEdit get gems => $_getN(2);
  @$pb.TagNumber(3)
  set gems(GemsEdit value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasGems() => $_has(2);
  @$pb.TagNumber(3)
  void clearGems() => $_clearField(3);
  @$pb.TagNumber(3)
  GemsEdit ensureGems() => $_ensure(2);

  @$pb.TagNumber(4)
  EquipmentEdit get equipment => $_getN(3);
  @$pb.TagNumber(4)
  set equipment(EquipmentEdit value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEquipment() => $_has(3);
  @$pb.TagNumber(4)
  void clearEquipment() => $_clearField(4);
  @$pb.TagNumber(4)
  EquipmentEdit ensureEquipment() => $_ensure(3);

  @$pb.TagNumber(5)
  PassivesEdit get passives => $_getN(4);
  @$pb.TagNumber(5)
  set passives(PassivesEdit value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPassives() => $_has(4);
  @$pb.TagNumber(5)
  void clearPassives() => $_clearField(5);
  @$pb.TagNumber(5)
  PassivesEdit ensurePassives() => $_ensure(4);

  @$pb.TagNumber(6)
  SelectionEdit get selection => $_getN(5);
  @$pb.TagNumber(6)
  set selection(SelectionEdit value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSelection() => $_has(5);
  @$pb.TagNumber(6)
  void clearSelection() => $_clearField(6);
  @$pb.TagNumber(6)
  SelectionEdit ensureSelection() => $_ensure(5);

  @$pb.TagNumber(7)
  AddSupportEdit get addSupport => $_getN(6);
  @$pb.TagNumber(7)
  set addSupport(AddSupportEdit value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasAddSupport() => $_has(6);
  @$pb.TagNumber(7)
  void clearAddSupport() => $_clearField(7);
  @$pb.TagNumber(7)
  AddSupportEdit ensureAddSupport() => $_ensure(6);

  @$pb.TagNumber(8)
  TreeNodeEdit get treeNode => $_getN(7);
  @$pb.TagNumber(8)
  set treeNode(TreeNodeEdit value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasTreeNode() => $_has(7);
  @$pb.TagNumber(8)
  void clearTreeNode() => $_clearField(8);
  @$pb.TagNumber(8)
  TreeNodeEdit ensureTreeNode() => $_ensure(7);

  @$pb.TagNumber(9)
  JewelEdit get jewel => $_getN(8);
  @$pb.TagNumber(9)
  set jewel(JewelEdit value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasJewel() => $_has(8);
  @$pb.TagNumber(9)
  void clearJewel() => $_clearField(9);
  @$pb.TagNumber(9)
  JewelEdit ensureJewel() => $_ensure(8);

  @$pb.TagNumber(10)
  TreeClassEdit get treeClass => $_getN(9);
  @$pb.TagNumber(10)
  set treeClass(TreeClassEdit value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasTreeClass() => $_has(9);
  @$pb.TagNumber(10)
  void clearTreeClass() => $_clearField(10);
  @$pb.TagNumber(10)
  TreeClassEdit ensureTreeClass() => $_ensure(9);

  @$pb.TagNumber(11)
  SkillChoiceEdit get skillChoice => $_getN(10);
  @$pb.TagNumber(11)
  set skillChoice(SkillChoiceEdit value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSkillChoice() => $_has(10);
  @$pb.TagNumber(11)
  void clearSkillChoice() => $_clearField(11);
  @$pb.TagNumber(11)
  SkillChoiceEdit ensureSkillChoice() => $_ensure(10);

  @$pb.TagNumber(12)
  SkillGroupEdit get skillGroup => $_getN(11);
  @$pb.TagNumber(12)
  set skillGroup(SkillGroupEdit value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasSkillGroup() => $_has(11);
  @$pb.TagNumber(12)
  void clearSkillGroup() => $_clearField(12);
  @$pb.TagNumber(12)
  SkillGroupEdit ensureSkillGroup() => $_ensure(11);
}

class PassiveChange extends $pb.GeneratedMessage {
  factory PassiveChange({
    $core.Iterable<$core.int>? added,
    $core.Iterable<$core.int>? removed,
    $core.Iterable<PassiveAttributeChange>? attributes,
    $core.Iterable<PassiveAllocationChange>? allocations,
    PassivePointsChange? points,
  }) {
    final result = PassiveChange._();
    if (added != null) result.added.addAll(added);
    if (removed != null) result.removed.addAll(removed);
    if (attributes != null) result.attributes.addAll(attributes);
    if (allocations != null) result.allocations.addAll(allocations);
    if (points != null) result.points = points;
    return result;
  }

  PassiveChange._();

  factory PassiveChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassiveChange()..mergeFromBuffer(data, registry);
  factory PassiveChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassiveChange()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PassiveChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PassiveChange.$_createMessage)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'added', $pb.PbFieldType.KU3)
    ..p<$core.int>(2, _omitFieldNames ? '' : 'removed', $pb.PbFieldType.KU3)
    ..pPM<PassiveAttributeChange>(3, _omitFieldNames ? '' : 'attributes',
        subBuilder: PassiveAttributeChange.$_createMessage)
    ..pPM<PassiveAllocationChange>(4, _omitFieldNames ? '' : 'allocations',
        subBuilder: PassiveAllocationChange.$_createMessage)
    ..aOM<PassivePointsChange>(5, _omitFieldNames ? '' : 'points',
        subBuilder: PassivePointsChange.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassiveChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassiveChange copyWith(void Function(PassiveChange) updates) =>
      super.copyWith((message) => updates(message as PassiveChange))
          as PassiveChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PassiveChange() / PassiveChange.new instead')
  static PassiveChange create() => PassiveChange._();
  static $pb.GeneratedMessage $_createMessage() => PassiveChange._();
  @$core.override
  PassiveChange createEmptyInstance() => PassiveChange._();
  @$core.pragma('dart2js:noInline')
  static PassiveChange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PassiveChange>(
          PassiveChange.$_createMessage);
  static PassiveChange? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get added => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get removed => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<PassiveAttributeChange> get attributes => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<PassiveAllocationChange> get allocations => $_getList(3);

  @$pb.TagNumber(5)
  PassivePointsChange get points => $_getN(4);
  @$pb.TagNumber(5)
  set points(PassivePointsChange value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPoints() => $_has(4);
  @$pb.TagNumber(5)
  void clearPoints() => $_clearField(5);
  @$pb.TagNumber(5)
  PassivePointsChange ensurePoints() => $_ensure(4);
}

class PassiveAllocationChange extends $pb.GeneratedMessage {
  factory PassiveAllocationChange({
    $core.int? nodeId,
    $core.String? before,
    $core.String? after,
  }) {
    final result = PassiveAllocationChange._();
    if (nodeId != null) result.nodeId = nodeId;
    if (before != null) result.before = before;
    if (after != null) result.after = after;
    return result;
  }

  PassiveAllocationChange._();

  factory PassiveAllocationChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassiveAllocationChange()..mergeFromBuffer(data, registry);
  factory PassiveAllocationChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassiveAllocationChange()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PassiveAllocationChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PassiveAllocationChange.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'nodeId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'before')
    ..aOS(3, _omitFieldNames ? '' : 'after')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassiveAllocationChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassiveAllocationChange copyWith(
          void Function(PassiveAllocationChange) updates) =>
      super.copyWith((message) => updates(message as PassiveAllocationChange))
          as PassiveAllocationChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PassiveAllocationChange() / PassiveAllocationChange.new instead')
  static PassiveAllocationChange create() => PassiveAllocationChange._();
  static $pb.GeneratedMessage $_createMessage() => PassiveAllocationChange._();
  @$core.override
  PassiveAllocationChange createEmptyInstance() => PassiveAllocationChange._();
  @$core.pragma('dart2js:noInline')
  static PassiveAllocationChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PassiveAllocationChange>(
          PassiveAllocationChange.$_createMessage);
  static PassiveAllocationChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nodeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  /// Пустой режим означает, что узел не был назначен.
  @$pb.TagNumber(2)
  $core.String get before => $_getSZ(1);
  @$pb.TagNumber(2)
  set before($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBefore() => $_has(1);
  @$pb.TagNumber(2)
  void clearBefore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get after => $_getSZ(2);
  @$pb.TagNumber(3)
  set after($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAfter() => $_has(2);
  @$pb.TagNumber(3)
  void clearAfter() => $_clearField(3);
}

class PassivePoints extends $pb.GeneratedMessage {
  factory PassivePoints({
    $core.int? passives,
    $core.int? weaponSet1,
    $core.int? weaponSet2,
  }) {
    final result = PassivePoints._();
    if (passives != null) result.passives = passives;
    if (weaponSet1 != null) result.weaponSet1 = weaponSet1;
    if (weaponSet2 != null) result.weaponSet2 = weaponSet2;
    return result;
  }

  PassivePoints._();

  factory PassivePoints.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassivePoints()..mergeFromBuffer(data, registry);
  factory PassivePoints.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassivePoints()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PassivePoints',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PassivePoints.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'passives', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'weaponSet1',
        protoName: 'weapon_set_1', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'weaponSet2',
        protoName: 'weapon_set_2', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassivePoints clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassivePoints copyWith(void Function(PassivePoints) updates) =>
      super.copyWith((message) => updates(message as PassivePoints))
          as PassivePoints;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PassivePoints() / PassivePoints.new instead')
  static PassivePoints create() => PassivePoints._();
  static $pb.GeneratedMessage $_createMessage() => PassivePoints._();
  @$core.override
  PassivePoints createEmptyInstance() => PassivePoints._();
  @$core.pragma('dart2js:noInline')
  static PassivePoints getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PassivePoints>(
          PassivePoints.$_createMessage);
  static PassivePoints? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get passives => $_getIZ(0);
  @$pb.TagNumber(1)
  set passives($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassives() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassives() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get weaponSet1 => $_getIZ(1);
  @$pb.TagNumber(2)
  set weaponSet1($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWeaponSet1() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeaponSet1() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get weaponSet2 => $_getIZ(2);
  @$pb.TagNumber(3)
  set weaponSet2($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWeaponSet2() => $_has(2);
  @$pb.TagNumber(3)
  void clearWeaponSet2() => $_clearField(3);
}

class PassivePointsChange extends $pb.GeneratedMessage {
  factory PassivePointsChange({
    PassivePoints? before,
    PassivePoints? after,
  }) {
    final result = PassivePointsChange._();
    if (before != null) result.before = before;
    if (after != null) result.after = after;
    return result;
  }

  PassivePointsChange._();

  factory PassivePointsChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassivePointsChange()..mergeFromBuffer(data, registry);
  factory PassivePointsChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassivePointsChange()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PassivePointsChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PassivePointsChange.$_createMessage)
    ..aOM<PassivePoints>(1, _omitFieldNames ? '' : 'before',
        subBuilder: PassivePoints.$_createMessage)
    ..aOM<PassivePoints>(2, _omitFieldNames ? '' : 'after',
        subBuilder: PassivePoints.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassivePointsChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassivePointsChange copyWith(void Function(PassivePointsChange) updates) =>
      super.copyWith((message) => updates(message as PassivePointsChange))
          as PassivePointsChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PassivePointsChange() / PassivePointsChange.new instead')
  static PassivePointsChange create() => PassivePointsChange._();
  static $pb.GeneratedMessage $_createMessage() => PassivePointsChange._();
  @$core.override
  PassivePointsChange createEmptyInstance() => PassivePointsChange._();
  @$core.pragma('dart2js:noInline')
  static PassivePointsChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PassivePointsChange>(
          PassivePointsChange.$_createMessage);
  static PassivePointsChange? _defaultInstance;

  @$pb.TagNumber(1)
  PassivePoints get before => $_getN(0);
  @$pb.TagNumber(1)
  set before(PassivePoints value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBefore() => $_has(0);
  @$pb.TagNumber(1)
  void clearBefore() => $_clearField(1);
  @$pb.TagNumber(1)
  PassivePoints ensureBefore() => $_ensure(0);

  @$pb.TagNumber(2)
  PassivePoints get after => $_getN(1);
  @$pb.TagNumber(2)
  set after(PassivePoints value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAfter() => $_has(1);
  @$pb.TagNumber(2)
  void clearAfter() => $_clearField(2);
  @$pb.TagNumber(2)
  PassivePoints ensureAfter() => $_ensure(1);
}

class PassiveAttributeChange extends $pb.GeneratedMessage {
  factory PassiveAttributeChange({
    $core.int? nodeId,
    $core.String? before,
    $core.String? after,
  }) {
    final result = PassiveAttributeChange._();
    if (nodeId != null) result.nodeId = nodeId;
    if (before != null) result.before = before;
    if (after != null) result.after = after;
    return result;
  }

  PassiveAttributeChange._();

  factory PassiveAttributeChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassiveAttributeChange()..mergeFromBuffer(data, registry);
  factory PassiveAttributeChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PassiveAttributeChange()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PassiveAttributeChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PassiveAttributeChange.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'nodeId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'before')
    ..aOS(3, _omitFieldNames ? '' : 'after')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassiveAttributeChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PassiveAttributeChange copyWith(
          void Function(PassiveAttributeChange) updates) =>
      super.copyWith((message) => updates(message as PassiveAttributeChange))
          as PassiveAttributeChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PassiveAttributeChange() / PassiveAttributeChange.new instead')
  static PassiveAttributeChange create() => PassiveAttributeChange._();
  static $pb.GeneratedMessage $_createMessage() => PassiveAttributeChange._();
  @$core.override
  PassiveAttributeChange createEmptyInstance() => PassiveAttributeChange._();
  @$core.pragma('dart2js:noInline')
  static PassiveAttributeChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PassiveAttributeChange>(
          PassiveAttributeChange.$_createMessage);
  static PassiveAttributeChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get nodeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set nodeId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeId() => $_clearField(1);

  /// Пустое значение, если PoB ещё не назначил атрибут.
  @$pb.TagNumber(2)
  $core.String get before => $_getSZ(1);
  @$pb.TagNumber(2)
  set before($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBefore() => $_has(1);
  @$pb.TagNumber(2)
  void clearBefore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get after => $_getSZ(2);
  @$pb.TagNumber(3)
  set after($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAfter() => $_has(2);
  @$pb.TagNumber(3)
  void clearAfter() => $_clearField(3);
}

class StatDelta extends $pb.GeneratedMessage {
  factory StatDelta({
    $core.String? stat,
    $core.double? before,
    $core.double? after,
    $core.double? difference,
  }) {
    final result = StatDelta._();
    if (stat != null) result.stat = stat;
    if (before != null) result.before = before;
    if (after != null) result.after = after;
    if (difference != null) result.difference = difference;
    return result;
  }

  StatDelta._();

  factory StatDelta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatDelta()..mergeFromBuffer(data, registry);
  factory StatDelta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatDelta()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatDelta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: StatDelta.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'stat')
    ..aD(2, _omitFieldNames ? '' : 'before')
    ..aD(3, _omitFieldNames ? '' : 'after')
    ..aD(4, _omitFieldNames ? '' : 'difference')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatDelta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatDelta copyWith(void Function(StatDelta) updates) =>
      super.copyWith((message) => updates(message as StatDelta)) as StatDelta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StatDelta() / StatDelta.new instead')
  static StatDelta create() => StatDelta._();
  static $pb.GeneratedMessage $_createMessage() => StatDelta._();
  @$core.override
  StatDelta createEmptyInstance() => StatDelta._();
  @$core.pragma('dart2js:noInline')
  static StatDelta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatDelta>(StatDelta.$_createMessage);
  static StatDelta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stat => $_getSZ(0);
  @$pb.TagNumber(1)
  set stat($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStat() => $_has(0);
  @$pb.TagNumber(1)
  void clearStat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get before => $_getN(1);
  @$pb.TagNumber(2)
  set before($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBefore() => $_has(1);
  @$pb.TagNumber(2)
  void clearBefore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get after => $_getN(2);
  @$pb.TagNumber(3)
  set after($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAfter() => $_has(2);
  @$pb.TagNumber(3)
  void clearAfter() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get difference => $_getN(3);
  @$pb.TagNumber(4)
  set difference($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDifference() => $_has(3);
  @$pb.TagNumber(4)
  void clearDifference() => $_clearField(4);
}

class BuildComparison extends $pb.GeneratedMessage {
  factory BuildComparison({
    CalculationResult? before,
    CalculationResult? after,
    $core.Iterable<StatDelta>? deltas,
  }) {
    final result = BuildComparison._();
    if (before != null) result.before = before;
    if (after != null) result.after = after;
    if (deltas != null) result.deltas.addAll(deltas);
    return result;
  }

  BuildComparison._();

  factory BuildComparison.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildComparison()..mergeFromBuffer(data, registry);
  factory BuildComparison.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildComparison()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuildComparison',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: BuildComparison.$_createMessage)
    ..aOM<CalculationResult>(1, _omitFieldNames ? '' : 'before',
        subBuilder: CalculationResult.$_createMessage)
    ..aOM<CalculationResult>(2, _omitFieldNames ? '' : 'after',
        subBuilder: CalculationResult.$_createMessage)
    ..pPM<StatDelta>(3, _omitFieldNames ? '' : 'deltas',
        subBuilder: StatDelta.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildComparison clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildComparison copyWith(void Function(BuildComparison) updates) =>
      super.copyWith((message) => updates(message as BuildComparison))
          as BuildComparison;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildComparison() / BuildComparison.new instead')
  static BuildComparison create() => BuildComparison._();
  static $pb.GeneratedMessage $_createMessage() => BuildComparison._();
  @$core.override
  BuildComparison createEmptyInstance() => BuildComparison._();
  @$core.pragma('dart2js:noInline')
  static BuildComparison getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildComparison>(
          BuildComparison.$_createMessage);
  static BuildComparison? _defaultInstance;

  @$pb.TagNumber(1)
  CalculationResult get before => $_getN(0);
  @$pb.TagNumber(1)
  set before(CalculationResult value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBefore() => $_has(0);
  @$pb.TagNumber(1)
  void clearBefore() => $_clearField(1);
  @$pb.TagNumber(1)
  CalculationResult ensureBefore() => $_ensure(0);

  @$pb.TagNumber(2)
  CalculationResult get after => $_getN(1);
  @$pb.TagNumber(2)
  set after(CalculationResult value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAfter() => $_has(1);
  @$pb.TagNumber(2)
  void clearAfter() => $_clearField(2);
  @$pb.TagNumber(2)
  CalculationResult ensureAfter() => $_ensure(1);

  /// Пуст при неподдержанном варианте; это не нулевые значения показателей.
  @$pb.TagNumber(3)
  $pb.PbList<StatDelta> get deltas => $_getList(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
