// This is a generated file - do not edit.
//
// Generated from pob2/v1/maintenance.proto.

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

@$core.Deprecated('Use updateRequestDescriptor instead')
const UpdateRequest$json = {
  '1': 'UpdateRequest',
  '2': [
    {'1': 'apply', '3': 1, '4': 1, '5': 8, '10': 'apply'},
    {'1': 'target', '3': 2, '4': 1, '5': 9, '10': 'target'},
  ],
};

/// Descriptor for `UpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateRequestDescriptor = $convert.base64Decode(
    'Cg1VcGRhdGVSZXF1ZXN0EhQKBWFwcGx5GAEgASgIUgVhcHBseRIWCgZ0YXJnZXQYAiABKAlSBn'
    'RhcmdldA==');

@$core.Deprecated('Use updateResponseDescriptor instead')
const UpdateResponse$json = {
  '1': 'UpdateResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'current_version', '3': 2, '4': 1, '5': 9, '10': 'currentVersion'},
    {'1': 'latest_version', '3': 3, '4': 1, '5': 9, '10': 'latestVersion'},
    {'1': 'release_url', '3': 4, '4': 1, '5': 9, '10': 'releaseUrl'},
    {'1': 'restart_required', '3': 5, '4': 1, '5': 8, '10': 'restartRequired'},
    {
      '1': 'engine',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ComponentVersion',
      '10': 'engine'
    },
    {
      '1': 'pob',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ComponentVersion',
      '10': 'pob'
    },
  ],
};

/// Descriptor for `UpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateResponseDescriptor = $convert.base64Decode(
    'Cg5VcGRhdGVSZXNwb25zZRIWCgZzdGF0dXMYASABKAlSBnN0YXR1cxInCg9jdXJyZW50X3Zlcn'
    'Npb24YAiABKAlSDmN1cnJlbnRWZXJzaW9uEiUKDmxhdGVzdF92ZXJzaW9uGAMgASgJUg1sYXRl'
    'c3RWZXJzaW9uEh8KC3JlbGVhc2VfdXJsGAQgASgJUgpyZWxlYXNlVXJsEikKEHJlc3RhcnRfcm'
    'VxdWlyZWQYBSABKAhSD3Jlc3RhcnRSZXF1aXJlZBIxCgZlbmdpbmUYBiABKAsyGS5wb2IyLnYx'
    'LkNvbXBvbmVudFZlcnNpb25SBmVuZ2luZRIrCgNwb2IYByABKAsyGS5wb2IyLnYxLkNvbXBvbm'
    'VudFZlcnNpb25SA3BvYg==');

@$core.Deprecated('Use doctorRequestDescriptor instead')
const DoctorRequest$json = {
  '1': 'DoctorRequest',
};

/// Descriptor for `DoctorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List doctorRequestDescriptor =
    $convert.base64Decode('Cg1Eb2N0b3JSZXF1ZXN0');

@$core.Deprecated('Use doctorResponseDescriptor instead')
const DoctorResponse$json = {
  '1': 'DoctorResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'protocol_version', '3': 3, '4': 1, '5': 9, '10': 'protocolVersion'},
    {'1': 'os', '3': 4, '4': 1, '5': 9, '10': 'os'},
    {'1': 'arch', '3': 5, '4': 1, '5': 9, '10': 'arch'},
    {'1': 'go_version', '3': 6, '4': 1, '5': 9, '10': 'goVersion'},
    {'1': 'executable', '3': 7, '4': 1, '5': 9, '10': 'executable'},
    {'1': 'commit', '3': 8, '4': 1, '5': 9, '10': 'commit'},
    {'1': 'modified', '3': 9, '4': 1, '5': 8, '10': 'modified'},
    {'1': 'data_id', '3': 10, '4': 1, '5': 9, '10': 'dataId'},
    {'1': 'data_sha256', '3': 11, '4': 1, '5': 9, '10': 'dataSha256'},
    {'1': 'tree_version', '3': 12, '4': 1, '5': 9, '10': 'treeVersion'},
    {'1': 'pob_commit', '3': 13, '4': 1, '5': 9, '10': 'pobCommit'},
    {'1': 'restart_required', '3': 14, '4': 1, '5': 8, '10': 'restartRequired'},
    {'1': 'issues', '3': 15, '4': 3, '5': 9, '10': 'issues'},
    {
      '1': 'server',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.DoctorServer',
      '10': 'server'
    },
    {
      '1': 'engine_update',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ComponentVersion',
      '10': 'engineUpdate'
    },
    {
      '1': 'pob',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ComponentVersion',
      '10': 'pob'
    },
  ],
};

