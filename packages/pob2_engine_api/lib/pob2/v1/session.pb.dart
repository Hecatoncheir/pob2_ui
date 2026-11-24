// This is a generated file - do not edit.
//
// Generated from pob2/v1/session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'build.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Приложение открывает поток только после разрешения на правки через MCP.
class WatchEditorRequest extends $pb.GeneratedMessage {
  factory WatchEditorRequest({
    $core.String? sessionId,
  }) {
    final result = WatchEditorRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  WatchEditorRequest._();

  factory WatchEditorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchEditorRequest()..mergeFromBuffer(data, registry);
  factory WatchEditorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchEditorRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchEditorRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchEditorRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEditorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEditorRequest copyWith(void Function(WatchEditorRequest) updates) =>
      super.copyWith((message) => updates(message as WatchEditorRequest))
          as WatchEditorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchEditorRequest() / WatchEditorRequest.new instead')
  static WatchEditorRequest create() => WatchEditorRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchEditorRequest._();
  @$core.override
  WatchEditorRequest createEmptyInstance() => WatchEditorRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchEditorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchEditorRequest>(
          WatchEditorRequest.$_createMessage);
  static WatchEditorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);
}

class CallEditorRequest extends $pb.GeneratedMessage {
  factory CallEditorRequest({
    $core.String? sessionId,
    $core.String? tool,
    $core.String? argumentsJson,
  }) {
    final result = CallEditorRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (tool != null) result.tool = tool;
    if (argumentsJson != null) result.argumentsJson = argumentsJson;
    return result;
  }

  CallEditorRequest._();

