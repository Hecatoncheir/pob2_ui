// This is a generated file - do not edit.
//
// Generated from pob2/v1/build.proto.

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

@$core.Deprecated('Use configValueTypeDescriptor instead')
const ConfigValueType$json = {
  '1': 'ConfigValueType',
  '2': [
    {'1': 'CONFIG_VALUE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'CONFIG_VALUE_TYPE_BOOLEAN', '2': 1},
    {'1': 'CONFIG_VALUE_TYPE_NUMBER', '2': 2},
    {'1': 'CONFIG_VALUE_TYPE_STRING', '2': 3},
  ],
};

/// Descriptor for `ConfigValueType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List configValueTypeDescriptor = $convert.base64Decode(
    'Cg9Db25maWdWYWx1ZVR5cGUSIQodQ09ORklHX1ZBTFVFX1RZUEVfVU5TUEVDSUZJRUQQABIdCh'
    'lDT05GSUdfVkFMVUVfVFlQRV9CT09MRUFOEAESHAoYQ09ORklHX1ZBTFVFX1RZUEVfTlVNQkVS'
    'EAISHAoYQ09ORklHX1ZBTFVFX1RZUEVfU1RSSU5HEAM=');

@$core.Deprecated('Use calculationStatusDescriptor instead')
const CalculationStatus$json = {
  '1': 'CalculationStatus',
  '2': [
    {'1': 'CALCULATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CALCULATION_STATUS_COMPLETE', '2': 1},
    {'1': 'CALCULATION_STATUS_PARTIAL', '2': 2},
    {'1': 'CALCULATION_STATUS_UNSUPPORTED', '2': 3},
  ],
};

/// Descriptor for `CalculationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List calculationStatusDescriptor = $convert.base64Decode(
    'ChFDYWxjdWxhdGlvblN0YXR1cxIiCh5DQUxDVUxBVElPTl9TVEFUVVNfVU5TUEVDSUZJRUQQAB'
    'IfChtDQUxDVUxBVElPTl9TVEFUVVNfQ09NUExFVEUQARIeChpDQUxDVUxBVElPTl9TVEFUVVNf'
    'UEFSVElBTBACEiIKHkNBTENVTEFUSU9OX1NUQVRVU19VTlNVUFBPUlRFRBAD');

@$core.Deprecated('Use configValueDescriptor instead')
const ConfigValue$json = {
  '1': 'ConfigValue',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pob2.v1.ConfigValueType',
      '10': 'type'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `ConfigValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configValueDescriptor = $convert.base64Decode(
    'CgtDb25maWdWYWx1ZRIsCgR0eXBlGAEgASgOMhgucG9iMi52MS5Db25maWdWYWx1ZVR5cGVSBH'
    'R5cGUSFAoFdmFsdWUYAiABKAlSBXZhbHVl');

@$core.Deprecated('Use buildIssueDescriptor instead')
const BuildIssue$json = {
  '1': 'BuildIssue',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'path', '3': 2, '4': 1, '5': 9, '10': 'path'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `BuildIssue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildIssueDescriptor = $convert.base64Decode(
    'CgpCdWlsZElzc3VlEhIKBGNvZGUYASABKAlSBGNvZGUSEgoEcGF0aBgCIAEoCVIEcGF0aBIYCg'
    'dtZXNzYWdlGAMgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use activeSetsDescriptor instead')
const ActiveSets$json = {
  '1': 'ActiveSets',
  '2': [
    {'1': 'skills', '3': 1, '4': 1, '5': 13, '10': 'skills'},
    {'1': 'items', '3': 2, '4': 1, '5': 13, '10': 'items'},
    {'1': 'tree', '3': 3, '4': 1, '5': 13, '10': 'tree'},
    {'1': 'config', '3': 4, '4': 1, '5': 13, '10': 'config'},
  ],
};

/// Descriptor for `ActiveSets`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activeSetsDescriptor = $convert.base64Decode(
    'CgpBY3RpdmVTZXRzEhYKBnNraWxscxgBIAEoDVIGc2tpbGxzEhQKBWl0ZW1zGAIgASgNUgVpdG'
    'VtcxISCgR0cmVlGAMgASgNUgR0cmVlEhYKBmNvbmZpZxgEIAEoDVIGY29uZmln');

@$core.Deprecated('Use buildGemDescriptor instead')
const BuildGem$json = {
  '1': 'BuildGem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'skill_id', '3': 3, '4': 1, '5': 9, '10': 'skillId'},
    {'1': 'variant_id', '3': 4, '4': 1, '5': 9, '10': 'variantId'},
    {'1': 'level', '3': 5, '4': 1, '5': 13, '10': 'level'},
    {'1': 'quality', '3': 6, '4': 1, '5': 13, '10': 'quality'},
    {'1': 'enabled', '3': 7, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'stat_set', '3': 8, '4': 1, '5': 13, '10': 'statSet'},
    {'1': 'corrupted', '3': 9, '4': 1, '5': 8, '10': 'corrupted'},
  ],
};

/// Descriptor for `BuildGem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildGemDescriptor = $convert.base64Decode(
    'CghCdWlsZEdlbRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIZCghza2lsbF'
    '9pZBgDIAEoCVIHc2tpbGxJZBIdCgp2YXJpYW50X2lkGAQgASgJUgl2YXJpYW50SWQSFAoFbGV2'
    'ZWwYBSABKA1SBWxldmVsEhgKB3F1YWxpdHkYBiABKA1SB3F1YWxpdHkSGAoHZW5hYmxlZBgHIA'
    'EoCFIHZW5hYmxlZBIZCghzdGF0X3NldBgIIAEoDVIHc3RhdFNldBIcCgljb3JydXB0ZWQYCSAB'
    'KAhSCWNvcnJ1cHRlZA==');

@$core.Deprecated('Use skillGroupDescriptor instead')
const SkillGroup$json = {
  '1': 'SkillGroup',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'enabled', '3': 3, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'main_skill', '3': 4, '4': 1, '5': 13, '10': 'mainSkill'},
    {
      '1': 'gems',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildGem',
      '10': 'gems'
    },
  ],
};

/// Descriptor for `SkillGroup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List skillGroupDescriptor = $convert.base64Decode(
    'CgpTa2lsbEdyb3VwEg4KAmlkGAEgASgNUgJpZBIUCgVsYWJlbBgCIAEoCVIFbGFiZWwSGAoHZW'
    '5hYmxlZBgDIAEoCFIHZW5hYmxlZBIdCgptYWluX3NraWxsGAQgASgNUgltYWluU2tpbGwSJQoE'
    'Z2VtcxgFIAMoCzIRLnBvYjIudjEuQnVpbGRHZW1SBGdlbXM=');

@$core.Deprecated('Use buildItemDescriptor instead')
const BuildItem$json = {
  '1': 'BuildItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'raw', '3': 2, '4': 1, '5': 9, '10': 'raw'},
  ],
};

/// Descriptor for `BuildItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildItemDescriptor = $convert.base64Decode(
    'CglCdWlsZEl0ZW0SDgoCaWQYASABKA1SAmlkEhAKA3JhdxgCIAEoCVIDcmF3');

