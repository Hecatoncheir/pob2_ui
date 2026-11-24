// This is a generated file - do not edit.
//
// Generated from pob2/v1/catalog.proto.

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

@$core.Deprecated('Use catalogEntryDescriptor instead')
const CatalogEntry$json = {
  '1': 'CatalogEntry',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'aliases', '3': 4, '4': 3, '5': 9, '10': 'aliases'},
    {'1': 'levels', '3': 5, '4': 3, '5': 5, '10': 'levels'},
    {'1': 'qualities', '3': 6, '4': 3, '5': 5, '10': 'qualities'},
    {'1': 'modes', '3': 7, '4': 3, '5': 9, '10': 'modes'},
    {'1': 'support', '3': 8, '4': 1, '5': 8, '10': 'support'},
    {'1': 'family', '3': 9, '4': 1, '5': 9, '10': 'family'},
    {'1': 'slots', '3': 10, '4': 3, '5': 9, '10': 'slots'},
    {'1': 'class_ids', '3': 11, '4': 3, '5': 5, '10': 'classIds'},
    {'1': 'coverage', '3': 12, '4': 3, '5': 9, '10': 'coverage'},
    {'1': 'attribute_choice', '3': 13, '4': 1, '5': 8, '10': 'attributeChoice'},
  ],
};

/// Descriptor for `CatalogEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catalogEntryDescriptor = $convert.base64Decode(
    'CgxDYXRhbG9nRW50cnkSEgoEa2luZBgBIAEoCVIEa2luZBIOCgJpZBgCIAEoCVICaWQSEgoEbm'
    'FtZRgDIAEoCVIEbmFtZRIYCgdhbGlhc2VzGAQgAygJUgdhbGlhc2VzEhYKBmxldmVscxgFIAMo'
    'BVIGbGV2ZWxzEhwKCXF1YWxpdGllcxgGIAMoBVIJcXVhbGl0aWVzEhQKBW1vZGVzGAcgAygJUg'
    'Vtb2RlcxIYCgdzdXBwb3J0GAggASgIUgdzdXBwb3J0EhYKBmZhbWlseRgJIAEoCVIGZmFtaWx5'
    'EhQKBXNsb3RzGAogAygJUgVzbG90cxIbCgljbGFzc19pZHMYCyADKAVSCGNsYXNzSWRzEhoKCG'
    'NvdmVyYWdlGAwgAygJUghjb3ZlcmFnZRIpChBhdHRyaWJ1dGVfY2hvaWNlGA0gASgIUg9hdHRy'
    'aWJ1dGVDaG9pY2U=');