  factory CallEditorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallEditorRequest()..mergeFromBuffer(data, registry);
  factory CallEditorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallEditorRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallEditorRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CallEditorRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'tool')
    ..aOS(3, _omitFieldNames ? '' : 'argumentsJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallEditorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallEditorRequest copyWith(void Function(CallEditorRequest) updates) =>
      super.copyWith((message) => updates(message as CallEditorRequest))
          as CallEditorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CallEditorRequest() / CallEditorRequest.new instead')
  static CallEditorRequest create() => CallEditorRequest._();
  static $pb.GeneratedMessage $_createMessage() => CallEditorRequest._();
  @$core.override
  CallEditorRequest createEmptyInstance() => CallEditorRequest._();
  @$core.pragma('dart2js:noInline')
  static CallEditorRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CallEditorRequest>(
          CallEditorRequest.$_createMessage);
  static CallEditorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tool => $_getSZ(1);
  @$pb.TagNumber(2)
  set tool($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTool() => $_has(1);
  @$pb.TagNumber(2)
  void clearTool() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get argumentsJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set argumentsJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasArgumentsJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearArgumentsJson() => $_clearField(3);
}

class WatchEditorResponse extends $pb.GeneratedMessage {
  factory WatchEditorResponse({
    $core.String? requestId,
    $core.String? tool,
    $core.String? argumentsJson,
    $core.bool? attached,
  }) {
    final result = WatchEditorResponse._();
    if (requestId != null) result.requestId = requestId;
    if (tool != null) result.tool = tool;
    if (argumentsJson != null) result.argumentsJson = argumentsJson;
    if (attached != null) result.attached = attached;
    return result;
  }

  WatchEditorResponse._();

  factory WatchEditorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchEditorResponse()..mergeFromBuffer(data, registry);
  factory WatchEditorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchEditorResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchEditorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchEditorResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'tool')
    ..aOS(3, _omitFieldNames ? '' : 'argumentsJson')
    ..aOB(4, _omitFieldNames ? '' : 'attached')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEditorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchEditorResponse copyWith(void Function(WatchEditorResponse) updates) =>
      super.copyWith((message) => updates(message as WatchEditorResponse))
          as WatchEditorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use WatchEditorResponse() / WatchEditorResponse.new instead')
  static WatchEditorResponse create() => WatchEditorResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchEditorResponse._();
  @$core.override
  WatchEditorResponse createEmptyInstance() => WatchEditorResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchEditorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchEditorResponse>(
          WatchEditorResponse.$_createMessage);
  static WatchEditorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tool => $_getSZ(1);
  @$pb.TagNumber(2)
  set tool($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTool() => $_has(1);
  @$pb.TagNumber(2)
  void clearTool() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get argumentsJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set argumentsJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasArgumentsJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearArgumentsJson() => $_clearField(3);

  /// Первое сообщение подтверждает привязку потока к сессии.
  @$pb.TagNumber(4)
  $core.bool get attached => $_getBF(3);
  @$pb.TagNumber(4)
  set attached($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAttached() => $_has(3);
  @$pb.TagNumber(4)
  void clearAttached() => $_clearField(4);
}

class CallEditorResponse extends $pb.GeneratedMessage {
  factory CallEditorResponse({
    $core.String? resultJson,
  }) {
    final result = CallEditorResponse._();
    if (resultJson != null) result.resultJson = resultJson;
    return result;
  }

  CallEditorResponse._();

  factory CallEditorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallEditorResponse()..mergeFromBuffer(data, registry);
  factory CallEditorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CallEditorResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CallEditorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CallEditorResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallEditorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CallEditorResponse copyWith(void Function(CallEditorResponse) updates) =>
      super.copyWith((message) => updates(message as CallEditorResponse))
          as CallEditorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CallEditorResponse() / CallEditorResponse.new instead')
  static CallEditorResponse create() => CallEditorResponse._();
  static $pb.GeneratedMessage $_createMessage() => CallEditorResponse._();
  @$core.override
  CallEditorResponse createEmptyInstance() => CallEditorResponse._();
  @$core.pragma('dart2js:noInline')
  static CallEditorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CallEditorResponse>(
          CallEditorResponse.$_createMessage);
  static CallEditorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get resultJson => $_getSZ(0);
  @$pb.TagNumber(1)
  set resultJson($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasResultJson() => $_has(0);
  @$pb.TagNumber(1)
  void clearResultJson() => $_clearField(1);
}

class ReplyEditorRequest extends $pb.GeneratedMessage {
  factory ReplyEditorRequest({
    $core.String? sessionId,
    $core.String? requestId,
    $core.String? resultJson,
  }) {
    final result = ReplyEditorRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (requestId != null) result.requestId = requestId;
    if (resultJson != null) result.resultJson = resultJson;
    return result;
  }

  ReplyEditorRequest._();

  factory ReplyEditorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReplyEditorRequest()..mergeFromBuffer(data, registry);
  factory ReplyEditorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReplyEditorRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReplyEditorRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ReplyEditorRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'requestId')
    ..aOS(3, _omitFieldNames ? '' : 'resultJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReplyEditorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReplyEditorRequest copyWith(void Function(ReplyEditorRequest) updates) =>
      super.copyWith((message) => updates(message as ReplyEditorRequest))
          as ReplyEditorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReplyEditorRequest() / ReplyEditorRequest.new instead')
  static ReplyEditorRequest create() => ReplyEditorRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReplyEditorRequest._();
  @$core.override
  ReplyEditorRequest createEmptyInstance() => ReplyEditorRequest._();
  @$core.pragma('dart2js:noInline')
  static ReplyEditorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReplyEditorRequest>(
          ReplyEditorRequest.$_createMessage);
  static ReplyEditorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get requestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set requestId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get resultJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set resultJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResultJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearResultJson() => $_clearField(3);
}

class ReplyEditorResponse extends $pb.GeneratedMessage {
  factory ReplyEditorResponse() => ReplyEditorResponse._();

  ReplyEditorResponse._();

  factory ReplyEditorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReplyEditorResponse()..mergeFromBuffer(data, registry);
  factory ReplyEditorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReplyEditorResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReplyEditorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ReplyEditorResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReplyEditorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReplyEditorResponse copyWith(void Function(ReplyEditorResponse) updates) =>
      super.copyWith((message) => updates(message as ReplyEditorResponse))
          as ReplyEditorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ReplyEditorResponse() / ReplyEditorResponse.new instead')
  static ReplyEditorResponse create() => ReplyEditorResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReplyEditorResponse._();
  @$core.override
  ReplyEditorResponse createEmptyInstance() => ReplyEditorResponse._();
  @$core.pragma('dart2js:noInline')
  static ReplyEditorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReplyEditorResponse>(
          ReplyEditorResponse.$_createMessage);
  static ReplyEditorResponse? _defaultInstance;
}

class SessionSnapshot extends $pb.GeneratedMessage {
  factory SessionSnapshot({
    $core.String? sessionId,
    $core.String? buildName,
    $fixnum.Int64? revision,
    $2.BuildDocument? build,
  }) {
    final result = SessionSnapshot._();
    if (sessionId != null) result.sessionId = sessionId;
    if (buildName != null) result.buildName = buildName;
    if (revision != null) result.revision = revision;
    if (build != null) result.build = build;
    return result;
  }

  SessionSnapshot._();

  factory SessionSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionSnapshot()..mergeFromBuffer(data, registry);
  factory SessionSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SessionSnapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: SessionSnapshot.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'buildName')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$2.BuildDocument>(4, _omitFieldNames ? '' : 'build',
        subBuilder: $2.BuildDocument.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionSnapshot copyWith(void Function(SessionSnapshot) updates) =>
      super.copyWith((message) => updates(message as SessionSnapshot))
          as SessionSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SessionSnapshot() / SessionSnapshot.new instead')
  static SessionSnapshot create() => SessionSnapshot._();
  static $pb.GeneratedMessage $_createMessage() => SessionSnapshot._();
  @$core.override
  SessionSnapshot createEmptyInstance() => SessionSnapshot._();
  @$core.pragma('dart2js:noInline')
  static SessionSnapshot getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionSnapshot>(
          SessionSnapshot.$_createMessage);
  static SessionSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get buildName => $_getSZ(1);
  @$pb.TagNumber(2)
  set buildName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuildName() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuildName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get revision => $_getI64(2);
  @$pb.TagNumber(3)
  set revision($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevision() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.BuildDocument get build => $_getN(3);
  @$pb.TagNumber(4)
  set build($2.BuildDocument value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBuild() => $_has(3);
  @$pb.TagNumber(4)
  void clearBuild() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.BuildDocument ensureBuild() => $_ensure(3);
}

class GetServerInfoRequest extends $pb.GeneratedMessage {
  factory GetServerInfoRequest() => GetServerInfoRequest._();

  GetServerInfoRequest._();

  factory GetServerInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetServerInfoRequest()..mergeFromBuffer(data, registry);
  factory GetServerInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetServerInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetServerInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetServerInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetServerInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetServerInfoRequest copyWith(void Function(GetServerInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetServerInfoRequest))
          as GetServerInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetServerInfoRequest() / GetServerInfoRequest.new instead')
  static GetServerInfoRequest create() => GetServerInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetServerInfoRequest._();
  @$core.override
  GetServerInfoRequest createEmptyInstance() => GetServerInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetServerInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetServerInfoRequest>(
          GetServerInfoRequest.$_createMessage);
  static GetServerInfoRequest? _defaultInstance;
}

class GetServerInfoResponse extends $pb.GeneratedMessage {
  factory GetServerInfoResponse({
    $core.String? version,
    $core.String? protocolVersion,
    $core.Iterable<$core.String>? capabilities,
    $core.String? state,
    $core.String? instanceId,
    $core.String? mode,
    $core.int? clientCount,
    $core.int? activeTasks,
    $fixnum.Int64? leaseTimeoutMs,
    $core.String? storageMode,
    $core.String? storagePath,
  }) {
    final result = GetServerInfoResponse._();
    if (version != null) result.version = version;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (capabilities != null) result.capabilities.addAll(capabilities);
    if (state != null) result.state = state;
    if (instanceId != null) result.instanceId = instanceId;
    if (mode != null) result.mode = mode;
    if (clientCount != null) result.clientCount = clientCount;
    if (activeTasks != null) result.activeTasks = activeTasks;
    if (leaseTimeoutMs != null) result.leaseTimeoutMs = leaseTimeoutMs;
    if (storageMode != null) result.storageMode = storageMode;
    if (storagePath != null) result.storagePath = storagePath;
    return result;
  }

  GetServerInfoResponse._();

  factory GetServerInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetServerInfoResponse()..mergeFromBuffer(data, registry);
  factory GetServerInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetServerInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetServerInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetServerInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOS(2, _omitFieldNames ? '' : 'protocolVersion')
    ..pPS(3, _omitFieldNames ? '' : 'capabilities')
    ..aOS(4, _omitFieldNames ? '' : 'state')
    ..aOS(5, _omitFieldNames ? '' : 'instanceId')
    ..aOS(6, _omitFieldNames ? '' : 'mode')
    ..aI(7, _omitFieldNames ? '' : 'clientCount',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'activeTasks',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        9, _omitFieldNames ? '' : 'leaseTimeoutMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(10, _omitFieldNames ? '' : 'storageMode')
    ..aOS(11, _omitFieldNames ? '' : 'storagePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetServerInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetServerInfoResponse copyWith(
          void Function(GetServerInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetServerInfoResponse))
          as GetServerInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetServerInfoResponse() / GetServerInfoResponse.new instead')
  static GetServerInfoResponse create() => GetServerInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetServerInfoResponse._();
  @$core.override
  GetServerInfoResponse createEmptyInstance() => GetServerInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetServerInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetServerInfoResponse>(
          GetServerInfoResponse.$_createMessage);
  static GetServerInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get protocolVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set protocolVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProtocolVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearProtocolVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get capabilities => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get state => $_getSZ(3);
  @$pb.TagNumber(4)
  set state($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasState() => $_has(3);
  @$pb.TagNumber(4)
  void clearState() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get instanceId => $_getSZ(4);
  @$pb.TagNumber(5)
  set instanceId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInstanceId() => $_has(4);
  @$pb.TagNumber(5)
  void clearInstanceId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mode => $_getSZ(5);
  @$pb.TagNumber(6)
  set mode($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMode() => $_has(5);
  @$pb.TagNumber(6)
  void clearMode() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get clientCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set clientCount($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasClientCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearClientCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get activeTasks => $_getIZ(7);
  @$pb.TagNumber(8)
  set activeTasks($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActiveTasks() => $_has(7);
  @$pb.TagNumber(8)
  void clearActiveTasks() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get leaseTimeoutMs => $_getI64(8);
  @$pb.TagNumber(9)
  set leaseTimeoutMs($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLeaseTimeoutMs() => $_has(8);
  @$pb.TagNumber(9)
  void clearLeaseTimeoutMs() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get storageMode => $_getSZ(9);
  @$pb.TagNumber(10)
  set storageMode($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStorageMode() => $_has(9);
  @$pb.TagNumber(10)
  void clearStorageMode() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get storagePath => $_getSZ(10);
  @$pb.TagNumber(11)
  set storagePath($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStoragePath() => $_has(10);
  @$pb.TagNumber(11)
  void clearStoragePath() => $_clearField(11);
}

/// request_id повторяется только для точного повтора той же команды.
class CreateSessionRequest extends $pb.GeneratedMessage {
  factory CreateSessionRequest({
    $core.String? sessionId,
    $core.String? buildName,
    $core.String? requestId,
  }) {
    final result = CreateSessionRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (buildName != null) result.buildName = buildName;
    if (requestId != null) result.requestId = requestId;
    return result;
  }

  CreateSessionRequest._();

  factory CreateSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionRequest()..mergeFromBuffer(data, registry);
  factory CreateSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CreateSessionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'buildName')
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionRequest copyWith(void Function(CreateSessionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSessionRequest))
          as CreateSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateSessionRequest() / CreateSessionRequest.new instead')
  static CreateSessionRequest create() => CreateSessionRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateSessionRequest._();
  @$core.override
  CreateSessionRequest createEmptyInstance() => CreateSessionRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionRequest>(
          CreateSessionRequest.$_createMessage);
  static CreateSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get buildName => $_getSZ(1);
  @$pb.TagNumber(2)
  set buildName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuildName() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuildName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get requestId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestId() => $_clearField(3);
}

class CreateSessionResponse extends $pb.GeneratedMessage {
  factory CreateSessionResponse({
    SessionSnapshot? snapshot,
  }) {
    final result = CreateSessionResponse._();
    if (snapshot != null) result.snapshot = snapshot;
    return result;
  }

  CreateSessionResponse._();

  factory CreateSessionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionResponse()..mergeFromBuffer(data, registry);
  factory CreateSessionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CreateSessionResponse.$_createMessage)
    ..aOM<SessionSnapshot>(1, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SessionSnapshot.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionResponse copyWith(
          void Function(CreateSessionResponse) updates) =>
      super.copyWith((message) => updates(message as CreateSessionResponse))
          as CreateSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateSessionResponse() / CreateSessionResponse.new instead')
  static CreateSessionResponse create() => CreateSessionResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateSessionResponse._();
  @$core.override
  CreateSessionResponse createEmptyInstance() => CreateSessionResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionResponse>(
          CreateSessionResponse.$_createMessage);
  static CreateSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSnapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot(SessionSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionSnapshot ensureSnapshot() => $_ensure(0);
}

/// Создаёт сессию и сохраняет XML в первой ревизии одной командой.
class CreateSessionFromXmlRequest extends $pb.GeneratedMessage {
  factory CreateSessionFromXmlRequest({
    $core.String? sessionId,
    $core.String? buildName,
    $core.String? requestId,
    $core.String? xml,
  }) {
    final result = CreateSessionFromXmlRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (buildName != null) result.buildName = buildName;
    if (requestId != null) result.requestId = requestId;
    if (xml != null) result.xml = xml;
    return result;
  }

  CreateSessionFromXmlRequest._();

  factory CreateSessionFromXmlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionFromXmlRequest()..mergeFromBuffer(data, registry);
  factory CreateSessionFromXmlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionFromXmlRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionFromXmlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CreateSessionFromXmlRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'buildName')
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..aOS(4, _omitFieldNames ? '' : 'xml')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionFromXmlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionFromXmlRequest copyWith(
          void Function(CreateSessionFromXmlRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateSessionFromXmlRequest))
          as CreateSessionFromXmlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateSessionFromXmlRequest() / CreateSessionFromXmlRequest.new instead')
  static CreateSessionFromXmlRequest create() =>
      CreateSessionFromXmlRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateSessionFromXmlRequest._();
  @$core.override
  CreateSessionFromXmlRequest createEmptyInstance() =>
      CreateSessionFromXmlRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateSessionFromXmlRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionFromXmlRequest>(
          CreateSessionFromXmlRequest.$_createMessage);
  static CreateSessionFromXmlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get buildName => $_getSZ(1);
  @$pb.TagNumber(2)
  set buildName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuildName() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuildName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get requestId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get xml => $_getSZ(3);
  @$pb.TagNumber(4)
  set xml($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasXml() => $_has(3);
  @$pb.TagNumber(4)
  void clearXml() => $_clearField(4);
}

class CreateSessionFromXmlResponse extends $pb.GeneratedMessage {
  factory CreateSessionFromXmlResponse({
    SessionSnapshot? snapshot,
  }) {
    final result = CreateSessionFromXmlResponse._();
    if (snapshot != null) result.snapshot = snapshot;
    return result;
  }

  CreateSessionFromXmlResponse._();

  factory CreateSessionFromXmlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionFromXmlResponse()..mergeFromBuffer(data, registry);
  factory CreateSessionFromXmlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSessionFromXmlResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSessionFromXmlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CreateSessionFromXmlResponse.$_createMessage)
    ..aOM<SessionSnapshot>(1, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SessionSnapshot.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionFromXmlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSessionFromXmlResponse copyWith(
          void Function(CreateSessionFromXmlResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateSessionFromXmlResponse))
          as CreateSessionFromXmlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateSessionFromXmlResponse() / CreateSessionFromXmlResponse.new instead')
  static CreateSessionFromXmlResponse create() =>
      CreateSessionFromXmlResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateSessionFromXmlResponse._();
  @$core.override
  CreateSessionFromXmlResponse createEmptyInstance() =>
      CreateSessionFromXmlResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateSessionFromXmlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSessionFromXmlResponse>(
          CreateSessionFromXmlResponse.$_createMessage);
  static CreateSessionFromXmlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSnapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot(SessionSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionSnapshot ensureSnapshot() => $_ensure(0);
}

class GetSnapshotRequest extends $pb.GeneratedMessage {
  factory GetSnapshotRequest({
    $core.String? sessionId,
  }) {
    final result = GetSnapshotRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  GetSnapshotRequest._();

  factory GetSnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotRequest()..mergeFromBuffer(data, registry);
  factory GetSnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetSnapshotRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotRequest copyWith(void Function(GetSnapshotRequest) updates) =>
      super.copyWith((message) => updates(message as GetSnapshotRequest))
          as GetSnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSnapshotRequest() / GetSnapshotRequest.new instead')
  static GetSnapshotRequest create() => GetSnapshotRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSnapshotRequest._();
  @$core.override
  GetSnapshotRequest createEmptyInstance() => GetSnapshotRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSnapshotRequest>(
          GetSnapshotRequest.$_createMessage);
  static GetSnapshotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);
}

class GetSnapshotResponse extends $pb.GeneratedMessage {
  factory GetSnapshotResponse({
    SessionSnapshot? snapshot,
  }) {
    final result = GetSnapshotResponse._();
    if (snapshot != null) result.snapshot = snapshot;
    return result;
  }

  GetSnapshotResponse._();

  factory GetSnapshotResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotResponse()..mergeFromBuffer(data, registry);
  factory GetSnapshotResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSnapshotResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSnapshotResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: GetSnapshotResponse.$_createMessage)
    ..aOM<SessionSnapshot>(1, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SessionSnapshot.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSnapshotResponse copyWith(void Function(GetSnapshotResponse) updates) =>
      super.copyWith((message) => updates(message as GetSnapshotResponse))
          as GetSnapshotResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use GetSnapshotResponse() / GetSnapshotResponse.new instead')
  static GetSnapshotResponse create() => GetSnapshotResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSnapshotResponse._();
  @$core.override
  GetSnapshotResponse createEmptyInstance() => GetSnapshotResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSnapshotResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSnapshotResponse>(
          GetSnapshotResponse.$_createMessage);
  static GetSnapshotResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSnapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot(SessionSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionSnapshot ensureSnapshot() => $_ensure(0);
}

/// Точный повтор возвращает исходный результат даже после последующих правок.
class RenameBuildRequest extends $pb.GeneratedMessage {
  factory RenameBuildRequest({
    $core.String? sessionId,
    $core.String? buildName,
    $fixnum.Int64? expectedRevision,
    $core.String? requestId,
  }) {
    final result = RenameBuildRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (buildName != null) result.buildName = buildName;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (requestId != null) result.requestId = requestId;
    return result;
  }

  RenameBuildRequest._();

  factory RenameBuildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RenameBuildRequest()..mergeFromBuffer(data, registry);
  factory RenameBuildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RenameBuildRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RenameBuildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: RenameBuildRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..aOS(2, _omitFieldNames ? '' : 'buildName')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameBuildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameBuildRequest copyWith(void Function(RenameBuildRequest) updates) =>
      super.copyWith((message) => updates(message as RenameBuildRequest))
          as RenameBuildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RenameBuildRequest() / RenameBuildRequest.new instead')
  static RenameBuildRequest create() => RenameBuildRequest._();
  static $pb.GeneratedMessage $_createMessage() => RenameBuildRequest._();
  @$core.override
  RenameBuildRequest createEmptyInstance() => RenameBuildRequest._();
  @$core.pragma('dart2js:noInline')
  static RenameBuildRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RenameBuildRequest>(
          RenameBuildRequest.$_createMessage);
  static RenameBuildRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get buildName => $_getSZ(1);
  @$pb.TagNumber(2)
  set buildName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuildName() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuildName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expectedRevision => $_getI64(2);
  @$pb.TagNumber(3)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedRevision() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get requestId => $_getSZ(3);
  @$pb.TagNumber(4)
  set requestId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequestId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestId() => $_clearField(4);
}

class RenameBuildResponse extends $pb.GeneratedMessage {
  factory RenameBuildResponse({
    SessionSnapshot? snapshot,
  }) {
    final result = RenameBuildResponse._();
    if (snapshot != null) result.snapshot = snapshot;
    return result;
  }

  RenameBuildResponse._();

  factory RenameBuildResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RenameBuildResponse()..mergeFromBuffer(data, registry);
  factory RenameBuildResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RenameBuildResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RenameBuildResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: RenameBuildResponse.$_createMessage)
    ..aOM<SessionSnapshot>(1, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SessionSnapshot.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameBuildResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameBuildResponse copyWith(void Function(RenameBuildResponse) updates) =>
      super.copyWith((message) => updates(message as RenameBuildResponse))
          as RenameBuildResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use RenameBuildResponse() / RenameBuildResponse.new instead')
  static RenameBuildResponse create() => RenameBuildResponse._();
  static $pb.GeneratedMessage $_createMessage() => RenameBuildResponse._();
  @$core.override
  RenameBuildResponse createEmptyInstance() => RenameBuildResponse._();
  @$core.pragma('dart2js:noInline')
  static RenameBuildResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RenameBuildResponse>(
          RenameBuildResponse.$_createMessage);
  static RenameBuildResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSnapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot(SessionSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionSnapshot ensureSnapshot() => $_ensure(0);
}

/// Ноль запрашивает начальный снимок; иначе возвращаются все последующие правки.
class WatchSessionRequest extends $pb.GeneratedMessage {
  factory WatchSessionRequest({
    $core.String? sessionId,
    $fixnum.Int64? afterRevision,
  }) {
    final result = WatchSessionRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (afterRevision != null) result.afterRevision = afterRevision;
    return result;
  }

  WatchSessionRequest._();

  factory WatchSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchSessionRequest()..mergeFromBuffer(data, registry);
  factory WatchSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchSessionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchSessionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchSessionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'afterRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchSessionRequest copyWith(void Function(WatchSessionRequest) updates) =>
      super.copyWith((message) => updates(message as WatchSessionRequest))
          as WatchSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use WatchSessionRequest() / WatchSessionRequest.new instead')
  static WatchSessionRequest create() => WatchSessionRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchSessionRequest._();
  @$core.override
  WatchSessionRequest createEmptyInstance() => WatchSessionRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchSessionRequest>(
          WatchSessionRequest.$_createMessage);
  static WatchSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get afterRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set afterRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAfterRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearAfterRevision() => $_clearField(2);
}

class WatchSessionResponse extends $pb.GeneratedMessage {
  factory WatchSessionResponse({
    SessionSnapshot? snapshot,
    $core.String? kind,
    $core.String? requestId,
    $core.Iterable<$core.String>? changedFields,
    $core.String? previousBuildName,
  }) {
    final result = WatchSessionResponse._();
    if (snapshot != null) result.snapshot = snapshot;
    if (kind != null) result.kind = kind;
    if (requestId != null) result.requestId = requestId;
    if (changedFields != null) result.changedFields.addAll(changedFields);
    if (previousBuildName != null) result.previousBuildName = previousBuildName;
    return result;
  }

  WatchSessionResponse._();

  factory WatchSessionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchSessionResponse()..mergeFromBuffer(data, registry);
  factory WatchSessionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchSessionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchSessionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchSessionResponse.$_createMessage)
    ..aOM<SessionSnapshot>(1, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SessionSnapshot.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..pPS(4, _omitFieldNames ? '' : 'changedFields')
    ..aOS(5, _omitFieldNames ? '' : 'previousBuildName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchSessionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchSessionResponse copyWith(void Function(WatchSessionResponse) updates) =>
      super.copyWith((message) => updates(message as WatchSessionResponse))
          as WatchSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use WatchSessionResponse() / WatchSessionResponse.new instead')
  static WatchSessionResponse create() => WatchSessionResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchSessionResponse._();
  @$core.override
  WatchSessionResponse createEmptyInstance() => WatchSessionResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchSessionResponse>(
          WatchSessionResponse.$_createMessage);
  static WatchSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSnapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot(SessionSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionSnapshot ensureSnapshot() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get kind => $_getSZ(1);
  @$pb.TagNumber(2)
  set kind($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get requestId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get changedFields => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get previousBuildName => $_getSZ(4);
  @$pb.TagNumber(5)
  set previousBuildName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPreviousBuildName() => $_has(4);
  @$pb.TagNumber(5)
  void clearPreviousBuildName() => $_clearField(5);
}

class ShutdownRequest extends $pb.GeneratedMessage {
  factory ShutdownRequest() => ShutdownRequest._();

  ShutdownRequest._();

  factory ShutdownRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownRequest()..mergeFromBuffer(data, registry);
  factory ShutdownRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ShutdownRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ShutdownRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownRequest copyWith(void Function(ShutdownRequest) updates) =>
      super.copyWith((message) => updates(message as ShutdownRequest))
          as ShutdownRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShutdownRequest() / ShutdownRequest.new instead')
  static ShutdownRequest create() => ShutdownRequest._();
  static $pb.GeneratedMessage $_createMessage() => ShutdownRequest._();
  @$core.override
  ShutdownRequest createEmptyInstance() => ShutdownRequest._();
  @$core.pragma('dart2js:noInline')
  static ShutdownRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownRequest>(
          ShutdownRequest.$_createMessage);
  static ShutdownRequest? _defaultInstance;
}

/// Поток не продлевает аренду и не считается вычислительной задачей.
class WatchServerRequest extends $pb.GeneratedMessage {
  factory WatchServerRequest() => WatchServerRequest._();

  WatchServerRequest._();

  factory WatchServerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchServerRequest()..mergeFromBuffer(data, registry);
  factory WatchServerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchServerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchServerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchServerRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchServerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchServerRequest copyWith(void Function(WatchServerRequest) updates) =>
      super.copyWith((message) => updates(message as WatchServerRequest))
          as WatchServerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchServerRequest() / WatchServerRequest.new instead')
  static WatchServerRequest create() => WatchServerRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchServerRequest._();
  @$core.override
  WatchServerRequest createEmptyInstance() => WatchServerRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchServerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchServerRequest>(
          WatchServerRequest.$_createMessage);
  static WatchServerRequest? _defaultInstance;
}

/// Сначала текущая фаза, затем переход в draining и штатный конец потока.
/// sequence относится только к instance_id; событие stopped по сети не обещается.
class WatchServerResponse extends $pb.GeneratedMessage {
  factory WatchServerResponse({
    $core.String? instanceId,
    $fixnum.Int64? sequence,
    $core.String? state,
    $core.String? reason,
    $fixnum.Int64? shutdownTimeoutMs,
  }) {
    final result = WatchServerResponse._();
    if (instanceId != null) result.instanceId = instanceId;
    if (sequence != null) result.sequence = sequence;
    if (state != null) result.state = state;
    if (reason != null) result.reason = reason;
    if (shutdownTimeoutMs != null) result.shutdownTimeoutMs = shutdownTimeoutMs;
    return result;
  }

  WatchServerResponse._();

  factory WatchServerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchServerResponse()..mergeFromBuffer(data, registry);
  factory WatchServerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchServerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WatchServerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: WatchServerResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'instanceId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'state')
    ..aOS(4, _omitFieldNames ? '' : 'reason')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'shutdownTimeoutMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchServerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchServerResponse copyWith(void Function(WatchServerResponse) updates) =>
      super.copyWith((message) => updates(message as WatchServerResponse))
          as WatchServerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use WatchServerResponse() / WatchServerResponse.new instead')
  static WatchServerResponse create() => WatchServerResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchServerResponse._();
  @$core.override
  WatchServerResponse createEmptyInstance() => WatchServerResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchServerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchServerResponse>(
          WatchServerResponse.$_createMessage);
  static WatchServerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get instanceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set instanceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInstanceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearInstanceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sequence => $_getI64(1);
  @$pb.TagNumber(2)
  set sequence($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearSequence() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get state => $_getSZ(2);
  @$pb.TagNumber(3)
  set state($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get reason => $_getSZ(3);
  @$pb.TagNumber(4)
  set reason($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearReason() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get shutdownTimeoutMs => $_getI64(4);
  @$pb.TagNumber(5)
  set shutdownTimeoutMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasShutdownTimeoutMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearShutdownTimeoutMs() => $_clearField(5);
}

class ShutdownResponse extends $pb.GeneratedMessage {
  factory ShutdownResponse() => ShutdownResponse._();

  ShutdownResponse._();

  factory ShutdownResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownResponse()..mergeFromBuffer(data, registry);
  factory ShutdownResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ShutdownResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ShutdownResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ShutdownResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShutdownResponse copyWith(void Function(ShutdownResponse) updates) =>
      super.copyWith((message) => updates(message as ShutdownResponse))
          as ShutdownResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ShutdownResponse() / ShutdownResponse.new instead')
  static ShutdownResponse create() => ShutdownResponse._();
  static $pb.GeneratedMessage $_createMessage() => ShutdownResponse._();
  @$core.override
  ShutdownResponse createEmptyInstance() => ShutdownResponse._();
  @$core.pragma('dart2js:noInline')
  static ShutdownResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShutdownResponse>(
          ShutdownResponse.$_createMessage);
  static ShutdownResponse? _defaultInstance;
}

/// client_id обозначает приложение, а не TCP-соединение или отдельный RPC.
class RegisterClientRequest extends $pb.GeneratedMessage {
  factory RegisterClientRequest({
    $core.String? clientId,
    $core.String? kind,
  }) {
    final result = RegisterClientRequest._();
    if (clientId != null) result.clientId = clientId;
    if (kind != null) result.kind = kind;
    return result;
  }

  RegisterClientRequest._();

  factory RegisterClientRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterClientRequest()..mergeFromBuffer(data, registry);
  factory RegisterClientRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterClientRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterClientRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: RegisterClientRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'clientId')
    ..aOS(2, _omitFieldNames ? '' : 'kind')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterClientRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterClientRequest copyWith(
          void Function(RegisterClientRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterClientRequest))
          as RegisterClientRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RegisterClientRequest() / RegisterClientRequest.new instead')
  static RegisterClientRequest create() => RegisterClientRequest._();
  static $pb.GeneratedMessage $_createMessage() => RegisterClientRequest._();
  @$core.override
  RegisterClientRequest createEmptyInstance() => RegisterClientRequest._();
  @$core.pragma('dart2js:noInline')
  static RegisterClientRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterClientRequest>(
          RegisterClientRequest.$_createMessage);
  static RegisterClientRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get kind => $_getSZ(1);
  @$pb.TagNumber(2)
  set kind($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);
}

class RegisterClientResponse extends $pb.GeneratedMessage {
  factory RegisterClientResponse({
    $core.String? leaseId,
    $fixnum.Int64? leaseTimeoutMs,
  }) {
    final result = RegisterClientResponse._();
    if (leaseId != null) result.leaseId = leaseId;
    if (leaseTimeoutMs != null) result.leaseTimeoutMs = leaseTimeoutMs;
    return result;
  }

  RegisterClientResponse._();

  factory RegisterClientResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterClientResponse()..mergeFromBuffer(data, registry);
  factory RegisterClientResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RegisterClientResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterClientResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: RegisterClientResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'leaseId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'leaseTimeoutMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterClientResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterClientResponse copyWith(
          void Function(RegisterClientResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterClientResponse))
          as RegisterClientResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RegisterClientResponse() / RegisterClientResponse.new instead')
  static RegisterClientResponse create() => RegisterClientResponse._();
  static $pb.GeneratedMessage $_createMessage() => RegisterClientResponse._();
  @$core.override
  RegisterClientResponse createEmptyInstance() => RegisterClientResponse._();
  @$core.pragma('dart2js:noInline')
  static RegisterClientResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterClientResponse>(
          RegisterClientResponse.$_createMessage);
  static RegisterClientResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get leaseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set leaseId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeaseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeaseId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get leaseTimeoutMs => $_getI64(1);
  @$pb.TagNumber(2)
  set leaseTimeoutMs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLeaseTimeoutMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeaseTimeoutMs() => $_clearField(2);
}

class HeartbeatRequest extends $pb.GeneratedMessage {
  factory HeartbeatRequest({
    $core.String? leaseId,
  }) {
    final result = HeartbeatRequest._();
    if (leaseId != null) result.leaseId = leaseId;
    return result;
  }

  HeartbeatRequest._();

  factory HeartbeatRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HeartbeatRequest()..mergeFromBuffer(data, registry);
  factory HeartbeatRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HeartbeatRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeartbeatRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: HeartbeatRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'leaseId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatRequest copyWith(void Function(HeartbeatRequest) updates) =>
      super.copyWith((message) => updates(message as HeartbeatRequest))
          as HeartbeatRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HeartbeatRequest() / HeartbeatRequest.new instead')
  static HeartbeatRequest create() => HeartbeatRequest._();
  static $pb.GeneratedMessage $_createMessage() => HeartbeatRequest._();
  @$core.override
  HeartbeatRequest createEmptyInstance() => HeartbeatRequest._();
  @$core.pragma('dart2js:noInline')
  static HeartbeatRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HeartbeatRequest>(
          HeartbeatRequest.$_createMessage);
  static HeartbeatRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get leaseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set leaseId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeaseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeaseId() => $_clearField(1);
}

class HeartbeatResponse extends $pb.GeneratedMessage {
  factory HeartbeatResponse() => HeartbeatResponse._();

  HeartbeatResponse._();

  factory HeartbeatResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HeartbeatResponse()..mergeFromBuffer(data, registry);
  factory HeartbeatResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HeartbeatResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HeartbeatResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: HeartbeatResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HeartbeatResponse copyWith(void Function(HeartbeatResponse) updates) =>
      super.copyWith((message) => updates(message as HeartbeatResponse))
          as HeartbeatResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HeartbeatResponse() / HeartbeatResponse.new instead')
  static HeartbeatResponse create() => HeartbeatResponse._();
  static $pb.GeneratedMessage $_createMessage() => HeartbeatResponse._();
  @$core.override
  HeartbeatResponse createEmptyInstance() => HeartbeatResponse._();
  @$core.pragma('dart2js:noInline')
  static HeartbeatResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HeartbeatResponse>(
          HeartbeatResponse.$_createMessage);
  static HeartbeatResponse? _defaultInstance;
}

/// Освобождение уже отсутствующей аренды безопасно.
class ReleaseClientRequest extends $pb.GeneratedMessage {
  factory ReleaseClientRequest({
    $core.String? leaseId,
  }) {
    final result = ReleaseClientRequest._();
    if (leaseId != null) result.leaseId = leaseId;
    return result;
  }

  ReleaseClientRequest._();

  factory ReleaseClientRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseClientRequest()..mergeFromBuffer(data, registry);
  factory ReleaseClientRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseClientRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReleaseClientRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ReleaseClientRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'leaseId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseClientRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseClientRequest copyWith(void Function(ReleaseClientRequest) updates) =>
      super.copyWith((message) => updates(message as ReleaseClientRequest))
          as ReleaseClientRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReleaseClientRequest() / ReleaseClientRequest.new instead')
  static ReleaseClientRequest create() => ReleaseClientRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReleaseClientRequest._();
  @$core.override
  ReleaseClientRequest createEmptyInstance() => ReleaseClientRequest._();
  @$core.pragma('dart2js:noInline')
  static ReleaseClientRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReleaseClientRequest>(
          ReleaseClientRequest.$_createMessage);
  static ReleaseClientRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get leaseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set leaseId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeaseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeaseId() => $_clearField(1);
}

class ReleaseClientResponse extends $pb.GeneratedMessage {
  factory ReleaseClientResponse() => ReleaseClientResponse._();

  ReleaseClientResponse._();

  factory ReleaseClientResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseClientResponse()..mergeFromBuffer(data, registry);
  factory ReleaseClientResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReleaseClientResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReleaseClientResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ReleaseClientResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseClientResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReleaseClientResponse copyWith(
          void Function(ReleaseClientResponse) updates) =>
      super.copyWith((message) => updates(message as ReleaseClientResponse))
          as ReleaseClientResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReleaseClientResponse() / ReleaseClientResponse.new instead')
  static ReleaseClientResponse create() => ReleaseClientResponse._();
  static $pb.GeneratedMessage $_createMessage() => ReleaseClientResponse._();
  @$core.override
  ReleaseClientResponse createEmptyInstance() => ReleaseClientResponse._();
  @$core.pragma('dart2js:noInline')
  static ReleaseClientResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReleaseClientResponse>(
          ReleaseClientResponse.$_createMessage);
  static ReleaseClientResponse? _defaultInstance;
}

enum ApplyBuildRequest_Input { xml, edit, notSet }

class ApplyBuildRequest extends $pb.GeneratedMessage {
  factory ApplyBuildRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.String? requestId,
    $core.String? xml,
    $2.BuildEdit? edit,
  }) {
    final result = ApplyBuildRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (requestId != null) result.requestId = requestId;
    if (xml != null) result.xml = xml;
    if (edit != null) result.edit = edit;
    return result;
  }

  ApplyBuildRequest._();

  factory ApplyBuildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyBuildRequest()..mergeFromBuffer(data, registry);
  factory ApplyBuildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyBuildRequest()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ApplyBuildRequest_Input>
      _ApplyBuildRequest_InputByTag = {
    4: ApplyBuildRequest_Input.xml,
    5: ApplyBuildRequest_Input.edit,
    0: ApplyBuildRequest_Input.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyBuildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ApplyBuildRequest.$_createMessage)
    ..oo(0, [4, 5])
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..aOS(4, _omitFieldNames ? '' : 'xml')
    ..aOM<$2.BuildEdit>(5, _omitFieldNames ? '' : 'edit',
        subBuilder: $2.BuildEdit.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyBuildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyBuildRequest copyWith(void Function(ApplyBuildRequest) updates) =>
      super.copyWith((message) => updates(message as ApplyBuildRequest))
          as ApplyBuildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApplyBuildRequest() / ApplyBuildRequest.new instead')
  static ApplyBuildRequest create() => ApplyBuildRequest._();
  static $pb.GeneratedMessage $_createMessage() => ApplyBuildRequest._();
  @$core.override
  ApplyBuildRequest createEmptyInstance() => ApplyBuildRequest._();
  @$core.pragma('dart2js:noInline')
  static ApplyBuildRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ApplyBuildRequest>(
          ApplyBuildRequest.$_createMessage);
  static ApplyBuildRequest? _defaultInstance;

  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  ApplyBuildRequest_Input whichInput() =>
      _ApplyBuildRequest_InputByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearInput() => $_clearField($_whichOneof(0));

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
  $core.String get requestId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get xml => $_getSZ(3);
  @$pb.TagNumber(4)
  set xml($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasXml() => $_has(3);
  @$pb.TagNumber(4)
  void clearXml() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.BuildEdit get edit => $_getN(4);
  @$pb.TagNumber(5)
  set edit($2.BuildEdit value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEdit() => $_has(4);
  @$pb.TagNumber(5)
  void clearEdit() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.BuildEdit ensureEdit() => $_ensure(4);
}

class ApplyBuildResponse extends $pb.GeneratedMessage {
  factory ApplyBuildResponse({
    SessionSnapshot? snapshot,
  }) {
    final result = ApplyBuildResponse._();
    if (snapshot != null) result.snapshot = snapshot;
    return result;
  }

  ApplyBuildResponse._();

  factory ApplyBuildResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyBuildResponse()..mergeFromBuffer(data, registry);
  factory ApplyBuildResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ApplyBuildResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyBuildResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ApplyBuildResponse.$_createMessage)
    ..aOM<SessionSnapshot>(1, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SessionSnapshot.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyBuildResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyBuildResponse copyWith(void Function(ApplyBuildResponse) updates) =>
      super.copyWith((message) => updates(message as ApplyBuildResponse))
          as ApplyBuildResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ApplyBuildResponse() / ApplyBuildResponse.new instead')
  static ApplyBuildResponse create() => ApplyBuildResponse._();
  static $pb.GeneratedMessage $_createMessage() => ApplyBuildResponse._();
  @$core.override
  ApplyBuildResponse createEmptyInstance() => ApplyBuildResponse._();
  @$core.pragma('dart2js:noInline')
  static ApplyBuildResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyBuildResponse>(
          ApplyBuildResponse.$_createMessage);
  static ApplyBuildResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SessionSnapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot(SessionSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  SessionSnapshot ensureSnapshot() => $_ensure(0);
}

class CalculateBuildRequest extends $pb.GeneratedMessage {
  factory CalculateBuildRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.String? requestId,
  }) {
    final result = CalculateBuildRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (requestId != null) result.requestId = requestId;
    return result;
  }

  CalculateBuildRequest._();

  factory CalculateBuildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateBuildRequest()..mergeFromBuffer(data, registry);
  factory CalculateBuildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateBuildRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalculateBuildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CalculateBuildRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateBuildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateBuildRequest copyWith(
          void Function(CalculateBuildRequest) updates) =>
      super.copyWith((message) => updates(message as CalculateBuildRequest))
          as CalculateBuildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CalculateBuildRequest() / CalculateBuildRequest.new instead')
  static CalculateBuildRequest create() => CalculateBuildRequest._();
  static $pb.GeneratedMessage $_createMessage() => CalculateBuildRequest._();
  @$core.override
  CalculateBuildRequest createEmptyInstance() => CalculateBuildRequest._();
  @$core.pragma('dart2js:noInline')
  static CalculateBuildRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalculateBuildRequest>(
          CalculateBuildRequest.$_createMessage);
  static CalculateBuildRequest? _defaultInstance;

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
  $core.String get requestId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestId() => $_clearField(3);
}

/// Промежуточные этапы могут объединяться; последний ответ всегда содержит snapshot.
class CalculateBuildResponse extends $pb.GeneratedMessage {
  factory CalculateBuildResponse({
    $core.String? stage,
    SessionSnapshot? snapshot,
  }) {
    final result = CalculateBuildResponse._();
    if (stage != null) result.stage = stage;
    if (snapshot != null) result.snapshot = snapshot;
    return result;
  }

  CalculateBuildResponse._();

  factory CalculateBuildResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateBuildResponse()..mergeFromBuffer(data, registry);
  factory CalculateBuildResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculateBuildResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalculateBuildResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CalculateBuildResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'stage')
    ..aOM<SessionSnapshot>(2, _omitFieldNames ? '' : 'snapshot',
        subBuilder: SessionSnapshot.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateBuildResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculateBuildResponse copyWith(
          void Function(CalculateBuildResponse) updates) =>
      super.copyWith((message) => updates(message as CalculateBuildResponse))
          as CalculateBuildResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CalculateBuildResponse() / CalculateBuildResponse.new instead')
  static CalculateBuildResponse create() => CalculateBuildResponse._();
  static $pb.GeneratedMessage $_createMessage() => CalculateBuildResponse._();
  @$core.override
  CalculateBuildResponse createEmptyInstance() => CalculateBuildResponse._();
  @$core.pragma('dart2js:noInline')
  static CalculateBuildResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalculateBuildResponse>(
          CalculateBuildResponse.$_createMessage);
  static CalculateBuildResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stage => $_getSZ(0);
  @$pb.TagNumber(1)
  set stage($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStage() => $_has(0);
  @$pb.TagNumber(1)
  void clearStage() => $_clearField(1);

  @$pb.TagNumber(2)
  SessionSnapshot get snapshot => $_getN(1);
  @$pb.TagNumber(2)
  set snapshot(SessionSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSnapshot() => $_has(1);
  @$pb.TagNumber(2)
  void clearSnapshot() => $_clearField(2);
  @$pb.TagNumber(2)
  SessionSnapshot ensureSnapshot() => $_ensure(1);
}

enum CompareBuildRequest_Input { xml, edit, notSet }

class CompareBuildRequest extends $pb.GeneratedMessage {
  factory CompareBuildRequest({
    $core.String? sessionId,
    $fixnum.Int64? expectedRevision,
    $core.String? xml,
    $2.BuildEdit? edit,
  }) {
    final result = CompareBuildRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (xml != null) result.xml = xml;
    if (edit != null) result.edit = edit;
    return result;
  }

  CompareBuildRequest._();

  factory CompareBuildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompareBuildRequest()..mergeFromBuffer(data, registry);
  factory CompareBuildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompareBuildRequest()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, CompareBuildRequest_Input>
      _CompareBuildRequest_InputByTag = {
    3: CompareBuildRequest_Input.xml,
    4: CompareBuildRequest_Input.edit,
    0: CompareBuildRequest_Input.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompareBuildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CompareBuildRequest.$_createMessage)
    ..oo(0, [3, 4])
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'xml')
    ..aOM<$2.BuildEdit>(4, _omitFieldNames ? '' : 'edit',
        subBuilder: $2.BuildEdit.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareBuildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareBuildRequest copyWith(void Function(CompareBuildRequest) updates) =>
      super.copyWith((message) => updates(message as CompareBuildRequest))
          as CompareBuildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CompareBuildRequest() / CompareBuildRequest.new instead')
  static CompareBuildRequest create() => CompareBuildRequest._();
  static $pb.GeneratedMessage $_createMessage() => CompareBuildRequest._();
  @$core.override
  CompareBuildRequest createEmptyInstance() => CompareBuildRequest._();
  @$core.pragma('dart2js:noInline')
  static CompareBuildRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompareBuildRequest>(
          CompareBuildRequest.$_createMessage);
  static CompareBuildRequest? _defaultInstance;

  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  CompareBuildRequest_Input whichInput() =>
      _CompareBuildRequest_InputByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  void clearInput() => $_clearField($_whichOneof(0));

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
  $core.String get xml => $_getSZ(2);
  @$pb.TagNumber(3)
  set xml($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasXml() => $_has(2);
  @$pb.TagNumber(3)
  void clearXml() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.BuildEdit get edit => $_getN(3);
  @$pb.TagNumber(4)
  set edit($2.BuildEdit value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEdit() => $_has(3);
  @$pb.TagNumber(4)
  void clearEdit() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.BuildEdit ensureEdit() => $_ensure(3);
}

class CompareBuildResponse extends $pb.GeneratedMessage {
  factory CompareBuildResponse({
    $core.String? sessionId,
    $fixnum.Int64? revision,
    $2.BuildComparison? comparison,
    $2.PassiveChange? passiveChange,
  }) {
    final result = CompareBuildResponse._();
    if (sessionId != null) result.sessionId = sessionId;
    if (revision != null) result.revision = revision;
    if (comparison != null) result.comparison = comparison;
    if (passiveChange != null) result.passiveChange = passiveChange;
    return result;
  }

  CompareBuildResponse._();

  factory CompareBuildResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompareBuildResponse()..mergeFromBuffer(data, registry);
  factory CompareBuildResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CompareBuildResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompareBuildResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: CompareBuildResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$2.BuildComparison>(3, _omitFieldNames ? '' : 'comparison',
        subBuilder: $2.BuildComparison.$_createMessage)
    ..aOM<$2.PassiveChange>(4, _omitFieldNames ? '' : 'passiveChange',
        subBuilder: $2.PassiveChange.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareBuildResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareBuildResponse copyWith(void Function(CompareBuildResponse) updates) =>
      super.copyWith((message) => updates(message as CompareBuildResponse))
          as CompareBuildResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CompareBuildResponse() / CompareBuildResponse.new instead')
  static CompareBuildResponse create() => CompareBuildResponse._();
  static $pb.GeneratedMessage $_createMessage() => CompareBuildResponse._();
  @$core.override
  CompareBuildResponse createEmptyInstance() => CompareBuildResponse._();
  @$core.pragma('dart2js:noInline')
  static CompareBuildResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompareBuildResponse>(
          CompareBuildResponse.$_createMessage);
  static CompareBuildResponse? _defaultInstance;

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
  $2.BuildComparison get comparison => $_getN(2);
  @$pb.TagNumber(3)
  set comparison($2.BuildComparison value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasComparison() => $_has(2);
  @$pb.TagNumber(3)
  void clearComparison() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.BuildComparison ensureComparison() => $_ensure(2);

  /// Заполняется для правки отдельного узла оригинального PoB.
  @$pb.TagNumber(4)
  $2.PassiveChange get passiveChange => $_getN(3);
  @$pb.TagNumber(4)
  set passiveChange($2.PassiveChange value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPassiveChange() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassiveChange() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.PassiveChange ensurePassiveChange() => $_ensure(3);
}

class ExportBuildRequest extends $pb.GeneratedMessage {
  factory ExportBuildRequest({
    $core.String? sessionId,
  }) {
    final result = ExportBuildRequest._();
    if (sessionId != null) result.sessionId = sessionId;
    return result;
  }

  ExportBuildRequest._();

  factory ExportBuildRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportBuildRequest()..mergeFromBuffer(data, registry);
  factory ExportBuildRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportBuildRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportBuildRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ExportBuildRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportBuildRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportBuildRequest copyWith(void Function(ExportBuildRequest) updates) =>
      super.copyWith((message) => updates(message as ExportBuildRequest))
          as ExportBuildRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportBuildRequest() / ExportBuildRequest.new instead')
  static ExportBuildRequest create() => ExportBuildRequest._();
  static $pb.GeneratedMessage $_createMessage() => ExportBuildRequest._();
  @$core.override
  ExportBuildRequest createEmptyInstance() => ExportBuildRequest._();
  @$core.pragma('dart2js:noInline')
  static ExportBuildRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportBuildRequest>(
          ExportBuildRequest.$_createMessage);
  static ExportBuildRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sessionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sessionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSessionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSessionId() => $_clearField(1);
}

class ExportBuildResponse extends $pb.GeneratedMessage {
  factory ExportBuildResponse({
    $core.String? sessionId,
    $fixnum.Int64? revision,
    $core.String? xml,
    $core.String? inputSha256,
  }) {
    final result = ExportBuildResponse._();
    if (sessionId != null) result.sessionId = sessionId;
    if (revision != null) result.revision = revision;
    if (xml != null) result.xml = xml;
    if (inputSha256 != null) result.inputSha256 = inputSha256;
    return result;
  }

  ExportBuildResponse._();

  factory ExportBuildResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportBuildResponse()..mergeFromBuffer(data, registry);
  factory ExportBuildResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportBuildResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportBuildResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ExportBuildResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sessionId')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'xml')
    ..aOS(4, _omitFieldNames ? '' : 'inputSha256')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportBuildResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportBuildResponse copyWith(void Function(ExportBuildResponse) updates) =>
      super.copyWith((message) => updates(message as ExportBuildResponse))
          as ExportBuildResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ExportBuildResponse() / ExportBuildResponse.new instead')
  static ExportBuildResponse create() => ExportBuildResponse._();
  static $pb.GeneratedMessage $_createMessage() => ExportBuildResponse._();
  @$core.override
  ExportBuildResponse createEmptyInstance() => ExportBuildResponse._();
  @$core.pragma('dart2js:noInline')
  static ExportBuildResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportBuildResponse>(
          ExportBuildResponse.$_createMessage);
  static ExportBuildResponse? _defaultInstance;

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
  $core.String get xml => $_getSZ(2);
  @$pb.TagNumber(3)
  set xml($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasXml() => $_has(2);
  @$pb.TagNumber(3)
  void clearXml() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inputSha256 => $_getSZ(3);
  @$pb.TagNumber(4)
  set inputSha256($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInputSha256() => $_has(3);
  @$pb.TagNumber(4)
  void clearInputSha256() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