@$core.Deprecated('Use buildModelDescriptor instead')
const BuildModel$json = {
  '1': 'BuildModel',
  '2': [
    {'1': 'target_version', '3': 1, '4': 1, '5': 9, '10': 'targetVersion'},
    {'1': 'tree_version', '3': 2, '4': 1, '5': 9, '10': 'treeVersion'},
    {'1': 'class_name', '3': 3, '4': 1, '5': 9, '10': 'className'},
    {'1': 'class_id', '3': 4, '4': 1, '5': 13, '10': 'classId'},
    {'1': 'ascendancy', '3': 5, '4': 1, '5': 9, '10': 'ascendancy'},
    {'1': 'ascendancy_id', '3': 6, '4': 1, '5': 13, '10': 'ascendancyId'},
    {'1': 'level', '3': 7, '4': 1, '5': 13, '10': 'level'},
    {'1': 'main_group', '3': 8, '4': 1, '5': 13, '10': 'mainGroup'},
    {'1': 'weapon_set', '3': 9, '4': 1, '5': 13, '10': 'weaponSet'},
    {
      '1': 'active_sets',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ActiveSets',
      '10': 'activeSets'
    },
    {
      '1': 'groups',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.SkillGroup',
      '10': 'groups'
    },
    {
      '1': 'items',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildItem',
      '10': 'items'
    },
    {
      '1': 'slots',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildModel.SlotsEntry',
      '10': 'slots'
    },
    {'1': 'nodes', '3': 14, '4': 3, '5': 13, '10': 'nodes'},
    {
      '1': 'config',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildModel.ConfigEntry',
      '10': 'config'
    },
    {
      '1': 'issues',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildIssue',
      '10': 'issues'
    },
    {
      '1': 'passive_attributes',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildModel.PassiveAttributesEntry',
      '10': 'passiveAttributes'
    },
    {
      '1': 'passive_allocations',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildModel.PassiveAllocationsEntry',
      '10': 'passiveAllocations'
    },
    {
      '1': 'passive_jewels',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildModel.PassiveJewelsEntry',
      '10': 'passiveJewels'
    },
  ],
  '3': [
    BuildModel_SlotsEntry$json,
    BuildModel_ConfigEntry$json,
    BuildModel_PassiveAttributesEntry$json,
    BuildModel_PassiveAllocationsEntry$json,
    BuildModel_PassiveJewelsEntry$json
  ],
};

@$core.Deprecated('Use buildModelDescriptor instead')
const BuildModel_SlotsEntry$json = {
  '1': 'SlotsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use buildModelDescriptor instead')
const BuildModel_ConfigEntry$json = {
  '1': 'ConfigEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ConfigValue',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use buildModelDescriptor instead')
const BuildModel_PassiveAttributesEntry$json = {
  '1': 'PassiveAttributesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use buildModelDescriptor instead')
const BuildModel_PassiveAllocationsEntry$json = {
  '1': 'PassiveAllocationsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use buildModelDescriptor instead')
const BuildModel_PassiveJewelsEntry$json = {
  '1': 'PassiveJewelsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 13, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `BuildModel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildModelDescriptor = $convert.base64Decode(
    'CgpCdWlsZE1vZGVsEiUKDnRhcmdldF92ZXJzaW9uGAEgASgJUg10YXJnZXRWZXJzaW9uEiEKDH'
    'RyZWVfdmVyc2lvbhgCIAEoCVILdHJlZVZlcnNpb24SHQoKY2xhc3NfbmFtZRgDIAEoCVIJY2xh'
    'c3NOYW1lEhkKCGNsYXNzX2lkGAQgASgNUgdjbGFzc0lkEh4KCmFzY2VuZGFuY3kYBSABKAlSCm'
    'FzY2VuZGFuY3kSIwoNYXNjZW5kYW5jeV9pZBgGIAEoDVIMYXNjZW5kYW5jeUlkEhQKBWxldmVs'
    'GAcgASgNUgVsZXZlbBIdCgptYWluX2dyb3VwGAggASgNUgltYWluR3JvdXASHQoKd2VhcG9uX3'
    'NldBgJIAEoDVIJd2VhcG9uU2V0EjQKC2FjdGl2ZV9zZXRzGAogASgLMhMucG9iMi52MS5BY3Rp'
    'dmVTZXRzUgphY3RpdmVTZXRzEisKBmdyb3VwcxgLIAMoCzITLnBvYjIudjEuU2tpbGxHcm91cF'
    'IGZ3JvdXBzEigKBWl0ZW1zGAwgAygLMhIucG9iMi52MS5CdWlsZEl0ZW1SBWl0ZW1zEjQKBXNs'
    'b3RzGA0gAygLMh4ucG9iMi52MS5CdWlsZE1vZGVsLlNsb3RzRW50cnlSBXNsb3RzEhQKBW5vZG'
    'VzGA4gAygNUgVub2RlcxI3CgZjb25maWcYDyADKAsyHy5wb2IyLnYxLkJ1aWxkTW9kZWwuQ29u'
    'ZmlnRW50cnlSBmNvbmZpZxIrCgZpc3N1ZXMYECADKAsyEy5wb2IyLnYxLkJ1aWxkSXNzdWVSBm'
    'lzc3VlcxJZChJwYXNzaXZlX2F0dHJpYnV0ZXMYESADKAsyKi5wb2IyLnYxLkJ1aWxkTW9kZWwu'
    'UGFzc2l2ZUF0dHJpYnV0ZXNFbnRyeVIRcGFzc2l2ZUF0dHJpYnV0ZXMSXAoTcGFzc2l2ZV9hbG'
    'xvY2F0aW9ucxgSIAMoCzIrLnBvYjIudjEuQnVpbGRNb2RlbC5QYXNzaXZlQWxsb2NhdGlvbnNF'
    'bnRyeVIScGFzc2l2ZUFsbG9jYXRpb25zEk0KDnBhc3NpdmVfamV3ZWxzGBMgAygLMiYucG9iMi'
    '52MS5CdWlsZE1vZGVsLlBhc3NpdmVKZXdlbHNFbnRyeVINcGFzc2l2ZUpld2Vscxo4CgpTbG90'
    'c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgNUgV2YWx1ZToCOAEaTwoLQ2'
    '9uZmlnRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSKgoFdmFsdWUYAiABKAsyFC5wb2IyLnYxLkNv'
    'bmZpZ1ZhbHVlUgV2YWx1ZToCOAEaRAoWUGFzc2l2ZUF0dHJpYnV0ZXNFbnRyeRIQCgNrZXkYAS'
    'ABKA1SA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgBGkUKF1Bhc3NpdmVBbGxvY2F0aW9u'
    'c0VudHJ5EhAKA2tleRgBIAEoDVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAEaQAoSUG'
    'Fzc2l2ZUpld2Vsc0VudHJ5EhAKA2tleRgBIAEoDVIDa2V5EhQKBXZhbHVlGAIgASgNUgV2YWx1'
    'ZToCOAE=');

@$core.Deprecated('Use appliedModifierDescriptor instead')
const AppliedModifier$json = {
  '1': 'AppliedModifier',
  '2': [
    {'1': 'stat', '3': 1, '4': 1, '5': 9, '10': 'stat'},
    {'1': 'kind', '3': 2, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'value', '3': 3, '4': 1, '5': 1, '10': 'value'},
    {'1': 'source', '3': 4, '4': 1, '5': 9, '10': 'source'},
  ],
};

/// Descriptor for `AppliedModifier`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List appliedModifierDescriptor = $convert.base64Decode(
    'Cg9BcHBsaWVkTW9kaWZpZXISEgoEc3RhdBgBIAEoCVIEc3RhdBISCgRraW5kGAIgASgJUgRraW'
    '5kEhQKBXZhbHVlGAMgASgBUgV2YWx1ZRIWCgZzb3VyY2UYBCABKAlSBnNvdXJjZQ==');

@$core.Deprecated('Use calculationResultDescriptor instead')
const CalculationResult$json = {
  '1': 'CalculationResult',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.pob2.v1.CalculationStatus',
      '10': 'status'
    },
    {'1': 'data_id', '3': 2, '4': 1, '5': 9, '10': 'dataId'},
    {'1': 'data_sha256', '3': 3, '4': 1, '5': 9, '10': 'dataSha256'},
    {'1': 'pob_commit', '3': 4, '4': 1, '5': 9, '10': 'pobCommit'},
    {'1': 'input_sha256', '3': 5, '4': 1, '5': 9, '10': 'inputSha256'},
    {'1': 'skill', '3': 6, '4': 1, '5': 9, '10': 'skill'},
    {'1': 'mode', '3': 7, '4': 1, '5': 9, '10': 'mode'},
    {
      '1': 'stats',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.CalculationResult.StatsEntry',
      '10': 'stats'
    },
    {
      '1': 'modifiers',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.AppliedModifier',
      '10': 'modifiers'
    },
    {
      '1': 'issues',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.BuildIssue',
      '10': 'issues'
    },
  ],
  '3': [CalculationResult_StatsEntry$json],
};