@$core.Deprecated('Use getCatalogRequestDescriptor instead')
const GetCatalogRequest$json = {
  '1': 'GetCatalogRequest',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `GetCatalogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCatalogRequestDescriptor = $convert.base64Decode(
    'ChFHZXRDYXRhbG9nUmVxdWVzdBISCgRraW5kGAEgASgJUgRraW5kEhQKBXF1ZXJ5GAIgASgJUg'
    'VxdWVyeRIWCgZvZmZzZXQYAyABKAVSBm9mZnNldBIUCgVsaW1pdBgEIAEoBVIFbGltaXQ=');

@$core.Deprecated('Use getCatalogResponseDescriptor instead')
const GetCatalogResponse$json = {
  '1': 'GetCatalogResponse',
  '2': [
    {'1': 'data_id', '3': 1, '4': 1, '5': 9, '10': 'dataId'},
    {'1': 'data_sha256', '3': 2, '4': 1, '5': 9, '10': 'dataSha256'},
    {'1': 'pob_commit', '3': 3, '4': 1, '5': 9, '10': 'pobCommit'},
    {'1': 'tree_version', '3': 4, '4': 1, '5': 9, '10': 'treeVersion'},
    {'1': 'kind', '3': 5, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'query', '3': 6, '4': 1, '5': 9, '10': 'query'},
    {'1': 'offset', '3': 7, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'limit', '3': 8, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'total', '3': 9, '4': 1, '5': 5, '10': 'total'},
    {
      '1': 'entries',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.CatalogEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `GetCatalogResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCatalogResponseDescriptor = $convert.base64Decode(
    'ChJHZXRDYXRhbG9nUmVzcG9uc2USFwoHZGF0YV9pZBgBIAEoCVIGZGF0YUlkEh8KC2RhdGFfc2'
    'hhMjU2GAIgASgJUgpkYXRhU2hhMjU2Eh0KCnBvYl9jb21taXQYAyABKAlSCXBvYkNvbW1pdBIh'
    'Cgx0cmVlX3ZlcnNpb24YBCABKAlSC3RyZWVWZXJzaW9uEhIKBGtpbmQYBSABKAlSBGtpbmQSFA'
    'oFcXVlcnkYBiABKAlSBXF1ZXJ5EhYKBm9mZnNldBgHIAEoBVIGb2Zmc2V0EhQKBWxpbWl0GAgg'
    'ASgFUgVsaW1pdBIUCgV0b3RhbBgJIAEoBVIFdG90YWwSLwoHZW50cmllcxgKIAMoCzIVLnBvYj'
    'IudjEuQ2F0YWxvZ0VudHJ5UgdlbnRyaWVz');

@$core.Deprecated('Use previewSupportRequestDescriptor instead')
const PreviewSupportRequest$json = {
  '1': 'PreviewSupportRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'support_id', '3': 3, '4': 1, '5': 9, '10': 'supportId'},
    {'1': 'level', '3': 4, '4': 1, '5': 5, '10': 'level'},
    {'1': 'quality', '3': 5, '4': 1, '5': 5, '10': 'quality'},
  ],
};

/// Descriptor for `PreviewSupportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewSupportRequestDescriptor = $convert.base64Decode(
    'ChVQcmV2aWV3U3VwcG9ydFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEi'
    'sKEWV4cGVjdGVkX3JldmlzaW9uGAIgASgEUhBleHBlY3RlZFJldmlzaW9uEh0KCnN1cHBvcnRf'
    'aWQYAyABKAlSCXN1cHBvcnRJZBIUCgVsZXZlbBgEIAEoBVIFbGV2ZWwSGAoHcXVhbGl0eRgFIA'
    'EoBVIHcXVhbGl0eQ==');

@$core.Deprecated('Use previewSupportResponseDescriptor instead')
const PreviewSupportResponse$json = {
  '1': 'PreviewSupportResponse',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'group_id', '3': 3, '4': 1, '5': 5, '10': 'groupId'},
    {
      '1': 'support',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.CatalogEntry',
      '10': 'support'
    },
    {'1': 'compatible', '3': 5, '4': 1, '5': 8, '10': 'compatible'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {
      '1': 'comparison',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.BuildComparison',
      '10': 'comparison'
    },
  ],
};

/// Descriptor for `PreviewSupportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List previewSupportResponseDescriptor = $convert.base64Decode(
    'ChZQcmV2aWV3U3VwcG9ydFJlc3BvbnNlEh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZB'
    'IaCghyZXZpc2lvbhgCIAEoBFIIcmV2aXNpb24SGQoIZ3JvdXBfaWQYAyABKAVSB2dyb3VwSWQS'
    'LwoHc3VwcG9ydBgEIAEoCzIVLnBvYjIudjEuQ2F0YWxvZ0VudHJ5UgdzdXBwb3J0Eh4KCmNvbX'
    'BhdGlibGUYBSABKAhSCmNvbXBhdGlibGUSFgoGc3RhdHVzGAYgASgJUgZzdGF0dXMSOAoKY29t'
    'cGFyaXNvbhgHIAEoCzIYLnBvYjIudjEuQnVpbGRDb21wYXJpc29uUgpjb21wYXJpc29u');
