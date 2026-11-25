// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetNameEntityCollection on Isar {
  IsarCollection<NameEntity> get nameEntitys => this.collection();
}

const NameEntitySchema = CollectionSchema(
  name: r'NameEntity',
  id: 4530843104995042790,
  properties: {
    r'audioUrl': PropertySchema(
      id: 0,
      name: r'audioUrl',
      type: IsarType.string,
    ),
    r'easyAbroad': PropertySchema(
      id: 1,
      name: r'easyAbroad',
      type: IsarType.bool,
    ),
    r'faiths': PropertySchema(
      id: 2,
      name: r'faiths',
      type: IsarType.stringList,
    ),
    r'famous': PropertySchema(
      id: 3,
      name: r'famous',
      type: IsarType.stringList,
    ),
    r'gender': PropertySchema(
      id: 4,
      name: r'gender',
      type: IsarType.string,
      enumMap: _NameEntitygenderEnumValueMap,
    ),
    r'languages': PropertySchema(
      id: 5,
      name: r'languages',
      type: IsarType.stringList,
    ),
    r'meaningAm': PropertySchema(
      id: 6,
      name: r'meaningAm',
      type: IsarType.string,
    ),
    r'meaningEn': PropertySchema(
      id: 7,
      name: r'meaningEn',
      type: IsarType.string,
    ),
    r'modern': PropertySchema(id: 8, name: r'modern', type: IsarType.bool),
    r'nameGeez': PropertySchema(
      id: 9,
      name: r'nameGeez',
      type: IsarType.string,
    ),
    r'nameId': PropertySchema(id: 10, name: r'nameId', type: IsarType.string),
    r'nameLatin': PropertySchema(
      id: 11,
      name: r'nameLatin',
      type: IsarType.string,
    ),
    r'nicknames': PropertySchema(
      id: 12,
      name: r'nicknames',
      type: IsarType.stringList,
    ),
    r'originAm': PropertySchema(
      id: 13,
      name: r'originAm',
      type: IsarType.string,
    ),
    r'originEn': PropertySchema(
      id: 14,
      name: r'originEn',
      type: IsarType.string,
    ),
    r'popularity': PropertySchema(
      id: 15,
      name: r'popularity',
      type: IsarType.long,
    ),
    r'pronunciation': PropertySchema(
      id: 16,
      name: r'pronunciation',
      type: IsarType.string,
    ),
    r'rarity': PropertySchema(
      id: 17,
      name: r'rarity',
      type: IsarType.string,
      enumMap: _NameEntityrarityEnumValueMap,
    ),
    r'similar': PropertySchema(
      id: 18,
      name: r'similar',
      type: IsarType.stringList,
    ),
    r'spellings': PropertySchema(
      id: 19,
      name: r'spellings',
      type: IsarType.stringList,
    ),
    r'syllables': PropertySchema(
      id: 20,
      name: r'syllables',
      type: IsarType.long,
    ),
    r'themes': PropertySchema(
      id: 21,
      name: r'themes',
      type: IsarType.stringList,
    ),
    r'trendScore': PropertySchema(
      id: 22,
      name: r'trendScore',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 23,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'verified': PropertySchema(id: 24, name: r'verified', type: IsarType.bool),
  },

  estimateSize: _nameEntityEstimateSize,
  serialize: _nameEntitySerialize,
  deserialize: _nameEntityDeserialize,
  deserializeProp: _nameEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'nameId': IndexSchema(
      id: -6985159207553840634,
      name: r'nameId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'nameId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'updatedAt': IndexSchema(
      id: -6238191080293565125,
      name: r'updatedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updatedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _nameEntityGetId,
  getLinks: _nameEntityGetLinks,
  attach: _nameEntityAttach,
  version: '3.4.1',
);

int _nameEntityEstimateSize(
  NameEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.audioUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.faiths.length * 3;
  {
    for (var i = 0; i < object.faiths.length; i++) {
      final value = object.faiths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.famous.length * 3;
  {
    for (var i = 0; i < object.famous.length; i++) {
      final value = object.famous[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.gender.name.length * 3;
  bytesCount += 3 + object.languages.length * 3;
  {
    for (var i = 0; i < object.languages.length; i++) {
      final value = object.languages[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.meaningAm.length * 3;
  bytesCount += 3 + object.meaningEn.length * 3;
  bytesCount += 3 + object.nameGeez.length * 3;
  bytesCount += 3 + object.nameId.length * 3;
  bytesCount += 3 + object.nameLatin.length * 3;
  bytesCount += 3 + object.nicknames.length * 3;
  {
    for (var i = 0; i < object.nicknames.length; i++) {
      final value = object.nicknames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.originAm.length * 3;
  bytesCount += 3 + object.originEn.length * 3;
  {
    final value = object.pronunciation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rarity.name.length * 3;
  bytesCount += 3 + object.similar.length * 3;
  {
    for (var i = 0; i < object.similar.length; i++) {
      final value = object.similar[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.spellings.length * 3;
  {
    for (var i = 0; i < object.spellings.length; i++) {
      final value = object.spellings[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.themes.length * 3;
  {
    for (var i = 0; i < object.themes.length; i++) {
      final value = object.themes[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _nameEntitySerialize(
  NameEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.audioUrl);
  writer.writeBool(offsets[1], object.easyAbroad);
  writer.writeStringList(offsets[2], object.faiths);
  writer.writeStringList(offsets[3], object.famous);
  writer.writeString(offsets[4], object.gender.name);
  writer.writeStringList(offsets[5], object.languages);
  writer.writeString(offsets[6], object.meaningAm);
  writer.writeString(offsets[7], object.meaningEn);
  writer.writeBool(offsets[8], object.modern);
  writer.writeString(offsets[9], object.nameGeez);
  writer.writeString(offsets[10], object.nameId);
  writer.writeString(offsets[11], object.nameLatin);
  writer.writeStringList(offsets[12], object.nicknames);
  writer.writeString(offsets[13], object.originAm);
  writer.writeString(offsets[14], object.originEn);
  writer.writeLong(offsets[15], object.popularity);
  writer.writeString(offsets[16], object.pronunciation);
  writer.writeString(offsets[17], object.rarity.name);
  writer.writeStringList(offsets[18], object.similar);
  writer.writeStringList(offsets[19], object.spellings);
  writer.writeLong(offsets[20], object.syllables);
  writer.writeStringList(offsets[21], object.themes);
  writer.writeLong(offsets[22], object.trendScore);
  writer.writeDateTime(offsets[23], object.updatedAt);
  writer.writeBool(offsets[24], object.verified);
}

NameEntity _nameEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NameEntity();
  object.audioUrl = reader.readStringOrNull(offsets[0]);
  object.easyAbroad = reader.readBool(offsets[1]);
  object.faiths = reader.readStringList(offsets[2]) ?? [];
  object.famous = reader.readStringList(offsets[3]) ?? [];
  object.gender =
      _NameEntitygenderValueEnumMap[reader.readStringOrNull(offsets[4])] ??
      Gender.boy;
  object.languages = reader.readStringList(offsets[5]) ?? [];
  object.meaningAm = reader.readString(offsets[6]);
  object.meaningEn = reader.readString(offsets[7]);
  object.modern = reader.readBool(offsets[8]);
  object.nameGeez = reader.readString(offsets[9]);
  object.nameId = reader.readString(offsets[10]);
  object.nameLatin = reader.readString(offsets[11]);
  object.nicknames = reader.readStringList(offsets[12]) ?? [];
  object.originAm = reader.readString(offsets[13]);
  object.originEn = reader.readString(offsets[14]);
  object.popularity = reader.readLong(offsets[15]);
  object.pronunciation = reader.readStringOrNull(offsets[16]);
  object.rarity =
      _NameEntityrarityValueEnumMap[reader.readStringOrNull(offsets[17])] ??
      Rarity.popular;
  object.similar = reader.readStringList(offsets[18]) ?? [];
  object.spellings = reader.readStringList(offsets[19]) ?? [];
  object.syllables = reader.readLong(offsets[20]);
  object.themes = reader.readStringList(offsets[21]) ?? [];
  object.trendScore = reader.readLong(offsets[22]);
  object.updatedAt = reader.readDateTime(offsets[23]);
  object.verified = reader.readBool(offsets[24]);
  return object;
}

P _nameEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (_NameEntitygenderValueEnumMap[reader.readStringOrNull(offset)] ??
              Gender.boy)
          as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (_NameEntityrarityValueEnumMap[reader.readStringOrNull(offset)] ??
              Rarity.popular)
          as P;
    case 18:
      return (reader.readStringList(offset) ?? []) as P;
    case 19:
      return (reader.readStringList(offset) ?? []) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    case 21:
      return (reader.readStringList(offset) ?? []) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readDateTime(offset)) as P;
    case 24:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _NameEntitygenderEnumValueMap = {
  r'boy': r'boy',
  r'girl': r'girl',
  r'unisex': r'unisex',
};
const _NameEntitygenderValueEnumMap = {
  r'boy': Gender.boy,
  r'girl': Gender.girl,
  r'unisex': Gender.unisex,
};
const _NameEntityrarityEnumValueMap = {
  r'popular': r'popular',
  r'unique': r'unique',
  r'rare': r'rare',
};
const _NameEntityrarityValueEnumMap = {
  r'popular': Rarity.popular,
  r'unique': Rarity.unique,
  r'rare': Rarity.rare,
};

Id _nameEntityGetId(NameEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _nameEntityGetLinks(NameEntity object) {
  return [];
}

void _nameEntityAttach(IsarCollection<dynamic> col, Id id, NameEntity object) {}

extension NameEntityByIndex on IsarCollection<NameEntity> {
  Future<NameEntity?> getByNameId(String nameId) {
    return getByIndex(r'nameId', [nameId]);
  }

  NameEntity? getByNameIdSync(String nameId) {
    return getByIndexSync(r'nameId', [nameId]);
  }

  Future<bool> deleteByNameId(String nameId) {
    return deleteByIndex(r'nameId', [nameId]);
  }

  bool deleteByNameIdSync(String nameId) {
    return deleteByIndexSync(r'nameId', [nameId]);
  }

  Future<List<NameEntity?>> getAllByNameId(List<String> nameIdValues) {
    final values = nameIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'nameId', values);
  }

  List<NameEntity?> getAllByNameIdSync(List<String> nameIdValues) {
    final values = nameIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'nameId', values);
  }

  Future<int> deleteAllByNameId(List<String> nameIdValues) {
    final values = nameIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'nameId', values);
  }

  int deleteAllByNameIdSync(List<String> nameIdValues) {
    final values = nameIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'nameId', values);
  }

  Future<Id> putByNameId(NameEntity object) {
    return putByIndex(r'nameId', object);
  }

  Id putByNameIdSync(NameEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'nameId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNameId(List<NameEntity> objects) {
    return putAllByIndex(r'nameId', objects);
  }

  List<Id> putAllByNameIdSync(
    List<NameEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'nameId', objects, saveLinks: saveLinks);
  }
}

extension NameEntityQueryWhereSort
    on QueryBuilder<NameEntity, NameEntity, QWhere> {
  QueryBuilder<NameEntity, NameEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhere> anyUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updatedAt'),
      );
    });
  }
}

extension NameEntityQueryWhere
    on QueryBuilder<NameEntity, NameEntity, QWhereClause> {
  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> isarIdEqualTo(
    Id isarId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> isarIdNotEqualTo(
    Id isarId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> isarIdGreaterThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> isarIdLessThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> nameIdEqualTo(
    String nameId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'nameId', value: [nameId]),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> nameIdNotEqualTo(
    String nameId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameId',
                lower: [],
                upper: [nameId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameId',
                lower: [nameId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameId',
                lower: [nameId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nameId',
                lower: [],
                upper: [nameId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> updatedAtEqualTo(
    DateTime updatedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'updatedAt', value: [updatedAt]),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> updatedAtNotEqualTo(
    DateTime updatedAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [updatedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'updatedAt',
                lower: [],
                upper: [updatedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> updatedAtGreaterThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [updatedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> updatedAtLessThan(
    DateTime updatedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [],
          upper: [updatedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterWhereClause> updatedAtBetween(
    DateTime lowerUpdatedAt,
    DateTime upperUpdatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'updatedAt',
          lower: [lowerUpdatedAt],
          includeLower: includeLower,
          upper: [upperUpdatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NameEntityQueryFilter
    on QueryBuilder<NameEntity, NameEntity, QFilterCondition> {
  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> audioUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'audioUrl'),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  audioUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'audioUrl'),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> audioUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'audioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  audioUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'audioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> audioUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'audioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> audioUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'audioUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  audioUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'audioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> audioUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'audioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> audioUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'audioUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> audioUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'audioUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  audioUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'audioUrl', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  audioUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'audioUrl', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> easyAbroadEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'easyAbroad', value: value),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'faiths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'faiths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'faiths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'faiths',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'faiths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'faiths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'faiths',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'faiths',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'faiths', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'faiths', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'faiths', length, true, length, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> faithsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'faiths', 0, true, 0, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'faiths', 0, false, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'faiths', 0, true, length, include);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'faiths', length, include, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  faithsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'faiths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'famous',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'famous',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'famous',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'famous',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'famous',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'famous',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'famous',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'famous',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'famous', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'famous', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'famous', length, true, length, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> famousIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'famous', 0, true, 0, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'famous', 0, false, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'famous', 0, true, length, include);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'famous', length, include, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  famousLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'famous',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderEqualTo(
    Gender value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderGreaterThan(
    Gender value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderLessThan(
    Gender value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderBetween(
    Gender lower,
    Gender upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gender',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'gender',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'gender',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gender', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'gender', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> isarIdEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'languages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'languages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'languages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'languages',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'languages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'languages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'languages',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'languages',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'languages', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'languages', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'languages', length, true, length, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'languages', 0, true, 0, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'languages', 0, false, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'languages', 0, true, length, include);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'languages', length, include, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  languagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'languages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningAmEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'meaningAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningAmGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'meaningAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningAmLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'meaningAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningAmBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'meaningAm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningAmStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'meaningAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningAmEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'meaningAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningAmContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'meaningAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningAmMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'meaningAm',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningAmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'meaningAm', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningAmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'meaningAm', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningEnEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'meaningEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningEnGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'meaningEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningEnLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'meaningEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningEnBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'meaningEn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningEnStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'meaningEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningEnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'meaningEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningEnContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'meaningEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> meaningEnMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'meaningEn',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'meaningEn', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  meaningEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'meaningEn', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> modernEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'modern', value: value),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameGeezEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameGeez',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameGeezGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameGeez',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameGeezLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameGeez',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameGeezBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameGeez',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameGeezStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameGeez',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameGeezEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameGeez',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameGeezContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameGeez',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameGeezMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameGeez',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameGeezIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameGeez', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameGeezIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameGeez', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameId', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameId', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameLatinEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameLatin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameLatinGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameLatin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameLatinLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameLatin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameLatinBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameLatin',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameLatinStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameLatin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameLatinEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameLatin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameLatinContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameLatin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> nameLatinMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameLatin',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameLatinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameLatin', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nameLatinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameLatin', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nicknames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nicknames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nicknames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nicknames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nicknames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nicknames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nicknames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nicknames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nicknames', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nicknames', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'nicknames', length, true, length, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'nicknames', 0, true, 0, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'nicknames', 0, false, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'nicknames', 0, true, length, include);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'nicknames', length, include, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  nicknamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nicknames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originAmEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'originAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originAmGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'originAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originAmLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'originAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originAmBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'originAm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originAmStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'originAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originAmEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'originAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originAmContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'originAm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originAmMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'originAm',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originAmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'originAm', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originAmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'originAm', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originEnEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'originEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originEnGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'originEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originEnLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'originEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originEnBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'originEn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originEnStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'originEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originEnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'originEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originEnContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'originEn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> originEnMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'originEn',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'originEn', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  originEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'originEn', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> popularityEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'popularity', value: value),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  popularityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'popularity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  popularityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'popularity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> popularityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'popularity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pronunciation'),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pronunciation'),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pronunciation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pronunciation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pronunciation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pronunciation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pronunciation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pronunciation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pronunciation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pronunciation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pronunciation', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  pronunciationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pronunciation', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityEqualTo(
    Rarity value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rarity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityGreaterThan(
    Rarity value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rarity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityLessThan(
    Rarity value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rarity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityBetween(
    Rarity lower,
    Rarity upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rarity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rarity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rarity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rarity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rarity',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> rarityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rarity', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  rarityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rarity', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'similar',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'similar',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'similar',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'similar',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'similar',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'similar',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'similar',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'similar',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'similar', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'similar', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'similar', length, true, length, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> similarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'similar', 0, true, 0, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'similar', 0, false, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'similar', 0, true, length, include);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'similar', length, include, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  similarLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'similar',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'spellings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'spellings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'spellings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'spellings',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'spellings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'spellings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'spellings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'spellings',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'spellings', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'spellings', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spellings', length, true, length, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spellings', 0, true, 0, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spellings', 0, false, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spellings', 0, true, length, include);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'spellings', length, include, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  spellingsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spellings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> syllablesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syllables', value: value),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  syllablesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syllables',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> syllablesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syllables',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> syllablesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syllables',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'themes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'themes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'themes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'themes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'themes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themes', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'themes', value: ''),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'themes', length, true, length, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> themesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'themes', 0, true, 0, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'themes', 0, false, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'themes', 0, true, length, include);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'themes', length, include, 999999, true);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  themesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'themes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> trendScoreEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trendScore', value: value),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  trendScoreGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trendScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  trendScoreLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trendScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> trendScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trendScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterFilterCondition> verifiedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verified', value: value),
      );
    });
  }
}

extension NameEntityQueryObject
    on QueryBuilder<NameEntity, NameEntity, QFilterCondition> {}

extension NameEntityQueryLinks
    on QueryBuilder<NameEntity, NameEntity, QFilterCondition> {}

extension NameEntityQuerySortBy
    on QueryBuilder<NameEntity, NameEntity, QSortBy> {
  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByAudioUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioUrl', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByAudioUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioUrl', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByEasyAbroad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyAbroad', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByEasyAbroadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyAbroad', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByMeaningAm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningAm', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByMeaningAmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningAm', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByMeaningEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningEn', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByMeaningEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningEn', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByModern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modern', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByModernDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modern', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByNameGeez() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameGeez', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByNameGeezDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameGeez', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByNameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByNameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByNameLatin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLatin', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByNameLatinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLatin', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByOriginAm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originAm', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByOriginAmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originAm', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByOriginEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originEn', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByOriginEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originEn', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByPopularity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByPopularityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByPronunciation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pronunciation', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByPronunciationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pronunciation', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByRarity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rarity', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByRarityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rarity', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortBySyllables() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllables', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortBySyllablesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllables', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByTrendScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendScore', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByTrendScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendScore', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension NameEntityQuerySortThenBy
    on QueryBuilder<NameEntity, NameEntity, QSortThenBy> {
  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByAudioUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioUrl', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByAudioUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioUrl', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByEasyAbroad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyAbroad', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByEasyAbroadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easyAbroad', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByMeaningAm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningAm', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByMeaningAmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningAm', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByMeaningEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningEn', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByMeaningEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'meaningEn', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByModern() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modern', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByModernDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modern', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByNameGeez() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameGeez', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByNameGeezDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameGeez', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByNameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByNameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByNameLatin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLatin', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByNameLatinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameLatin', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByOriginAm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originAm', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByOriginAmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originAm', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByOriginEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originEn', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByOriginEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originEn', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByPopularity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByPopularityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'popularity', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByPronunciation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pronunciation', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByPronunciationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pronunciation', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByRarity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rarity', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByRarityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rarity', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenBySyllables() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllables', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenBySyllablesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllables', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByTrendScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendScore', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByTrendScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendScore', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QAfterSortBy> thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension NameEntityQueryWhereDistinct
    on QueryBuilder<NameEntity, NameEntity, QDistinct> {
  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByAudioUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByEasyAbroad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'easyAbroad');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByFaiths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'faiths');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByFamous() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'famous');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByGender({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByLanguages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languages');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByMeaningAm({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meaningAm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByMeaningEn({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meaningEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByModern() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modern');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByNameGeez({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameGeez', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByNameId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByNameLatin({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameLatin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByNicknames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nicknames');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByOriginAm({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originAm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByOriginEn({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originEn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByPopularity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'popularity');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByPronunciation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'pronunciation',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByRarity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rarity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctBySimilar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'similar');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctBySpellings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spellings');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctBySyllables() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syllables');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByThemes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themes');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByTrendScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trendScore');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<NameEntity, NameEntity, QDistinct> distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }
}

extension NameEntityQueryProperty
    on QueryBuilder<NameEntity, NameEntity, QQueryProperty> {
  QueryBuilder<NameEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<NameEntity, String?, QQueryOperations> audioUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioUrl');
    });
  }

  QueryBuilder<NameEntity, bool, QQueryOperations> easyAbroadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'easyAbroad');
    });
  }

  QueryBuilder<NameEntity, List<String>, QQueryOperations> faithsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'faiths');
    });
  }

  QueryBuilder<NameEntity, List<String>, QQueryOperations> famousProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'famous');
    });
  }

  QueryBuilder<NameEntity, Gender, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<NameEntity, List<String>, QQueryOperations> languagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languages');
    });
  }

  QueryBuilder<NameEntity, String, QQueryOperations> meaningAmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meaningAm');
    });
  }

  QueryBuilder<NameEntity, String, QQueryOperations> meaningEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meaningEn');
    });
  }

  QueryBuilder<NameEntity, bool, QQueryOperations> modernProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modern');
    });
  }

  QueryBuilder<NameEntity, String, QQueryOperations> nameGeezProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameGeez');
    });
  }

  QueryBuilder<NameEntity, String, QQueryOperations> nameIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameId');
    });
  }

  QueryBuilder<NameEntity, String, QQueryOperations> nameLatinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameLatin');
    });
  }

  QueryBuilder<NameEntity, List<String>, QQueryOperations> nicknamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nicknames');
    });
  }

  QueryBuilder<NameEntity, String, QQueryOperations> originAmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originAm');
    });
  }

  QueryBuilder<NameEntity, String, QQueryOperations> originEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originEn');
    });
  }

  QueryBuilder<NameEntity, int, QQueryOperations> popularityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'popularity');
    });
  }

  QueryBuilder<NameEntity, String?, QQueryOperations> pronunciationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pronunciation');
    });
  }

  QueryBuilder<NameEntity, Rarity, QQueryOperations> rarityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rarity');
    });
  }

  QueryBuilder<NameEntity, List<String>, QQueryOperations> similarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'similar');
    });
  }

  QueryBuilder<NameEntity, List<String>, QQueryOperations> spellingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spellings');
    });
  }

  QueryBuilder<NameEntity, int, QQueryOperations> syllablesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syllables');
    });
  }

  QueryBuilder<NameEntity, List<String>, QQueryOperations> themesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themes');
    });
  }

  QueryBuilder<NameEntity, int, QQueryOperations> trendScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trendScore');
    });
  }

  QueryBuilder<NameEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<NameEntity, bool, QQueryOperations> verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }
}