@$core.Deprecated('Use calculationResultDescriptor instead')
const CalculationResult_StatsEntry$json = {
  '1': 'StatsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CalculationResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculationResultDescriptor = $convert.base64Decode(
    'ChFDYWxjdWxhdGlvblJlc3VsdBIyCgZzdGF0dXMYASABKA4yGi5wb2IyLnYxLkNhbGN1bGF0aW'
    '9uU3RhdHVzUgZzdGF0dXMSFwoHZGF0YV9pZBgCIAEoCVIGZGF0YUlkEh8KC2RhdGFfc2hhMjU2'
    'GAMgASgJUgpkYXRhU2hhMjU2Eh0KCnBvYl9jb21taXQYBCABKAlSCXBvYkNvbW1pdBIhCgxpbn'
    'B1dF9zaGEyNTYYBSABKAlSC2lucHV0U2hhMjU2EhQKBXNraWxsGAYgASgJUgVza2lsbBISCgRt'
    'b2RlGAcgASgJUgRtb2RlEjsKBXN0YXRzGAggAygLMiUucG9iMi52MS5DYWxjdWxhdGlvblJlc3'
    'VsdC5TdGF0c0VudHJ5UgVzdGF0cxI2Cgltb2RpZmllcnMYCSADKAsyGC5wb2IyLnYxLkFwcGxp'
    'ZWRNb2RpZmllclIJbW9kaWZpZXJzEisKBmlzc3VlcxgKIAMoCzITLnBvYjIudjEuQnVpbGRJc3'
    'N1ZVIGaXNzdWVzGjgKClN0YXRzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiAB'
    'KAFSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use buildDocumentDescriptor instead')
const BuildDocument$json = {
  '1': 'BuildDocument',
  '2': [
    {'1': 'xml', '3': 1, '4': 1, '5': 9, '10': 'xml'},
    {'1': 'input_sha256', '3': 2, '4': 1, '5': 9, '10': 'inputSha256'},
    {'1': 'input_revision', '3': 3, '4': 1, '5': 4, '10': 'inputRevision'},
    {
      '1': 'model',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.BuildModel',
      '10': 'model'
    },
    {
      '1': 'calculation',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.CalculationResult',
      '10': 'calculation'
    },
    {
      '1': 'calculated_from_revision',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'calculatedFromRevision'
    },
  ],
};

/// Descriptor for `BuildDocument`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildDocumentDescriptor = $convert.base64Decode(
    'Cg1CdWlsZERvY3VtZW50EhAKA3htbBgBIAEoCVIDeG1sEiEKDGlucHV0X3NoYTI1NhgCIAEoCV'
    'ILaW5wdXRTaGEyNTYSJQoOaW5wdXRfcmV2aXNpb24YAyABKARSDWlucHV0UmV2aXNpb24SKQoF'
    'bW9kZWwYBCABKAsyEy5wb2IyLnYxLkJ1aWxkTW9kZWxSBW1vZGVsEjwKC2NhbGN1bGF0aW9uGA'
    'UgASgLMhoucG9iMi52MS5DYWxjdWxhdGlvblJlc3VsdFILY2FsY3VsYXRpb24SOAoYY2FsY3Vs'
    'YXRlZF9mcm9tX3JldmlzaW9uGAYgASgEUhZjYWxjdWxhdGVkRnJvbVJldmlzaW9u');

@$core.Deprecated('Use levelEditDescriptor instead')
const LevelEdit$json = {
  '1': 'LevelEdit',
  '2': [
    {'1': 'level', '3': 1, '4': 1, '5': 13, '10': 'level'},
  ],
};

/// Descriptor for `LevelEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List levelEditDescriptor =
    $convert.base64Decode('CglMZXZlbEVkaXQSFAoFbGV2ZWwYASABKA1SBWxldmVs');

@$core.Deprecated('Use configEditDescriptor instead')
const ConfigEdit$json = {
  '1': 'ConfigEdit',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ConfigValue',
      '10': 'value'
    },
  ],
};

/// Descriptor for `ConfigEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configEditDescriptor = $convert.base64Decode(
    'CgpDb25maWdFZGl0EhIKBG5hbWUYASABKAlSBG5hbWUSKgoFdmFsdWUYAiABKAsyFC5wb2IyLn'
    'YxLkNvbmZpZ1ZhbHVlUgV2YWx1ZQ==');

@$core.Deprecated('Use gemInputDescriptor instead')
const GemInput$json = {
  '1': 'GemInput',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'level', '3': 2, '4': 1, '5': 13, '10': 'level'},
    {'1': 'quality', '3': 3, '4': 1, '5': 13, '10': 'quality'},
    {'1': 'enabled', '3': 4, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `GemInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gemInputDescriptor = $convert.base64Decode(
    'CghHZW1JbnB1dBIOCgJpZBgBIAEoCVICaWQSFAoFbGV2ZWwYAiABKA1SBWxldmVsEhgKB3F1YW'
    'xpdHkYAyABKA1SB3F1YWxpdHkSGAoHZW5hYmxlZBgEIAEoCFIHZW5hYmxlZA==');

@$core.Deprecated('Use gemsEditDescriptor instead')
const GemsEdit$json = {
  '1': 'GemsEdit',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 13, '10': 'groupId'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'enabled', '3': 3, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'delete', '3': 4, '4': 1, '5': 8, '10': 'delete'},
    {
      '1': 'gems',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.GemInput',
      '10': 'gems'
    },
  ],
};

/// Descriptor for `GemsEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gemsEditDescriptor = $convert.base64Decode(
    'CghHZW1zRWRpdBIZCghncm91cF9pZBgBIAEoDVIHZ3JvdXBJZBIUCgVsYWJlbBgCIAEoCVIFbG'
    'FiZWwSGAoHZW5hYmxlZBgDIAEoCFIHZW5hYmxlZBIWCgZkZWxldGUYBCABKAhSBmRlbGV0ZRIl'
    'CgRnZW1zGAUgAygLMhEucG9iMi52MS5HZW1JbnB1dFIEZ2Vtcw==');

@$core.Deprecated('Use equipmentEditDescriptor instead')
const EquipmentEdit$json = {
  '1': 'EquipmentEdit',
  '2': [
    {'1': 'slot', '3': 1, '4': 1, '5': 9, '10': 'slot'},
    {'1': 'raw', '3': 2, '4': 1, '5': 9, '10': 'raw'},
    {'1': 'item_id', '3': 3, '4': 1, '5': 13, '10': 'itemId'},
  ],
};

/// Descriptor for `EquipmentEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List equipmentEditDescriptor = $convert.base64Decode(
    'Cg1FcXVpcG1lbnRFZGl0EhIKBHNsb3QYASABKAlSBHNsb3QSEAoDcmF3GAIgASgJUgNyYXcSFw'
    'oHaXRlbV9pZBgDIAEoDVIGaXRlbUlk');

@$core.Deprecated('Use passivesEditDescriptor instead')
const PassivesEdit$json = {
  '1': 'PassivesEdit',
  '2': [
    {'1': 'nodes', '3': 1, '4': 3, '5': 13, '10': 'nodes'},
  ],
};

/// Descriptor for `PassivesEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List passivesEditDescriptor =
    $convert.base64Decode('CgxQYXNzaXZlc0VkaXQSFAoFbm9kZXMYASADKA1SBW5vZGVz');

@$core.Deprecated('Use jewelEditDescriptor instead')
const JewelEdit$json = {
  '1': 'JewelEdit',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 13, '10': 'nodeId'},
    {'1': 'item_id', '3': 2, '4': 1, '5': 13, '10': 'itemId'},
    {'1': 'raw', '3': 3, '4': 1, '5': 9, '10': 'raw'},
  ],
};

/// Descriptor for `JewelEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List jewelEditDescriptor = $convert.base64Decode(
    'CglKZXdlbEVkaXQSFwoHbm9kZV9pZBgBIAEoDVIGbm9kZUlkEhcKB2l0ZW1faWQYAiABKA1SBm'
    'l0ZW1JZBIQCgNyYXcYAyABKAlSA3Jhdw==');

@$core.Deprecated('Use selectionEditDescriptor instead')
const SelectionEdit$json = {
  '1': 'SelectionEdit',
  '2': [
    {
      '1': 'sets',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ActiveSets',
      '10': 'sets'
    },
    {'1': 'main_group', '3': 2, '4': 1, '5': 13, '10': 'mainGroup'},
    {'1': 'weapon_set', '3': 3, '4': 1, '5': 13, '10': 'weaponSet'},
  ],
};

