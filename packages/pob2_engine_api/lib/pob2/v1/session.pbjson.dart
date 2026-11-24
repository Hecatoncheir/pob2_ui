// This is a generated file - do not edit.
//
// Generated from pob2/v1/session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use watchEditorRequestDescriptor instead')
const WatchEditorRequest$json = {
  '1': 'WatchEditorRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `WatchEditorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchEditorRequestDescriptor =
    $convert.base64Decode(
        'ChJXYXRjaEVkaXRvclJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklk');

@$core.Deprecated('Use callEditorRequestDescriptor instead')
const CallEditorRequest$json = {
  '1': 'CallEditorRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'tool', '3': 2, '4': 1, '5': 9, '10': 'tool'},
    {'1': 'arguments_json', '3': 3, '4': 1, '5': 9, '10': 'argumentsJson'},
  ],
};

/// Descriptor for `CallEditorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callEditorRequestDescriptor = $convert.base64Decode(
    'ChFDYWxsRWRpdG9yUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSEgoEdG'
    '9vbBgCIAEoCVIEdG9vbBIlCg5hcmd1bWVudHNfanNvbhgDIAEoCVINYXJndW1lbnRzSnNvbg==');

@$core.Deprecated('Use watchEditorResponseDescriptor instead')
const WatchEditorResponse$json = {
  '1': 'WatchEditorResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'tool', '3': 2, '4': 1, '5': 9, '10': 'tool'},
    {'1': 'arguments_json', '3': 3, '4': 1, '5': 9, '10': 'argumentsJson'},
    {'1': 'attached', '3': 4, '4': 1, '5': 8, '10': 'attached'},
  ],
};

/// Descriptor for `WatchEditorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchEditorResponseDescriptor = $convert.base64Decode(
    'ChNXYXRjaEVkaXRvclJlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZBISCg'
    'R0b29sGAIgASgJUgR0b29sEiUKDmFyZ3VtZW50c19qc29uGAMgASgJUg1hcmd1bWVudHNKc29u'
    'EhoKCGF0dGFjaGVkGAQgASgIUghhdHRhY2hlZA==');

@$core.Deprecated('Use callEditorResponseDescriptor instead')
const CallEditorResponse$json = {
  '1': 'CallEditorResponse',
  '2': [
    {'1': 'result_json', '3': 1, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `CallEditorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callEditorResponseDescriptor = $convert.base64Decode(
    'ChJDYWxsRWRpdG9yUmVzcG9uc2USHwoLcmVzdWx0X2pzb24YASABKAlSCnJlc3VsdEpzb24=');

@$core.Deprecated('Use replyEditorRequestDescriptor instead')
const ReplyEditorRequest$json = {
  '1': 'ReplyEditorRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'request_id', '3': 2, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'result_json', '3': 3, '4': 1, '5': 9, '10': 'resultJson'},
  ],
};

/// Descriptor for `ReplyEditorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List replyEditorRequestDescriptor = $convert.base64Decode(
    'ChJSZXBseUVkaXRvclJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh0KCn'
    'JlcXVlc3RfaWQYAiABKAlSCXJlcXVlc3RJZBIfCgtyZXN1bHRfanNvbhgDIAEoCVIKcmVzdWx0'
    'SnNvbg==');

@$core.Deprecated('Use replyEditorResponseDescriptor instead')
const ReplyEditorResponse$json = {
  '1': 'ReplyEditorResponse',
};

/// Descriptor for `ReplyEditorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List replyEditorResponseDescriptor =
    $convert.base64Decode('ChNSZXBseUVkaXRvclJlc3BvbnNl');

@$core.Deprecated('Use sessionSnapshotDescriptor instead')
const SessionSnapshot$json = {
  '1': 'SessionSnapshot',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'build_name', '3': 2, '4': 1, '5': 9, '10': 'buildName'},
    {'1': 'revision', '3': 3, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'build',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.BuildDocument',
      '10': 'build'
    },
  ],
};

/// Descriptor for `SessionSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionSnapshotDescriptor = $convert.base64Decode(
    'Cg9TZXNzaW9uU25hcHNob3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh0KCmJ1aW'
    'xkX25hbWUYAiABKAlSCWJ1aWxkTmFtZRIaCghyZXZpc2lvbhgDIAEoBFIIcmV2aXNpb24SLAoF'
    'YnVpbGQYBCABKAsyFi5wb2IyLnYxLkJ1aWxkRG9jdW1lbnRSBWJ1aWxk');

