// This is a generated file - do not edit.
//
// Generated from pob2/v1/session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'build.pb.dart' as $2;
import 'catalog.pb.dart' as $3;
import 'maintenance.pb.dart' as $1;
import 'session.pb.dart' as $0;

export 'session.pb.dart';

/// SessionService предоставляет общий сервис сессий первого этапа.
@$pb.GrpcServiceName('pob2.v1.SessionService')
class SessionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SessionServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetServerInfoResponse> getServerInfo(
    $0.GetServerInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getServerInfo, request, options: options);
  }

  $grpc.ResponseFuture<$1.UpdateResponse> update(
    $1.UpdateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$update, request, options: options);
  }

  $grpc.ResponseFuture<$1.DoctorResponse> doctor(
    $1.DoctorRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$doctor, request, options: options);
  }

  $grpc.ResponseFuture<$0.CreateSessionResponse> createSession(
    $0.CreateSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.CreateSessionFromXmlResponse> createSessionFromXml(
    $0.CreateSessionFromXmlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createSessionFromXml, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetSnapshotResponse> getSnapshot(
    $0.GetSnapshotRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSnapshot, request, options: options);
  }

  $grpc.ResponseFuture<$0.RenameBuildResponse> renameBuild(
    $0.RenameBuildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$renameBuild, request, options: options);
  }

  $grpc.ResponseFuture<$0.ApplyBuildResponse> applyBuild(
    $0.ApplyBuildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$applyBuild, request, options: options);
  }

  $grpc.ResponseStream<$0.CalculateBuildResponse> calculateBuild(
    $0.CalculateBuildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$calculateBuild, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CompareBuildResponse> compareBuild(
    $0.CompareBuildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$compareBuild, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetTreeGeometryResponse> getTreeGeometry(
    $2.GetTreeGeometryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTreeGeometry, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetTreeNodeTooltipResponse> getTreeNodeTooltip(
    $2.GetTreeNodeTooltipRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTreeNodeTooltip, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetBuildReportResponse> getBuildReport(
    $2.GetBuildReportRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBuildReport, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetTreePowerResponse> getTreePower(
    $2.GetTreePowerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTreePower, request, options: options);
  }

  $grpc.ResponseStream<$2.WatchTreePowerResponse> watchTreePower(
    $2.WatchTreePowerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchTreePower, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$2.GetEquipmentDetailsResponse> getEquipmentDetails(
    $2.GetEquipmentDetailsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getEquipmentDetails, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetTreeTextureResponse> getTreeTexture(
    $2.GetTreeTextureRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTreeTexture, request, options: options);
  }

  $grpc.ResponseStream<$2.GetTreeTexturesResponse> getTreeTextures(
    $2.GetTreeTexturesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$getTreeTextures, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$3.GetCatalogResponse> getCatalog(
    $3.GetCatalogRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCatalog, request, options: options);
  }

  $grpc.ResponseFuture<$3.PreviewSupportResponse> previewSupport(
    $3.PreviewSupportRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$previewSupport, request, options: options);
  }

  $grpc.ResponseFuture<$0.ExportBuildResponse> exportBuild(
    $0.ExportBuildRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exportBuild, request, options: options);
  }

  $grpc.ResponseStream<$0.WatchSessionResponse> watchSession(
    $0.WatchSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchSession, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.WatchServerResponse> watchServer(
    $0.WatchServerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchServer, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.WatchEditorResponse> watchEditor(
    $0.WatchEditorRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchEditor, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CallEditorResponse> callEditor(
    $0.CallEditorRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$callEditor, request, options: options);
  }

  $grpc.ResponseFuture<$0.ReplyEditorResponse> replyEditor(
    $0.ReplyEditorRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$replyEditor, request, options: options);
  }

  $grpc.ResponseFuture<$0.ShutdownResponse> shutdown(
    $0.ShutdownRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$shutdown, request, options: options);
  }

  $grpc.ResponseFuture<$0.RegisterClientResponse> registerClient(
    $0.RegisterClientRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$registerClient, request, options: options);
  }

  $grpc.ResponseFuture<$0.HeartbeatResponse> heartbeat(
    $0.HeartbeatRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$heartbeat, request, options: options);
  }

  $grpc.ResponseFuture<$0.ReleaseClientResponse> releaseClient(
    $0.ReleaseClientRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$releaseClient, request, options: options);
  }

  // method descriptors

  static final _$getServerInfo =
      $grpc.ClientMethod<$0.GetServerInfoRequest, $0.GetServerInfoResponse>(
          '/pob2.v1.SessionService/GetServerInfo',
          ($0.GetServerInfoRequest value) => value.writeToBuffer(),
          $0.GetServerInfoResponse.fromBuffer);
  static final _$update =
      $grpc.ClientMethod<$1.UpdateRequest, $1.UpdateResponse>(
          '/pob2.v1.SessionService/Update',
          ($1.UpdateRequest value) => value.writeToBuffer(),
          $1.UpdateResponse.fromBuffer);
  static final _$doctor =
      $grpc.ClientMethod<$1.DoctorRequest, $1.DoctorResponse>(
          '/pob2.v1.SessionService/Doctor',
          ($1.DoctorRequest value) => value.writeToBuffer(),
          $1.DoctorResponse.fromBuffer);
  static final _$createSession =
      $grpc.ClientMethod<$0.CreateSessionRequest, $0.CreateSessionResponse>(
          '/pob2.v1.SessionService/CreateSession',
          ($0.CreateSessionRequest value) => value.writeToBuffer(),
          $0.CreateSessionResponse.fromBuffer);
  static final _$createSessionFromXml = $grpc.ClientMethod<
          $0.CreateSessionFromXmlRequest, $0.CreateSessionFromXmlResponse>(
      '/pob2.v1.SessionService/CreateSessionFromXml',
      ($0.CreateSessionFromXmlRequest value) => value.writeToBuffer(),
      $0.CreateSessionFromXmlResponse.fromBuffer);
  static final _$getSnapshot =
      $grpc.ClientMethod<$0.GetSnapshotRequest, $0.GetSnapshotResponse>(
          '/pob2.v1.SessionService/GetSnapshot',
          ($0.GetSnapshotRequest value) => value.writeToBuffer(),
          $0.GetSnapshotResponse.fromBuffer);
  static final _$renameBuild =
      $grpc.ClientMethod<$0.RenameBuildRequest, $0.RenameBuildResponse>(
          '/pob2.v1.SessionService/RenameBuild',
          ($0.RenameBuildRequest value) => value.writeToBuffer(),
          $0.RenameBuildResponse.fromBuffer);
  static final _$applyBuild =
      $grpc.ClientMethod<$0.ApplyBuildRequest, $0.ApplyBuildResponse>(
          '/pob2.v1.SessionService/ApplyBuild',
          ($0.ApplyBuildRequest value) => value.writeToBuffer(),
          $0.ApplyBuildResponse.fromBuffer);
  static final _$calculateBuild =
      $grpc.ClientMethod<$0.CalculateBuildRequest, $0.CalculateBuildResponse>(
          '/pob2.v1.SessionService/CalculateBuild',
          ($0.CalculateBuildRequest value) => value.writeToBuffer(),
          $0.CalculateBuildResponse.fromBuffer);
  static final _$compareBuild =
      $grpc.ClientMethod<$0.CompareBuildRequest, $0.CompareBuildResponse>(
          '/pob2.v1.SessionService/CompareBuild',
          ($0.CompareBuildRequest value) => value.writeToBuffer(),
          $0.CompareBuildResponse.fromBuffer);
  static final _$getTreeGeometry =
      $grpc.ClientMethod<$2.GetTreeGeometryRequest, $2.GetTreeGeometryResponse>(
          '/pob2.v1.SessionService/GetTreeGeometry',
          ($2.GetTreeGeometryRequest value) => value.writeToBuffer(),
          $2.GetTreeGeometryResponse.fromBuffer);
  static final _$getTreeNodeTooltip = $grpc.ClientMethod<
          $2.GetTreeNodeTooltipRequest, $2.GetTreeNodeTooltipResponse>(
      '/pob2.v1.SessionService/GetTreeNodeTooltip',
      ($2.GetTreeNodeTooltipRequest value) => value.writeToBuffer(),
      $2.GetTreeNodeTooltipResponse.fromBuffer);
  static final _$getBuildReport =
      $grpc.ClientMethod<$2.GetBuildReportRequest, $2.GetBuildReportResponse>(
          '/pob2.v1.SessionService/GetBuildReport',
          ($2.GetBuildReportRequest value) => value.writeToBuffer(),
          $2.GetBuildReportResponse.fromBuffer);
  static final _$getTreePower =
      $grpc.ClientMethod<$2.GetTreePowerRequest, $2.GetTreePowerResponse>(
          '/pob2.v1.SessionService/GetTreePower',
          ($2.GetTreePowerRequest value) => value.writeToBuffer(),
          $2.GetTreePowerResponse.fromBuffer);
  static final _$watchTreePower =
      $grpc.ClientMethod<$2.WatchTreePowerRequest, $2.WatchTreePowerResponse>(
          '/pob2.v1.SessionService/WatchTreePower',
          ($2.WatchTreePowerRequest value) => value.writeToBuffer(),
          $2.WatchTreePowerResponse.fromBuffer);
  static final _$getEquipmentDetails = $grpc.ClientMethod<
          $2.GetEquipmentDetailsRequest, $2.GetEquipmentDetailsResponse>(
      '/pob2.v1.SessionService/GetEquipmentDetails',
      ($2.GetEquipmentDetailsRequest value) => value.writeToBuffer(),
      $2.GetEquipmentDetailsResponse.fromBuffer);
  static final _$getTreeTexture =
      $grpc.ClientMethod<$2.GetTreeTextureRequest, $2.GetTreeTextureResponse>(
          '/pob2.v1.SessionService/GetTreeTexture',
          ($2.GetTreeTextureRequest value) => value.writeToBuffer(),
          $2.GetTreeTextureResponse.fromBuffer);
  static final _$getTreeTextures =
      $grpc.ClientMethod<$2.GetTreeTexturesRequest, $2.GetTreeTexturesResponse>(
          '/pob2.v1.SessionService/GetTreeTextures',
          ($2.GetTreeTexturesRequest value) => value.writeToBuffer(),
          $2.GetTreeTexturesResponse.fromBuffer);
  static final _$getCatalog =
      $grpc.ClientMethod<$3.GetCatalogRequest, $3.GetCatalogResponse>(
          '/pob2.v1.SessionService/GetCatalog',
          ($3.GetCatalogRequest value) => value.writeToBuffer(),
          $3.GetCatalogResponse.fromBuffer);
  static final _$previewSupport =
      $grpc.ClientMethod<$3.PreviewSupportRequest, $3.PreviewSupportResponse>(
          '/pob2.v1.SessionService/PreviewSupport',
          ($3.PreviewSupportRequest value) => value.writeToBuffer(),
          $3.PreviewSupportResponse.fromBuffer);
  static final _$exportBuild =
      $grpc.ClientMethod<$0.ExportBuildRequest, $0.ExportBuildResponse>(
          '/pob2.v1.SessionService/ExportBuild',
          ($0.ExportBuildRequest value) => value.writeToBuffer(),
          $0.ExportBuildResponse.fromBuffer);
  static final _$watchSession =
      $grpc.ClientMethod<$0.WatchSessionRequest, $0.WatchSessionResponse>(
          '/pob2.v1.SessionService/WatchSession',
          ($0.WatchSessionRequest value) => value.writeToBuffer(),
          $0.WatchSessionResponse.fromBuffer);
  static final _$watchServer =
      $grpc.ClientMethod<$0.WatchServerRequest, $0.WatchServerResponse>(
          '/pob2.v1.SessionService/WatchServer',
          ($0.WatchServerRequest value) => value.writeToBuffer(),
          $0.WatchServerResponse.fromBuffer);
  static final _$watchEditor =
      $grpc.ClientMethod<$0.WatchEditorRequest, $0.WatchEditorResponse>(
          '/pob2.v1.SessionService/WatchEditor',
          ($0.WatchEditorRequest value) => value.writeToBuffer(),
          $0.WatchEditorResponse.fromBuffer);
  static final _$callEditor =
      $grpc.ClientMethod<$0.CallEditorRequest, $0.CallEditorResponse>(
          '/pob2.v1.SessionService/CallEditor',
          ($0.CallEditorRequest value) => value.writeToBuffer(),
          $0.CallEditorResponse.fromBuffer);
  static final _$replyEditor =
      $grpc.ClientMethod<$0.ReplyEditorRequest, $0.ReplyEditorResponse>(
          '/pob2.v1.SessionService/ReplyEditor',
          ($0.ReplyEditorRequest value) => value.writeToBuffer(),
          $0.ReplyEditorResponse.fromBuffer);
  static final _$shutdown =
      $grpc.ClientMethod<$0.ShutdownRequest, $0.ShutdownResponse>(
          '/pob2.v1.SessionService/Shutdown',
          ($0.ShutdownRequest value) => value.writeToBuffer(),
          $0.ShutdownResponse.fromBuffer);
  static final _$registerClient =
      $grpc.ClientMethod<$0.RegisterClientRequest, $0.RegisterClientResponse>(
          '/pob2.v1.SessionService/RegisterClient',
          ($0.RegisterClientRequest value) => value.writeToBuffer(),
          $0.RegisterClientResponse.fromBuffer);
  static final _$heartbeat =
      $grpc.ClientMethod<$0.HeartbeatRequest, $0.HeartbeatResponse>(
          '/pob2.v1.SessionService/Heartbeat',
          ($0.HeartbeatRequest value) => value.writeToBuffer(),
          $0.HeartbeatResponse.fromBuffer);
  static final _$releaseClient =
      $grpc.ClientMethod<$0.ReleaseClientRequest, $0.ReleaseClientResponse>(
          '/pob2.v1.SessionService/ReleaseClient',
          ($0.ReleaseClientRequest value) => value.writeToBuffer(),
          $0.ReleaseClientResponse.fromBuffer);
}

