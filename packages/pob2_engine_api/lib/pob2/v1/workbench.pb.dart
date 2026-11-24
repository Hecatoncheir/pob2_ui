// This is a generated file - do not edit.
//
// Generated from pob2/v1/workbench.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ListWorkbenchToolsRequest extends $pb.GeneratedMessage {
  factory ListWorkbenchToolsRequest() => ListWorkbenchToolsRequest._();

  ListWorkbenchToolsRequest._();

  factory ListWorkbenchToolsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWorkbenchToolsRequest()..mergeFromBuffer(data, registry);
  factory ListWorkbenchToolsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWorkbenchToolsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListWorkbenchToolsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ListWorkbenchToolsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWorkbenchToolsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWorkbenchToolsRequest copyWith(
          void Function(ListWorkbenchToolsRequest) updates) =>
      super.copyWith((message) => updates(message as ListWorkbenchToolsRequest))
          as ListWorkbenchToolsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListWorkbenchToolsRequest() / ListWorkbenchToolsRequest.new instead')
  static ListWorkbenchToolsRequest create() => ListWorkbenchToolsRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ListWorkbenchToolsRequest._();
  @$core.override
  ListWorkbenchToolsRequest createEmptyInstance() =>
      ListWorkbenchToolsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListWorkbenchToolsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWorkbenchToolsRequest>(
          ListWorkbenchToolsRequest.$_createMessage);
  static ListWorkbenchToolsRequest? _defaultInstance;
}

class ListWorkbenchToolsResponse extends $pb.GeneratedMessage {
  factory ListWorkbenchToolsResponse({
    $core.Iterable<$core.String>? names,
  }) {
    final result = ListWorkbenchToolsResponse._();
    if (names != null) result.names.addAll(names);
    return result;
  }

  ListWorkbenchToolsResponse._();

  factory ListWorkbenchToolsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWorkbenchToolsResponse()..mergeFromBuffer(data, registry);
  factory ListWorkbenchToolsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWorkbenchToolsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListWorkbenchToolsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ListWorkbenchToolsResponse.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'names')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWorkbenchToolsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWorkbenchToolsResponse copyWith(
          void Function(ListWorkbenchToolsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListWorkbenchToolsResponse))
          as ListWorkbenchToolsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ListWorkbenchToolsResponse() / ListWorkbenchToolsResponse.new instead')
  static ListWorkbenchToolsResponse create() => ListWorkbenchToolsResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ListWorkbenchToolsResponse._();
  @$core.override
  ListWorkbenchToolsResponse createEmptyInstance() =>
      ListWorkbenchToolsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListWorkbenchToolsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWorkbenchToolsResponse>(
          ListWorkbenchToolsResponse.$_createMessage);
  static ListWorkbenchToolsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get names => $_getList(0);
}

class CallWorkbenchToolRequest extends $pb.GeneratedMessage {
  factory CallWorkbenchToolRequest({
    $core.String? name,
    $core.List<$core.int>? argumentsJson,
  }) {
    final result = CallWorkbenchToolRequest._();
    if (name != null) result.name = name;
    if (argumentsJson != null) result.argumentsJson = argumentsJson;
    return result;
  }

  CallWorkbenchToolRequest._();