@$core.Deprecated('Use getServerInfoRequestDescriptor instead')
const GetServerInfoRequest$json = {
  '1': 'GetServerInfoRequest',
};

/// Descriptor for `GetServerInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getServerInfoRequestDescriptor =
    $convert.base64Decode('ChRHZXRTZXJ2ZXJJbmZvUmVxdWVzdA==');

@$core.Deprecated('Use getServerInfoResponseDescriptor instead')
const GetServerInfoResponse$json = {
  '1': 'GetServerInfoResponse',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'protocol_version', '3': 2, '4': 1, '5': 9, '10': 'protocolVersion'},
    {'1': 'capabilities', '3': 3, '4': 3, '5': 9, '10': 'capabilities'},
    {'1': 'state', '3': 4, '4': 1, '5': 9, '10': 'state'},
    {'1': 'instance_id', '3': 5, '4': 1, '5': 9, '10': 'instanceId'},
    {'1': 'mode', '3': 6, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'client_count', '3': 7, '4': 1, '5': 13, '10': 'clientCount'},
    {'1': 'active_tasks', '3': 8, '4': 1, '5': 13, '10': 'activeTasks'},
    {'1': 'lease_timeout_ms', '3': 9, '4': 1, '5': 4, '10': 'leaseTimeoutMs'},
    {'1': 'storage_mode', '3': 10, '4': 1, '5': 9, '10': 'storageMode'},
    {'1': 'storage_path', '3': 11, '4': 1, '5': 9, '10': 'storagePath'},
  ],
};

/// Descriptor for `GetServerInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getServerInfoResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTZXJ2ZXJJbmZvUmVzcG9uc2USGAoHdmVyc2lvbhgBIAEoCVIHdmVyc2lvbhIpChBwcm'
    '90b2NvbF92ZXJzaW9uGAIgASgJUg9wcm90b2NvbFZlcnNpb24SIgoMY2FwYWJpbGl0aWVzGAMg'
    'AygJUgxjYXBhYmlsaXRpZXMSFAoFc3RhdGUYBCABKAlSBXN0YXRlEh8KC2luc3RhbmNlX2lkGA'
    'UgASgJUgppbnN0YW5jZUlkEhIKBG1vZGUYBiABKAlSBG1vZGUSIQoMY2xpZW50X2NvdW50GAcg'
    'ASgNUgtjbGllbnRDb3VudBIhCgxhY3RpdmVfdGFza3MYCCABKA1SC2FjdGl2ZVRhc2tzEigKEG'
    'xlYXNlX3RpbWVvdXRfbXMYCSABKARSDmxlYXNlVGltZW91dE1zEiEKDHN0b3JhZ2VfbW9kZRgK'
    'IAEoCVILc3RvcmFnZU1vZGUSIQoMc3RvcmFnZV9wYXRoGAsgASgJUgtzdG9yYWdlUGF0aA==');

@$core.Deprecated('Use createSessionRequestDescriptor instead')
const CreateSessionRequest$json = {
  '1': 'CreateSessionRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'build_name', '3': 2, '4': 1, '5': 9, '10': 'buildName'},
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
  ],
};

/// Descriptor for `CreateSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSessionRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVTZXNzaW9uUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSHQ'
    'oKYnVpbGRfbmFtZRgCIAEoCVIJYnVpbGROYW1lEh0KCnJlcXVlc3RfaWQYAyABKAlSCXJlcXVl'
    'c3RJZA==');

@$core.Deprecated('Use createSessionResponseDescriptor instead')
const CreateSessionResponse$json = {
  '1': 'CreateSessionResponse',
  '2': [
    {
      '1': 'snapshot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SessionSnapshot',
      '10': 'snapshot'
    },
  ],
};

/// Descriptor for `CreateSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSessionResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVTZXNzaW9uUmVzcG9uc2USNAoIc25hcHNob3QYASABKAsyGC5wb2IyLnYxLlNlc3'
    'Npb25TbmFwc2hvdFIIc25hcHNob3Q=');

@$core.Deprecated('Use createSessionFromXmlRequestDescriptor instead')
const CreateSessionFromXmlRequest$json = {
  '1': 'CreateSessionFromXmlRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'build_name', '3': 2, '4': 1, '5': 9, '10': 'buildName'},
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'xml', '3': 4, '4': 1, '5': 9, '10': 'xml'},
  ],
};