@$pb.GrpcServiceName('pob2.v1.SessionService')
abstract class SessionServiceBase extends $grpc.Service {
  $core.String get $name => 'pob2.v1.SessionService';

  SessionServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetServerInfoRequest, $0.GetServerInfoResponse>(
            'GetServerInfo',
            getServerInfo_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetServerInfoRequest.fromBuffer(value),
            ($0.GetServerInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.UpdateRequest, $1.UpdateResponse>(
        'Update',
        update_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.UpdateRequest.fromBuffer(value),
        ($1.UpdateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.DoctorRequest, $1.DoctorResponse>(
        'Doctor',
        doctor_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.DoctorRequest.fromBuffer(value),
        ($1.DoctorResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateSessionRequest, $0.CreateSessionResponse>(
            'CreateSession',
            createSession_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateSessionRequest.fromBuffer(value),
            ($0.CreateSessionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateSessionFromXmlRequest,
            $0.CreateSessionFromXmlResponse>(
        'CreateSessionFromXml',
        createSessionFromXml_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateSessionFromXmlRequest.fromBuffer(value),
        ($0.CreateSessionFromXmlResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetSnapshotRequest, $0.GetSnapshotResponse>(
            'GetSnapshot',
            getSnapshot_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetSnapshotRequest.fromBuffer(value),
            ($0.GetSnapshotResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RenameBuildRequest, $0.RenameBuildResponse>(
            'RenameBuild',
            renameBuild_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RenameBuildRequest.fromBuffer(value),
            ($0.RenameBuildResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ApplyBuildRequest, $0.ApplyBuildResponse>(
        'ApplyBuild',
        applyBuild_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ApplyBuildRequest.fromBuffer(value),
        ($0.ApplyBuildResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CalculateBuildRequest,
            $0.CalculateBuildResponse>(
        'CalculateBuild',
        calculateBuild_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.CalculateBuildRequest.fromBuffer(value),
        ($0.CalculateBuildResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CompareBuildRequest, $0.CompareBuildResponse>(
            'CompareBuild',
            compareBuild_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CompareBuildRequest.fromBuffer(value),
            ($0.CompareBuildResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetTreeGeometryRequest,
            $2.GetTreeGeometryResponse>(
        'GetTreeGeometry',
        getTreeGeometry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.GetTreeGeometryRequest.fromBuffer(value),
        ($2.GetTreeGeometryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetTreeNodeTooltipRequest,
            $2.GetTreeNodeTooltipResponse>(
        'GetTreeNodeTooltip',
        getTreeNodeTooltip_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.GetTreeNodeTooltipRequest.fromBuffer(value),
        ($2.GetTreeNodeTooltipResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetBuildReportRequest,
            $2.GetBuildReportResponse>(
        'GetBuildReport',
        getBuildReport_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.GetBuildReportRequest.fromBuffer(value),
        ($2.GetBuildReportResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$2.GetTreePowerRequest, $2.GetTreePowerResponse>(
            'GetTreePower',
            getTreePower_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $2.GetTreePowerRequest.fromBuffer(value),
            ($2.GetTreePowerResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.WatchTreePowerRequest,
            $2.WatchTreePowerResponse>(
        'WatchTreePower',
        watchTreePower_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $2.WatchTreePowerRequest.fromBuffer(value),
        ($2.WatchTreePowerResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetEquipmentDetailsRequest,
            $2.GetEquipmentDetailsResponse>(
        'GetEquipmentDetails',
        getEquipmentDetails_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.GetEquipmentDetailsRequest.fromBuffer(value),
        ($2.GetEquipmentDetailsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetTreeTextureRequest,
            $2.GetTreeTextureResponse>(
        'GetTreeTexture',
        getTreeTexture_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.GetTreeTextureRequest.fromBuffer(value),
        ($2.GetTreeTextureResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetTreeTexturesRequest,
            $2.GetTreeTexturesResponse>(
        'GetTreeTextures',
        getTreeTextures_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $2.GetTreeTexturesRequest.fromBuffer(value),
        ($2.GetTreeTexturesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.GetCatalogRequest, $3.GetCatalogResponse>(
        'GetCatalog',
        getCatalog_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.GetCatalogRequest.fromBuffer(value),
        ($3.GetCatalogResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$3.PreviewSupportRequest,
            $3.PreviewSupportResponse>(
        'PreviewSupport',
        previewSupport_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $3.PreviewSupportRequest.fromBuffer(value),
        ($3.PreviewSupportResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ExportBuildRequest, $0.ExportBuildResponse>(
            'ExportBuild',
            exportBuild_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ExportBuildRequest.fromBuffer(value),
            ($0.ExportBuildResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.WatchSessionRequest, $0.WatchSessionResponse>(
            'WatchSession',
            watchSession_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.WatchSessionRequest.fromBuffer(value),
            ($0.WatchSessionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.WatchServerRequest, $0.WatchServerResponse>(
            'WatchServer',
            watchServer_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.WatchServerRequest.fromBuffer(value),
            ($0.WatchServerResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.WatchEditorRequest, $0.WatchEditorResponse>(
            'WatchEditor',
            watchEditor_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.WatchEditorRequest.fromBuffer(value),
            ($0.WatchEditorResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CallEditorRequest, $0.CallEditorResponse>(
        'CallEditor',
        callEditor_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CallEditorRequest.fromBuffer(value),
        ($0.CallEditorResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ReplyEditorRequest, $0.ReplyEditorResponse>(
            'ReplyEditor',
            replyEditor_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ReplyEditorRequest.fromBuffer(value),
            ($0.ReplyEditorResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ShutdownRequest, $0.ShutdownResponse>(
        'Shutdown',
        shutdown_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ShutdownRequest.fromBuffer(value),
        ($0.ShutdownResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RegisterClientRequest,
            $0.RegisterClientResponse>(
        'RegisterClient',
        registerClient_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RegisterClientRequest.fromBuffer(value),
        ($0.RegisterClientResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HeartbeatRequest, $0.HeartbeatResponse>(
        'Heartbeat',
        heartbeat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HeartbeatRequest.fromBuffer(value),
        ($0.HeartbeatResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ReleaseClientRequest, $0.ReleaseClientResponse>(
            'ReleaseClient',
            releaseClient_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ReleaseClientRequest.fromBuffer(value),
            ($0.ReleaseClientResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetServerInfoResponse> getServerInfo_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetServerInfoRequest> $request) async {
    return getServerInfo($call, await $request);
  }

  $async.Future<$0.GetServerInfoResponse> getServerInfo(
      $grpc.ServiceCall call, $0.GetServerInfoRequest request);

  $async.Future<$1.UpdateResponse> update_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.UpdateRequest> $request) async {
    return update($call, await $request);
  }

  $async.Future<$1.UpdateResponse> update(
      $grpc.ServiceCall call, $1.UpdateRequest request);

  $async.Future<$1.DoctorResponse> doctor_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.DoctorRequest> $request) async {
    return doctor($call, await $request);
  }

  $async.Future<$1.DoctorResponse> doctor(
      $grpc.ServiceCall call, $1.DoctorRequest request);

  $async.Future<$0.CreateSessionResponse> createSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateSessionRequest> $request) async {
    return createSession($call, await $request);
  }

  $async.Future<$0.CreateSessionResponse> createSession(
      $grpc.ServiceCall call, $0.CreateSessionRequest request);

  $async.Future<$0.CreateSessionFromXmlResponse> createSessionFromXml_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateSessionFromXmlRequest> $request) async {
    return createSessionFromXml($call, await $request);
  }

  $async.Future<$0.CreateSessionFromXmlResponse> createSessionFromXml(
      $grpc.ServiceCall call, $0.CreateSessionFromXmlRequest request);

  $async.Future<$0.GetSnapshotResponse> getSnapshot_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetSnapshotRequest> $request) async {
    return getSnapshot($call, await $request);
  }

  $async.Future<$0.GetSnapshotResponse> getSnapshot(
      $grpc.ServiceCall call, $0.GetSnapshotRequest request);

  $async.Future<$0.RenameBuildResponse> renameBuild_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RenameBuildRequest> $request) async {
    return renameBuild($call, await $request);
  }

  $async.Future<$0.RenameBuildResponse> renameBuild(
      $grpc.ServiceCall call, $0.RenameBuildRequest request);

  $async.Future<$0.ApplyBuildResponse> applyBuild_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ApplyBuildRequest> $request) async {
    return applyBuild($call, await $request);
  }

  $async.Future<$0.ApplyBuildResponse> applyBuild(
      $grpc.ServiceCall call, $0.ApplyBuildRequest request);

  $async.Stream<$0.CalculateBuildResponse> calculateBuild_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CalculateBuildRequest> $request) async* {
    yield* calculateBuild($call, await $request);
  }

  $async.Stream<$0.CalculateBuildResponse> calculateBuild(
      $grpc.ServiceCall call, $0.CalculateBuildRequest request);

  $async.Future<$0.CompareBuildResponse> compareBuild_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CompareBuildRequest> $request) async {
    return compareBuild($call, await $request);
  }

  $async.Future<$0.CompareBuildResponse> compareBuild(
      $grpc.ServiceCall call, $0.CompareBuildRequest request);

  $async.Future<$2.GetTreeGeometryResponse> getTreeGeometry_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.GetTreeGeometryRequest> $request) async {
    return getTreeGeometry($call, await $request);
  }

  $async.Future<$2.GetTreeGeometryResponse> getTreeGeometry(
      $grpc.ServiceCall call, $2.GetTreeGeometryRequest request);

  $async.Future<$2.GetTreeNodeTooltipResponse> getTreeNodeTooltip_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.GetTreeNodeTooltipRequest> $request) async {
    return getTreeNodeTooltip($call, await $request);
  }

  $async.Future<$2.GetTreeNodeTooltipResponse> getTreeNodeTooltip(
      $grpc.ServiceCall call, $2.GetTreeNodeTooltipRequest request);

  $async.Future<$2.GetBuildReportResponse> getBuildReport_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.GetBuildReportRequest> $request) async {
    return getBuildReport($call, await $request);
  }

  $async.Future<$2.GetBuildReportResponse> getBuildReport(
      $grpc.ServiceCall call, $2.GetBuildReportRequest request);

  $async.Future<$2.GetTreePowerResponse> getTreePower_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.GetTreePowerRequest> $request) async {
    return getTreePower($call, await $request);
  }

  $async.Future<$2.GetTreePowerResponse> getTreePower(
      $grpc.ServiceCall call, $2.GetTreePowerRequest request);

  $async.Stream<$2.WatchTreePowerResponse> watchTreePower_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.WatchTreePowerRequest> $request) async* {
    yield* watchTreePower($call, await $request);
  }

  $async.Stream<$2.WatchTreePowerResponse> watchTreePower(
      $grpc.ServiceCall call, $2.WatchTreePowerRequest request);

  $async.Future<$2.GetEquipmentDetailsResponse> getEquipmentDetails_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.GetEquipmentDetailsRequest> $request) async {
    return getEquipmentDetails($call, await $request);
  }

  $async.Future<$2.GetEquipmentDetailsResponse> getEquipmentDetails(
      $grpc.ServiceCall call, $2.GetEquipmentDetailsRequest request);

  $async.Future<$2.GetTreeTextureResponse> getTreeTexture_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.GetTreeTextureRequest> $request) async {
    return getTreeTexture($call, await $request);
  }

  $async.Future<$2.GetTreeTextureResponse> getTreeTexture(
      $grpc.ServiceCall call, $2.GetTreeTextureRequest request);

  $async.Stream<$2.GetTreeTexturesResponse> getTreeTextures_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$2.GetTreeTexturesRequest> $request) async* {
    yield* getTreeTextures($call, await $request);
  }

  $async.Stream<$2.GetTreeTexturesResponse> getTreeTextures(
      $grpc.ServiceCall call, $2.GetTreeTexturesRequest request);

  $async.Future<$3.GetCatalogResponse> getCatalog_Pre($grpc.ServiceCall $call,
      $async.Future<$3.GetCatalogRequest> $request) async {
    return getCatalog($call, await $request);
  }

  $async.Future<$3.GetCatalogResponse> getCatalog(
      $grpc.ServiceCall call, $3.GetCatalogRequest request);

  $async.Future<$3.PreviewSupportResponse> previewSupport_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$3.PreviewSupportRequest> $request) async {
    return previewSupport($call, await $request);
  }

  $async.Future<$3.PreviewSupportResponse> previewSupport(
      $grpc.ServiceCall call, $3.PreviewSupportRequest request);

  $async.Future<$0.ExportBuildResponse> exportBuild_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ExportBuildRequest> $request) async {
    return exportBuild($call, await $request);
  }

  $async.Future<$0.ExportBuildResponse> exportBuild(
      $grpc.ServiceCall call, $0.ExportBuildRequest request);

  $async.Stream<$0.WatchSessionResponse> watchSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.WatchSessionRequest> $request) async* {
    yield* watchSession($call, await $request);
  }

  $async.Stream<$0.WatchSessionResponse> watchSession(
      $grpc.ServiceCall call, $0.WatchSessionRequest request);

  $async.Stream<$0.WatchServerResponse> watchServer_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WatchServerRequest> $request) async* {
    yield* watchServer($call, await $request);
  }

  $async.Stream<$0.WatchServerResponse> watchServer(
      $grpc.ServiceCall call, $0.WatchServerRequest request);

  $async.Stream<$0.WatchEditorResponse> watchEditor_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WatchEditorRequest> $request) async* {
    yield* watchEditor($call, await $request);
  }

  $async.Stream<$0.WatchEditorResponse> watchEditor(
      $grpc.ServiceCall call, $0.WatchEditorRequest request);

  $async.Future<$0.CallEditorResponse> callEditor_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CallEditorRequest> $request) async {
    return callEditor($call, await $request);
  }

  $async.Future<$0.CallEditorResponse> callEditor(
      $grpc.ServiceCall call, $0.CallEditorRequest request);

  $async.Future<$0.ReplyEditorResponse> replyEditor_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ReplyEditorRequest> $request) async {
    return replyEditor($call, await $request);
  }

  $async.Future<$0.ReplyEditorResponse> replyEditor(
      $grpc.ServiceCall call, $0.ReplyEditorRequest request);

  $async.Future<$0.ShutdownResponse> shutdown_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ShutdownRequest> $request) async {
    return shutdown($call, await $request);
  }

  $async.Future<$0.ShutdownResponse> shutdown(
      $grpc.ServiceCall call, $0.ShutdownRequest request);

  $async.Future<$0.RegisterClientResponse> registerClient_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RegisterClientRequest> $request) async {
    return registerClient($call, await $request);
  }

  $async.Future<$0.RegisterClientResponse> registerClient(
      $grpc.ServiceCall call, $0.RegisterClientRequest request);

  $async.Future<$0.HeartbeatResponse> heartbeat_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HeartbeatRequest> $request) async {
    return heartbeat($call, await $request);
  }

  $async.Future<$0.HeartbeatResponse> heartbeat(
      $grpc.ServiceCall call, $0.HeartbeatRequest request);

  $async.Future<$0.ReleaseClientResponse> releaseClient_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ReleaseClientRequest> $request) async {
    return releaseClient($call, await $request);
  }

  $async.Future<$0.ReleaseClientResponse> releaseClient(
      $grpc.ServiceCall call, $0.ReleaseClientRequest request);
}