  factory CallWorkbenchToolRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallWorkbenchToolRequest()..mergeFromBuffer(data, registry);
  factory CallWorkbenchToolRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallWorkbenchToolRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallWorkbenchToolRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CallWorkbenchToolRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'argumentsJson', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallWorkbenchToolRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallWorkbenchToolRequest copyWith(
          void Function(CallWorkbenchToolRequest) updates) =>
      super.copyWith((message) => updates(message as CallWorkbenchToolRequest))
          as CallWorkbenchToolRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CallWorkbenchToolRequest() / CallWorkbenchToolRequest.new instead')
  static CallWorkbenchToolRequest create() => CallWorkbenchToolRequest._();
  static $pb.GeneratedMessage $_createMessage() => CallWorkbenchToolRequest._();
  @$core.override
  CallWorkbenchToolRequest createEmptyInstance() =>
      CallWorkbenchToolRequest._();
  @$core.pragma('dart2js:noInline')
  static CallWorkbenchToolRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallWorkbenchToolRequest>(
          CallWorkbenchToolRequest.$_createMessage);
  static CallWorkbenchToolRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get argumentsJson => $_getN(1);
  @$pb.TagNumber(2)
  set argumentsJson($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasArgumentsJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearArgumentsJson() => $_clearField(2);
}

class CallWorkbenchToolResponse extends $pb.GeneratedMessage {
  factory CallWorkbenchToolResponse({
    $fixnum.Int64? revision,
    $core.List<$core.int>? resultJson,
    $core.List<$core.int>? png,
    WorkbenchToolError? error,
  }) {
    final result = CallWorkbenchToolResponse._();
    if (revision != null) result.revision = revision;
    if (resultJson != null) result.resultJson = resultJson;
    if (png != null) result.png = png;
    if (error != null) result.error = error;
    return result;
  }

  CallWorkbenchToolResponse._();

  factory CallWorkbenchToolResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallWorkbenchToolResponse()..mergeFromBuffer(data, registry);
  factory CallWorkbenchToolResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallWorkbenchToolResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallWorkbenchToolResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CallWorkbenchToolResponse.$_createMessage)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'resultJson', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'png', $pb.PbFieldType.OY)
    ..aOM<WorkbenchToolError>(4, _omitFieldNames ? '' : 'error',
        subBuilder: WorkbenchToolError.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallWorkbenchToolResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallWorkbenchToolResponse copyWith(
          void Function(CallWorkbenchToolResponse) updates) =>
      super.copyWith((message) => updates(message as CallWorkbenchToolResponse))
          as CallWorkbenchToolResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CallWorkbenchToolResponse() / CallWorkbenchToolResponse.new instead')
  static CallWorkbenchToolResponse create() => CallWorkbenchToolResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CallWorkbenchToolResponse._();
  @$core.override
  CallWorkbenchToolResponse createEmptyInstance() =>
      CallWorkbenchToolResponse._();
  @$core.pragma('dart2js:noInline')
  static CallWorkbenchToolResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallWorkbenchToolResponse>(
          CallWorkbenchToolResponse.$_createMessage);
  static CallWorkbenchToolResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get revision => $_getI64(0);
  @$pb.TagNumber(1)
  set revision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevision() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get resultJson => $_getN(1);
  @$pb.TagNumber(2)
  set resultJson($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasResultJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearResultJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get png => $_getN(2);
  @$pb.TagNumber(3)
  set png($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPng() => $_has(2);
  @$pb.TagNumber(3)
  void clearPng() => $_clearField(3);

  @$pb.TagNumber(4)
  WorkbenchToolError get error => $_getN(3);
  @$pb.TagNumber(4)
  set error(WorkbenchToolError value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
  @$pb.TagNumber(4)
  WorkbenchToolError ensureError() => $_ensure(3);
}

class WorkbenchToolError extends $pb.GeneratedMessage {
  factory WorkbenchToolError({
    $core.String? code,
    $core.String? message,
  }) {
    final result = WorkbenchToolError._();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  WorkbenchToolError._();

  factory WorkbenchToolError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkbenchToolError()..mergeFromBuffer(data, registry);
  factory WorkbenchToolError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WorkbenchToolError()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WorkbenchToolError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WorkbenchToolError.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkbenchToolError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WorkbenchToolError copyWith(void Function(WorkbenchToolError) updates) =>
      super.copyWith((message) => updates(message as WorkbenchToolError))
          as WorkbenchToolError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WorkbenchToolError() / WorkbenchToolError.new instead')
  static WorkbenchToolError create() => WorkbenchToolError._();
  static $pb.GeneratedMessage $_createMessage() => WorkbenchToolError._();
  @$core.override
  WorkbenchToolError createEmptyInstance() => WorkbenchToolError._();
  @$core.pragma('dart2js:noInline')
  static WorkbenchToolError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WorkbenchToolError>(
          WorkbenchToolError.$_createMessage);
  static WorkbenchToolError? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