/// Descriptor for `CreateSessionFromXmlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSessionFromXmlRequestDescriptor =
    $convert.base64Decode(
        'ChtDcmVhdGVTZXNzaW9uRnJvbVhtbFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2'
        'lvbklkEh0KCmJ1aWxkX25hbWUYAiABKAlSCWJ1aWxkTmFtZRIdCgpyZXF1ZXN0X2lkGAMgASgJ'
        'UglyZXF1ZXN0SWQSEAoDeG1sGAQgASgJUgN4bWw=');

@$core.Deprecated('Use createSessionFromXmlResponseDescriptor instead')
const CreateSessionFromXmlResponse$json = {
  '1': 'CreateSessionFromXmlResponse',
  '2': [
    {
      '1': 'snapshot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SessionSnapshot',
      '10': 'snapshot'
    },
  ],
};

/// Descriptor for `CreateSessionFromXmlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSessionFromXmlResponseDescriptor =
    $convert.base64Decode(
        'ChxDcmVhdGVTZXNzaW9uRnJvbVhtbFJlc3BvbnNlEjQKCHNuYXBzaG90GAEgASgLMhgucG9iMi'
        '52MS5TZXNzaW9uU25hcHNob3RSCHNuYXBzaG90');

@$core.Deprecated('Use getSnapshotRequestDescriptor instead')
const GetSnapshotRequest$json = {
  '1': 'GetSnapshotRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `GetSnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSnapshotRequestDescriptor =
    $convert.base64Decode(
        'ChJHZXRTbmFwc2hvdFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklk');

@$core.Deprecated('Use getSnapshotResponseDescriptor instead')
const GetSnapshotResponse$json = {
  '1': 'GetSnapshotResponse',
  '2': [
    {
      '1': 'snapshot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SessionSnapshot',
      '10': 'snapshot'
    },
  ],
};

/// Descriptor for `GetSnapshotResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSnapshotResponseDescriptor = $convert.base64Decode(
    'ChNHZXRTbmFwc2hvdFJlc3BvbnNlEjQKCHNuYXBzaG90GAEgASgLMhgucG9iMi52MS5TZXNzaW'
    '9uU25hcHNob3RSCHNuYXBzaG90');

@$core.Deprecated('Use renameBuildRequestDescriptor instead')
const RenameBuildRequest$json = {
  '1': 'RenameBuildRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'build_name', '3': 2, '4': 1, '5': 9, '10': 'buildName'},
    {
      '1': 'expected_revision',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'request_id', '3': 4, '4': 1, '5': 9, '10': 'requestId'},
  ],
};

/// Descriptor for `RenameBuildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List renameBuildRequestDescriptor = $convert.base64Decode(
    'ChJSZW5hbWVCdWlsZFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEh0KCm'
    'J1aWxkX25hbWUYAiABKAlSCWJ1aWxkTmFtZRIrChFleHBlY3RlZF9yZXZpc2lvbhgDIAEoBFIQ'
    'ZXhwZWN0ZWRSZXZpc2lvbhIdCgpyZXF1ZXN0X2lkGAQgASgJUglyZXF1ZXN0SWQ=');

@$core.Deprecated('Use renameBuildResponseDescriptor instead')
const RenameBuildResponse$json = {
  '1': 'RenameBuildResponse',
  '2': [
    {
      '1': 'snapshot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SessionSnapshot',
      '10': 'snapshot'
    },
  ],
};

/// Descriptor for `RenameBuildResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List renameBuildResponseDescriptor = $convert.base64Decode(
    'ChNSZW5hbWVCdWlsZFJlc3BvbnNlEjQKCHNuYXBzaG90GAEgASgLMhgucG9iMi52MS5TZXNzaW'
    '9uU25hcHNob3RSCHNuYXBzaG90');

@$core.Deprecated('Use watchSessionRequestDescriptor instead')
const WatchSessionRequest$json = {
  '1': 'WatchSessionRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'after_revision', '3': 2, '4': 1, '5': 4, '10': 'afterRevision'},
  ],
};

/// Descriptor for `WatchSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchSessionRequestDescriptor = $convert.base64Decode(
    'ChNXYXRjaFNlc3Npb25SZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIlCg'
    '5hZnRlcl9yZXZpc2lvbhgCIAEoBFINYWZ0ZXJSZXZpc2lvbg==');