/// Descriptor for `SelectionEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List selectionEditDescriptor = $convert.base64Decode(
    'Cg1TZWxlY3Rpb25FZGl0EicKBHNldHMYASABKAsyEy5wb2IyLnYxLkFjdGl2ZVNldHNSBHNldH'
    'MSHQoKbWFpbl9ncm91cBgCIAEoDVIJbWFpbkdyb3VwEh0KCndlYXBvbl9zZXQYAyABKA1SCXdl'
    'YXBvblNldA==');

@$core.Deprecated('Use addSupportEditDescriptor instead')
const AddSupportEdit$json = {
  '1': 'AddSupportEdit',
  '2': [
    {'1': 'support_id', '3': 1, '4': 1, '5': 9, '10': 'supportId'},
    {'1': 'level', '3': 2, '4': 1, '5': 13, '10': 'level'},
    {'1': 'quality', '3': 3, '4': 1, '5': 13, '10': 'quality'},
  ],
};

/// Descriptor for `AddSupportEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addSupportEditDescriptor = $convert.base64Decode(
    'Cg5BZGRTdXBwb3J0RWRpdBIdCgpzdXBwb3J0X2lkGAEgASgJUglzdXBwb3J0SWQSFAoFbGV2ZW'
    'wYAiABKA1SBWxldmVsEhgKB3F1YWxpdHkYAyABKA1SB3F1YWxpdHk=');

@$core.Deprecated('Use treeNodeEditDescriptor instead')
const TreeNodeEdit$json = {
  '1': 'TreeNodeEdit',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 13, '10': 'nodeId'},
    {'1': 'action', '3': 2, '4': 1, '5': 9, '10': 'action'},
    {'1': 'attribute', '3': 3, '4': 1, '5': 9, '10': 'attribute'},
    {'1': 'allocation_mode', '3': 4, '4': 1, '5': 9, '10': 'allocationMode'},
  ],
};

/// Descriptor for `TreeNodeEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeNodeEditDescriptor = $convert.base64Decode(
    'CgxUcmVlTm9kZUVkaXQSFwoHbm9kZV9pZBgBIAEoDVIGbm9kZUlkEhYKBmFjdGlvbhgCIAEoCV'
    'IGYWN0aW9uEhwKCWF0dHJpYnV0ZRgDIAEoCVIJYXR0cmlidXRlEicKD2FsbG9jYXRpb25fbW9k'
    'ZRgEIAEoCVIOYWxsb2NhdGlvbk1vZGU=');

@$core.Deprecated('Use treeClassEditDescriptor instead')
const TreeClassEdit$json = {
  '1': 'TreeClassEdit',
  '2': [
    {'1': 'class_id', '3': 1, '4': 1, '5': 13, '10': 'classId'},
    {'1': 'ascendancy_id', '3': 2, '4': 1, '5': 13, '10': 'ascendancyId'},
    {'1': 'mode', '3': 3, '4': 1, '5': 9, '10': 'mode'},
  ],
};

/// Descriptor for `TreeClassEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeClassEditDescriptor = $convert.base64Decode(
    'Cg1UcmVlQ2xhc3NFZGl0EhkKCGNsYXNzX2lkGAEgASgNUgdjbGFzc0lkEiMKDWFzY2VuZGFuY3'
    'lfaWQYAiABKA1SDGFzY2VuZGFuY3lJZBISCgRtb2RlGAMgASgJUgRtb2Rl');

@$core.Deprecated('Use getTreeGeometryRequestDescriptor instead')
const GetTreeGeometryRequest$json = {
  '1': 'GetTreeGeometryRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'include_scene', '3': 3, '4': 1, '5': 8, '10': 'includeScene'},
  ],
};

/// Descriptor for `GetTreeGeometryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreeGeometryRequestDescriptor = $convert.base64Decode(
    'ChZHZXRUcmVlR2VvbWV0cnlSZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZB'
    'IrChFleHBlY3RlZF9yZXZpc2lvbhgCIAEoBFIQZXhwZWN0ZWRSZXZpc2lvbhIjCg1pbmNsdWRl'
    'X3NjZW5lGAMgASgIUgxpbmNsdWRlU2NlbmU=');

@$core.Deprecated('Use getTreeGeometryResponseDescriptor instead')
const GetTreeGeometryResponse$json = {
  '1': 'GetTreeGeometryResponse',
  '2': [
    {'1': 'revision', '3': 1, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {
      '1': 'nodes',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.TreeGeometryNode',
      '10': 'nodes'
    },
    {
      '1': 'edges',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.TreeGeometryEdge',
      '10': 'edges'
    },
    {
      '1': 'scene',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.TreeScene',
      '10': 'scene'
    },
  ],
};

/// Descriptor for `GetTreeGeometryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreeGeometryResponseDescriptor = $convert.base64Decode(
    'ChdHZXRUcmVlR2VvbWV0cnlSZXNwb25zZRIaCghyZXZpc2lvbhgBIAEoBFIIcmV2aXNpb24SGA'
    'oHdmVyc2lvbhgCIAEoCVIHdmVyc2lvbhIvCgVub2RlcxgDIAMoCzIZLnBvYjIudjEuVHJlZUdl'
    'b21ldHJ5Tm9kZVIFbm9kZXMSLwoFZWRnZXMYBCADKAsyGS5wb2IyLnYxLlRyZWVHZW9tZXRyeU'
    'VkZ2VSBWVkZ2VzEigKBXNjZW5lGAUgASgLMhIucG9iMi52MS5UcmVlU2NlbmVSBXNjZW5l');

@$core.Deprecated('Use treeGeometryNodeDescriptor instead')
const TreeGeometryNode$json = {
  '1': 'TreeGeometryNode',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'x', '3': 2, '4': 1, '5': 1, '10': 'x'},
    {'1': 'y', '3': 3, '4': 1, '5': 1, '10': 'y'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'kind', '3': 5, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'icon', '3': 6, '4': 1, '5': 9, '10': 'icon'},
    {'1': 'allocated', '3': 7, '4': 1, '5': 8, '10': 'allocated'},
    {'1': 'attribute', '3': 8, '4': 1, '5': 8, '10': 'attribute'},
    {'1': 'allocation_mode', '3': 9, '4': 1, '5': 13, '10': 'allocationMode'},
    {'1': 'draw_size', '3': 10, '4': 1, '5': 1, '10': 'drawSize'},
  ],
};

/// Descriptor for `TreeGeometryNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeGeometryNodeDescriptor = $convert.base64Decode(
    'ChBUcmVlR2VvbWV0cnlOb2RlEg4KAmlkGAEgASgNUgJpZBIMCgF4GAIgASgBUgF4EgwKAXkYAy'
    'ABKAFSAXkSEgoEbmFtZRgEIAEoCVIEbmFtZRISCgRraW5kGAUgASgJUgRraW5kEhIKBGljb24Y'
    'BiABKAlSBGljb24SHAoJYWxsb2NhdGVkGAcgASgIUglhbGxvY2F0ZWQSHAoJYXR0cmlidXRlGA'
    'ggASgIUglhdHRyaWJ1dGUSJwoPYWxsb2NhdGlvbl9tb2RlGAkgASgNUg5hbGxvY2F0aW9uTW9k'
    'ZRIbCglkcmF3X3NpemUYCiABKAFSCGRyYXdTaXpl');

@$core.Deprecated('Use treeGeometryEdgeDescriptor instead')
const TreeGeometryEdge$json = {
  '1': 'TreeGeometryEdge',
  '2': [
    {'1': 'from_node', '3': 1, '4': 1, '5': 13, '10': 'fromNode'},
    {'1': 'to_node', '3': 2, '4': 1, '5': 13, '10': 'toNode'},
    {'1': 'hidden_in_scene', '3': 3, '4': 1, '5': 8, '10': 'hiddenInScene'},
  ],
};

/// Descriptor for `TreeGeometryEdge`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeGeometryEdgeDescriptor = $convert.base64Decode(
    'ChBUcmVlR2VvbWV0cnlFZGdlEhsKCWZyb21fbm9kZRgBIAEoDVIIZnJvbU5vZGUSFwoHdG9fbm'
    '9kZRgCIAEoDVIGdG9Ob2RlEiYKD2hpZGRlbl9pbl9zY2VuZRgDIAEoCFINaGlkZGVuSW5TY2Vu'
    'ZQ==');

