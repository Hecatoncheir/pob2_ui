// This is a generated file - do not edit.
//
// Generated from pob2/v1/workbench.proto.

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

@$core.Deprecated('Use listWorkbenchToolsRequestDescriptor instead')
const ListWorkbenchToolsRequest$json = {
  '1': 'ListWorkbenchToolsRequest',
};

/// Descriptor for `ListWorkbenchToolsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWorkbenchToolsRequestDescriptor =
    $convert.base64Decode('ChlMaXN0V29ya2JlbmNoVG9vbHNSZXF1ZXN0');

@$core.Deprecated('Use listWorkbenchToolsResponseDescriptor instead')
const ListWorkbenchToolsResponse$json = {
  '1': 'ListWorkbenchToolsResponse',
  '2': [
    {'1': 'names', '3': 1, '4': 3, '5': 9, '10': 'names'},
  ],
};

/// Descriptor for `ListWorkbenchToolsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWorkbenchToolsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0V29ya2JlbmNoVG9vbHNSZXNwb25zZRIUCgVuYW1lcxgBIAMoCVIFbmFtZXM=');

@$core.Deprecated('Use callWorkbenchToolRequestDescriptor instead')
const CallWorkbenchToolRequest$json = {
  '1': 'CallWorkbenchToolRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'arguments_json', '3': 2, '4': 1, '5': 12, '10': 'argumentsJson'},
  ],
};

/// Descriptor for `CallWorkbenchToolRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callWorkbenchToolRequestDescriptor =
    $convert.base64Decode(
        'ChhDYWxsV29ya2JlbmNoVG9vbFJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIlCg5hcmd1bW'
        'VudHNfanNvbhgCIAEoDFINYXJndW1lbnRzSnNvbg==');

@$core.Deprecated('Use callWorkbenchToolResponseDescriptor instead')
const CallWorkbenchToolResponse$json = {
  '1': 'CallWorkbenchToolResponse',
  '2': [
    {'1': 'revision', '3': 1, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'result_json', '3': 2, '4': 1, '5': 12, '10': 'resultJson'},
    {'1': 'png', '3': 3, '4': 1, '5': 12, '10': 'png'},
    {
      '1': 'error',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.WorkbenchToolError',
      '10': 'error'
    },
  ],
};

/// Descriptor for `CallWorkbenchToolResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callWorkbenchToolResponseDescriptor = $convert.base64Decode(
    'ChlDYWxsV29ya2JlbmNoVG9vbFJlc3BvbnNlEhoKCHJldmlzaW9uGAEgASgEUghyZXZpc2lvbh'
    'IfCgtyZXN1bHRfanNvbhgCIAEoDFIKcmVzdWx0SnNvbhIQCgNwbmcYAyABKAxSA3BuZxIxCgVl'
    'cnJvchgEIAEoCzIbLnBvYjIudjEuV29ya2JlbmNoVG9vbEVycm9yUgVlcnJvcg==');

@$core.Deprecated('Use workbenchToolErrorDescriptor instead')
const WorkbenchToolError$json = {
  '1': 'WorkbenchToolError',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `WorkbenchToolError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List workbenchToolErrorDescriptor = $convert.base64Decode(
    'ChJXb3JrYmVuY2hUb29sRXJyb3ISEgoEY29kZRgBIAEoCVIEY29kZRIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdl');