@$core.Deprecated('Use watchSessionResponseDescriptor instead')
const WatchSessionResponse$json = {
  '1': 'WatchSessionResponse',
  '2': [
    {
      '1': 'snapshot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SessionSnapshot',
      '10': 'snapshot'
    },
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'changed_fields', '3': 4, '4': 3, '5': 9, '10': 'changedFields'},
    {
      '1': 'previous_build_name',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'previousBuildName'
    },
  ],
};

/// Descriptor for `WatchSessionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchSessionResponseDescriptor = $convert.base64Decode(
    'ChRXYXRjaFNlc3Npb25SZXNwb25zZRI0CghzbmFwc2hvdBgBIAEoCzIYLnBvYjIudjEuU2Vzc2'
    'lvblNuYXBzaG90UghzbmFwc2hvdBISCgRraW5kGAIgASgJUgRraW5kEh0KCnJlcXVlc3RfaWQY'
    'AyABKAlSCXJlcXVlc3RJZBIlCg5jaGFuZ2VkX2ZpZWxkcxgEIAMoCVINY2hhbmdlZEZpZWxkcx'
    'IuChNwcmV2aW91c19idWlsZF9uYW1lGAUgASgJUhFwcmV2aW91c0J1aWxkTmFtZQ==');

@$core.Deprecated('Use shutdownRequestDescriptor instead')
const ShutdownRequest$json = {
  '1': 'ShutdownRequest',
};

/// Descriptor for `ShutdownRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shutdownRequestDescriptor =
    $convert.base64Decode('Cg9TaHV0ZG93blJlcXVlc3Q=');

@$core.Deprecated('Use watchServerRequestDescriptor instead')
const WatchServerRequest$json = {
  '1': 'WatchServerRequest',
};

/// Descriptor for `WatchServerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchServerRequestDescriptor =
    $convert.base64Decode('ChJXYXRjaFNlcnZlclJlcXVlc3Q=');

@$core.Deprecated('Use watchServerResponseDescriptor instead')
const WatchServerResponse$json = {
  '1': 'WatchServerResponse',
  '2': [
    {'1': 'instance_id', '3': 1, '4': 1, '5': 9, '10': 'instanceId'},
    {'1': 'sequence', '3': 2, '4': 1, '5': 4, '10': 'sequence'},
    {'1': 'state', '3': 3, '4': 1, '5': 9, '10': 'state'},
    {'1': 'reason', '3': 4, '4': 1, '5': 9, '10': 'reason'},
    {
      '1': 'shutdown_timeout_ms',
      '3': 5,
      '4': 1,
      '5': 4,
      '10': 'shutdownTimeoutMs'
    },
  ],
};

/// Descriptor for `WatchServerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchServerResponseDescriptor = $convert.base64Decode(
    'ChNXYXRjaFNlcnZlclJlc3BvbnNlEh8KC2luc3RhbmNlX2lkGAEgASgJUgppbnN0YW5jZUlkEh'
    'oKCHNlcXVlbmNlGAIgASgEUghzZXF1ZW5jZRIUCgVzdGF0ZRgDIAEoCVIFc3RhdGUSFgoGcmVh'
    'c29uGAQgASgJUgZyZWFzb24SLgoTc2h1dGRvd25fdGltZW91dF9tcxgFIAEoBFIRc2h1dGRvd2'
    '5UaW1lb3V0TXM=');

@$core.Deprecated('Use shutdownResponseDescriptor instead')
const ShutdownResponse$json = {
  '1': 'ShutdownResponse',
};

/// Descriptor for `ShutdownResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shutdownResponseDescriptor =
    $convert.base64Decode('ChBTaHV0ZG93blJlc3BvbnNl');

@$core.Deprecated('Use registerClientRequestDescriptor instead')
const RegisterClientRequest$json = {
  '1': 'RegisterClientRequest',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
  ],
};

/// Descriptor for `RegisterClientRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerClientRequestDescriptor = $convert.base64Decode(
    'ChVSZWdpc3RlckNsaWVudFJlcXVlc3QSGwoJY2xpZW50X2lkGAEgASgJUghjbGllbnRJZBISCg'
    'RraW5kGAIgASgJUgRraW5k');