@$core.Deprecated('Use getTreeNodeTooltipRequestDescriptor instead')
const GetTreeNodeTooltipRequest$json = {
  '1': 'GetTreeNodeTooltipRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'node_id', '3': 3, '4': 1, '5': 13, '10': 'nodeId'},
    {'1': 'compare', '3': 4, '4': 1, '5': 8, '10': 'compare'},
    {'1': 'include_scene', '3': 5, '4': 1, '5': 8, '10': 'includeScene'},
  ],
};

/// Descriptor for `GetTreeNodeTooltipRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreeNodeTooltipRequestDescriptor = $convert.base64Decode(
    'ChlHZXRUcmVlTm9kZVRvb2x0aXBSZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb2'
    '5JZBIrChFleHBlY3RlZF9yZXZpc2lvbhgCIAEoBFIQZXhwZWN0ZWRSZXZpc2lvbhIXCgdub2Rl'
    'X2lkGAMgASgNUgZub2RlSWQSGAoHY29tcGFyZRgEIAEoCFIHY29tcGFyZRIjCg1pbmNsdWRlX3'
    'NjZW5lGAUgASgIUgxpbmNsdWRlU2NlbmU=');

@$core.Deprecated('Use getTreeNodeTooltipResponseDescriptor instead')
const GetTreeNodeTooltipResponse$json = {
  '1': 'GetTreeNodeTooltipResponse',
  '2': [
    {'1': 'revision', '3': 1, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'node_id', '3': 2, '4': 1, '5': 13, '10': 'nodeId'},
    {
      '1': 'lines',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.TreeTooltipLine',
      '10': 'lines'
    },
    {'1': 'path', '3': 4, '4': 3, '5': 13, '10': 'path'},
    {'1': 'points', '3': 5, '4': 1, '5': 13, '10': 'points'},
    {'1': 'note', '3': 6, '4': 1, '5': 9, '10': 'note'},
    {'1': 'recipe', '3': 7, '4': 3, '5': 9, '10': 'recipe'},
    {
      '1': 'scene',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.TreeScene',
      '10': 'scene'
    },
  ],
};

/// Descriptor for `GetTreeNodeTooltipResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreeNodeTooltipResponseDescriptor = $convert.base64Decode(
    'ChpHZXRUcmVlTm9kZVRvb2x0aXBSZXNwb25zZRIaCghyZXZpc2lvbhgBIAEoBFIIcmV2aXNpb2'
    '4SFwoHbm9kZV9pZBgCIAEoDVIGbm9kZUlkEi4KBWxpbmVzGAMgAygLMhgucG9iMi52MS5UcmVl'
    'VG9vbHRpcExpbmVSBWxpbmVzEhIKBHBhdGgYBCADKA1SBHBhdGgSFgoGcG9pbnRzGAUgASgNUg'
    'Zwb2ludHMSEgoEbm90ZRgGIAEoCVIEbm90ZRIWCgZyZWNpcGUYByADKAlSBnJlY2lwZRIoCgVz'
    'Y2VuZRgIIAEoCzISLnBvYjIudjEuVHJlZVNjZW5lUgVzY2VuZQ==');

@$core.Deprecated('Use treeTooltipLineDescriptor instead')
const TreeTooltipLine$json = {
  '1': 'TreeTooltipLine',
  '2': [
    {'1': 'size', '3': 1, '4': 1, '5': 1, '10': 'size'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'separator', '3': 3, '4': 1, '5': 8, '10': 'separator'},
  ],
};

/// Descriptor for `TreeTooltipLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeTooltipLineDescriptor = $convert.base64Decode(
    'Cg9UcmVlVG9vbHRpcExpbmUSEgoEc2l6ZRgBIAEoAVIEc2l6ZRISCgR0ZXh0GAIgASgJUgR0ZX'
    'h0EhwKCXNlcGFyYXRvchgDIAEoCFIJc2VwYXJhdG9y');

@$core.Deprecated('Use getBuildReportRequestDescriptor instead')
const GetBuildReportRequest$json = {
  '1': 'GetBuildReportRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
  ],
};

/// Descriptor for `GetBuildReportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBuildReportRequestDescriptor = $convert.base64Decode(
    'ChVHZXRCdWlsZFJlcG9ydFJlcXVlc3QSHQoKc2Vzc2lvbl9pZBgBIAEoCVIJc2Vzc2lvbklkEi'
    'sKEWV4cGVjdGVkX3JldmlzaW9uGAIgASgEUhBleHBlY3RlZFJldmlzaW9u');

@$core.Deprecated('Use getBuildReportResponseDescriptor instead')
const GetBuildReportResponse$json = {
  '1': 'GetBuildReportResponse',
  '2': [
    {'1': 'revision', '3': 1, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'report_json', '3': 2, '4': 1, '5': 12, '10': 'reportJson'},
  ],
};

/// Descriptor for `GetBuildReportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBuildReportResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRCdWlsZFJlcG9ydFJlc3BvbnNlEhoKCHJldmlzaW9uGAEgASgEUghyZXZpc2lvbhIfCg'
        'tyZXBvcnRfanNvbhgCIAEoDFIKcmVwb3J0SnNvbg==');

@$core.Deprecated('Use skillChoiceEditDescriptor instead')
const SkillChoiceEdit$json = {
  '1': 'SkillChoiceEdit',
  '2': [
    {'1': 'control', '3': 1, '4': 1, '5': 9, '10': 'control'},
    {'1': 'option_id', '3': 2, '4': 1, '5': 13, '10': 'optionId'},
  ],
};

/// Descriptor for `SkillChoiceEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List skillChoiceEditDescriptor = $convert.base64Decode(
    'Cg9Ta2lsbENob2ljZUVkaXQSGAoHY29udHJvbBgBIAEoCVIHY29udHJvbBIbCglvcHRpb25faW'
    'QYAiABKA1SCG9wdGlvbklk');

@$core.Deprecated('Use skillGroupEditDescriptor instead')
const SkillGroupEdit$json = {
  '1': 'SkillGroupEdit',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 13, '10': 'groupId'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'label', '17': true},
    {'1': 'delete', '3': 3, '4': 1, '5': 8, '10': 'delete'},
    {
      '1': 'gems',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.SkillGroupGem',
      '10': 'gems'
    },
  ],
  '8': [
    {'1': '_label'},
  ],
};

/// Descriptor for `SkillGroupEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List skillGroupEditDescriptor = $convert.base64Decode(
    'Cg5Ta2lsbEdyb3VwRWRpdBIZCghncm91cF9pZBgBIAEoDVIHZ3JvdXBJZBIZCgVsYWJlbBgCIA'
    'EoCUgAUgVsYWJlbIgBARIWCgZkZWxldGUYAyABKAhSBmRlbGV0ZRIqCgRnZW1zGAQgAygLMhYu'
    'cG9iMi52MS5Ta2lsbEdyb3VwR2VtUgRnZW1zQggKBl9sYWJlbA==');

@$core.Deprecated('Use skillGroupGemDescriptor instead')
const SkillGroupGem$json = {
  '1': 'SkillGroupGem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'level', '3': 2, '4': 1, '5': 13, '10': 'level'},
    {'1': 'quality', '3': 3, '4': 1, '5': 13, '10': 'quality'},
    {
      '1': 'enabled',
      '3': 4,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'enabled',
      '17': true
    },
    {'1': 'source_index', '3': 5, '4': 1, '5': 13, '10': 'sourceIndex'},
  ],
  '8': [
    {'1': '_enabled'},
  ],
};

/// Descriptor for `SkillGroupGem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List skillGroupGemDescriptor = $convert.base64Decode(
    'Cg1Ta2lsbEdyb3VwR2VtEg4KAmlkGAEgASgJUgJpZBIUCgVsZXZlbBgCIAEoDVIFbGV2ZWwSGA'
    'oHcXVhbGl0eRgDIAEoDVIHcXVhbGl0eRIdCgdlbmFibGVkGAQgASgISABSB2VuYWJsZWSIAQES'
    'IQoMc291cmNlX2luZGV4GAUgASgNUgtzb3VyY2VJbmRleEIKCghfZW5hYmxlZA==');

