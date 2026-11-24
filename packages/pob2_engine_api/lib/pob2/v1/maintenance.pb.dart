// This is a generated file - do not edit.
//
// Generated from pob2/v1/maintenance.proto.

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

class UpdateRequest extends $pb.GeneratedMessage {
  factory UpdateRequest({
    $core.bool? apply,
    $core.String? target,
  }) {
    final result = UpdateRequest._();
    if (apply != null) result.apply = apply;
    if (target != null) result.target = target;
    return result;
  }

  UpdateRequest._();

  factory UpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateRequest()..mergeFromBuffer(data, registry);
  factory UpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: UpdateRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'apply')
    ..aOS(2, _omitFieldNames ? '' : 'target')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateRequest copyWith(void Function(UpdateRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateRequest))
          as UpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateRequest() / UpdateRequest.new instead')
  static UpdateRequest create() => UpdateRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateRequest._();
  @$core.override
  UpdateRequest createEmptyInstance() => UpdateRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateRequest>(
          UpdateRequest.$_createMessage);
  static UpdateRequest? _defaultInstance;

  /// При false проверяется наличие обновления или предыдущей установки.
  @$pb.TagNumber(1)
  $core.bool get apply => $_getBF(0);
  @$pb.TagNumber(1)
  set apply($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasApply() => $_has(0);
  @$pb.TagNumber(1)
  void clearApply() => $_clearField(1);

  /// all, engine, pob, pob@vX.Y.Z или pob-rollback. Пустое значение означает all.
  @$pb.TagNumber(2)
  $core.String get target => $_getSZ(1);
  @$pb.TagNumber(2)
  set target($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTarget() => $_has(1);
  @$pb.TagNumber(2)
  void clearTarget() => $_clearField(2);
}

class UpdateResponse extends $pb.GeneratedMessage {
  factory UpdateResponse({
    $core.String? status,
    $core.String? currentVersion,
    $core.String? latestVersion,
    $core.String? releaseUrl,
    $core.bool? restartRequired,
    ComponentVersion? engine,
    ComponentVersion? pob,
  }) {
    final result = UpdateResponse._();
    if (status != null) result.status = status;
    if (currentVersion != null) result.currentVersion = currentVersion;
    if (latestVersion != null) result.latestVersion = latestVersion;
    if (releaseUrl != null) result.releaseUrl = releaseUrl;
    if (restartRequired != null) result.restartRequired = restartRequired;
    if (engine != null) result.engine = engine;
    if (pob != null) result.pob = pob;
    return result;
  }

  UpdateResponse._();

  factory UpdateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateResponse()..mergeFromBuffer(data, registry);
  factory UpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: UpdateResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'currentVersion')
    ..aOS(3, _omitFieldNames ? '' : 'latestVersion')
    ..aOS(4, _omitFieldNames ? '' : 'releaseUrl')
    ..aOB(5, _omitFieldNames ? '' : 'restartRequired')
    ..aOM<ComponentVersion>(6, _omitFieldNames ? '' : 'engine',
        subBuilder: ComponentVersion.$_createMessage)
    ..aOM<ComponentVersion>(7, _omitFieldNames ? '' : 'pob',
        subBuilder: ComponentVersion.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateResponse copyWith(void Function(UpdateResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateResponse))
          as UpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateResponse() / UpdateResponse.new instead')
  static UpdateResponse create() => UpdateResponse._();
  static $pb.GeneratedMessage $_createMessage() => UpdateResponse._();
  @$core.override
  UpdateResponse createEmptyInstance() => UpdateResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateResponse>(
          UpdateResponse.$_createMessage);
  static UpdateResponse? _defaultInstance;

  /// Статус обновления или отката для выбранной цели.
  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get currentVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set currentVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrentVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get latestVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set latestVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatestVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatestVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get releaseUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set releaseUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReleaseUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearReleaseUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get restartRequired => $_getBF(4);
  @$pb.TagNumber(5)
  set restartRequired($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRestartRequired() => $_has(4);
  @$pb.TagNumber(5)
  void clearRestartRequired() => $_clearField(5);

  @$pb.TagNumber(6)
  ComponentVersion get engine => $_getN(5);
  @$pb.TagNumber(6)
  set engine(ComponentVersion value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasEngine() => $_has(5);
  @$pb.TagNumber(6)
  void clearEngine() => $_clearField(6);
  @$pb.TagNumber(6)
  ComponentVersion ensureEngine() => $_ensure(5);

  @$pb.TagNumber(7)
  ComponentVersion get pob => $_getN(6);
  @$pb.TagNumber(7)
  set pob(ComponentVersion value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPob() => $_has(6);
  @$pb.TagNumber(7)
  void clearPob() => $_clearField(7);
  @$pb.TagNumber(7)
  ComponentVersion ensurePob() => $_ensure(6);
}

class DoctorRequest extends $pb.GeneratedMessage {
  factory DoctorRequest() => DoctorRequest._();

  DoctorRequest._();

  factory DoctorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DoctorRequest()..mergeFromBuffer(data, registry);
  factory DoctorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DoctorRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DoctorRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: DoctorRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DoctorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DoctorRequest copyWith(void Function(DoctorRequest) updates) =>
      super.copyWith((message) => updates(message as DoctorRequest))
          as DoctorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DoctorRequest() / DoctorRequest.new instead')
  static DoctorRequest create() => DoctorRequest._();
  static $pb.GeneratedMessage $_createMessage() => DoctorRequest._();
  @$core.override
  DoctorRequest createEmptyInstance() => DoctorRequest._();
  @$core.pragma('dart2js:noInline')
  static DoctorRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DoctorRequest>(
          DoctorRequest.$_createMessage);
  static DoctorRequest? _defaultInstance;
}

class DoctorResponse extends $pb.GeneratedMessage {
  factory DoctorResponse({
    $core.String? status,
    $core.String? version,
    $core.String? protocolVersion,
    $core.String? os,
    $core.String? arch,
    $core.String? goVersion,
    $core.String? executable,
    $core.String? commit,
    $core.bool? modified,
    $core.String? dataId,
    $core.String? dataSha256,
    $core.String? treeVersion,
    $core.String? pobCommit,
    $core.bool? restartRequired,
    $core.Iterable<$core.String>? issues,
    DoctorServer? server,
    ComponentVersion? engineUpdate,
    ComponentVersion? pob,
  }) {
    final result = DoctorResponse._();
    if (status != null) result.status = status;
    if (version != null) result.version = version;
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (os != null) result.os = os;
    if (arch != null) result.arch = arch;
    if (goVersion != null) result.goVersion = goVersion;
    if (executable != null) result.executable = executable;
    if (commit != null) result.commit = commit;
    if (modified != null) result.modified = modified;
    if (dataId != null) result.dataId = dataId;
    if (dataSha256 != null) result.dataSha256 = dataSha256;
    if (treeVersion != null) result.treeVersion = treeVersion;
    if (pobCommit != null) result.pobCommit = pobCommit;
    if (restartRequired != null) result.restartRequired = restartRequired;
    if (issues != null) result.issues.addAll(issues);
    if (server != null) result.server = server;
    if (engineUpdate != null) result.engineUpdate = engineUpdate;
    if (pob != null) result.pob = pob;
    return result;
  }

  DoctorResponse._();

  factory DoctorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DoctorResponse()..mergeFromBuffer(data, registry);
  factory DoctorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DoctorResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DoctorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: DoctorResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'protocolVersion')
    ..aOS(4, _omitFieldNames ? '' : 'os')
    ..aOS(5, _omitFieldNames ? '' : 'arch')
    ..aOS(6, _omitFieldNames ? '' : 'goVersion')
    ..aOS(7, _omitFieldNames ? '' : 'executable')
    ..aOS(8, _omitFieldNames ? '' : 'commit')
    ..aOB(9, _omitFieldNames ? '' : 'modified')
    ..aOS(10, _omitFieldNames ? '' : 'dataId')
    ..aOS(11, _omitFieldNames ? '' : 'dataSha256')
    ..aOS(12, _omitFieldNames ? '' : 'treeVersion')
    ..aOS(13, _omitFieldNames ? '' : 'pobCommit')
    ..aOB(14, _omitFieldNames ? '' : 'restartRequired')
    ..pPS(15, _omitFieldNames ? '' : 'issues')
    ..aOM<DoctorServer>(16, _omitFieldNames ? '' : 'server',
        subBuilder: DoctorServer.$_createMessage)
    ..aOM<ComponentVersion>(17, _omitFieldNames ? '' : 'engineUpdate',
        subBuilder: ComponentVersion.$_createMessage)
    ..aOM<ComponentVersion>(18, _omitFieldNames ? '' : 'pob',
        subBuilder: ComponentVersion.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DoctorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DoctorResponse copyWith(void Function(DoctorResponse) updates) =>
      super.copyWith((message) => updates(message as DoctorResponse))
          as DoctorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DoctorResponse() / DoctorResponse.new instead')
  static DoctorResponse create() => DoctorResponse._();
  static $pb.GeneratedMessage $_createMessage() => DoctorResponse._();
  @$core.override
  DoctorResponse createEmptyInstance() => DoctorResponse._();
  @$core.pragma('dart2js:noInline')
  static DoctorResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DoctorResponse>(
          DoctorResponse.$_createMessage);
  static DoctorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get protocolVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set protocolVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProtocolVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearProtocolVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get os => $_getSZ(3);
  @$pb.TagNumber(4)
  set os($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOs() => $_has(3);
  @$pb.TagNumber(4)
  void clearOs() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get arch => $_getSZ(4);
  @$pb.TagNumber(5)
  set arch($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasArch() => $_has(4);
  @$pb.TagNumber(5)
  void clearArch() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get goVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set goVersion($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGoVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearGoVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get executable => $_getSZ(6);
  @$pb.TagNumber(7)
  set executable($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExecutable() => $_has(6);
  @$pb.TagNumber(7)
  void clearExecutable() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get commit => $_getSZ(7);
  @$pb.TagNumber(8)
  set commit($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCommit() => $_has(7);
  @$pb.TagNumber(8)
  void clearCommit() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get modified => $_getBF(8);
  @$pb.TagNumber(9)
  set modified($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasModified() => $_has(8);
  @$pb.TagNumber(9)
  void clearModified() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get dataId => $_getSZ(9);
  @$pb.TagNumber(10)
  set dataId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDataId() => $_has(9);
  @$pb.TagNumber(10)
  void clearDataId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get dataSha256 => $_getSZ(10);
  @$pb.TagNumber(11)
  set dataSha256($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDataSha256() => $_has(10);
  @$pb.TagNumber(11)
  void clearDataSha256() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get treeVersion => $_getSZ(11);
  @$pb.TagNumber(12)
  set treeVersion($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTreeVersion() => $_has(11);
  @$pb.TagNumber(12)
  void clearTreeVersion() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get pobCommit => $_getSZ(12);
  @$pb.TagNumber(13)
  set pobCommit($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPobCommit() => $_has(12);
  @$pb.TagNumber(13)
  void clearPobCommit() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get restartRequired => $_getBF(13);
  @$pb.TagNumber(14)
  set restartRequired($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRestartRequired() => $_has(13);
  @$pb.TagNumber(14)
  void clearRestartRequired() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbList<$core.String> get issues => $_getList(14);

  @$pb.TagNumber(16)
  DoctorServer get server => $_getN(15);
  @$pb.TagNumber(16)
  set server(DoctorServer value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasServer() => $_has(15);
  @$pb.TagNumber(16)
  void clearServer() => $_clearField(16);
  @$pb.TagNumber(16)
  DoctorServer ensureServer() => $_ensure(15);

  @$pb.TagNumber(17)
  ComponentVersion get engineUpdate => $_getN(16);
  @$pb.TagNumber(17)
  set engineUpdate(ComponentVersion value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasEngineUpdate() => $_has(16);
  @$pb.TagNumber(17)
  void clearEngineUpdate() => $_clearField(17);
  @$pb.TagNumber(17)
  ComponentVersion ensureEngineUpdate() => $_ensure(16);

  @$pb.TagNumber(18)
  ComponentVersion get pob => $_getN(17);
  @$pb.TagNumber(18)
  set pob(ComponentVersion value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasPob() => $_has(17);
  @$pb.TagNumber(18)
  void clearPob() => $_clearField(18);
  @$pb.TagNumber(18)
  ComponentVersion ensurePob() => $_ensure(17);
}

class ComponentVersion extends $pb.GeneratedMessage {
  factory ComponentVersion({
    $core.String? status,
    $core.String? installedVersion,
    $core.String? latestVersion,
    $core.String? releaseUrl,
    $core.String? message,
    $core.bool? restartRequired,
    $core.String? installedCommit,
    $core.String? runningVersion,
    $core.String? runningCommit,
    $core.String? previousVersion,
    $core.String? previousCommit,
  }) {
    final result = ComponentVersion._();
    if (status != null) result.status = status;
    if (installedVersion != null) result.installedVersion = installedVersion;
    if (latestVersion != null) result.latestVersion = latestVersion;
    if (releaseUrl != null) result.releaseUrl = releaseUrl;
    if (message != null) result.message = message;
    if (restartRequired != null) result.restartRequired = restartRequired;
    if (installedCommit != null) result.installedCommit = installedCommit;
    if (runningVersion != null) result.runningVersion = runningVersion;
    if (runningCommit != null) result.runningCommit = runningCommit;
    if (previousVersion != null) result.previousVersion = previousVersion;
    if (previousCommit != null) result.previousCommit = previousCommit;
    return result;
  }

  ComponentVersion._();

  factory ComponentVersion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ComponentVersion()..mergeFromBuffer(data, registry);
  factory ComponentVersion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ComponentVersion()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComponentVersion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: ComponentVersion.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'installedVersion')
    ..aOS(3, _omitFieldNames ? '' : 'latestVersion')
    ..aOS(4, _omitFieldNames ? '' : 'releaseUrl')
    ..aOS(5, _omitFieldNames ? '' : 'message')
    ..aOB(6, _omitFieldNames ? '' : 'restartRequired')
    ..aOS(7, _omitFieldNames ? '' : 'installedCommit')
    ..aOS(8, _omitFieldNames ? '' : 'runningVersion')
    ..aOS(9, _omitFieldNames ? '' : 'runningCommit')
    ..aOS(10, _omitFieldNames ? '' : 'previousVersion')
    ..aOS(11, _omitFieldNames ? '' : 'previousCommit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComponentVersion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComponentVersion copyWith(void Function(ComponentVersion) updates) =>
      super.copyWith((message) => updates(message as ComponentVersion))
          as ComponentVersion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ComponentVersion() / ComponentVersion.new instead')
  static ComponentVersion create() => ComponentVersion._();
  static $pb.GeneratedMessage $_createMessage() => ComponentVersion._();
  @$core.override
  ComponentVersion createEmptyInstance() => ComponentVersion._();
  @$core.pragma('dart2js:noInline')
  static ComponentVersion getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ComponentVersion>(
          ComponentVersion.$_createMessage);
  static ComponentVersion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get installedVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set installedVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInstalledVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearInstalledVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get latestVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set latestVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatestVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatestVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get releaseUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set releaseUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReleaseUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearReleaseUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get message => $_getSZ(4);
  @$pb.TagNumber(5)
  set message($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessage() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get restartRequired => $_getBF(5);
  @$pb.TagNumber(6)
  set restartRequired($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRestartRequired() => $_has(5);
  @$pb.TagNumber(6)
  void clearRestartRequired() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get installedCommit => $_getSZ(6);
  @$pb.TagNumber(7)
  set installedCommit($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasInstalledCommit() => $_has(6);
  @$pb.TagNumber(7)
  void clearInstalledCommit() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get runningVersion => $_getSZ(7);
  @$pb.TagNumber(8)
  set runningVersion($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRunningVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearRunningVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get runningCommit => $_getSZ(8);
  @$pb.TagNumber(9)
  set runningCommit($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRunningCommit() => $_has(8);
  @$pb.TagNumber(9)
  void clearRunningCommit() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get previousVersion => $_getSZ(9);
  @$pb.TagNumber(10)
  set previousVersion($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPreviousVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearPreviousVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get previousCommit => $_getSZ(10);
  @$pb.TagNumber(11)
  set previousCommit($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPreviousCommit() => $_has(10);
  @$pb.TagNumber(11)
  void clearPreviousCommit() => $_clearField(11);
}

class DoctorServer extends $pb.GeneratedMessage {
  factory DoctorServer({
    $core.String? state,
    $core.String? mode,
    $core.String? storageMode,
    $core.String? storagePath,
    $fixnum.Int64? storageBytes,
    $core.int? clients,
    $core.int? activeTasks,
  }) {
    final result = DoctorServer._();
    if (state != null) result.state = state;
    if (mode != null) result.mode = mode;
    if (storageMode != null) result.storageMode = storageMode;
    if (storagePath != null) result.storagePath = storagePath;
    if (storageBytes != null) result.storageBytes = storageBytes;
    if (clients != null) result.clients = clients;
    if (activeTasks != null) result.activeTasks = activeTasks;
    return result;
  }

  DoctorServer._();

  factory DoctorServer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DoctorServer()..mergeFromBuffer(data, registry);
  factory DoctorServer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DoctorServer()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DoctorServer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pob2.v1'),
      createEmptyInstance: DoctorServer.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'state')
    ..aOS(2, _omitFieldNames ? '' : 'mode')
    ..aOS(3, _omitFieldNames ? '' : 'storageMode')
    ..aOS(4, _omitFieldNames ? '' : 'storagePath')
    ..aInt64(5, _omitFieldNames ? '' : 'storageBytes')
    ..aI(6, _omitFieldNames ? '' : 'clients', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'activeTasks',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DoctorServer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DoctorServer copyWith(void Function(DoctorServer) updates) =>
      super.copyWith((message) => updates(message as DoctorServer))
          as DoctorServer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DoctorServer() / DoctorServer.new instead')
  static DoctorServer create() => DoctorServer._();
  static $pb.GeneratedMessage $_createMessage() => DoctorServer._();
  @$core.override
  DoctorServer createEmptyInstance() => DoctorServer._();
  @$core.pragma('dart2js:noInline')
  static DoctorServer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DoctorServer>(
          DoctorServer.$_createMessage);
  static DoctorServer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get state => $_getSZ(0);
  @$pb.TagNumber(1)
  set state($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mode => $_getSZ(1);
  @$pb.TagNumber(2)
  set mode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get storageMode => $_getSZ(2);
  @$pb.TagNumber(3)
  set storageMode($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStorageMode() => $_has(2);
  @$pb.TagNumber(3)
  void clearStorageMode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get storagePath => $_getSZ(3);
  @$pb.TagNumber(4)
  set storagePath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStoragePath() => $_has(3);
  @$pb.TagNumber(4)
  void clearStoragePath() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get storageBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set storageBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStorageBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearStorageBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get clients => $_getIZ(5);
  @$pb.TagNumber(6)
  set clients($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasClients() => $_has(5);
  @$pb.TagNumber(6)
  void clearClients() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get activeTasks => $_getIZ(6);
  @$pb.TagNumber(7)
  set activeTasks($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActiveTasks() => $_has(6);
  @$pb.TagNumber(7)
  void clearActiveTasks() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