@$core.Deprecated('Use registerClientResponseDescriptor instead')
const RegisterClientResponse$json = {
  '1': 'RegisterClientResponse',
  '2': [
    {'1': 'lease_id', '3': 1, '4': 1, '5': 9, '10': 'leaseId'},
    {'1': 'lease_timeout_ms', '3': 2, '4': 1, '5': 4, '10': 'leaseTimeoutMs'},
  ],
};

/// Descriptor for `RegisterClientResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerClientResponseDescriptor =
    $convert.base64Decode(
        'ChZSZWdpc3RlckNsaWVudFJlc3BvbnNlEhkKCGxlYXNlX2lkGAEgASgJUgdsZWFzZUlkEigKEG'
        'xlYXNlX3RpbWVvdXRfbXMYAiABKARSDmxlYXNlVGltZW91dE1z');

@$core.Deprecated('Use heartbeatRequestDescriptor instead')
const HeartbeatRequest$json = {
  '1': 'HeartbeatRequest',
  '2': [
    {'1': 'lease_id', '3': 1, '4': 1, '5': 9, '10': 'leaseId'},
  ],
};

/// Descriptor for `HeartbeatRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatRequestDescriptor = $convert.base64Decode(
    'ChBIZWFydGJlYXRSZXF1ZXN0EhkKCGxlYXNlX2lkGAEgASgJUgdsZWFzZUlk');

@$core.Deprecated('Use heartbeatResponseDescriptor instead')
const HeartbeatResponse$json = {
  '1': 'HeartbeatResponse',
};

/// Descriptor for `HeartbeatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatResponseDescriptor =
    $convert.base64Decode('ChFIZWFydGJlYXRSZXNwb25zZQ==');

@$core.Deprecated('Use releaseClientRequestDescriptor instead')
const ReleaseClientRequest$json = {
  '1': 'ReleaseClientRequest',
  '2': [
    {'1': 'lease_id', '3': 1, '4': 1, '5': 9, '10': 'leaseId'},
  ],
};

/// Descriptor for `ReleaseClientRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List releaseClientRequestDescriptor =
    $convert.base64Decode(
        'ChRSZWxlYXNlQ2xpZW50UmVxdWVzdBIZCghsZWFzZV9pZBgBIAEoCVIHbGVhc2VJZA==');

@$core.Deprecated('Use releaseClientResponseDescriptor instead')
const ReleaseClientResponse$json = {
  '1': 'ReleaseClientResponse',
};

/// Descriptor for `ReleaseClientResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List releaseClientResponseDescriptor =
    $convert.base64Decode('ChVSZWxlYXNlQ2xpZW50UmVzcG9uc2U=');

@$core.Deprecated('Use applyBuildRequestDescriptor instead')
const ApplyBuildRequest$json = {
  '1': 'ApplyBuildRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'xml', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'xml'},
    {
      '1': 'edit',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.BuildEdit',
      '9': 0,
      '10': 'edit'
    },
  ],
  '8': [
    {'1': 'input'},
  ],
};

/// Descriptor for `ApplyBuildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyBuildRequestDescriptor = $convert.base64Decode(
    'ChFBcHBseUJ1aWxkUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSKwoRZX'
    'hwZWN0ZWRfcmV2aXNpb24YAiABKARSEGV4cGVjdGVkUmV2aXNpb24SHQoKcmVxdWVzdF9pZBgD'
    'IAEoCVIJcmVxdWVzdElkEhIKA3htbBgEIAEoCUgAUgN4bWwSKAoEZWRpdBgFIAEoCzISLnBvYj'
    'IudjEuQnVpbGRFZGl0SABSBGVkaXRCBwoFaW5wdXQ=');

@$core.Deprecated('Use applyBuildResponseDescriptor instead')
const ApplyBuildResponse$json = {
  '1': 'ApplyBuildResponse',
  '2': [
    {
      '1': 'snapshot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SessionSnapshot',
      '10': 'snapshot'
    },
  ],
};

/// Descriptor for `ApplyBuildResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyBuildResponseDescriptor = $convert.base64Decode(
    'ChJBcHBseUJ1aWxkUmVzcG9uc2USNAoIc25hcHNob3QYASABKAsyGC5wb2IyLnYxLlNlc3Npb2'
    '5TbmFwc2hvdFIIc25hcHNob3Q=');

@$core.Deprecated('Use calculateBuildRequestDescriptor instead')
const CalculateBuildRequest$json = {
  '1': 'CalculateBuildRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
  ],
};