@$core.Deprecated('Use getTreePowerRequestDescriptor instead')
const GetTreePowerRequest$json = {
  '1': 'GetTreePowerRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'metric', '3': 3, '4': 1, '5': 9, '10': 'metric'},
    {'1': 'max_distance', '3': 4, '4': 1, '5': 13, '10': 'maxDistance'},
    {'1': 'allocation', '3': 5, '4': 1, '5': 9, '10': 'allocation'},
    {'1': 'include_scene', '3': 6, '4': 1, '5': 8, '10': 'includeScene'},
  ],
};

/// Descriptor for `GetTreePowerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreePowerRequestDescriptor = $convert.base64Decode(
    'ChNHZXRUcmVlUG93ZXJSZXF1ZXN0Eh0KCnNlc3Npb25faWQYASABKAlSCXNlc3Npb25JZBIrCh'
    'FleHBlY3RlZF9yZXZpc2lvbhgCIAEoBFIQZXhwZWN0ZWRSZXZpc2lvbhIWCgZtZXRyaWMYAyAB'
    'KAlSBm1ldHJpYxIhCgxtYXhfZGlzdGFuY2UYBCABKA1SC21heERpc3RhbmNlEh4KCmFsbG9jYX'
    'Rpb24YBSABKAlSCmFsbG9jYXRpb24SIwoNaW5jbHVkZV9zY2VuZRgGIAEoCFIMaW5jbHVkZVNj'
    'ZW5l');

@$core.Deprecated('Use getTreePowerResponseDescriptor instead')
const GetTreePowerResponse$json = {
  '1': 'GetTreePowerResponse',
  '2': [
    {'1': 'revision', '3': 1, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'metric',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.TreePowerMetric',
      '10': 'metric'
    },
    {
      '1': 'metrics',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.TreePowerMetric',
      '10': 'metrics'
    },
    {
      '1': 'entries',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.TreePowerEntry',
      '10': 'entries'
    },
    {
      '1': 'scene',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.TreeScene',
      '10': 'scene'
    },
  ],
};

/// Descriptor for `GetTreePowerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreePowerResponseDescriptor = $convert.base64Decode(
    'ChRHZXRUcmVlUG93ZXJSZXNwb25zZRIaCghyZXZpc2lvbhgBIAEoBFIIcmV2aXNpb24SMAoGbW'
    'V0cmljGAIgASgLMhgucG9iMi52MS5UcmVlUG93ZXJNZXRyaWNSBm1ldHJpYxIyCgdtZXRyaWNz'
    'GAMgAygLMhgucG9iMi52MS5UcmVlUG93ZXJNZXRyaWNSB21ldHJpY3MSMQoHZW50cmllcxgEIA'
    'MoCzIXLnBvYjIudjEuVHJlZVBvd2VyRW50cnlSB2VudHJpZXMSKAoFc2NlbmUYBSABKAsyEi5w'
    'b2IyLnYxLlRyZWVTY2VuZVIFc2NlbmU=');

@$core.Deprecated('Use treePowerMetricDescriptor instead')
const TreePowerMetric$json = {
  '1': 'TreePowerMetric',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `TreePowerMetric`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treePowerMetricDescriptor = $convert.base64Decode(
    'Cg9UcmVlUG93ZXJNZXRyaWMSDgoCaWQYASABKAlSAmlkEhQKBWxhYmVsGAIgASgJUgVsYWJlbA'
    '==');

@$core.Deprecated('Use watchTreePowerRequestDescriptor instead')
const WatchTreePowerRequest$json = {
  '1': 'WatchTreePowerRequest',
  '2': [
    {
      '1': 'query',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.GetTreePowerRequest',
      '10': 'query'
    },
  ],
};

/// Descriptor for `WatchTreePowerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchTreePowerRequestDescriptor = $convert.base64Decode(
    'ChVXYXRjaFRyZWVQb3dlclJlcXVlc3QSMgoFcXVlcnkYASABKAsyHC5wb2IyLnYxLkdldFRyZW'
    'VQb3dlclJlcXVlc3RSBXF1ZXJ5');

@$core.Deprecated('Use watchTreePowerResponseDescriptor instead')
const WatchTreePowerResponse$json = {
  '1': 'WatchTreePowerResponse',
  '2': [
    {'1': 'progress', '3': 1, '4': 1, '5': 13, '9': 0, '10': 'progress'},
    {
      '1': 'result',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.GetTreePowerResponse',
      '9': 0,
      '10': 'result'
    },
  ],
  '8': [
    {'1': 'update'},
  ],
};

/// Descriptor for `WatchTreePowerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List watchTreePowerResponseDescriptor = $convert.base64Decode(
    'ChZXYXRjaFRyZWVQb3dlclJlc3BvbnNlEhwKCHByb2dyZXNzGAEgASgNSABSCHByb2dyZXNzEj'
    'cKBnJlc3VsdBgCIAEoCzIdLnBvYjIudjEuR2V0VHJlZVBvd2VyUmVzcG9uc2VIAFIGcmVzdWx0'
    'QggKBnVwZGF0ZQ==');

@$core.Deprecated('Use treePowerEntryDescriptor instead')
const TreePowerEntry$json = {
  '1': 'TreePowerEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'kind', '3': 3, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'allocated', '3': 4, '4': 1, '5': 8, '10': 'allocated'},
    {'1': 'distance', '3': 5, '4': 1, '5': 13, '10': 'distance'},
    {'1': 'power', '3': 6, '4': 1, '5': 1, '10': 'power'},
    {'1': 'path_power', '3': 7, '4': 1, '5': 1, '10': 'pathPower'},
    {'1': 'power_text', '3': 8, '4': 1, '5': 9, '10': 'powerText'},
    {'1': 'path_power_text', '3': 9, '4': 1, '5': 9, '10': 'pathPowerText'},
  ],
};

/// Descriptor for `TreePowerEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treePowerEntryDescriptor = $convert.base64Decode(
    'Cg5UcmVlUG93ZXJFbnRyeRIOCgJpZBgBIAEoDVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRISCg'
    'RraW5kGAMgASgJUgRraW5kEhwKCWFsbG9jYXRlZBgEIAEoCFIJYWxsb2NhdGVkEhoKCGRpc3Rh'
    'bmNlGAUgASgNUghkaXN0YW5jZRIUCgVwb3dlchgGIAEoAVIFcG93ZXISHQoKcGF0aF9wb3dlch'
    'gHIAEoAVIJcGF0aFBvd2VyEh0KCnBvd2VyX3RleHQYCCABKAlSCXBvd2VyVGV4dBImCg9wYXRo'
    'X3Bvd2VyX3RleHQYCSABKAlSDXBhdGhQb3dlclRleHQ=');

@$core.Deprecated('Use treeSceneDescriptor instead')
const TreeScene$json = {
  '1': 'TreeScene',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 1, '10': 'width'},
    {'1': 'height', '3': 2, '4': 1, '5': 1, '10': 'height'},
    {'1': 'scale', '3': 3, '4': 1, '5': 1, '10': 'scale'},
    {'1': 'offset_x', '3': 4, '4': 1, '5': 1, '10': 'offsetX'},
    {'1': 'offset_y', '3': 5, '4': 1, '5': 1, '10': 'offsetY'},
    {
      '1': 'commands',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.TreeDrawCommand',
      '10': 'commands'
    },
    {'1': 'asset_id', '3': 7, '4': 1, '5': 9, '10': 'assetId'},
  ],
};

/// Descriptor for `TreeScene`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeSceneDescriptor = $convert.base64Decode(
    'CglUcmVlU2NlbmUSFAoFd2lkdGgYASABKAFSBXdpZHRoEhYKBmhlaWdodBgCIAEoAVIGaGVpZ2'
    'h0EhQKBXNjYWxlGAMgASgBUgVzY2FsZRIZCghvZmZzZXRfeBgEIAEoAVIHb2Zmc2V0WBIZCghv'
    'ZmZzZXRfeRgFIAEoAVIHb2Zmc2V0WRI0Cghjb21tYW5kcxgGIAMoCzIYLnBvYjIudjEuVHJlZU'
    'RyYXdDb21tYW5kUghjb21tYW5kcxIZCghhc3NldF9pZBgHIAEoCVIHYXNzZXRJZA==');

