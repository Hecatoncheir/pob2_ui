// This is a generated file - do not edit.
//
// Generated from pob2/v1/catalog.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'build.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Только текущий расчётный набор; наличие записи не означает поддержку всех механик.
class CatalogEntry extends $pb.GeneratedMessage {
  factory CatalogEntry({
    $core.String? kind,
    $core.String? id,
    $core.String? name,
    $core.Iterable<$core.String>? aliases,
    $core.Iterable<$core.int>? levels,
    $core.Iterable<$core.int>? qualities,
    $core.Iterable<$core.String>? modes,
    $core.bool? support,
    $core.String? family,
    $core.Iterable<$core.String>? slots,
    $core.Iterable<$core.int>? classIds,
    $core.Iterable<$core.String>? coverage,
    $core.bool? attributeChoice,
  }) {
    final result = CatalogEntry._();
    if (kind != null) result.kind = kind;
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (aliases != null) result.aliases.addAll(aliases);
    if (levels != null) result.levels.addAll(levels);
    if (qualities != null) result.qualities.addAll(qualities);
    if (modes != null) result.modes.addAll(modes);
    if (support != null) result.support = support;
    if (family != null) result.family = family;
    if (slots != null) result.slots.addAll(slots);
    if (classIds != null) result.classIds.addAll(classIds);
    if (coverage != null) result.coverage.addAll(coverage);
    if (attributeChoice != null) result.attributeChoice = attributeChoice;
    return result;
  }

  CatalogEntry._();