/// Descriptor for `DoctorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List doctorResponseDescriptor = $convert.base64Decode(
    'Cg5Eb2N0b3JSZXNwb25zZRIWCgZzdGF0dXMYASABKAlSBnN0YXR1cxIYCgd2ZXJzaW9uGAIgAS'
    'gJUgd2ZXJzaW9uEikKEHByb3RvY29sX3ZlcnNpb24YAyABKAlSD3Byb3RvY29sVmVyc2lvbhIO'
    'CgJvcxgEIAEoCVICb3MSEgoEYXJjaBgFIAEoCVIEYXJjaBIdCgpnb192ZXJzaW9uGAYgASgJUg'
    'lnb1ZlcnNpb24SHgoKZXhlY3V0YWJsZRgHIAEoCVIKZXhlY3V0YWJsZRIWCgZjb21taXQYCCAB'
    'KAlSBmNvbW1pdBIaCghtb2RpZmllZBgJIAEoCFIIbW9kaWZpZWQSFwoHZGF0YV9pZBgKIAEoCV'
    'IGZGF0YUlkEh8KC2RhdGFfc2hhMjU2GAsgASgJUgpkYXRhU2hhMjU2EiEKDHRyZWVfdmVyc2lv'
    'bhgMIAEoCVILdHJlZVZlcnNpb24SHQoKcG9iX2NvbW1pdBgNIAEoCVIJcG9iQ29tbWl0EikKEH'
    'Jlc3RhcnRfcmVxdWlyZWQYDiABKAhSD3Jlc3RhcnRSZXF1aXJlZBIWCgZpc3N1ZXMYDyADKAlS'
    'Bmlzc3VlcxItCgZzZXJ2ZXIYECABKAsyFS5wb2IyLnYxLkRvY3RvclNlcnZlclIGc2VydmVyEj'
    '4KDWVuZ2luZV91cGRhdGUYESABKAsyGS5wb2IyLnYxLkNvbXBvbmVudFZlcnNpb25SDGVuZ2lu'
    'ZVVwZGF0ZRIrCgNwb2IYEiABKAsyGS5wb2IyLnYxLkNvbXBvbmVudFZlcnNpb25SA3BvYg==');

@$core.Deprecated('Use componentVersionDescriptor instead')
const ComponentVersion$json = {
  '1': 'ComponentVersion',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {
      '1': 'installed_version',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'installedVersion'
    },
    {'1': 'latest_version', '3': 3, '4': 1, '5': 9, '10': 'latestVersion'},
    {'1': 'release_url', '3': 4, '4': 1, '5': 9, '10': 'releaseUrl'},
    {'1': 'message', '3': 5, '4': 1, '5': 9, '10': 'message'},
    {'1': 'restart_required', '3': 6, '4': 1, '5': 8, '10': 'restartRequired'},
    {'1': 'installed_commit', '3': 7, '4': 1, '5': 9, '10': 'installedCommit'},
    {'1': 'running_version', '3': 8, '4': 1, '5': 9, '10': 'runningVersion'},
    {'1': 'running_commit', '3': 9, '4': 1, '5': 9, '10': 'runningCommit'},
    {'1': 'previous_version', '3': 10, '4': 1, '5': 9, '10': 'previousVersion'},
    {'1': 'previous_commit', '3': 11, '4': 1, '5': 9, '10': 'previousCommit'},
  ],
};

/// Descriptor for `ComponentVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List componentVersionDescriptor = $convert.base64Decode(
    'ChBDb21wb25lbnRWZXJzaW9uEhYKBnN0YXR1cxgBIAEoCVIGc3RhdHVzEisKEWluc3RhbGxlZF'
    '92ZXJzaW9uGAIgASgJUhBpbnN0YWxsZWRWZXJzaW9uEiUKDmxhdGVzdF92ZXJzaW9uGAMgASgJ'
    'Ug1sYXRlc3RWZXJzaW9uEh8KC3JlbGVhc2VfdXJsGAQgASgJUgpyZWxlYXNlVXJsEhgKB21lc3'
    'NhZ2UYBSABKAlSB21lc3NhZ2USKQoQcmVzdGFydF9yZXF1aXJlZBgGIAEoCFIPcmVzdGFydFJl'
    'cXVpcmVkEikKEGluc3RhbGxlZF9jb21taXQYByABKAlSD2luc3RhbGxlZENvbW1pdBInCg9ydW'
    '5uaW5nX3ZlcnNpb24YCCABKAlSDnJ1bm5pbmdWZXJzaW9uEiUKDnJ1bm5pbmdfY29tbWl0GAkg'
    'ASgJUg1ydW5uaW5nQ29tbWl0EikKEHByZXZpb3VzX3ZlcnNpb24YCiABKAlSD3ByZXZpb3VzVm'
    'Vyc2lvbhInCg9wcmV2aW91c19jb21taXQYCyABKAlSDnByZXZpb3VzQ29tbWl0');

@$core.Deprecated('Use doctorServerDescriptor instead')
const DoctorServer$json = {
  '1': 'DoctorServer',
  '2': [
    {'1': 'state', '3': 1, '4': 1, '5': 9, '10': 'state'},
    {'1': 'mode', '3': 2, '4': 1, '5': 9, '10': 'mode'},
    {'1': 'storage_mode', '3': 3, '4': 1, '5': 9, '10': 'storageMode'},
    {'1': 'storage_path', '3': 4, '4': 1, '5': 9, '10': 'storagePath'},
    {'1': 'storage_bytes', '3': 5, '4': 1, '5': 3, '10': 'storageBytes'},
    {'1': 'clients', '3': 6, '4': 1, '5': 13, '10': 'clients'},
    {'1': 'active_tasks', '3': 7, '4': 1, '5': 13, '10': 'activeTasks'},
  ],
};

/// Descriptor for `DoctorServer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List doctorServerDescriptor = $convert.base64Decode(
    'CgxEb2N0b3JTZXJ2ZXISFAoFc3RhdGUYASABKAlSBXN0YXRlEhIKBG1vZGUYAiABKAlSBG1vZG'
    'USIQoMc3RvcmFnZV9tb2RlGAMgASgJUgtzdG9yYWdlTW9kZRIhCgxzdG9yYWdlX3BhdGgYBCAB'
    'KAlSC3N0b3JhZ2VQYXRoEiMKDXN0b3JhZ2VfYnl0ZXMYBSABKANSDHN0b3JhZ2VCeXRlcxIYCg'
    'djbGllbnRzGAYgASgNUgdjbGllbnRzEiEKDGFjdGl2ZV90YXNrcxgHIAEoDVILYWN0aXZlVGFz'
    'a3M=');