@$core.Deprecated('Use treeDrawCommandDescriptor instead')
const TreeDrawCommand$json = {
  '1': 'TreeDrawCommand',
  '2': [
    {'1': 'file', '3': 1, '4': 1, '5': 9, '10': 'file'},
    {'1': 'index', '3': 2, '4': 1, '5': 13, '10': 'index'},
    {'1': 'positions', '3': 3, '4': 3, '5': 1, '10': 'positions'},
    {'1': 'uv', '3': 4, '4': 3, '5': 1, '10': 'uv'},
    {'1': 'color', '3': 5, '4': 3, '5': 1, '10': 'color'},
    {'1': 'blend', '3': 6, '4': 1, '5': 9, '10': 'blend'},
    {'1': 'clamp', '3': 7, '4': 1, '5': 8, '10': 'clamp'},
  ],
};

/// Descriptor for `TreeDrawCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treeDrawCommandDescriptor = $convert.base64Decode(
    'Cg9UcmVlRHJhd0NvbW1hbmQSEgoEZmlsZRgBIAEoCVIEZmlsZRIUCgVpbmRleBgCIAEoDVIFaW'
    '5kZXgSHAoJcG9zaXRpb25zGAMgAygBUglwb3NpdGlvbnMSDgoCdXYYBCADKAFSAnV2EhQKBWNv'
    'bG9yGAUgAygBUgVjb2xvchIUCgVibGVuZBgGIAEoCVIFYmxlbmQSFAoFY2xhbXAYByABKAhSBW'
    'NsYW1w');

@$core.Deprecated('Use getTreeTextureRequestDescriptor instead')
const GetTreeTextureRequest$json = {
  '1': 'GetTreeTextureRequest',
  '2': [
    {'1': 'file', '3': 1, '4': 1, '5': 9, '10': 'file'},
    {'1': 'index', '3': 2, '4': 1, '5': 13, '10': 'index'},
    {'1': 'target_size', '3': 3, '4': 1, '5': 13, '10': 'targetSize'},
  ],
};

/// Descriptor for `GetTreeTextureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreeTextureRequestDescriptor = $convert.base64Decode(
    'ChVHZXRUcmVlVGV4dHVyZVJlcXVlc3QSEgoEZmlsZRgBIAEoCVIEZmlsZRIUCgVpbmRleBgCIA'
    'EoDVIFaW5kZXgSHwoLdGFyZ2V0X3NpemUYAyABKA1SCnRhcmdldFNpemU=');

@$core.Deprecated('Use getTreeTextureResponseDescriptor instead')
const GetTreeTextureResponse$json = {
  '1': 'GetTreeTextureResponse',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 13, '10': 'width'},
    {'1': 'height', '3': 2, '4': 1, '5': 13, '10': 'height'},
    {'1': 'mip_level', '3': 3, '4': 1, '5': 13, '10': 'mipLevel'},
    {'1': 'png', '3': 4, '4': 1, '5': 12, '10': 'png'},
  ],
};

/// Descriptor for `GetTreeTextureResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreeTextureResponseDescriptor = $convert.base64Decode(
    'ChZHZXRUcmVlVGV4dHVyZVJlc3BvbnNlEhQKBXdpZHRoGAEgASgNUgV3aWR0aBIWCgZoZWlnaH'
    'QYAiABKA1SBmhlaWdodBIbCgltaXBfbGV2ZWwYAyABKA1SCG1pcExldmVsEhAKA3BuZxgEIAEo'
    'DFIDcG5n');

@$core.Deprecated('Use getEquipmentDetailsRequestDescriptor instead')
const GetEquipmentDetailsRequest$json = {
  '1': 'GetEquipmentDetailsRequest',
  '2': [
    {'1': 'session_id', '3': 1, '4': 1, '5': 9, '10': 'sessionId'},
    {
      '1': 'expected_revision',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'slot', '3': 3, '4': 1, '5': 9, '10': 'slot'},
    {'1': 'item_id', '3': 4, '4': 1, '5': 13, '9': 0, '10': 'itemId'},
    {'1': 'raw', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'raw'},
    {'1': 'compare', '3': 6, '4': 1, '5': 8, '10': 'compare'},
  ],
  '8': [
    {'1': 'item'},
  ],
};

/// Descriptor for `GetEquipmentDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEquipmentDetailsRequestDescriptor = $convert.base64Decode(
    'ChpHZXRFcXVpcG1lbnREZXRhaWxzUmVxdWVzdBIdCgpzZXNzaW9uX2lkGAEgASgJUglzZXNzaW'
    '9uSWQSKwoRZXhwZWN0ZWRfcmV2aXNpb24YAiABKARSEGV4cGVjdGVkUmV2aXNpb24SEgoEc2xv'
    'dBgDIAEoCVIEc2xvdBIZCgdpdGVtX2lkGAQgASgNSABSBml0ZW1JZBISCgNyYXcYBSABKAlIAF'
    'IDcmF3EhgKB2NvbXBhcmUYBiABKAhSB2NvbXBhcmVCBgoEaXRlbQ==');

@$core.Deprecated('Use getEquipmentDetailsResponseDescriptor instead')
const GetEquipmentDetailsResponse$json = {
  '1': 'GetEquipmentDetailsResponse',
  '2': [
    {'1': 'revision', '3': 1, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'details_json', '3': 2, '4': 1, '5': 12, '10': 'detailsJson'},
  ],
};

/// Descriptor for `GetEquipmentDetailsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getEquipmentDetailsResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRFcXVpcG1lbnREZXRhaWxzUmVzcG9uc2USGgoIcmV2aXNpb24YASABKARSCHJldmlzaW'
        '9uEiEKDGRldGFpbHNfanNvbhgCIAEoDFILZGV0YWlsc0pzb24=');

@$core.Deprecated('Use buildEditDescriptor instead')
const BuildEdit$json = {
  '1': 'BuildEdit',
  '2': [
    {
      '1': 'level',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.LevelEdit',
      '9': 0,
      '10': 'level'
    },
    {
      '1': 'config',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.ConfigEdit',
      '9': 0,
      '10': 'config'
    },
    {
      '1': 'gems',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.GemsEdit',
      '9': 0,
      '10': 'gems'
    },
    {
      '1': 'equipment',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.EquipmentEdit',
      '9': 0,
      '10': 'equipment'
    },
    {
      '1': 'passives',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.PassivesEdit',
      '9': 0,
      '10': 'passives'
    },
    {
      '1': 'selection',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SelectionEdit',
      '9': 0,
      '10': 'selection'
    },
    {
      '1': 'add_support',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.AddSupportEdit',
      '9': 0,
      '10': 'addSupport'
    },
    {
      '1': 'tree_node',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.TreeNodeEdit',
      '9': 0,
      '10': 'treeNode'
    },
    {
      '1': 'jewel',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.JewelEdit',
      '9': 0,
      '10': 'jewel'
    },
    {
      '1': 'tree_class',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.TreeClassEdit',
      '9': 0,
      '10': 'treeClass'
    },
    {
      '1': 'skill_choice',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SkillChoiceEdit',
      '9': 0,
      '10': 'skillChoice'
    },
    {
      '1': 'skill_group',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.SkillGroupEdit',
      '9': 0,
      '10': 'skillGroup'
    },
  ],
  '8': [
    {'1': 'operation'},
  ],
};

/// Descriptor for `BuildEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildEditDescriptor = $convert.base64Decode(
    'CglCdWlsZEVkaXQSKgoFbGV2ZWwYASABKAsyEi5wb2IyLnYxLkxldmVsRWRpdEgAUgVsZXZlbB'
    'ItCgZjb25maWcYAiABKAsyEy5wb2IyLnYxLkNvbmZpZ0VkaXRIAFIGY29uZmlnEicKBGdlbXMY'
    'AyABKAsyES5wb2IyLnYxLkdlbXNFZGl0SABSBGdlbXMSNgoJZXF1aXBtZW50GAQgASgLMhYucG'
    '9iMi52MS5FcXVpcG1lbnRFZGl0SABSCWVxdWlwbWVudBIzCghwYXNzaXZlcxgFIAEoCzIVLnBv'
    'YjIudjEuUGFzc2l2ZXNFZGl0SABSCHBhc3NpdmVzEjYKCXNlbGVjdGlvbhgGIAEoCzIWLnBvYj'
    'IudjEuU2VsZWN0aW9uRWRpdEgAUglzZWxlY3Rpb24SOgoLYWRkX3N1cHBvcnQYByABKAsyFy5w'
    'b2IyLnYxLkFkZFN1cHBvcnRFZGl0SABSCmFkZFN1cHBvcnQSNAoJdHJlZV9ub2RlGAggASgLMh'
    'UucG9iMi52MS5UcmVlTm9kZUVkaXRIAFIIdHJlZU5vZGUSKgoFamV3ZWwYCSABKAsyEi5wb2Iy'
    'LnYxLkpld2VsRWRpdEgAUgVqZXdlbBI3Cgp0cmVlX2NsYXNzGAogASgLMhYucG9iMi52MS5Ucm'
    'VlQ2xhc3NFZGl0SABSCXRyZWVDbGFzcxI9Cgxza2lsbF9jaG9pY2UYCyABKAsyGC5wb2IyLnYx'
    'LlNraWxsQ2hvaWNlRWRpdEgAUgtza2lsbENob2ljZRI6Cgtza2lsbF9ncm91cBgMIAEoCzIXLn'
    'BvYjIudjEuU2tpbGxHcm91cEVkaXRIAFIKc2tpbGxHcm91cEILCglvcGVyYXRpb24=');