/// Descriptor for `CalculateBuildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculateBuildRequestDescriptor = $convert.base64Decode(
    'ChVDYWxjdWxhdGVCdWlsZFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEi'
    'sKEWV4cGVjdGVkX3JldmlzaW9uGAIgASgEUhBleHBlY3RlZFJldmlzaW9uEh0KCnJlcXVlc3Rf'
    'aWQYAyABKAlSCXJlcXVlc3RJZA==');

@$core.Deprecated('Use calculateBuildResponseDescriptor instead')
const CalculateBuildResponse$json = {
  '1': 'CalculateBuildResponse',
  '2': [
    {'1': 'stage', '3': 1, '4': 1, '5': 9, '10': 'stage'},
    {
      '1': 'snapshot',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SessionSnapshot',
      '10': 'snapshot'
    },
  ],
};

/// Descriptor for `CalculateBuildResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculateBuildResponseDescriptor =
    $convert.base64Decode(
        'ChZDYWxjdWxhdGVCdWlsZFJlc3BvbnNlEhQKBXN0YWdlGAEgASgJUgVzdGFnZRI0CghzbmFwc2'
        'hvdBgCIAEoCzIYLnBvYjIudjEuU2Vzc2lvblNuYXBzaG90UghzbmFwc2hvdA==');

@$core.Deprecated('Use compareBuildRequestDescriptor instead')
const CompareBuildRequest$json = {
  '1': 'CompareBuildRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'xml', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'xml'},
    {
      '1': 'edit',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.BuildEdit',
      '9': 0,
      '10': 'edit'
    },
  ],
  '8': [
    {'1': 'input'},
  ],
};

/// Descriptor for `CompareBuildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compareBuildRequestDescriptor = $convert.base64Decode(
    'ChNDb21wYXJlQnVpbGRSZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIrCh'
    'FleHBlY3RlZF9yZXZpc2lvbhgCIAEoBFIQZXhwZWN0ZWRSZXZpc2lvbhISCgN4bWwYAyABKAlI'
    'AFIDeG1sEigKBGVkaXQYBCABKAsyEi5wb2IyLnYxLkJ1aWxkRWRpdEgAUgRlZGl0QgcKBWlucH'
    'V0');

@$core.Deprecated('Use compareBuildResponseDescriptor instead')
const CompareBuildResponse$json = {
  '1': 'CompareBuildResponse',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'comparison',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.BuildComparison',
      '10': 'comparison'
    },
    {
      '1': 'passive_change',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.PassiveChange',
      '10': 'passiveChange'
    },
  ],
};

/// Descriptor for `CompareBuildResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compareBuildResponseDescriptor = $convert.base64Decode(
    'ChRDb21wYXJlQnVpbGRSZXNwb25zZRIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW9uSWQSGg'
    'oIcmV2aXNpb24YAiABKARSCHJldmlzaW9uEjgKCmNvbXBhcmlzb24YAyABKAsyGC5wb2IyLnYx'
    'LkJ1aWxkQ29tcGFyaXNvblIKY29tcGFyaXNvbhI9Cg5wYXNzaXZlX2NoYW5nZRgEIAEoCzIWLn'
    'BvYjIudjEuUGFzc2l2ZUNoYW5nZVINcGFzc2l2ZUNoYW5nZQ==');

@$core.Deprecated('Use exportBuildRequestDescriptor instead')
const ExportBuildRequest$json = {
  '1': 'ExportBuildRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
  ],
};

/// Descriptor for `ExportBuildRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportBuildRequestDescriptor =
    $convert.base64Decode(
        'ChJFeHBvcnRCdWlsZFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklk');

@$core.Deprecated('Use exportBuildResponseDescriptor instead')
const ExportBuildResponse$json = {
  '1': 'ExportBuildResponse',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'xml', '3': 3, '4': 1, '5': 9, '10': 'xml'},
    {'1': 'input_sha256', '3': 4, '4': 1, '5': 9, '10': 'inputSha256'},
  ],
};

/// Descriptor for `ExportBuildResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportBuildResponseDescriptor = $convert.base64Decode(
    'ChNFeHBvcnRCdWlsZFJlc3BvbnNlEh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIaCg'
    'hyZXZpc2lvbhgCIAEoBFIIcmV2aXNpb24SEAoDeG1sGAMgASgJUgN4bWwSIQoMaW5wdXRfc2hh'
    'MjU2GAQgASgJUgtpbnB1dFNoYTI1Ng==');