  factory CatalogEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogEntry()..mergeFromBuffer(data, registry);
  factory CatalogEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CatalogEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CatalogEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CatalogEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'kind')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..pPS(4, _omitFieldNames ? '' : 'aliases')
    ..p<$core.int>(5, _omitFieldNames ? '' : 'levels', $pb.PbFieldType.K3)
    ..p<$core.int>(6, _omitFieldNames ? '' : 'qualities', $pb.PbFieldType.K3)
    ..pPS(7, _omitFieldNames ? '' : 'modes')
    ..aOB(8, _omitFieldNames ? '' : 'support')
    ..aOS(9, _omitFieldNames ? '' : 'family')
    ..pPS(10, _omitFieldNames ? '' : 'slots')
    ..p<$core.int>(11, _omitFieldNames ? '' : 'classIds', $pb.PbFieldType.K3)
    ..pPS(12, _omitFieldNames ? '' : 'coverage')
    ..aOB(13, _omitFieldNames ? '' : 'attributeChoice')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CatalogEntry copyWith(void Function(CatalogEntry) updates) =>
      super.copyWith((message) => updates(message as CatalogEntry))
          as CatalogEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CatalogEntry() / CatalogEntry.new instead')
  static CatalogEntry create() => CatalogEntry._();
  static $pb.GeneratedMessage $_createMessage() => CatalogEntry._();
  @$core.override
  CatalogEntry createEmptyInstance() => CatalogEntry._();
  @$core.pragma('dart2js:noInline')
  static CatalogEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CatalogEntry>(
          CatalogEntry.$_createMessage);
  static CatalogEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get kind => $_getSZ(0);
  @$pb.TagNumber(1)
  set kind($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get aliases => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get levels => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.int> get qualities => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get modes => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get support => $_getBF(7);
  @$pb.TagNumber(8)
  set support($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSupport() => $_has(7);
  @$pb.TagNumber(8)
  void clearSupport() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get family => $_getSZ(8);
  @$pb.TagNumber(9)
  set family($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFamily() => $_has(8);
  @$pb.TagNumber(9)
  void clearFamily() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get slots => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbList<$core.int> get classIds => $_getList(10);

  @$pb.TagNumber(12)
  $pb.PbList<$core.String> get coverage => $_getList(11);

  @$pb.TagNumber(13)
  $core.bool get attributeChoice => $_getBF(12);
  @$pb.TagNumber(13)
  set attributeChoice($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasAttributeChoice() => $_has(12);
  @$pb.TagNumber(13)
  void clearAttributeChoice() => $_clearField(13);
}

/// kind: gems/classes/items/passives. Поиск по ID, имени и псевдонимам без учёта регистра.
class GetCatalogRequest extends $pb.GeneratedMessage {
  factory GetCatalogRequest({
    $core.String? kind,
    $core.String? query,
    $core.int? offset,
    $core.int? limit,
  }) {
    final result = GetCatalogRequest._();
    if (kind != null) result.kind = kind;
    if (query != null) result.query = query;
    if (offset != null) result.offset = offset;
    if (limit != null) result.limit = limit;
    return result;
  }

  GetCatalogRequest._();

  factory GetCatalogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCatalogRequest()..mergeFromBuffer(data, registry);
  factory GetCatalogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCatalogRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCatalogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetCatalogRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'kind')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..aI(3, _omitFieldNames ? '' : 'offset')
    ..aI(4, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCatalogRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCatalogRequest copyWith(void Function(GetCatalogRequest) updates) =>
      super.copyWith((message) => updates(message as GetCatalogRequest))
          as GetCatalogRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCatalogRequest() / GetCatalogRequest.new instead')
  static GetCatalogRequest create() => GetCatalogRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetCatalogRequest._();
  @$core.override
  GetCatalogRequest createEmptyInstance() => GetCatalogRequest._();
  @$core.pragma('dart2js:noInline')
  static GetCatalogRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCatalogRequest>(
          GetCatalogRequest.$_createMessage);
  static GetCatalogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get kind => $_getSZ(0);
  @$pb.TagNumber(1)
  set kind($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get query => $_getSZ(1);
  @$pb.TagNumber(2)
  set query($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuery() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuery() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get offset => $_getIZ(2);
  @$pb.TagNumber(3)
  set offset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);
}

class GetCatalogResponse extends $pb.GeneratedMessage {
  factory GetCatalogResponse({
    $core.String? dataId,
    $core.String? dataSha256,
    $core.String? pobCommit,
    $core.String? treeVersion,
    $core.String? kind,
    $core.String? query,
    $core.int? offset,
    $core.int? limit,
    $core.int? total,
    $core.Iterable<CatalogEntry>? entries,
  }) {
    final result = GetCatalogResponse._();
    if (dataId != null) result.dataId = dataId;
    if (dataSha256 != null) result.dataSha256 = dataSha256;
    if (pobCommit != null) result.pobCommit = pobCommit;
    if (treeVersion != null) result.treeVersion = treeVersion;
    if (kind != null) result.kind = kind;
    if (query != null) result.query = query;
    if (offset != null) result.offset = offset;
    if (limit != null) result.limit = limit;
    if (total != null) result.total = total;
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  GetCatalogResponse._();

  factory GetCatalogResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCatalogResponse()..mergeFromBuffer(data, registry);
  factory GetCatalogResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCatalogResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCatalogResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetCatalogResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'dataId')
    ..aOS(2, _omitFieldNames ? '' : 'dataSha256')
    ..aOS(3, _omitFieldNames ? '' : 'pobCommit')
    ..aOS(4, _omitFieldNames ? '' : 'treeVersion')
    ..aOS(5, _omitFieldNames ? '' : 'kind')
    ..aOS(6, _omitFieldNames ? '' : 'query')
    ..aI(7, _omitFieldNames ? '' : 'offset')
    ..aI(8, _omitFieldNames ? '' : 'limit')
    ..aI(9, _omitFieldNames ? '' : 'total')
    ..pPM<CatalogEntry>(10, _omitFieldNames ? '' : 'entries',
        subBuilder: CatalogEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCatalogResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCatalogResponse copyWith(void Function(GetCatalogResponse) updates) =>
      super.copyWith((message) => updates(message as GetCatalogResponse))
          as GetCatalogResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCatalogResponse() / GetCatalogResponse.new instead')
  static GetCatalogResponse create() => GetCatalogResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCatalogResponse._();
  @$core.override
  GetCatalogResponse createEmptyInstance() => GetCatalogResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCatalogResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCatalogResponse>(
          GetCatalogResponse.$_createMessage);
  static GetCatalogResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dataId => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get dataSha256 => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataSha256($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataSha256() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataSha256() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pobCommit => $_getSZ(2);
  @$pb.TagNumber(3)
  set pobCommit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPobCommit() => $_has(2);
  @$pb.TagNumber(3)
  void clearPobCommit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get treeVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set treeVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTreeVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearTreeVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get kind => $_getSZ(4);
  @$pb.TagNumber(5)
  set kind($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKind() => $_has(4);
  @$pb.TagNumber(5)
  void clearKind() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get query => $_getSZ(5);
  @$pb.TagNumber(6)
  set query($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQuery() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuery() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get offset => $_getIZ(6);
  @$pb.TagNumber(7)
  set offset($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOffset() => $_has(6);
  @$pb.TagNumber(7)
  void clearOffset() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get limit => $_getIZ(7);
  @$pb.TagNumber(8)
  set limit($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLimit() => $_has(7);
  @$pb.TagNumber(8)
  void clearLimit() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get total => $_getIZ(8);
  @$pb.TagNumber(9)
  set total($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotal() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotal() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<CatalogEntry> get entries => $_getList(9);
}

/// Добавляет поддержку в копию выбранной группы; уровень 0 означает 1. Сессию не меняет.
class PreviewSupportRequest extends $pb.GeneratedMessage {
  factory PreviewSupportRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.String? supportId,
    $core.int? level,
    $core.int? quality,
  }) {
    final result = PreviewSupportRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (supportId != null) result.supportId = supportId;
    if (level != null) result.level = level;
    if (quality != null) result.quality = quality;
    return result;
  }

  PreviewSupportRequest._();

  factory PreviewSupportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSupportRequest()..mergeFromBuffer(data, registry);
  factory PreviewSupportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSupportRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PreviewSupportRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PreviewSupportRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'supportId')
    ..aI(4, _omitFieldNames ? '' : 'level')
    ..aI(5, _omitFieldNames ? '' : 'quality')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSupportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSupportRequest copyWith(
          void Function(PreviewSupportRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewSupportRequest))
          as PreviewSupportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PreviewSupportRequest() / PreviewSupportRequest.new instead')
  static PreviewSupportRequest create() => PreviewSupportRequest._();
  static $pb.GeneratedMessage $_createMessage() => PreviewSupportRequest._();
  @$core.override
  PreviewSupportRequest createEmptyInstance() => PreviewSupportRequest._();
  @$core.pragma('dart2js:noInline')
  static PreviewSupportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewSupportRequest>(
          PreviewSupportRequest.$_createMessage);
  static PreviewSupportRequest? _defaultInstance;

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
  $core.String get supportId => $_getSZ(2);
  @$pb.TagNumber(3)
  set supportId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSupportId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupportId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get level => $_getIZ(3);
  @$pb.TagNumber(4)
  set level($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLevel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get quality => $_getIZ(4);
  @$pb.TagNumber(5)
  set quality($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQuality() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuality() => $_clearField(5);
}

class PreviewSupportResponse extends $pb.GeneratedMessage {
  factory PreviewSupportResponse({
    $core.String? sessionId,
    $fixnum.Int64? revision,
    $core.int? groupId,
    CatalogEntry? support,
    $core.bool? compatible,
    $core.String? status,
    $0.BuildComparison? comparison,
  }) {
    final result = PreviewSupportResponse._();
    if (sessionId != null) result.sessionId = sessionId;
    if (revision != null) result.revision = revision;
    if (groupId != null) result.groupId = groupId;
    if (support != null) result.support = support;
    if (compatible != null) result.compatible = compatible;
    if (status != null) result.status = status;
    if (comparison != null) result.comparison = comparison;
    return result;
  }

  PreviewSupportResponse._();

  factory PreviewSupportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSupportResponse()..mergeFromBuffer(data, registry);
  factory PreviewSupportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSupportResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PreviewSupportResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: PreviewSupportResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'groupId')
    ..aOM<CatalogEntry>(4, _omitFieldNames ? '' : 'support',
        subBuilder: CatalogEntry.$_createMessage)
    ..aOB(5, _omitFieldNames ? '' : 'compatible')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aOM<$0.BuildComparison>(7, _omitFieldNames ? '' : 'comparison',
        subBuilder: $0.BuildComparison.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSupportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSupportResponse copyWith(
          void Function(PreviewSupportResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewSupportResponse))
          as PreviewSupportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PreviewSupportResponse() / PreviewSupportResponse.new instead')
  static PreviewSupportResponse create() => PreviewSupportResponse._();
  static $pb.GeneratedMessage $_createMessage() => PreviewSupportResponse._();
  @$core.override
  PreviewSupportResponse createEmptyInstance() => PreviewSupportResponse._();
  @$core.pragma('dart2js:noInline')
  static PreviewSupportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewSupportResponse>(
          PreviewSupportResponse.$_createMessage);
  static PreviewSupportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get groupId => $_getIZ(2);
  @$pb.TagNumber(3)
  set groupId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupId() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupId() => $_clearField(3);

  @$pb.TagNumber(4)
  CatalogEntry get support => $_getN(3);
  @$pb.TagNumber(4)
  set support(CatalogEntry value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSupport() => $_has(3);
  @$pb.TagNumber(4)
  void clearSupport() => $_clearField(4);
  @$pb.TagNumber(4)
  CatalogEntry ensureSupport() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get compatible => $_getBF(4);
  @$pb.TagNumber(5)
  set compatible($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCompatible() => $_has(4);
  @$pb.TagNumber(5)
  void clearCompatible() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.BuildComparison get comparison => $_getN(6);
  @$pb.TagNumber(7)
  set comparison($0.BuildComparison value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasComparison() => $_has(6);
  @$pb.TagNumber(7)
  void clearComparison() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.BuildComparison ensureComparison() => $_ensure(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