@$core.Deprecated('Use passiveChangeDescriptor instead')
const PassiveChange$json = {
  '1': 'PassiveChange',
  '2': [
    {'1': 'added', '3': 1, '4': 3, '5': 13, '10': 'added'},
    {'1': 'removed', '3': 2, '4': 3, '5': 13, '10': 'removed'},
    {
      '1': 'attributes',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.PassiveAttributeChange',
      '10': 'attributes'
    },
    {
      '1': 'allocations',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.PassiveAllocationChange',
      '10': 'allocations'
    },
    {
      '1': 'points',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.PassivePointsChange',
      '10': 'points'
    },
  ],
};

/// Descriptor for `PassiveChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List passiveChangeDescriptor = $convert.base64Decode(
    'Cg1QYXNzaXZlQ2hhbmdlEhQKBWFkZGVkGAEgAygNUgVhZGRlZBIYCgdyZW1vdmVkGAIgAygNUg'
    'dyZW1vdmVkEj8KCmF0dHJpYnV0ZXMYAyADKAsyHy5wb2IyLnYxLlBhc3NpdmVBdHRyaWJ1dGVD'
    'aGFuZ2VSCmF0dHJpYnV0ZXMSQgoLYWxsb2NhdGlvbnMYBCADKAsyIC5wb2IyLnYxLlBhc3Npdm'
    'VBbGxvY2F0aW9uQ2hhbmdlUgthbGxvY2F0aW9ucxI0CgZwb2ludHMYBSABKAsyHC5wb2IyLnYx'
    'LlBhc3NpdmVQb2ludHNDaGFuZ2VSBnBvaW50cw==');

@$core.Deprecated('Use passiveAllocationChangeDescriptor instead')
const PassiveAllocationChange$json = {
  '1': 'PassiveAllocationChange',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 13, '10': 'nodeId'},
    {'1': 'before', '3': 2, '4': 1, '5': 9, '10': 'before'},
    {'1': 'after', '3': 3, '4': 1, '5': 9, '10': 'after'},
  ],
};

/// Descriptor for `PassiveAllocationChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List passiveAllocationChangeDescriptor =
    $convert.base64Decode(
        'ChdQYXNzaXZlQWxsb2NhdGlvbkNoYW5nZRIXCgdub2RlX2lkGAEgASgNUgZub2RlSWQSFgoGYm'
        'Vmb3JlGAIgASgJUgZiZWZvcmUSFAoFYWZ0ZXIYAyABKAlSBWFmdGVy');

@$core.Deprecated('Use passivePointsDescriptor instead')
const PassivePoints$json = {
  '1': 'PassivePoints',
  '2': [
    {'1': 'passives', '3': 1, '4': 1, '5': 13, '10': 'passives'},
    {'1': 'weapon_set_1', '3': 2, '4': 1, '5': 13, '10': 'weaponSet1'},
    {'1': 'weapon_set_2', '3': 3, '4': 1, '5': 13, '10': 'weaponSet2'},
  ],
};

/// Descriptor for `PassivePoints`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List passivePointsDescriptor = $convert.base64Decode(
    'Cg1QYXNzaXZlUG9pbnRzEhoKCHBhc3NpdmVzGAEgASgNUghwYXNzaXZlcxIgCgx3ZWFwb25fc2'
    'V0XzEYAiABKA1SCndlYXBvblNldDESIAoMd2VhcG9uX3NldF8yGAMgASgNUgp3ZWFwb25TZXQy');

@$core.Deprecated('Use passivePointsChangeDescriptor instead')
const PassivePointsChange$json = {
  '1': 'PassivePointsChange',
  '2': [
    {
      '1': 'before',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.PassivePoints',
      '10': 'before'
    },
    {
      '1': 'after',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.PassivePoints',
      '10': 'after'
    },
  ],
};

/// Descriptor for `PassivePointsChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List passivePointsChangeDescriptor = $convert.base64Decode(
    'ChNQYXNzaXZlUG9pbnRzQ2hhbmdlEi4KBmJlZm9yZRgBIAEoCzIWLnBvYjIudjEuUGFzc2l2ZV'
    'BvaW50c1IGYmVmb3JlEiwKBWFmdGVyGAIgASgLMhYucG9iMi52MS5QYXNzaXZlUG9pbnRzUgVh'
    'ZnRlcg==');

@$core.Deprecated('Use passiveAttributeChangeDescriptor instead')
const PassiveAttributeChange$json = {
  '1': 'PassiveAttributeChange',
  '2': [
    {'1': 'node_id', '3': 1, '4': 1, '5': 13, '10': 'nodeId'},
    {'1': 'before', '3': 2, '4': 1, '5': 9, '10': 'before'},
    {'1': 'after', '3': 3, '4': 1, '5': 9, '10': 'after'},
  ],
};

/// Descriptor for `PassiveAttributeChange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List passiveAttributeChangeDescriptor =
    $convert.base64Decode(
        'ChZQYXNzaXZlQXR0cmlidXRlQ2hhbmdlEhcKB25vZGVfaWQYASABKA1SBm5vZGVJZBIWCgZiZW'
        'ZvcmUYAiABKAlSBmJlZm9yZRIUCgVhZnRlchgDIAEoCVIFYWZ0ZXI=');

@$core.Deprecated('Use statDeltaDescriptor instead')
const StatDelta$json = {
  '1': 'StatDelta',
  '2': [
    {'1': 'stat', '3': 1, '4': 1, '5': 9, '10': 'stat'},
    {'1': 'before', '3': 2, '4': 1, '5': 1, '10': 'before'},
    {'1': 'after', '3': 3, '4': 1, '5': 1, '10': 'after'},
    {'1': 'difference', '3': 4, '4': 1, '5': 1, '10': 'difference'},
  ],
};

/// Descriptor for `StatDelta`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statDeltaDescriptor = $convert.base64Decode(
    'CglTdGF0RGVsdGESEgoEc3RhdBgBIAEoCVIEc3RhdBIWCgZiZWZvcmUYAiABKAFSBmJlZm9yZR'
    'IUCgVhZnRlchgDIAEoAVIFYWZ0ZXISHgoKZGlmZmVyZW5jZRgEIAEoAVIKZGlmZmVyZW5jZQ==');

@$core.Deprecated('Use buildComparisonDescriptor instead')
const BuildComparison$json = {
  '1': 'BuildComparison',
  '2': [
    {
      '1': 'before',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.CalculationResult',
      '10': 'before'
    },
    {
      '1': 'after',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.pob2.v1.CalculationResult',
      '10': 'after'
    },
    {
      '1': 'deltas',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.pob2.v1.StatDelta',
      '10': 'deltas'
    },
  ],
};

/// Descriptor for `BuildComparison`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buildComparisonDescriptor = $convert.base64Decode(
    'Cg9CdWlsZENvbXBhcmlzb24SMgoGYmVmb3JlGAEgASgLMhoucG9iMi52MS5DYWxjdWxhdGlvbl'
    'Jlc3VsdFIGYmVmb3JlEjAKBWFmdGVyGAIgASgLMhoucG9iMi52MS5DYWxjdWxhdGlvblJlc3Vs'
    'dFIFYWZ0ZXISKgoGZGVsdGFzGAMgAygLMhIucG9iMi52MS5TdGF0RGVsdGFSBmRlbHRhcw==');
