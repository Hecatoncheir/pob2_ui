// This is a generated file - do not edit.
//
// Generated from pob2/v1/workbench.proto.

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

import 'workbench.pb.dart' as $0;

export 'workbench.pb.dart';

/// Рабочая копия принадлежит одному процессу клиента и не записывает общую сессию.
@$pb.GrpcServiceName('pob2.v1.WorkbenchService')
class WorkbenchServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  WorkbenchServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ListWorkbenchToolsResponse> listWorkbenchTools(
    $0.ListWorkbenchToolsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listWorkbenchTools, request, options: options);
  }

  $grpc.ResponseFuture<$0.CallWorkbenchToolResponse> callWorkbenchTool(
    $0.CallWorkbenchToolRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$callWorkbenchTool, request, options: options);
  }

  // method descriptors

  static final _$listWorkbenchTools = $grpc.ClientMethod<
          $0.ListWorkbenchToolsRequest, $0.ListWorkbenchToolsResponse>(
      '/pob2.v1.WorkbenchService/ListWorkbenchTools',
      ($0.ListWorkbenchToolsRequest value) => value.writeToBuffer(),
      $0.ListWorkbenchToolsResponse.fromBuffer);
  static final _$callWorkbenchTool = $grpc.ClientMethod<
          $0.CallWorkbenchToolRequest, $0.CallWorkbenchToolResponse>(
      '/pob2.v1.WorkbenchService/CallWorkbenchTool',
      ($0.CallWorkbenchToolRequest value) => value.writeToBuffer(),
      $0.CallWorkbenchToolResponse.fromBuffer);
}

@$pb.GrpcServiceName('pob2.v1.WorkbenchService')
abstract class WorkbenchServiceBase extends $grpc.Service {
  $core.String get $name => 'pob2.v1.WorkbenchService';

  WorkbenchServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListWorkbenchToolsRequest,
            $0.ListWorkbenchToolsResponse>(
        'ListWorkbenchTools',
        listWorkbenchTools_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListWorkbenchToolsRequest.fromBuffer(value),
        ($0.ListWorkbenchToolsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CallWorkbenchToolRequest,
            $0.CallWorkbenchToolResponse>(
        'CallWorkbenchTool',
        callWorkbenchTool_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CallWorkbenchToolRequest.fromBuffer(value),
        ($0.CallWorkbenchToolResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListWorkbenchToolsResponse> listWorkbenchTools_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListWorkbenchToolsRequest> $request) async {
    return listWorkbenchTools($call, await $request);
  }

  $async.Future<$0.ListWorkbenchToolsResponse> listWorkbenchTools(
      $grpc.ServiceCall call, $0.ListWorkbenchToolsRequest request);

  $async.Future<$0.CallWorkbenchToolResponse> callWorkbenchTool_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CallWorkbenchToolRequest> $request) async {
    return callWorkbenchTool($call, await $request);
  }

  $async.Future<$0.CallWorkbenchToolResponse> callWorkbenchTool(
      $grpc.ServiceCall call, $0.CallWorkbenchToolRequest request);
}
