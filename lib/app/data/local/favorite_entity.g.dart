// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetFavoriteEntityCollection on Isar {
  IsarCollection<FavoriteEntity> get favoriteEntitys => this.collection();
}

const FavoriteEntitySchema = CollectionSchema(
  name: r'FavoriteEntity',
  id: -2424802716597037588,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deleted': PropertySchema(id: 1, name: r'deleted', type: IsarType.bool),
    r'dirty': PropertySchema(id: 2, name: r'dirty', type: IsarType.bool),
    r'nameId': PropertySchema(id: 3, name: r'nameId', type: IsarType.string),
    r'note': PropertySchema(id: 4, name: r'note', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _favoriteEntityEstimateSize,
  serialize: _favoriteEntitySerialize,
  deserialize: _favoriteEntityDeserialize,
  deserializeProp: _favoriteEntityDeserializeProp,
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
  },
  links: {},
  embeddedSchemas: {},

  getId: _favoriteEntityGetId,
  getLinks: _favoriteEntityGetLinks,
  attach: _favoriteEntityAttach,
  version: '3.4.1',
);

int _favoriteEntityEstimateSize(
  FavoriteEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nameId.length * 3;
  bytesCount += 3 + object.note.length * 3;
  return bytesCount;
}

void _favoriteEntitySerialize(
  FavoriteEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.deleted);
  writer.writeBool(offsets[2], object.dirty);
  writer.writeString(offsets[3], object.nameId);
  writer.writeString(offsets[4], object.note);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

FavoriteEntity _favoriteEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FavoriteEntity();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.deleted = reader.readBool(offsets[1]);
  object.dirty = reader.readBool(offsets[2]);
  object.nameId = reader.readString(offsets[3]);
  object.note = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _favoriteEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _favoriteEntityGetId(FavoriteEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _favoriteEntityGetLinks(FavoriteEntity object) {
  return [];
}

void _favoriteEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  FavoriteEntity object,
) {}

extension FavoriteEntityByIndex on IsarCollection<FavoriteEntity> {
  Future<FavoriteEntity?> getByNameId(String nameId) {
    return getByIndex(r'nameId', [nameId]);
  }

  FavoriteEntity? getByNameIdSync(String nameId) {
    return getByIndexSync(r'nameId', [nameId]);
  }

  Future<bool> deleteByNameId(String nameId) {
    return deleteByIndex(r'nameId', [nameId]);
  }

  bool deleteByNameIdSync(String nameId) {
    return deleteByIndexSync(r'nameId', [nameId]);
  }

  Future<List<FavoriteEntity?>> getAllByNameId(List<String> nameIdValues) {
    final values = nameIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'nameId', values);
  }

  List<FavoriteEntity?> getAllByNameIdSync(List<String> nameIdValues) {
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

  Future<Id> putByNameId(FavoriteEntity object) {
    return putByIndex(r'nameId', object);
  }

  Id putByNameIdSync(FavoriteEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'nameId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNameId(List<FavoriteEntity> objects) {
    return putAllByIndex(r'nameId', objects);
  }

  List<Id> putAllByNameIdSync(
    List<FavoriteEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'nameId', objects, saveLinks: saveLinks);
  }
}

extension FavoriteEntityQueryWhereSort
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QWhere> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FavoriteEntityQueryWhere
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QWhereClause> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause> isarIdEqualTo(
    Id isarId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
  isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
  isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause> nameIdEqualTo(
    String nameId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'nameId', value: [nameId]),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterWhereClause>
  nameIdNotEqualTo(String nameId) {
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
}

extension FavoriteEntityQueryFilter
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QFilterCondition> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  deletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deleted', value: value),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  dirtyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dirty', value: value),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  isarIdGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  isarIdLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  isarIdBetween(
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdGreaterThan(
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdLessThan(
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdBetween(
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameId', value: ''),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  nameIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameId', value: ''),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterFilterCondition>
  updatedAtBetween(
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
}

extension FavoriteEntityQueryObject
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QFilterCondition> {}

extension FavoriteEntityQueryLinks
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QFilterCondition> {}

extension FavoriteEntityQuerySortBy
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QSortBy> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirty', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirty', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByNameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  sortByNameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FavoriteEntityQuerySortThenBy
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QSortThenBy> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirty', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dirty', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByNameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  thenByNameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameId', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FavoriteEntityQueryWhereDistinct
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> {
  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dirty');
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByNameId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FavoriteEntity, FavoriteEntity, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension FavoriteEntityQueryProperty
    on QueryBuilder<FavoriteEntity, FavoriteEntity, QQueryProperty> {
  QueryBuilder<FavoriteEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<FavoriteEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<FavoriteEntity, bool, QQueryOperations> deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<FavoriteEntity, bool, QQueryOperations> dirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dirty');
    });
  }

  QueryBuilder<FavoriteEntity, String, QQueryOperations> nameIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameId');
    });
  }

  QueryBuilder<FavoriteEntity, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<FavoriteEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
