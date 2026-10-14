// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_database.dart';

// ignore_for_file: type=lint
class Meta extends Table with TableInfo<Meta, CatalogueMetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Meta(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueMetaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CatalogueMetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueMetaEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  Meta createAlias(String alias) {
    return Meta(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueMetaEntry extends DataClass
    implements Insertable<CatalogueMetaEntry> {
  final String key;
  final String value;
  const CatalogueMetaEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory CatalogueMetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueMetaEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  CatalogueMetaEntry copyWith({String? key, String? value}) =>
      CatalogueMetaEntry(key: key ?? this.key, value: value ?? this.value);
  CatalogueMetaEntry copyWithCompanion(MetaCompanion data) {
    return CatalogueMetaEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueMetaEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueMetaEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<CatalogueMetaEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<CatalogueMetaEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Categories extends Table with TableInfo<Categories, CatalogueCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Categories(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _nameElMeta = const VerificationMeta('nameEl');
  late final GeneratedColumn<String> nameEl = GeneratedColumn<String>(
    'name_el',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    nameEl,
    nameEn,
    parentId,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_el')) {
      context.handle(
        _nameElMeta,
        nameEl.isAcceptableOrUnknown(data['name_el']!, _nameElMeta),
      );
    } else if (isInserting) {
      context.missing(_nameElMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogueCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      nameEl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_el'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  Categories createAlias(String alias) {
    return Categories(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueCategory extends DataClass
    implements Insertable<CatalogueCategory> {
  final String id;
  final String code;
  final String nameEl;
  final String nameEn;
  final String? parentId;
  final int? sortOrder;
  const CatalogueCategory({
    required this.id,
    required this.code,
    required this.nameEl,
    required this.nameEn,
    this.parentId,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name_el'] = Variable<String>(nameEl);
    map['name_en'] = Variable<String>(nameEn);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      code: Value(code),
      nameEl: Value(nameEl),
      nameEn: Value(nameEn),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory CatalogueCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueCategory(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      nameEl: serializer.fromJson<String>(json['name_el']),
      nameEn: serializer.fromJson<String>(json['name_en']),
      parentId: serializer.fromJson<String?>(json['parent_id']),
      sortOrder: serializer.fromJson<int?>(json['sort_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name_el': serializer.toJson<String>(nameEl),
      'name_en': serializer.toJson<String>(nameEn),
      'parent_id': serializer.toJson<String?>(parentId),
      'sort_order': serializer.toJson<int?>(sortOrder),
    };
  }

  CatalogueCategory copyWith({
    String? id,
    String? code,
    String? nameEl,
    String? nameEn,
    Value<String?> parentId = const Value.absent(),
    Value<int?> sortOrder = const Value.absent(),
  }) => CatalogueCategory(
    id: id ?? this.id,
    code: code ?? this.code,
    nameEl: nameEl ?? this.nameEl,
    nameEn: nameEn ?? this.nameEn,
    parentId: parentId.present ? parentId.value : this.parentId,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  CatalogueCategory copyWithCompanion(CategoriesCompanion data) {
    return CatalogueCategory(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      nameEl: data.nameEl.present ? data.nameEl.value : this.nameEl,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueCategory(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameEl: $nameEl, ')
          ..write('nameEn: $nameEn, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, nameEl, nameEn, parentId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueCategory &&
          other.id == this.id &&
          other.code == this.code &&
          other.nameEl == this.nameEl &&
          other.nameEn == this.nameEn &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CatalogueCategory> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> nameEl;
  final Value<String> nameEn;
  final Value<String?> parentId;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.nameEl = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String code,
    required String nameEl,
    required String nameEn,
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       nameEl = Value(nameEl),
       nameEn = Value(nameEn);
  static Insertable<CatalogueCategory> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? nameEl,
    Expression<String>? nameEn,
    Expression<String>? parentId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (nameEl != null) 'name_el': nameEl,
      if (nameEn != null) 'name_en': nameEn,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? nameEl,
    Value<String>? nameEn,
    Value<String?>? parentId,
    Value<int?>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      nameEl: nameEl ?? this.nameEl,
      nameEn: nameEn ?? this.nameEn,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameEl.present) {
      map['name_el'] = Variable<String>(nameEl.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameEl: $nameEl, ')
          ..write('nameEn: $nameEn, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ClimateZones extends Table
    with TableInfo<ClimateZones, CatalogueClimateZone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ClimateZones(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _nameElMeta = const VerificationMeta('nameEl');
  late final GeneratedColumn<String> nameEl = GeneratedColumn<String>(
    'name_el',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _rulesMeta = const VerificationMeta('rules');
  late final GeneratedColumn<String> rules = GeneratedColumn<String>(
    'rules',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    nameEl,
    nameEn,
    description,
    rules,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'climate_zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueClimateZone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_el')) {
      context.handle(
        _nameElMeta,
        nameEl.isAcceptableOrUnknown(data['name_el']!, _nameElMeta),
      );
    } else if (isInserting) {
      context.missing(_nameElMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('rules')) {
      context.handle(
        _rulesMeta,
        rules.isAcceptableOrUnknown(data['rules']!, _rulesMeta),
      );
    } else if (isInserting) {
      context.missing(_rulesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogueClimateZone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueClimateZone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      nameEl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_el'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      rules: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules'],
      )!,
    );
  }

  @override
  ClimateZones createAlias(String alias) {
    return ClimateZones(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueClimateZone extends DataClass
    implements Insertable<CatalogueClimateZone> {
  final String id;
  final String code;
  final String nameEl;
  final String nameEn;
  final String? description;
  final String rules;
  const CatalogueClimateZone({
    required this.id,
    required this.code,
    required this.nameEl,
    required this.nameEn,
    this.description,
    required this.rules,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name_el'] = Variable<String>(nameEl);
    map['name_en'] = Variable<String>(nameEn);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['rules'] = Variable<String>(rules);
    return map;
  }

  ClimateZonesCompanion toCompanion(bool nullToAbsent) {
    return ClimateZonesCompanion(
      id: Value(id),
      code: Value(code),
      nameEl: Value(nameEl),
      nameEn: Value(nameEn),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      rules: Value(rules),
    );
  }

  factory CatalogueClimateZone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueClimateZone(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      nameEl: serializer.fromJson<String>(json['name_el']),
      nameEn: serializer.fromJson<String>(json['name_en']),
      description: serializer.fromJson<String?>(json['description']),
      rules: serializer.fromJson<String>(json['rules']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name_el': serializer.toJson<String>(nameEl),
      'name_en': serializer.toJson<String>(nameEn),
      'description': serializer.toJson<String?>(description),
      'rules': serializer.toJson<String>(rules),
    };
  }

  CatalogueClimateZone copyWith({
    String? id,
    String? code,
    String? nameEl,
    String? nameEn,
    Value<String?> description = const Value.absent(),
    String? rules,
  }) => CatalogueClimateZone(
    id: id ?? this.id,
    code: code ?? this.code,
    nameEl: nameEl ?? this.nameEl,
    nameEn: nameEn ?? this.nameEn,
    description: description.present ? description.value : this.description,
    rules: rules ?? this.rules,
  );
  CatalogueClimateZone copyWithCompanion(ClimateZonesCompanion data) {
    return CatalogueClimateZone(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      nameEl: data.nameEl.present ? data.nameEl.value : this.nameEl,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      description: data.description.present
          ? data.description.value
          : this.description,
      rules: data.rules.present ? data.rules.value : this.rules,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueClimateZone(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameEl: $nameEl, ')
          ..write('nameEn: $nameEn, ')
          ..write('description: $description, ')
          ..write('rules: $rules')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, nameEl, nameEn, description, rules);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueClimateZone &&
          other.id == this.id &&
          other.code == this.code &&
          other.nameEl == this.nameEl &&
          other.nameEn == this.nameEn &&
          other.description == this.description &&
          other.rules == this.rules);
}

class ClimateZonesCompanion extends UpdateCompanion<CatalogueClimateZone> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> nameEl;
  final Value<String> nameEn;
  final Value<String?> description;
  final Value<String> rules;
  final Value<int> rowid;
  const ClimateZonesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.nameEl = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.description = const Value.absent(),
    this.rules = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClimateZonesCompanion.insert({
    required String id,
    required String code,
    required String nameEl,
    required String nameEn,
    this.description = const Value.absent(),
    required String rules,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       nameEl = Value(nameEl),
       nameEn = Value(nameEn),
       rules = Value(rules);
  static Insertable<CatalogueClimateZone> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? nameEl,
    Expression<String>? nameEn,
    Expression<String>? description,
    Expression<String>? rules,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (nameEl != null) 'name_el': nameEl,
      if (nameEn != null) 'name_en': nameEn,
      if (description != null) 'description': description,
      if (rules != null) 'rules': rules,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClimateZonesCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? nameEl,
    Value<String>? nameEn,
    Value<String?>? description,
    Value<String>? rules,
    Value<int>? rowid,
  }) {
    return ClimateZonesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      nameEl: nameEl ?? this.nameEl,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameEl.present) {
      map['name_el'] = Variable<String>(nameEl.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rules.present) {
      map['rules'] = Variable<String>(rules.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClimateZonesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameEl: $nameEl, ')
          ..write('nameEn: $nameEn, ')
          ..write('description: $description, ')
          ..write('rules: $rules, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Plants extends Table with TableInfo<Plants, CataloguePlant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Plants(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _gbifIdMeta = const VerificationMeta('gbifId');
  late final GeneratedColumn<int> gbifId = GeneratedColumn<int>(
    'gbif_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tempMinCMeta = const VerificationMeta(
    'tempMinC',
  );
  late final GeneratedColumn<double> tempMinC = GeneratedColumn<double>(
    'temp_min_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tempOptCMeta = const VerificationMeta(
    'tempOptC',
  );
  late final GeneratedColumn<double> tempOptC = GeneratedColumn<double>(
    'temp_opt_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tempMaxCMeta = const VerificationMeta(
    'tempMaxC',
  );
  late final GeneratedColumn<double> tempMaxC = GeneratedColumn<double>(
    'temp_max_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _waterNeedMeta = const VerificationMeta(
    'waterNeed',
  );
  late final GeneratedColumn<int> waterNeed = GeneratedColumn<int>(
    'water_need',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sunMeta = const VerificationMeta('sun');
  late final GeneratedColumn<String> sun = GeneratedColumn<String>(
    'sun',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _soilTypesMeta = const VerificationMeta(
    'soilTypes',
  );
  late final GeneratedColumn<String> soilTypes = GeneratedColumn<String>(
    'soil_types',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _phMinMeta = const VerificationMeta('phMin');
  late final GeneratedColumn<double> phMin = GeneratedColumn<double>(
    'ph_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _phMaxMeta = const VerificationMeta('phMax');
  late final GeneratedColumn<double> phMax = GeneratedColumn<double>(
    'ph_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _frostHardinessMeta = const VerificationMeta(
    'frostHardiness',
  );
  late final GeneratedColumn<String> frostHardiness = GeneratedColumn<String>(
    'frost_hardiness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _propagationMeta = const VerificationMeta(
    'propagation',
  );
  late final GeneratedColumn<String> propagation = GeneratedColumn<String>(
    'propagation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sowDepthCmMeta = const VerificationMeta(
    'sowDepthCm',
  );
  late final GeneratedColumn<double> sowDepthCm = GeneratedColumn<double>(
    'sow_depth_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _spacingCmMeta = const VerificationMeta(
    'spacingCm',
  );
  late final GeneratedColumn<int> spacingCm = GeneratedColumn<int>(
    'spacing_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _rowSpacingCmMeta = const VerificationMeta(
    'rowSpacingCm',
  );
  late final GeneratedColumn<int> rowSpacingCm = GeneratedColumn<int>(
    'row_spacing_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _daysToHarvestMeta = const VerificationMeta(
    'daysToHarvest',
  );
  late final GeneratedColumn<int> daysToHarvest = GeneratedColumn<int>(
    'days_to_harvest',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  late final GeneratedColumn<String> publishedAt = GeneratedColumn<String>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _searchKeysMeta = const VerificationMeta(
    'searchKeys',
  );
  late final GeneratedColumn<String> searchKeys = GeneratedColumn<String>(
    'search_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scientificName,
    gbifId,
    categoryId,
    tempMinC,
    tempOptC,
    tempMaxC,
    waterNeed,
    sun,
    soilTypes,
    phMin,
    phMax,
    frostHardiness,
    propagation,
    sowDepthCm,
    spacingCm,
    rowSpacingCm,
    daysToHarvest,
    publishedAt,
    updatedAt,
    searchKeys,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plants';
  @override
  VerificationContext validateIntegrity(
    Insertable<CataloguePlant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('gbif_id')) {
      context.handle(
        _gbifIdMeta,
        gbifId.isAcceptableOrUnknown(data['gbif_id']!, _gbifIdMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('temp_min_c')) {
      context.handle(
        _tempMinCMeta,
        tempMinC.isAcceptableOrUnknown(data['temp_min_c']!, _tempMinCMeta),
      );
    }
    if (data.containsKey('temp_opt_c')) {
      context.handle(
        _tempOptCMeta,
        tempOptC.isAcceptableOrUnknown(data['temp_opt_c']!, _tempOptCMeta),
      );
    }
    if (data.containsKey('temp_max_c')) {
      context.handle(
        _tempMaxCMeta,
        tempMaxC.isAcceptableOrUnknown(data['temp_max_c']!, _tempMaxCMeta),
      );
    }
    if (data.containsKey('water_need')) {
      context.handle(
        _waterNeedMeta,
        waterNeed.isAcceptableOrUnknown(data['water_need']!, _waterNeedMeta),
      );
    }
    if (data.containsKey('sun')) {
      context.handle(
        _sunMeta,
        sun.isAcceptableOrUnknown(data['sun']!, _sunMeta),
      );
    }
    if (data.containsKey('soil_types')) {
      context.handle(
        _soilTypesMeta,
        soilTypes.isAcceptableOrUnknown(data['soil_types']!, _soilTypesMeta),
      );
    }
    if (data.containsKey('ph_min')) {
      context.handle(
        _phMinMeta,
        phMin.isAcceptableOrUnknown(data['ph_min']!, _phMinMeta),
      );
    }
    if (data.containsKey('ph_max')) {
      context.handle(
        _phMaxMeta,
        phMax.isAcceptableOrUnknown(data['ph_max']!, _phMaxMeta),
      );
    }
    if (data.containsKey('frost_hardiness')) {
      context.handle(
        _frostHardinessMeta,
        frostHardiness.isAcceptableOrUnknown(
          data['frost_hardiness']!,
          _frostHardinessMeta,
        ),
      );
    }
    if (data.containsKey('propagation')) {
      context.handle(
        _propagationMeta,
        propagation.isAcceptableOrUnknown(
          data['propagation']!,
          _propagationMeta,
        ),
      );
    }
    if (data.containsKey('sow_depth_cm')) {
      context.handle(
        _sowDepthCmMeta,
        sowDepthCm.isAcceptableOrUnknown(
          data['sow_depth_cm']!,
          _sowDepthCmMeta,
        ),
      );
    }
    if (data.containsKey('spacing_cm')) {
      context.handle(
        _spacingCmMeta,
        spacingCm.isAcceptableOrUnknown(data['spacing_cm']!, _spacingCmMeta),
      );
    }
    if (data.containsKey('row_spacing_cm')) {
      context.handle(
        _rowSpacingCmMeta,
        rowSpacingCm.isAcceptableOrUnknown(
          data['row_spacing_cm']!,
          _rowSpacingCmMeta,
        ),
      );
    }
    if (data.containsKey('days_to_harvest')) {
      context.handle(
        _daysToHarvestMeta,
        daysToHarvest.isAcceptableOrUnknown(
          data['days_to_harvest']!,
          _daysToHarvestMeta,
        ),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('search_keys')) {
      context.handle(
        _searchKeysMeta,
        searchKeys.isAcceptableOrUnknown(data['search_keys']!, _searchKeysMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CataloguePlant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CataloguePlant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      gbifId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gbif_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      tempMinC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_min_c'],
      ),
      tempOptC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_opt_c'],
      ),
      tempMaxC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_max_c'],
      ),
      waterNeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}water_need'],
      ),
      sun: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sun'],
      ),
      soilTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}soil_types'],
      ),
      phMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_min'],
      ),
      phMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ph_max'],
      ),
      frostHardiness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frost_hardiness'],
      ),
      propagation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}propagation'],
      ),
      sowDepthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sow_depth_cm'],
      ),
      spacingCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spacing_cm'],
      ),
      rowSpacingCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_spacing_cm'],
      ),
      daysToHarvest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_to_harvest'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      searchKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_keys'],
      )!,
    );
  }

  @override
  Plants createAlias(String alias) {
    return Plants(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CataloguePlant extends DataClass implements Insertable<CataloguePlant> {
  final String id;
  final String scientificName;
  final int? gbifId;
  final String categoryId;
  final double? tempMinC;
  final double? tempOptC;
  final double? tempMaxC;
  final int? waterNeed;
  final String? sun;
  final String? soilTypes;
  final double? phMin;
  final double? phMax;
  final String? frostHardiness;
  final String? propagation;
  final double? sowDepthCm;
  final int? spacingCm;
  final int? rowSpacingCm;
  final int? daysToHarvest;
  final String? publishedAt;
  final String? updatedAt;
  final String searchKeys;
  const CataloguePlant({
    required this.id,
    required this.scientificName,
    this.gbifId,
    required this.categoryId,
    this.tempMinC,
    this.tempOptC,
    this.tempMaxC,
    this.waterNeed,
    this.sun,
    this.soilTypes,
    this.phMin,
    this.phMax,
    this.frostHardiness,
    this.propagation,
    this.sowDepthCm,
    this.spacingCm,
    this.rowSpacingCm,
    this.daysToHarvest,
    this.publishedAt,
    this.updatedAt,
    required this.searchKeys,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scientific_name'] = Variable<String>(scientificName);
    if (!nullToAbsent || gbifId != null) {
      map['gbif_id'] = Variable<int>(gbifId);
    }
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || tempMinC != null) {
      map['temp_min_c'] = Variable<double>(tempMinC);
    }
    if (!nullToAbsent || tempOptC != null) {
      map['temp_opt_c'] = Variable<double>(tempOptC);
    }
    if (!nullToAbsent || tempMaxC != null) {
      map['temp_max_c'] = Variable<double>(tempMaxC);
    }
    if (!nullToAbsent || waterNeed != null) {
      map['water_need'] = Variable<int>(waterNeed);
    }
    if (!nullToAbsent || sun != null) {
      map['sun'] = Variable<String>(sun);
    }
    if (!nullToAbsent || soilTypes != null) {
      map['soil_types'] = Variable<String>(soilTypes);
    }
    if (!nullToAbsent || phMin != null) {
      map['ph_min'] = Variable<double>(phMin);
    }
    if (!nullToAbsent || phMax != null) {
      map['ph_max'] = Variable<double>(phMax);
    }
    if (!nullToAbsent || frostHardiness != null) {
      map['frost_hardiness'] = Variable<String>(frostHardiness);
    }
    if (!nullToAbsent || propagation != null) {
      map['propagation'] = Variable<String>(propagation);
    }
    if (!nullToAbsent || sowDepthCm != null) {
      map['sow_depth_cm'] = Variable<double>(sowDepthCm);
    }
    if (!nullToAbsent || spacingCm != null) {
      map['spacing_cm'] = Variable<int>(spacingCm);
    }
    if (!nullToAbsent || rowSpacingCm != null) {
      map['row_spacing_cm'] = Variable<int>(rowSpacingCm);
    }
    if (!nullToAbsent || daysToHarvest != null) {
      map['days_to_harvest'] = Variable<int>(daysToHarvest);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<String>(publishedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    map['search_keys'] = Variable<String>(searchKeys);
    return map;
  }

  PlantsCompanion toCompanion(bool nullToAbsent) {
    return PlantsCompanion(
      id: Value(id),
      scientificName: Value(scientificName),
      gbifId: gbifId == null && nullToAbsent
          ? const Value.absent()
          : Value(gbifId),
      categoryId: Value(categoryId),
      tempMinC: tempMinC == null && nullToAbsent
          ? const Value.absent()
          : Value(tempMinC),
      tempOptC: tempOptC == null && nullToAbsent
          ? const Value.absent()
          : Value(tempOptC),
      tempMaxC: tempMaxC == null && nullToAbsent
          ? const Value.absent()
          : Value(tempMaxC),
      waterNeed: waterNeed == null && nullToAbsent
          ? const Value.absent()
          : Value(waterNeed),
      sun: sun == null && nullToAbsent ? const Value.absent() : Value(sun),
      soilTypes: soilTypes == null && nullToAbsent
          ? const Value.absent()
          : Value(soilTypes),
      phMin: phMin == null && nullToAbsent
          ? const Value.absent()
          : Value(phMin),
      phMax: phMax == null && nullToAbsent
          ? const Value.absent()
          : Value(phMax),
      frostHardiness: frostHardiness == null && nullToAbsent
          ? const Value.absent()
          : Value(frostHardiness),
      propagation: propagation == null && nullToAbsent
          ? const Value.absent()
          : Value(propagation),
      sowDepthCm: sowDepthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(sowDepthCm),
      spacingCm: spacingCm == null && nullToAbsent
          ? const Value.absent()
          : Value(spacingCm),
      rowSpacingCm: rowSpacingCm == null && nullToAbsent
          ? const Value.absent()
          : Value(rowSpacingCm),
      daysToHarvest: daysToHarvest == null && nullToAbsent
          ? const Value.absent()
          : Value(daysToHarvest),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      searchKeys: Value(searchKeys),
    );
  }

  factory CataloguePlant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CataloguePlant(
      id: serializer.fromJson<String>(json['id']),
      scientificName: serializer.fromJson<String>(json['scientific_name']),
      gbifId: serializer.fromJson<int?>(json['gbif_id']),
      categoryId: serializer.fromJson<String>(json['category_id']),
      tempMinC: serializer.fromJson<double?>(json['temp_min_c']),
      tempOptC: serializer.fromJson<double?>(json['temp_opt_c']),
      tempMaxC: serializer.fromJson<double?>(json['temp_max_c']),
      waterNeed: serializer.fromJson<int?>(json['water_need']),
      sun: serializer.fromJson<String?>(json['sun']),
      soilTypes: serializer.fromJson<String?>(json['soil_types']),
      phMin: serializer.fromJson<double?>(json['ph_min']),
      phMax: serializer.fromJson<double?>(json['ph_max']),
      frostHardiness: serializer.fromJson<String?>(json['frost_hardiness']),
      propagation: serializer.fromJson<String?>(json['propagation']),
      sowDepthCm: serializer.fromJson<double?>(json['sow_depth_cm']),
      spacingCm: serializer.fromJson<int?>(json['spacing_cm']),
      rowSpacingCm: serializer.fromJson<int?>(json['row_spacing_cm']),
      daysToHarvest: serializer.fromJson<int?>(json['days_to_harvest']),
      publishedAt: serializer.fromJson<String?>(json['published_at']),
      updatedAt: serializer.fromJson<String?>(json['updated_at']),
      searchKeys: serializer.fromJson<String>(json['search_keys']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scientific_name': serializer.toJson<String>(scientificName),
      'gbif_id': serializer.toJson<int?>(gbifId),
      'category_id': serializer.toJson<String>(categoryId),
      'temp_min_c': serializer.toJson<double?>(tempMinC),
      'temp_opt_c': serializer.toJson<double?>(tempOptC),
      'temp_max_c': serializer.toJson<double?>(tempMaxC),
      'water_need': serializer.toJson<int?>(waterNeed),
      'sun': serializer.toJson<String?>(sun),
      'soil_types': serializer.toJson<String?>(soilTypes),
      'ph_min': serializer.toJson<double?>(phMin),
      'ph_max': serializer.toJson<double?>(phMax),
      'frost_hardiness': serializer.toJson<String?>(frostHardiness),
      'propagation': serializer.toJson<String?>(propagation),
      'sow_depth_cm': serializer.toJson<double?>(sowDepthCm),
      'spacing_cm': serializer.toJson<int?>(spacingCm),
      'row_spacing_cm': serializer.toJson<int?>(rowSpacingCm),
      'days_to_harvest': serializer.toJson<int?>(daysToHarvest),
      'published_at': serializer.toJson<String?>(publishedAt),
      'updated_at': serializer.toJson<String?>(updatedAt),
      'search_keys': serializer.toJson<String>(searchKeys),
    };
  }

  CataloguePlant copyWith({
    String? id,
    String? scientificName,
    Value<int?> gbifId = const Value.absent(),
    String? categoryId,
    Value<double?> tempMinC = const Value.absent(),
    Value<double?> tempOptC = const Value.absent(),
    Value<double?> tempMaxC = const Value.absent(),
    Value<int?> waterNeed = const Value.absent(),
    Value<String?> sun = const Value.absent(),
    Value<String?> soilTypes = const Value.absent(),
    Value<double?> phMin = const Value.absent(),
    Value<double?> phMax = const Value.absent(),
    Value<String?> frostHardiness = const Value.absent(),
    Value<String?> propagation = const Value.absent(),
    Value<double?> sowDepthCm = const Value.absent(),
    Value<int?> spacingCm = const Value.absent(),
    Value<int?> rowSpacingCm = const Value.absent(),
    Value<int?> daysToHarvest = const Value.absent(),
    Value<String?> publishedAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    String? searchKeys,
  }) => CataloguePlant(
    id: id ?? this.id,
    scientificName: scientificName ?? this.scientificName,
    gbifId: gbifId.present ? gbifId.value : this.gbifId,
    categoryId: categoryId ?? this.categoryId,
    tempMinC: tempMinC.present ? tempMinC.value : this.tempMinC,
    tempOptC: tempOptC.present ? tempOptC.value : this.tempOptC,
    tempMaxC: tempMaxC.present ? tempMaxC.value : this.tempMaxC,
    waterNeed: waterNeed.present ? waterNeed.value : this.waterNeed,
    sun: sun.present ? sun.value : this.sun,
    soilTypes: soilTypes.present ? soilTypes.value : this.soilTypes,
    phMin: phMin.present ? phMin.value : this.phMin,
    phMax: phMax.present ? phMax.value : this.phMax,
    frostHardiness: frostHardiness.present
        ? frostHardiness.value
        : this.frostHardiness,
    propagation: propagation.present ? propagation.value : this.propagation,
    sowDepthCm: sowDepthCm.present ? sowDepthCm.value : this.sowDepthCm,
    spacingCm: spacingCm.present ? spacingCm.value : this.spacingCm,
    rowSpacingCm: rowSpacingCm.present ? rowSpacingCm.value : this.rowSpacingCm,
    daysToHarvest: daysToHarvest.present
        ? daysToHarvest.value
        : this.daysToHarvest,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    searchKeys: searchKeys ?? this.searchKeys,
  );
  CataloguePlant copyWithCompanion(PlantsCompanion data) {
    return CataloguePlant(
      id: data.id.present ? data.id.value : this.id,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      gbifId: data.gbifId.present ? data.gbifId.value : this.gbifId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      tempMinC: data.tempMinC.present ? data.tempMinC.value : this.tempMinC,
      tempOptC: data.tempOptC.present ? data.tempOptC.value : this.tempOptC,
      tempMaxC: data.tempMaxC.present ? data.tempMaxC.value : this.tempMaxC,
      waterNeed: data.waterNeed.present ? data.waterNeed.value : this.waterNeed,
      sun: data.sun.present ? data.sun.value : this.sun,
      soilTypes: data.soilTypes.present ? data.soilTypes.value : this.soilTypes,
      phMin: data.phMin.present ? data.phMin.value : this.phMin,
      phMax: data.phMax.present ? data.phMax.value : this.phMax,
      frostHardiness: data.frostHardiness.present
          ? data.frostHardiness.value
          : this.frostHardiness,
      propagation: data.propagation.present
          ? data.propagation.value
          : this.propagation,
      sowDepthCm: data.sowDepthCm.present
          ? data.sowDepthCm.value
          : this.sowDepthCm,
      spacingCm: data.spacingCm.present ? data.spacingCm.value : this.spacingCm,
      rowSpacingCm: data.rowSpacingCm.present
          ? data.rowSpacingCm.value
          : this.rowSpacingCm,
      daysToHarvest: data.daysToHarvest.present
          ? data.daysToHarvest.value
          : this.daysToHarvest,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      searchKeys: data.searchKeys.present
          ? data.searchKeys.value
          : this.searchKeys,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CataloguePlant(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('gbifId: $gbifId, ')
          ..write('categoryId: $categoryId, ')
          ..write('tempMinC: $tempMinC, ')
          ..write('tempOptC: $tempOptC, ')
          ..write('tempMaxC: $tempMaxC, ')
          ..write('waterNeed: $waterNeed, ')
          ..write('sun: $sun, ')
          ..write('soilTypes: $soilTypes, ')
          ..write('phMin: $phMin, ')
          ..write('phMax: $phMax, ')
          ..write('frostHardiness: $frostHardiness, ')
          ..write('propagation: $propagation, ')
          ..write('sowDepthCm: $sowDepthCm, ')
          ..write('spacingCm: $spacingCm, ')
          ..write('rowSpacingCm: $rowSpacingCm, ')
          ..write('daysToHarvest: $daysToHarvest, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('searchKeys: $searchKeys')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    scientificName,
    gbifId,
    categoryId,
    tempMinC,
    tempOptC,
    tempMaxC,
    waterNeed,
    sun,
    soilTypes,
    phMin,
    phMax,
    frostHardiness,
    propagation,
    sowDepthCm,
    spacingCm,
    rowSpacingCm,
    daysToHarvest,
    publishedAt,
    updatedAt,
    searchKeys,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CataloguePlant &&
          other.id == this.id &&
          other.scientificName == this.scientificName &&
          other.gbifId == this.gbifId &&
          other.categoryId == this.categoryId &&
          other.tempMinC == this.tempMinC &&
          other.tempOptC == this.tempOptC &&
          other.tempMaxC == this.tempMaxC &&
          other.waterNeed == this.waterNeed &&
          other.sun == this.sun &&
          other.soilTypes == this.soilTypes &&
          other.phMin == this.phMin &&
          other.phMax == this.phMax &&
          other.frostHardiness == this.frostHardiness &&
          other.propagation == this.propagation &&
          other.sowDepthCm == this.sowDepthCm &&
          other.spacingCm == this.spacingCm &&
          other.rowSpacingCm == this.rowSpacingCm &&
          other.daysToHarvest == this.daysToHarvest &&
          other.publishedAt == this.publishedAt &&
          other.updatedAt == this.updatedAt &&
          other.searchKeys == this.searchKeys);
}

class PlantsCompanion extends UpdateCompanion<CataloguePlant> {
  final Value<String> id;
  final Value<String> scientificName;
  final Value<int?> gbifId;
  final Value<String> categoryId;
  final Value<double?> tempMinC;
  final Value<double?> tempOptC;
  final Value<double?> tempMaxC;
  final Value<int?> waterNeed;
  final Value<String?> sun;
  final Value<String?> soilTypes;
  final Value<double?> phMin;
  final Value<double?> phMax;
  final Value<String?> frostHardiness;
  final Value<String?> propagation;
  final Value<double?> sowDepthCm;
  final Value<int?> spacingCm;
  final Value<int?> rowSpacingCm;
  final Value<int?> daysToHarvest;
  final Value<String?> publishedAt;
  final Value<String?> updatedAt;
  final Value<String> searchKeys;
  final Value<int> rowid;
  const PlantsCompanion({
    this.id = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.gbifId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.tempMinC = const Value.absent(),
    this.tempOptC = const Value.absent(),
    this.tempMaxC = const Value.absent(),
    this.waterNeed = const Value.absent(),
    this.sun = const Value.absent(),
    this.soilTypes = const Value.absent(),
    this.phMin = const Value.absent(),
    this.phMax = const Value.absent(),
    this.frostHardiness = const Value.absent(),
    this.propagation = const Value.absent(),
    this.sowDepthCm = const Value.absent(),
    this.spacingCm = const Value.absent(),
    this.rowSpacingCm = const Value.absent(),
    this.daysToHarvest = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.searchKeys = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantsCompanion.insert({
    required String id,
    required String scientificName,
    this.gbifId = const Value.absent(),
    required String categoryId,
    this.tempMinC = const Value.absent(),
    this.tempOptC = const Value.absent(),
    this.tempMaxC = const Value.absent(),
    this.waterNeed = const Value.absent(),
    this.sun = const Value.absent(),
    this.soilTypes = const Value.absent(),
    this.phMin = const Value.absent(),
    this.phMax = const Value.absent(),
    this.frostHardiness = const Value.absent(),
    this.propagation = const Value.absent(),
    this.sowDepthCm = const Value.absent(),
    this.spacingCm = const Value.absent(),
    this.rowSpacingCm = const Value.absent(),
    this.daysToHarvest = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String searchKeys,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scientificName = Value(scientificName),
       categoryId = Value(categoryId),
       searchKeys = Value(searchKeys);
  static Insertable<CataloguePlant> custom({
    Expression<String>? id,
    Expression<String>? scientificName,
    Expression<int>? gbifId,
    Expression<String>? categoryId,
    Expression<double>? tempMinC,
    Expression<double>? tempOptC,
    Expression<double>? tempMaxC,
    Expression<int>? waterNeed,
    Expression<String>? sun,
    Expression<String>? soilTypes,
    Expression<double>? phMin,
    Expression<double>? phMax,
    Expression<String>? frostHardiness,
    Expression<String>? propagation,
    Expression<double>? sowDepthCm,
    Expression<int>? spacingCm,
    Expression<int>? rowSpacingCm,
    Expression<int>? daysToHarvest,
    Expression<String>? publishedAt,
    Expression<String>? updatedAt,
    Expression<String>? searchKeys,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scientificName != null) 'scientific_name': scientificName,
      if (gbifId != null) 'gbif_id': gbifId,
      if (categoryId != null) 'category_id': categoryId,
      if (tempMinC != null) 'temp_min_c': tempMinC,
      if (tempOptC != null) 'temp_opt_c': tempOptC,
      if (tempMaxC != null) 'temp_max_c': tempMaxC,
      if (waterNeed != null) 'water_need': waterNeed,
      if (sun != null) 'sun': sun,
      if (soilTypes != null) 'soil_types': soilTypes,
      if (phMin != null) 'ph_min': phMin,
      if (phMax != null) 'ph_max': phMax,
      if (frostHardiness != null) 'frost_hardiness': frostHardiness,
      if (propagation != null) 'propagation': propagation,
      if (sowDepthCm != null) 'sow_depth_cm': sowDepthCm,
      if (spacingCm != null) 'spacing_cm': spacingCm,
      if (rowSpacingCm != null) 'row_spacing_cm': rowSpacingCm,
      if (daysToHarvest != null) 'days_to_harvest': daysToHarvest,
      if (publishedAt != null) 'published_at': publishedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (searchKeys != null) 'search_keys': searchKeys,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantsCompanion copyWith({
    Value<String>? id,
    Value<String>? scientificName,
    Value<int?>? gbifId,
    Value<String>? categoryId,
    Value<double?>? tempMinC,
    Value<double?>? tempOptC,
    Value<double?>? tempMaxC,
    Value<int?>? waterNeed,
    Value<String?>? sun,
    Value<String?>? soilTypes,
    Value<double?>? phMin,
    Value<double?>? phMax,
    Value<String?>? frostHardiness,
    Value<String?>? propagation,
    Value<double?>? sowDepthCm,
    Value<int?>? spacingCm,
    Value<int?>? rowSpacingCm,
    Value<int?>? daysToHarvest,
    Value<String?>? publishedAt,
    Value<String?>? updatedAt,
    Value<String>? searchKeys,
    Value<int>? rowid,
  }) {
    return PlantsCompanion(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      gbifId: gbifId ?? this.gbifId,
      categoryId: categoryId ?? this.categoryId,
      tempMinC: tempMinC ?? this.tempMinC,
      tempOptC: tempOptC ?? this.tempOptC,
      tempMaxC: tempMaxC ?? this.tempMaxC,
      waterNeed: waterNeed ?? this.waterNeed,
      sun: sun ?? this.sun,
      soilTypes: soilTypes ?? this.soilTypes,
      phMin: phMin ?? this.phMin,
      phMax: phMax ?? this.phMax,
      frostHardiness: frostHardiness ?? this.frostHardiness,
      propagation: propagation ?? this.propagation,
      sowDepthCm: sowDepthCm ?? this.sowDepthCm,
      spacingCm: spacingCm ?? this.spacingCm,
      rowSpacingCm: rowSpacingCm ?? this.rowSpacingCm,
      daysToHarvest: daysToHarvest ?? this.daysToHarvest,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      searchKeys: searchKeys ?? this.searchKeys,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (gbifId.present) {
      map['gbif_id'] = Variable<int>(gbifId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (tempMinC.present) {
      map['temp_min_c'] = Variable<double>(tempMinC.value);
    }
    if (tempOptC.present) {
      map['temp_opt_c'] = Variable<double>(tempOptC.value);
    }
    if (tempMaxC.present) {
      map['temp_max_c'] = Variable<double>(tempMaxC.value);
    }
    if (waterNeed.present) {
      map['water_need'] = Variable<int>(waterNeed.value);
    }
    if (sun.present) {
      map['sun'] = Variable<String>(sun.value);
    }
    if (soilTypes.present) {
      map['soil_types'] = Variable<String>(soilTypes.value);
    }
    if (phMin.present) {
      map['ph_min'] = Variable<double>(phMin.value);
    }
    if (phMax.present) {
      map['ph_max'] = Variable<double>(phMax.value);
    }
    if (frostHardiness.present) {
      map['frost_hardiness'] = Variable<String>(frostHardiness.value);
    }
    if (propagation.present) {
      map['propagation'] = Variable<String>(propagation.value);
    }
    if (sowDepthCm.present) {
      map['sow_depth_cm'] = Variable<double>(sowDepthCm.value);
    }
    if (spacingCm.present) {
      map['spacing_cm'] = Variable<int>(spacingCm.value);
    }
    if (rowSpacingCm.present) {
      map['row_spacing_cm'] = Variable<int>(rowSpacingCm.value);
    }
    if (daysToHarvest.present) {
      map['days_to_harvest'] = Variable<int>(daysToHarvest.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<String>(publishedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (searchKeys.present) {
      map['search_keys'] = Variable<String>(searchKeys.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantsCompanion(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('gbifId: $gbifId, ')
          ..write('categoryId: $categoryId, ')
          ..write('tempMinC: $tempMinC, ')
          ..write('tempOptC: $tempOptC, ')
          ..write('tempMaxC: $tempMaxC, ')
          ..write('waterNeed: $waterNeed, ')
          ..write('sun: $sun, ')
          ..write('soilTypes: $soilTypes, ')
          ..write('phMin: $phMin, ')
          ..write('phMax: $phMax, ')
          ..write('frostHardiness: $frostHardiness, ')
          ..write('propagation: $propagation, ')
          ..write('sowDepthCm: $sowDepthCm, ')
          ..write('spacingCm: $spacingCm, ')
          ..write('rowSpacingCm: $rowSpacingCm, ')
          ..write('daysToHarvest: $daysToHarvest, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('searchKeys: $searchKeys, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlantTranslations extends Table
    with TableInfo<PlantTranslations, CataloguePlantTranslation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlantTranslations(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plantingMeta = const VerificationMeta(
    'planting',
  );
  late final GeneratedColumn<String> planting = GeneratedColumn<String>(
    'planting',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _careMeta = const VerificationMeta('care');
  late final GeneratedColumn<String> care = GeneratedColumn<String>(
    'care',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _seedSavingMeta = const VerificationMeta(
    'seedSaving',
  );
  late final GeneratedColumn<String> seedSaving = GeneratedColumn<String>(
    'seed_saving',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tipsMeta = const VerificationMeta('tips');
  late final GeneratedColumn<String> tips = GeneratedColumn<String>(
    'tips',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plantId,
    lang,
    name,
    description,
    planting,
    care,
    seedSaving,
    tips,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CataloguePlantTranslation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('planting')) {
      context.handle(
        _plantingMeta,
        planting.isAcceptableOrUnknown(data['planting']!, _plantingMeta),
      );
    }
    if (data.containsKey('care')) {
      context.handle(
        _careMeta,
        care.isAcceptableOrUnknown(data['care']!, _careMeta),
      );
    }
    if (data.containsKey('seed_saving')) {
      context.handle(
        _seedSavingMeta,
        seedSaving.isAcceptableOrUnknown(data['seed_saving']!, _seedSavingMeta),
      );
    }
    if (data.containsKey('tips')) {
      context.handle(
        _tipsMeta,
        tips.isAcceptableOrUnknown(data['tips']!, _tipsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {plantId, lang},
  ];
  @override
  CataloguePlantTranslation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CataloguePlantTranslation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      planting: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planting'],
      ),
      care: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}care'],
      ),
      seedSaving: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_saving'],
      ),
      tips: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tips'],
      ),
    );
  }

  @override
  PlantTranslations createAlias(String alias) {
    return PlantTranslations(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(plant_id, lang)'];
  @override
  bool get dontWriteConstraints => true;
}

class CataloguePlantTranslation extends DataClass
    implements Insertable<CataloguePlantTranslation> {
  final String id;
  final String plantId;
  final String lang;
  final String name;
  final String? description;
  final String? planting;
  final String? care;
  final String? seedSaving;
  final String? tips;
  const CataloguePlantTranslation({
    required this.id,
    required this.plantId,
    required this.lang,
    required this.name,
    this.description,
    this.planting,
    this.care,
    this.seedSaving,
    this.tips,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['lang'] = Variable<String>(lang);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || planting != null) {
      map['planting'] = Variable<String>(planting);
    }
    if (!nullToAbsent || care != null) {
      map['care'] = Variable<String>(care);
    }
    if (!nullToAbsent || seedSaving != null) {
      map['seed_saving'] = Variable<String>(seedSaving);
    }
    if (!nullToAbsent || tips != null) {
      map['tips'] = Variable<String>(tips);
    }
    return map;
  }

  PlantTranslationsCompanion toCompanion(bool nullToAbsent) {
    return PlantTranslationsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      lang: Value(lang),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      planting: planting == null && nullToAbsent
          ? const Value.absent()
          : Value(planting),
      care: care == null && nullToAbsent ? const Value.absent() : Value(care),
      seedSaving: seedSaving == null && nullToAbsent
          ? const Value.absent()
          : Value(seedSaving),
      tips: tips == null && nullToAbsent ? const Value.absent() : Value(tips),
    );
  }

  factory CataloguePlantTranslation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CataloguePlantTranslation(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plant_id']),
      lang: serializer.fromJson<String>(json['lang']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      planting: serializer.fromJson<String?>(json['planting']),
      care: serializer.fromJson<String?>(json['care']),
      seedSaving: serializer.fromJson<String?>(json['seed_saving']),
      tips: serializer.fromJson<String?>(json['tips']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plant_id': serializer.toJson<String>(plantId),
      'lang': serializer.toJson<String>(lang),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'planting': serializer.toJson<String?>(planting),
      'care': serializer.toJson<String?>(care),
      'seed_saving': serializer.toJson<String?>(seedSaving),
      'tips': serializer.toJson<String?>(tips),
    };
  }

  CataloguePlantTranslation copyWith({
    String? id,
    String? plantId,
    String? lang,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> planting = const Value.absent(),
    Value<String?> care = const Value.absent(),
    Value<String?> seedSaving = const Value.absent(),
    Value<String?> tips = const Value.absent(),
  }) => CataloguePlantTranslation(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    lang: lang ?? this.lang,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    planting: planting.present ? planting.value : this.planting,
    care: care.present ? care.value : this.care,
    seedSaving: seedSaving.present ? seedSaving.value : this.seedSaving,
    tips: tips.present ? tips.value : this.tips,
  );
  CataloguePlantTranslation copyWithCompanion(PlantTranslationsCompanion data) {
    return CataloguePlantTranslation(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      lang: data.lang.present ? data.lang.value : this.lang,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      planting: data.planting.present ? data.planting.value : this.planting,
      care: data.care.present ? data.care.value : this.care,
      seedSaving: data.seedSaving.present
          ? data.seedSaving.value
          : this.seedSaving,
      tips: data.tips.present ? data.tips.value : this.tips,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CataloguePlantTranslation(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('planting: $planting, ')
          ..write('care: $care, ')
          ..write('seedSaving: $seedSaving, ')
          ..write('tips: $tips')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plantId,
    lang,
    name,
    description,
    planting,
    care,
    seedSaving,
    tips,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CataloguePlantTranslation &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.lang == this.lang &&
          other.name == this.name &&
          other.description == this.description &&
          other.planting == this.planting &&
          other.care == this.care &&
          other.seedSaving == this.seedSaving &&
          other.tips == this.tips);
}

class PlantTranslationsCompanion
    extends UpdateCompanion<CataloguePlantTranslation> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<String> lang;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> planting;
  final Value<String?> care;
  final Value<String?> seedSaving;
  final Value<String?> tips;
  final Value<int> rowid;
  const PlantTranslationsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.lang = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.planting = const Value.absent(),
    this.care = const Value.absent(),
    this.seedSaving = const Value.absent(),
    this.tips = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantTranslationsCompanion.insert({
    required String id,
    required String plantId,
    required String lang,
    required String name,
    this.description = const Value.absent(),
    this.planting = const Value.absent(),
    this.care = const Value.absent(),
    this.seedSaving = const Value.absent(),
    this.tips = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plantId = Value(plantId),
       lang = Value(lang),
       name = Value(name);
  static Insertable<CataloguePlantTranslation> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? lang,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? planting,
    Expression<String>? care,
    Expression<String>? seedSaving,
    Expression<String>? tips,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (lang != null) 'lang': lang,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (planting != null) 'planting': planting,
      if (care != null) 'care': care,
      if (seedSaving != null) 'seed_saving': seedSaving,
      if (tips != null) 'tips': tips,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantTranslationsCompanion copyWith({
    Value<String>? id,
    Value<String>? plantId,
    Value<String>? lang,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? planting,
    Value<String?>? care,
    Value<String?>? seedSaving,
    Value<String?>? tips,
    Value<int>? rowid,
  }) {
    return PlantTranslationsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      lang: lang ?? this.lang,
      name: name ?? this.name,
      description: description ?? this.description,
      planting: planting ?? this.planting,
      care: care ?? this.care,
      seedSaving: seedSaving ?? this.seedSaving,
      tips: tips ?? this.tips,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (planting.present) {
      map['planting'] = Variable<String>(planting.value);
    }
    if (care.present) {
      map['care'] = Variable<String>(care.value);
    }
    if (seedSaving.present) {
      map['seed_saving'] = Variable<String>(seedSaving.value);
    }
    if (tips.present) {
      map['tips'] = Variable<String>(tips.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantTranslationsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('planting: $planting, ')
          ..write('care: $care, ')
          ..write('seedSaving: $seedSaving, ')
          ..write('tips: $tips, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlantAliases extends Table
    with TableInfo<PlantAliases, CataloguePlantAlias> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlantAliases(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [id, plantId, lang, alias, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<CataloguePlantAlias> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CataloguePlantAlias map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CataloguePlantAlias(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      ),
    );
  }

  @override
  PlantAliases createAlias(String alias) {
    return PlantAliases(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CataloguePlantAlias extends DataClass
    implements Insertable<CataloguePlantAlias> {
  final String id;
  final String plantId;
  final String? lang;
  final String alias;
  final String? kind;
  const CataloguePlantAlias({
    required this.id,
    required this.plantId,
    this.lang,
    required this.alias,
    this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    map['alias'] = Variable<String>(alias);
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    return map;
  }

  PlantAliasesCompanion toCompanion(bool nullToAbsent) {
    return PlantAliasesCompanion(
      id: Value(id),
      plantId: Value(plantId),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
      alias: Value(alias),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
    );
  }

  factory CataloguePlantAlias.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CataloguePlantAlias(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plant_id']),
      lang: serializer.fromJson<String?>(json['lang']),
      alias: serializer.fromJson<String>(json['alias']),
      kind: serializer.fromJson<String?>(json['kind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plant_id': serializer.toJson<String>(plantId),
      'lang': serializer.toJson<String?>(lang),
      'alias': serializer.toJson<String>(alias),
      'kind': serializer.toJson<String?>(kind),
    };
  }

  CataloguePlantAlias copyWith({
    String? id,
    String? plantId,
    Value<String?> lang = const Value.absent(),
    String? alias,
    Value<String?> kind = const Value.absent(),
  }) => CataloguePlantAlias(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    lang: lang.present ? lang.value : this.lang,
    alias: alias ?? this.alias,
    kind: kind.present ? kind.value : this.kind,
  );
  CataloguePlantAlias copyWithCompanion(PlantAliasesCompanion data) {
    return CataloguePlantAlias(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      lang: data.lang.present ? data.lang.value : this.lang,
      alias: data.alias.present ? data.alias.value : this.alias,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CataloguePlantAlias(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('lang: $lang, ')
          ..write('alias: $alias, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, lang, alias, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CataloguePlantAlias &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.lang == this.lang &&
          other.alias == this.alias &&
          other.kind == this.kind);
}

class PlantAliasesCompanion extends UpdateCompanion<CataloguePlantAlias> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<String?> lang;
  final Value<String> alias;
  final Value<String?> kind;
  final Value<int> rowid;
  const PlantAliasesCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.lang = const Value.absent(),
    this.alias = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantAliasesCompanion.insert({
    required String id,
    required String plantId,
    this.lang = const Value.absent(),
    required String alias,
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plantId = Value(plantId),
       alias = Value(alias);
  static Insertable<CataloguePlantAlias> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? lang,
    Expression<String>? alias,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (lang != null) 'lang': lang,
      if (alias != null) 'alias': alias,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantAliasesCompanion copyWith({
    Value<String>? id,
    Value<String>? plantId,
    Value<String?>? lang,
    Value<String>? alias,
    Value<String?>? kind,
    Value<int>? rowid,
  }) {
    return PlantAliasesCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      lang: lang ?? this.lang,
      alias: alias ?? this.alias,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantAliasesCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('lang: $lang, ')
          ..write('alias: $alias, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlantCalendars extends Table
    with TableInfo<PlantCalendars, CataloguePlantCalendar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlantCalendars(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _climateZoneIdMeta = const VerificationMeta(
    'climateZoneId',
  );
  late final GeneratedColumn<String> climateZoneId = GeneratedColumn<String>(
    'climate_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  late final GeneratedColumn<String> activity = GeneratedColumn<String>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monthFromMeta = const VerificationMeta(
    'monthFrom',
  );
  late final GeneratedColumn<int> monthFrom = GeneratedColumn<int>(
    'month_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monthToMeta = const VerificationMeta(
    'monthTo',
  );
  late final GeneratedColumn<int> monthTo = GeneratedColumn<int>(
    'month_to',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plantId,
    climateZoneId,
    activity,
    monthFrom,
    monthTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_calendars';
  @override
  VerificationContext validateIntegrity(
    Insertable<CataloguePlantCalendar> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('climate_zone_id')) {
      context.handle(
        _climateZoneIdMeta,
        climateZoneId.isAcceptableOrUnknown(
          data['climate_zone_id']!,
          _climateZoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_climateZoneIdMeta);
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    } else if (isInserting) {
      context.missing(_activityMeta);
    }
    if (data.containsKey('month_from')) {
      context.handle(
        _monthFromMeta,
        monthFrom.isAcceptableOrUnknown(data['month_from']!, _monthFromMeta),
      );
    } else if (isInserting) {
      context.missing(_monthFromMeta);
    }
    if (data.containsKey('month_to')) {
      context.handle(
        _monthToMeta,
        monthTo.isAcceptableOrUnknown(data['month_to']!, _monthToMeta),
      );
    } else if (isInserting) {
      context.missing(_monthToMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CataloguePlantCalendar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CataloguePlantCalendar(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      climateZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}climate_zone_id'],
      )!,
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity'],
      )!,
      monthFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_from'],
      )!,
      monthTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_to'],
      )!,
    );
  }

  @override
  PlantCalendars createAlias(String alias) {
    return PlantCalendars(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CataloguePlantCalendar extends DataClass
    implements Insertable<CataloguePlantCalendar> {
  final String id;
  final String plantId;
  final String climateZoneId;
  final String activity;
  final int monthFrom;
  final int monthTo;
  const CataloguePlantCalendar({
    required this.id,
    required this.plantId,
    required this.climateZoneId,
    required this.activity,
    required this.monthFrom,
    required this.monthTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['climate_zone_id'] = Variable<String>(climateZoneId);
    map['activity'] = Variable<String>(activity);
    map['month_from'] = Variable<int>(monthFrom);
    map['month_to'] = Variable<int>(monthTo);
    return map;
  }

  PlantCalendarsCompanion toCompanion(bool nullToAbsent) {
    return PlantCalendarsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      climateZoneId: Value(climateZoneId),
      activity: Value(activity),
      monthFrom: Value(monthFrom),
      monthTo: Value(monthTo),
    );
  }

  factory CataloguePlantCalendar.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CataloguePlantCalendar(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plant_id']),
      climateZoneId: serializer.fromJson<String>(json['climate_zone_id']),
      activity: serializer.fromJson<String>(json['activity']),
      monthFrom: serializer.fromJson<int>(json['month_from']),
      monthTo: serializer.fromJson<int>(json['month_to']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plant_id': serializer.toJson<String>(plantId),
      'climate_zone_id': serializer.toJson<String>(climateZoneId),
      'activity': serializer.toJson<String>(activity),
      'month_from': serializer.toJson<int>(monthFrom),
      'month_to': serializer.toJson<int>(monthTo),
    };
  }

  CataloguePlantCalendar copyWith({
    String? id,
    String? plantId,
    String? climateZoneId,
    String? activity,
    int? monthFrom,
    int? monthTo,
  }) => CataloguePlantCalendar(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    climateZoneId: climateZoneId ?? this.climateZoneId,
    activity: activity ?? this.activity,
    monthFrom: monthFrom ?? this.monthFrom,
    monthTo: monthTo ?? this.monthTo,
  );
  CataloguePlantCalendar copyWithCompanion(PlantCalendarsCompanion data) {
    return CataloguePlantCalendar(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      climateZoneId: data.climateZoneId.present
          ? data.climateZoneId.value
          : this.climateZoneId,
      activity: data.activity.present ? data.activity.value : this.activity,
      monthFrom: data.monthFrom.present ? data.monthFrom.value : this.monthFrom,
      monthTo: data.monthTo.present ? data.monthTo.value : this.monthTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CataloguePlantCalendar(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('climateZoneId: $climateZoneId, ')
          ..write('activity: $activity, ')
          ..write('monthFrom: $monthFrom, ')
          ..write('monthTo: $monthTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, plantId, climateZoneId, activity, monthFrom, monthTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CataloguePlantCalendar &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.climateZoneId == this.climateZoneId &&
          other.activity == this.activity &&
          other.monthFrom == this.monthFrom &&
          other.monthTo == this.monthTo);
}

class PlantCalendarsCompanion extends UpdateCompanion<CataloguePlantCalendar> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<String> climateZoneId;
  final Value<String> activity;
  final Value<int> monthFrom;
  final Value<int> monthTo;
  final Value<int> rowid;
  const PlantCalendarsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.climateZoneId = const Value.absent(),
    this.activity = const Value.absent(),
    this.monthFrom = const Value.absent(),
    this.monthTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantCalendarsCompanion.insert({
    required String id,
    required String plantId,
    required String climateZoneId,
    required String activity,
    required int monthFrom,
    required int monthTo,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plantId = Value(plantId),
       climateZoneId = Value(climateZoneId),
       activity = Value(activity),
       monthFrom = Value(monthFrom),
       monthTo = Value(monthTo);
  static Insertable<CataloguePlantCalendar> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? climateZoneId,
    Expression<String>? activity,
    Expression<int>? monthFrom,
    Expression<int>? monthTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (climateZoneId != null) 'climate_zone_id': climateZoneId,
      if (activity != null) 'activity': activity,
      if (monthFrom != null) 'month_from': monthFrom,
      if (monthTo != null) 'month_to': monthTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantCalendarsCompanion copyWith({
    Value<String>? id,
    Value<String>? plantId,
    Value<String>? climateZoneId,
    Value<String>? activity,
    Value<int>? monthFrom,
    Value<int>? monthTo,
    Value<int>? rowid,
  }) {
    return PlantCalendarsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      climateZoneId: climateZoneId ?? this.climateZoneId,
      activity: activity ?? this.activity,
      monthFrom: monthFrom ?? this.monthFrom,
      monthTo: monthTo ?? this.monthTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (climateZoneId.present) {
      map['climate_zone_id'] = Variable<String>(climateZoneId.value);
    }
    if (activity.present) {
      map['activity'] = Variable<String>(activity.value);
    }
    if (monthFrom.present) {
      map['month_from'] = Variable<int>(monthFrom.value);
    }
    if (monthTo.present) {
      map['month_to'] = Variable<int>(monthTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantCalendarsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('climateZoneId: $climateZoneId, ')
          ..write('activity: $activity, ')
          ..write('monthFrom: $monthFrom, ')
          ..write('monthTo: $monthTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Companions extends Table with TableInfo<Companions, CatalogueCompanion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Companions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _otherPlantIdMeta = const VerificationMeta(
    'otherPlantId',
  );
  late final GeneratedColumn<String> otherPlantId = GeneratedColumn<String>(
    'other_plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, plantId, otherPlantId, relation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueCompanion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('other_plant_id')) {
      context.handle(
        _otherPlantIdMeta,
        otherPlantId.isAcceptableOrUnknown(
          data['other_plant_id']!,
          _otherPlantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_otherPlantIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogueCompanion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueCompanion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      otherPlantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_plant_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
    );
  }

  @override
  Companions createAlias(String alias) {
    return Companions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueCompanion extends DataClass
    implements Insertable<CatalogueCompanion> {
  final String id;
  final String plantId;
  final String otherPlantId;
  final String relation;
  const CatalogueCompanion({
    required this.id,
    required this.plantId,
    required this.otherPlantId,
    required this.relation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['other_plant_id'] = Variable<String>(otherPlantId);
    map['relation'] = Variable<String>(relation);
    return map;
  }

  CompanionsCompanion toCompanion(bool nullToAbsent) {
    return CompanionsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      otherPlantId: Value(otherPlantId),
      relation: Value(relation),
    );
  }

  factory CatalogueCompanion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueCompanion(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plant_id']),
      otherPlantId: serializer.fromJson<String>(json['other_plant_id']),
      relation: serializer.fromJson<String>(json['relation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plant_id': serializer.toJson<String>(plantId),
      'other_plant_id': serializer.toJson<String>(otherPlantId),
      'relation': serializer.toJson<String>(relation),
    };
  }

  CatalogueCompanion copyWith({
    String? id,
    String? plantId,
    String? otherPlantId,
    String? relation,
  }) => CatalogueCompanion(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    otherPlantId: otherPlantId ?? this.otherPlantId,
    relation: relation ?? this.relation,
  );
  CatalogueCompanion copyWithCompanion(CompanionsCompanion data) {
    return CatalogueCompanion(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      otherPlantId: data.otherPlantId.present
          ? data.otherPlantId.value
          : this.otherPlantId,
      relation: data.relation.present ? data.relation.value : this.relation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('otherPlantId: $otherPlantId, ')
          ..write('relation: $relation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, otherPlantId, relation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueCompanion &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.otherPlantId == this.otherPlantId &&
          other.relation == this.relation);
}

class CompanionsCompanion extends UpdateCompanion<CatalogueCompanion> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<String> otherPlantId;
  final Value<String> relation;
  final Value<int> rowid;
  const CompanionsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.otherPlantId = const Value.absent(),
    this.relation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanionsCompanion.insert({
    required String id,
    required String plantId,
    required String otherPlantId,
    required String relation,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plantId = Value(plantId),
       otherPlantId = Value(otherPlantId),
       relation = Value(relation);
  static Insertable<CatalogueCompanion> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? otherPlantId,
    Expression<String>? relation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (otherPlantId != null) 'other_plant_id': otherPlantId,
      if (relation != null) 'relation': relation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanionsCompanion copyWith({
    Value<String>? id,
    Value<String>? plantId,
    Value<String>? otherPlantId,
    Value<String>? relation,
    Value<int>? rowid,
  }) {
    return CompanionsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      otherPlantId: otherPlantId ?? this.otherPlantId,
      relation: relation ?? this.relation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (otherPlantId.present) {
      map['other_plant_id'] = Variable<String>(otherPlantId.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanionsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('otherPlantId: $otherPlantId, ')
          ..write('relation: $relation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CareIntervals extends Table
    with TableInfo<CareIntervals, CatalogueCareInterval> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CareIntervals(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monthFromMeta = const VerificationMeta(
    'monthFrom',
  );
  late final GeneratedColumn<int> monthFrom = GeneratedColumn<int>(
    'month_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _monthToMeta = const VerificationMeta(
    'monthTo',
  );
  late final GeneratedColumn<int> monthTo = GeneratedColumn<int>(
    'month_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plantId,
    action,
    intervalDays,
    monthFrom,
    monthTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_intervals';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueCareInterval> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalDaysMeta);
    }
    if (data.containsKey('month_from')) {
      context.handle(
        _monthFromMeta,
        monthFrom.isAcceptableOrUnknown(data['month_from']!, _monthFromMeta),
      );
    }
    if (data.containsKey('month_to')) {
      context.handle(
        _monthToMeta,
        monthTo.isAcceptableOrUnknown(data['month_to']!, _monthToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogueCareInterval map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueCareInterval(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      monthFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_from'],
      ),
      monthTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_to'],
      ),
    );
  }

  @override
  CareIntervals createAlias(String alias) {
    return CareIntervals(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueCareInterval extends DataClass
    implements Insertable<CatalogueCareInterval> {
  final String id;
  final String plantId;
  final String action;
  final int intervalDays;
  final int? monthFrom;
  final int? monthTo;
  const CatalogueCareInterval({
    required this.id,
    required this.plantId,
    required this.action,
    required this.intervalDays,
    this.monthFrom,
    this.monthTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['action'] = Variable<String>(action);
    map['interval_days'] = Variable<int>(intervalDays);
    if (!nullToAbsent || monthFrom != null) {
      map['month_from'] = Variable<int>(monthFrom);
    }
    if (!nullToAbsent || monthTo != null) {
      map['month_to'] = Variable<int>(monthTo);
    }
    return map;
  }

  CareIntervalsCompanion toCompanion(bool nullToAbsent) {
    return CareIntervalsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      action: Value(action),
      intervalDays: Value(intervalDays),
      monthFrom: monthFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(monthFrom),
      monthTo: monthTo == null && nullToAbsent
          ? const Value.absent()
          : Value(monthTo),
    );
  }

  factory CatalogueCareInterval.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueCareInterval(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plant_id']),
      action: serializer.fromJson<String>(json['action']),
      intervalDays: serializer.fromJson<int>(json['interval_days']),
      monthFrom: serializer.fromJson<int?>(json['month_from']),
      monthTo: serializer.fromJson<int?>(json['month_to']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plant_id': serializer.toJson<String>(plantId),
      'action': serializer.toJson<String>(action),
      'interval_days': serializer.toJson<int>(intervalDays),
      'month_from': serializer.toJson<int?>(monthFrom),
      'month_to': serializer.toJson<int?>(monthTo),
    };
  }

  CatalogueCareInterval copyWith({
    String? id,
    String? plantId,
    String? action,
    int? intervalDays,
    Value<int?> monthFrom = const Value.absent(),
    Value<int?> monthTo = const Value.absent(),
  }) => CatalogueCareInterval(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    action: action ?? this.action,
    intervalDays: intervalDays ?? this.intervalDays,
    monthFrom: monthFrom.present ? monthFrom.value : this.monthFrom,
    monthTo: monthTo.present ? monthTo.value : this.monthTo,
  );
  CatalogueCareInterval copyWithCompanion(CareIntervalsCompanion data) {
    return CatalogueCareInterval(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      action: data.action.present ? data.action.value : this.action,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      monthFrom: data.monthFrom.present ? data.monthFrom.value : this.monthFrom,
      monthTo: data.monthTo.present ? data.monthTo.value : this.monthTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueCareInterval(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('action: $action, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('monthFrom: $monthFrom, ')
          ..write('monthTo: $monthTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, plantId, action, intervalDays, monthFrom, monthTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueCareInterval &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.action == this.action &&
          other.intervalDays == this.intervalDays &&
          other.monthFrom == this.monthFrom &&
          other.monthTo == this.monthTo);
}

class CareIntervalsCompanion extends UpdateCompanion<CatalogueCareInterval> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<String> action;
  final Value<int> intervalDays;
  final Value<int?> monthFrom;
  final Value<int?> monthTo;
  final Value<int> rowid;
  const CareIntervalsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.action = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.monthFrom = const Value.absent(),
    this.monthTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareIntervalsCompanion.insert({
    required String id,
    required String plantId,
    required String action,
    required int intervalDays,
    this.monthFrom = const Value.absent(),
    this.monthTo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plantId = Value(plantId),
       action = Value(action),
       intervalDays = Value(intervalDays);
  static Insertable<CatalogueCareInterval> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? action,
    Expression<int>? intervalDays,
    Expression<int>? monthFrom,
    Expression<int>? monthTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (action != null) 'action': action,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (monthFrom != null) 'month_from': monthFrom,
      if (monthTo != null) 'month_to': monthTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareIntervalsCompanion copyWith({
    Value<String>? id,
    Value<String>? plantId,
    Value<String>? action,
    Value<int>? intervalDays,
    Value<int?>? monthFrom,
    Value<int?>? monthTo,
    Value<int>? rowid,
  }) {
    return CareIntervalsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      action: action ?? this.action,
      intervalDays: intervalDays ?? this.intervalDays,
      monthFrom: monthFrom ?? this.monthFrom,
      monthTo: monthTo ?? this.monthTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (monthFrom.present) {
      map['month_from'] = Variable<int>(monthFrom.value);
    }
    if (monthTo.present) {
      map['month_to'] = Variable<int>(monthTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareIntervalsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('action: $action, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('monthFrom: $monthFrom, ')
          ..write('monthTo: $monthTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlantPhotos extends Table
    with TableInfo<PlantPhotos, CataloguePlantPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlantPhotos(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _creditMeta = const VerificationMeta('credit');
  late final GeneratedColumn<String> credit = GeneratedColumn<String>(
    'credit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _licenceMeta = const VerificationMeta(
    'licence',
  );
  late final GeneratedColumn<String> licence = GeneratedColumn<String>(
    'licence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plantId,
    credit,
    licence,
    sourceUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CataloguePlantPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('credit')) {
      context.handle(
        _creditMeta,
        credit.isAcceptableOrUnknown(data['credit']!, _creditMeta),
      );
    } else if (isInserting) {
      context.missing(_creditMeta);
    }
    if (data.containsKey('licence')) {
      context.handle(
        _licenceMeta,
        licence.isAcceptableOrUnknown(data['licence']!, _licenceMeta),
      );
    } else if (isInserting) {
      context.missing(_licenceMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CataloguePlantPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CataloguePlantPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      credit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credit'],
      )!,
      licence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}licence'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
    );
  }

  @override
  PlantPhotos createAlias(String alias) {
    return PlantPhotos(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CataloguePlantPhoto extends DataClass
    implements Insertable<CataloguePlantPhoto> {
  final String id;
  final String plantId;
  final String credit;
  final String licence;
  final String? sourceUrl;
  const CataloguePlantPhoto({
    required this.id,
    required this.plantId,
    required this.credit,
    required this.licence,
    this.sourceUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['credit'] = Variable<String>(credit);
    map['licence'] = Variable<String>(licence);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    return map;
  }

  PlantPhotosCompanion toCompanion(bool nullToAbsent) {
    return PlantPhotosCompanion(
      id: Value(id),
      plantId: Value(plantId),
      credit: Value(credit),
      licence: Value(licence),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
    );
  }

  factory CataloguePlantPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CataloguePlantPhoto(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plant_id']),
      credit: serializer.fromJson<String>(json['credit']),
      licence: serializer.fromJson<String>(json['licence']),
      sourceUrl: serializer.fromJson<String?>(json['source_url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plant_id': serializer.toJson<String>(plantId),
      'credit': serializer.toJson<String>(credit),
      'licence': serializer.toJson<String>(licence),
      'source_url': serializer.toJson<String?>(sourceUrl),
    };
  }

  CataloguePlantPhoto copyWith({
    String? id,
    String? plantId,
    String? credit,
    String? licence,
    Value<String?> sourceUrl = const Value.absent(),
  }) => CataloguePlantPhoto(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    credit: credit ?? this.credit,
    licence: licence ?? this.licence,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
  );
  CataloguePlantPhoto copyWithCompanion(PlantPhotosCompanion data) {
    return CataloguePlantPhoto(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      credit: data.credit.present ? data.credit.value : this.credit,
      licence: data.licence.present ? data.licence.value : this.licence,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CataloguePlantPhoto(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('credit: $credit, ')
          ..write('licence: $licence, ')
          ..write('sourceUrl: $sourceUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, credit, licence, sourceUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CataloguePlantPhoto &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.credit == this.credit &&
          other.licence == this.licence &&
          other.sourceUrl == this.sourceUrl);
}

class PlantPhotosCompanion extends UpdateCompanion<CataloguePlantPhoto> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<String> credit;
  final Value<String> licence;
  final Value<String?> sourceUrl;
  final Value<int> rowid;
  const PlantPhotosCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.credit = const Value.absent(),
    this.licence = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantPhotosCompanion.insert({
    required String id,
    required String plantId,
    required String credit,
    required String licence,
    this.sourceUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plantId = Value(plantId),
       credit = Value(credit),
       licence = Value(licence);
  static Insertable<CataloguePlantPhoto> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? credit,
    Expression<String>? licence,
    Expression<String>? sourceUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (credit != null) 'credit': credit,
      if (licence != null) 'licence': licence,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? plantId,
    Value<String>? credit,
    Value<String>? licence,
    Value<String?>? sourceUrl,
    Value<int>? rowid,
  }) {
    return PlantPhotosCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      credit: credit ?? this.credit,
      licence: licence ?? this.licence,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (credit.present) {
      map['credit'] = Variable<String>(credit.value);
    }
    if (licence.present) {
      map['licence'] = Variable<String>(licence.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantPhotosCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('credit: $credit, ')
          ..write('licence: $licence, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class FactSources extends Table
    with TableInfo<FactSources, CatalogueFactSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FactSources(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _licenceMeta = const VerificationMeta(
    'licence',
  );
  late final GeneratedColumn<String> licence = GeneratedColumn<String>(
    'licence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  late final GeneratedColumn<String> importedAt = GeneratedColumn<String>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plantId,
    field,
    sourceName,
    sourceUrl,
    licence,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fact_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueFactSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('licence')) {
      context.handle(
        _licenceMeta,
        licence.isAcceptableOrUnknown(data['licence']!, _licenceMeta),
      );
    } else if (isInserting) {
      context.missing(_licenceMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogueFactSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueFactSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      licence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}licence'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imported_at'],
      ),
    );
  }

  @override
  FactSources createAlias(String alias) {
    return FactSources(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueFactSource extends DataClass
    implements Insertable<CatalogueFactSource> {
  final String id;
  final String plantId;
  final String field;
  final String sourceName;
  final String? sourceUrl;
  final String licence;
  final String? importedAt;
  const CatalogueFactSource({
    required this.id,
    required this.plantId,
    required this.field,
    required this.sourceName,
    this.sourceUrl,
    required this.licence,
    this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['field'] = Variable<String>(field);
    map['source_name'] = Variable<String>(sourceName);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['licence'] = Variable<String>(licence);
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<String>(importedAt);
    }
    return map;
  }

  FactSourcesCompanion toCompanion(bool nullToAbsent) {
    return FactSourcesCompanion(
      id: Value(id),
      plantId: Value(plantId),
      field: Value(field),
      sourceName: Value(sourceName),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      licence: Value(licence),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
    );
  }

  factory CatalogueFactSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueFactSource(
      id: serializer.fromJson<String>(json['id']),
      plantId: serializer.fromJson<String>(json['plant_id']),
      field: serializer.fromJson<String>(json['field']),
      sourceName: serializer.fromJson<String>(json['source_name']),
      sourceUrl: serializer.fromJson<String?>(json['source_url']),
      licence: serializer.fromJson<String>(json['licence']),
      importedAt: serializer.fromJson<String?>(json['imported_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plant_id': serializer.toJson<String>(plantId),
      'field': serializer.toJson<String>(field),
      'source_name': serializer.toJson<String>(sourceName),
      'source_url': serializer.toJson<String?>(sourceUrl),
      'licence': serializer.toJson<String>(licence),
      'imported_at': serializer.toJson<String?>(importedAt),
    };
  }

  CatalogueFactSource copyWith({
    String? id,
    String? plantId,
    String? field,
    String? sourceName,
    Value<String?> sourceUrl = const Value.absent(),
    String? licence,
    Value<String?> importedAt = const Value.absent(),
  }) => CatalogueFactSource(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    field: field ?? this.field,
    sourceName: sourceName ?? this.sourceName,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    licence: licence ?? this.licence,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
  );
  CatalogueFactSource copyWithCompanion(FactSourcesCompanion data) {
    return CatalogueFactSource(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      field: data.field.present ? data.field.value : this.field,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      licence: data.licence.present ? data.licence.value : this.licence,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueFactSource(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('field: $field, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('licence: $licence, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plantId,
    field,
    sourceName,
    sourceUrl,
    licence,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueFactSource &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.field == this.field &&
          other.sourceName == this.sourceName &&
          other.sourceUrl == this.sourceUrl &&
          other.licence == this.licence &&
          other.importedAt == this.importedAt);
}

class FactSourcesCompanion extends UpdateCompanion<CatalogueFactSource> {
  final Value<String> id;
  final Value<String> plantId;
  final Value<String> field;
  final Value<String> sourceName;
  final Value<String?> sourceUrl;
  final Value<String> licence;
  final Value<String?> importedAt;
  final Value<int> rowid;
  const FactSourcesCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.field = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.licence = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FactSourcesCompanion.insert({
    required String id,
    required String plantId,
    required String field,
    required String sourceName,
    this.sourceUrl = const Value.absent(),
    required String licence,
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plantId = Value(plantId),
       field = Value(field),
       sourceName = Value(sourceName),
       licence = Value(licence);
  static Insertable<CatalogueFactSource> custom({
    Expression<String>? id,
    Expression<String>? plantId,
    Expression<String>? field,
    Expression<String>? sourceName,
    Expression<String>? sourceUrl,
    Expression<String>? licence,
    Expression<String>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (field != null) 'field': field,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (licence != null) 'licence': licence,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FactSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? plantId,
    Value<String>? field,
    Value<String>? sourceName,
    Value<String?>? sourceUrl,
    Value<String>? licence,
    Value<String?>? importedAt,
    Value<int>? rowid,
  }) {
    return FactSourcesCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      field: field ?? this.field,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      licence: licence ?? this.licence,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (licence.present) {
      map['licence'] = Variable<String>(licence.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<String>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FactSourcesCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('field: $field, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('licence: $licence, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Tips extends Table with TableInfo<Tips, CatalogueTip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tips(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _textElMeta = const VerificationMeta('textEl');
  late final GeneratedColumn<String> textEl = GeneratedColumn<String>(
    'text_el',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _textEnMeta = const VerificationMeta('textEn');
  late final GeneratedColumn<String> textEn = GeneratedColumn<String>(
    'text_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monthFromMeta = const VerificationMeta(
    'monthFrom',
  );
  late final GeneratedColumn<int> monthFrom = GeneratedColumn<int>(
    'month_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _monthToMeta = const VerificationMeta(
    'monthTo',
  );
  late final GeneratedColumn<int> monthTo = GeneratedColumn<int>(
    'month_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _climateZoneIdMeta = const VerificationMeta(
    'climateZoneId',
  );
  late final GeneratedColumn<String> climateZoneId = GeneratedColumn<String>(
    'climate_zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    textEl,
    textEn,
    monthFrom,
    monthTo,
    climateZoneId,
    plantId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tips';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueTip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('text_el')) {
      context.handle(
        _textElMeta,
        textEl.isAcceptableOrUnknown(data['text_el']!, _textElMeta),
      );
    } else if (isInserting) {
      context.missing(_textElMeta);
    }
    if (data.containsKey('text_en')) {
      context.handle(
        _textEnMeta,
        textEn.isAcceptableOrUnknown(data['text_en']!, _textEnMeta),
      );
    } else if (isInserting) {
      context.missing(_textEnMeta);
    }
    if (data.containsKey('month_from')) {
      context.handle(
        _monthFromMeta,
        monthFrom.isAcceptableOrUnknown(data['month_from']!, _monthFromMeta),
      );
    }
    if (data.containsKey('month_to')) {
      context.handle(
        _monthToMeta,
        monthTo.isAcceptableOrUnknown(data['month_to']!, _monthToMeta),
      );
    }
    if (data.containsKey('climate_zone_id')) {
      context.handle(
        _climateZoneIdMeta,
        climateZoneId.isAcceptableOrUnknown(
          data['climate_zone_id']!,
          _climateZoneIdMeta,
        ),
      );
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogueTip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueTip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      textEl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_el'],
      )!,
      textEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_en'],
      )!,
      monthFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_from'],
      ),
      monthTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_to'],
      ),
      climateZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}climate_zone_id'],
      ),
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      ),
    );
  }

  @override
  Tips createAlias(String alias) {
    return Tips(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueTip extends DataClass implements Insertable<CatalogueTip> {
  final String id;
  final String textEl;
  final String textEn;
  final int? monthFrom;
  final int? monthTo;
  final String? climateZoneId;
  final String? plantId;
  const CatalogueTip({
    required this.id,
    required this.textEl,
    required this.textEn,
    this.monthFrom,
    this.monthTo,
    this.climateZoneId,
    this.plantId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['text_el'] = Variable<String>(textEl);
    map['text_en'] = Variable<String>(textEn);
    if (!nullToAbsent || monthFrom != null) {
      map['month_from'] = Variable<int>(monthFrom);
    }
    if (!nullToAbsent || monthTo != null) {
      map['month_to'] = Variable<int>(monthTo);
    }
    if (!nullToAbsent || climateZoneId != null) {
      map['climate_zone_id'] = Variable<String>(climateZoneId);
    }
    if (!nullToAbsent || plantId != null) {
      map['plant_id'] = Variable<String>(plantId);
    }
    return map;
  }

  TipsCompanion toCompanion(bool nullToAbsent) {
    return TipsCompanion(
      id: Value(id),
      textEl: Value(textEl),
      textEn: Value(textEn),
      monthFrom: monthFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(monthFrom),
      monthTo: monthTo == null && nullToAbsent
          ? const Value.absent()
          : Value(monthTo),
      climateZoneId: climateZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(climateZoneId),
      plantId: plantId == null && nullToAbsent
          ? const Value.absent()
          : Value(plantId),
    );
  }

  factory CatalogueTip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueTip(
      id: serializer.fromJson<String>(json['id']),
      textEl: serializer.fromJson<String>(json['text_el']),
      textEn: serializer.fromJson<String>(json['text_en']),
      monthFrom: serializer.fromJson<int?>(json['month_from']),
      monthTo: serializer.fromJson<int?>(json['month_to']),
      climateZoneId: serializer.fromJson<String?>(json['climate_zone_id']),
      plantId: serializer.fromJson<String?>(json['plant_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'text_el': serializer.toJson<String>(textEl),
      'text_en': serializer.toJson<String>(textEn),
      'month_from': serializer.toJson<int?>(monthFrom),
      'month_to': serializer.toJson<int?>(monthTo),
      'climate_zone_id': serializer.toJson<String?>(climateZoneId),
      'plant_id': serializer.toJson<String?>(plantId),
    };
  }

  CatalogueTip copyWith({
    String? id,
    String? textEl,
    String? textEn,
    Value<int?> monthFrom = const Value.absent(),
    Value<int?> monthTo = const Value.absent(),
    Value<String?> climateZoneId = const Value.absent(),
    Value<String?> plantId = const Value.absent(),
  }) => CatalogueTip(
    id: id ?? this.id,
    textEl: textEl ?? this.textEl,
    textEn: textEn ?? this.textEn,
    monthFrom: monthFrom.present ? monthFrom.value : this.monthFrom,
    monthTo: monthTo.present ? monthTo.value : this.monthTo,
    climateZoneId: climateZoneId.present
        ? climateZoneId.value
        : this.climateZoneId,
    plantId: plantId.present ? plantId.value : this.plantId,
  );
  CatalogueTip copyWithCompanion(TipsCompanion data) {
    return CatalogueTip(
      id: data.id.present ? data.id.value : this.id,
      textEl: data.textEl.present ? data.textEl.value : this.textEl,
      textEn: data.textEn.present ? data.textEn.value : this.textEn,
      monthFrom: data.monthFrom.present ? data.monthFrom.value : this.monthFrom,
      monthTo: data.monthTo.present ? data.monthTo.value : this.monthTo,
      climateZoneId: data.climateZoneId.present
          ? data.climateZoneId.value
          : this.climateZoneId,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueTip(')
          ..write('id: $id, ')
          ..write('textEl: $textEl, ')
          ..write('textEn: $textEn, ')
          ..write('monthFrom: $monthFrom, ')
          ..write('monthTo: $monthTo, ')
          ..write('climateZoneId: $climateZoneId, ')
          ..write('plantId: $plantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    textEl,
    textEn,
    monthFrom,
    monthTo,
    climateZoneId,
    plantId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueTip &&
          other.id == this.id &&
          other.textEl == this.textEl &&
          other.textEn == this.textEn &&
          other.monthFrom == this.monthFrom &&
          other.monthTo == this.monthTo &&
          other.climateZoneId == this.climateZoneId &&
          other.plantId == this.plantId);
}

class TipsCompanion extends UpdateCompanion<CatalogueTip> {
  final Value<String> id;
  final Value<String> textEl;
  final Value<String> textEn;
  final Value<int?> monthFrom;
  final Value<int?> monthTo;
  final Value<String?> climateZoneId;
  final Value<String?> plantId;
  final Value<int> rowid;
  const TipsCompanion({
    this.id = const Value.absent(),
    this.textEl = const Value.absent(),
    this.textEn = const Value.absent(),
    this.monthFrom = const Value.absent(),
    this.monthTo = const Value.absent(),
    this.climateZoneId = const Value.absent(),
    this.plantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TipsCompanion.insert({
    required String id,
    required String textEl,
    required String textEn,
    this.monthFrom = const Value.absent(),
    this.monthTo = const Value.absent(),
    this.climateZoneId = const Value.absent(),
    this.plantId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       textEl = Value(textEl),
       textEn = Value(textEn);
  static Insertable<CatalogueTip> custom({
    Expression<String>? id,
    Expression<String>? textEl,
    Expression<String>? textEn,
    Expression<int>? monthFrom,
    Expression<int>? monthTo,
    Expression<String>? climateZoneId,
    Expression<String>? plantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (textEl != null) 'text_el': textEl,
      if (textEn != null) 'text_en': textEn,
      if (monthFrom != null) 'month_from': monthFrom,
      if (monthTo != null) 'month_to': monthTo,
      if (climateZoneId != null) 'climate_zone_id': climateZoneId,
      if (plantId != null) 'plant_id': plantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TipsCompanion copyWith({
    Value<String>? id,
    Value<String>? textEl,
    Value<String>? textEn,
    Value<int?>? monthFrom,
    Value<int?>? monthTo,
    Value<String?>? climateZoneId,
    Value<String?>? plantId,
    Value<int>? rowid,
  }) {
    return TipsCompanion(
      id: id ?? this.id,
      textEl: textEl ?? this.textEl,
      textEn: textEn ?? this.textEn,
      monthFrom: monthFrom ?? this.monthFrom,
      monthTo: monthTo ?? this.monthTo,
      climateZoneId: climateZoneId ?? this.climateZoneId,
      plantId: plantId ?? this.plantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (textEl.present) {
      map['text_el'] = Variable<String>(textEl.value);
    }
    if (textEn.present) {
      map['text_en'] = Variable<String>(textEn.value);
    }
    if (monthFrom.present) {
      map['month_from'] = Variable<int>(monthFrom.value);
    }
    if (monthTo.present) {
      map['month_to'] = Variable<int>(monthTo.value);
    }
    if (climateZoneId.present) {
      map['climate_zone_id'] = Variable<String>(climateZoneId.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipsCompanion(')
          ..write('id: $id, ')
          ..write('textEl: $textEl, ')
          ..write('textEn: $textEn, ')
          ..write('monthFrom: $monthFrom, ')
          ..write('monthTo: $monthTo, ')
          ..write('climateZoneId: $climateZoneId, ')
          ..write('plantId: $plantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Settlements extends Table
    with TableInfo<Settlements, CatalogueSettlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settlements(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  static const VerificationMeta _nameElMeta = const VerificationMeta('nameEl');
  late final GeneratedColumn<String> nameEl = GeneratedColumn<String>(
    'name_el',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _searchKeysMeta = const VerificationMeta(
    'searchKeys',
  );
  late final GeneratedColumn<String> searchKeys = GeneratedColumn<String>(
    'search_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameEl,
    nameEn,
    region,
    lat,
    lon,
    searchKeys,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueSettlement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_el')) {
      context.handle(
        _nameElMeta,
        nameEl.isAcceptableOrUnknown(data['name_el']!, _nameElMeta),
      );
    } else if (isInserting) {
      context.missing(_nameElMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('search_keys')) {
      context.handle(
        _searchKeysMeta,
        searchKeys.isAcceptableOrUnknown(data['search_keys']!, _searchKeysMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogueSettlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueSettlement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameEl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_el'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      searchKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_keys'],
      )!,
    );
  }

  @override
  Settlements createAlias(String alias) {
    return Settlements(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CatalogueSettlement extends DataClass
    implements Insertable<CatalogueSettlement> {
  final String id;
  final String nameEl;
  final String? nameEn;
  final String? region;
  final double lat;
  final double lon;
  final String searchKeys;
  const CatalogueSettlement({
    required this.id,
    required this.nameEl,
    this.nameEn,
    this.region,
    required this.lat,
    required this.lon,
    required this.searchKeys,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_el'] = Variable<String>(nameEl);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['search_keys'] = Variable<String>(searchKeys);
    return map;
  }

  SettlementsCompanion toCompanion(bool nullToAbsent) {
    return SettlementsCompanion(
      id: Value(id),
      nameEl: Value(nameEl),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      lat: Value(lat),
      lon: Value(lon),
      searchKeys: Value(searchKeys),
    );
  }

  factory CatalogueSettlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueSettlement(
      id: serializer.fromJson<String>(json['id']),
      nameEl: serializer.fromJson<String>(json['name_el']),
      nameEn: serializer.fromJson<String?>(json['name_en']),
      region: serializer.fromJson<String?>(json['region']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      searchKeys: serializer.fromJson<String>(json['search_keys']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name_el': serializer.toJson<String>(nameEl),
      'name_en': serializer.toJson<String?>(nameEn),
      'region': serializer.toJson<String?>(region),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'search_keys': serializer.toJson<String>(searchKeys),
    };
  }

  CatalogueSettlement copyWith({
    String? id,
    String? nameEl,
    Value<String?> nameEn = const Value.absent(),
    Value<String?> region = const Value.absent(),
    double? lat,
    double? lon,
    String? searchKeys,
  }) => CatalogueSettlement(
    id: id ?? this.id,
    nameEl: nameEl ?? this.nameEl,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    region: region.present ? region.value : this.region,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    searchKeys: searchKeys ?? this.searchKeys,
  );
  CatalogueSettlement copyWithCompanion(SettlementsCompanion data) {
    return CatalogueSettlement(
      id: data.id.present ? data.id.value : this.id,
      nameEl: data.nameEl.present ? data.nameEl.value : this.nameEl,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      region: data.region.present ? data.region.value : this.region,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      searchKeys: data.searchKeys.present
          ? data.searchKeys.value
          : this.searchKeys,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueSettlement(')
          ..write('id: $id, ')
          ..write('nameEl: $nameEl, ')
          ..write('nameEn: $nameEn, ')
          ..write('region: $region, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('searchKeys: $searchKeys')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nameEl, nameEn, region, lat, lon, searchKeys);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueSettlement &&
          other.id == this.id &&
          other.nameEl == this.nameEl &&
          other.nameEn == this.nameEn &&
          other.region == this.region &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.searchKeys == this.searchKeys);
}

class SettlementsCompanion extends UpdateCompanion<CatalogueSettlement> {
  final Value<String> id;
  final Value<String> nameEl;
  final Value<String?> nameEn;
  final Value<String?> region;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String> searchKeys;
  final Value<int> rowid;
  const SettlementsCompanion({
    this.id = const Value.absent(),
    this.nameEl = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.region = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.searchKeys = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementsCompanion.insert({
    required String id,
    required String nameEl,
    this.nameEn = const Value.absent(),
    this.region = const Value.absent(),
    required double lat,
    required double lon,
    required String searchKeys,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameEl = Value(nameEl),
       lat = Value(lat),
       lon = Value(lon),
       searchKeys = Value(searchKeys);
  static Insertable<CatalogueSettlement> custom({
    Expression<String>? id,
    Expression<String>? nameEl,
    Expression<String>? nameEn,
    Expression<String>? region,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? searchKeys,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameEl != null) 'name_el': nameEl,
      if (nameEn != null) 'name_en': nameEn,
      if (region != null) 'region': region,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (searchKeys != null) 'search_keys': searchKeys,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementsCompanion copyWith({
    Value<String>? id,
    Value<String>? nameEl,
    Value<String?>? nameEn,
    Value<String?>? region,
    Value<double>? lat,
    Value<double>? lon,
    Value<String>? searchKeys,
    Value<int>? rowid,
  }) {
    return SettlementsCompanion(
      id: id ?? this.id,
      nameEl: nameEl ?? this.nameEl,
      nameEn: nameEn ?? this.nameEn,
      region: region ?? this.region,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      searchKeys: searchKeys ?? this.searchKeys,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameEl.present) {
      map['name_el'] = Variable<String>(nameEl.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (searchKeys.present) {
      map['search_keys'] = Variable<String>(searchKeys.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementsCompanion(')
          ..write('id: $id, ')
          ..write('nameEl: $nameEl, ')
          ..write('nameEn: $nameEn, ')
          ..write('region: $region, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('searchKeys: $searchKeys, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class PlantSearch extends Table
    with
        TableInfo<PlantSearch, PlantSearchData>,
        VirtualTableInfo<PlantSearch, PlantSearchData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PlantSearch(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _searchKeysMeta = const VerificationMeta(
    'searchKeys',
  );
  late final GeneratedColumn<String> searchKeys = GeneratedColumn<String>(
    'search_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [plantId, searchKeys];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_search';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlantSearchData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('search_keys')) {
      context.handle(
        _searchKeysMeta,
        searchKeys.isAcceptableOrUnknown(data['search_keys']!, _searchKeysMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  PlantSearchData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantSearchData(
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      searchKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_keys'],
      )!,
    );
  }

  @override
  PlantSearch createAlias(String alias) {
    return PlantSearch(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(plant_id UNINDEXED, search_keys, tokenize = \'unicode61 remove_diacritics 2\')';
}

class PlantSearchData extends DataClass implements Insertable<PlantSearchData> {
  final String plantId;
  final String searchKeys;
  const PlantSearchData({required this.plantId, required this.searchKeys});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plant_id'] = Variable<String>(plantId);
    map['search_keys'] = Variable<String>(searchKeys);
    return map;
  }

  PlantSearchCompanion toCompanion(bool nullToAbsent) {
    return PlantSearchCompanion(
      plantId: Value(plantId),
      searchKeys: Value(searchKeys),
    );
  }

  factory PlantSearchData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantSearchData(
      plantId: serializer.fromJson<String>(json['plant_id']),
      searchKeys: serializer.fromJson<String>(json['search_keys']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'plant_id': serializer.toJson<String>(plantId),
      'search_keys': serializer.toJson<String>(searchKeys),
    };
  }

  PlantSearchData copyWith({String? plantId, String? searchKeys}) =>
      PlantSearchData(
        plantId: plantId ?? this.plantId,
        searchKeys: searchKeys ?? this.searchKeys,
      );
  PlantSearchData copyWithCompanion(PlantSearchCompanion data) {
    return PlantSearchData(
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      searchKeys: data.searchKeys.present
          ? data.searchKeys.value
          : this.searchKeys,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantSearchData(')
          ..write('plantId: $plantId, ')
          ..write('searchKeys: $searchKeys')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(plantId, searchKeys);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantSearchData &&
          other.plantId == this.plantId &&
          other.searchKeys == this.searchKeys);
}

class PlantSearchCompanion extends UpdateCompanion<PlantSearchData> {
  final Value<String> plantId;
  final Value<String> searchKeys;
  final Value<int> rowid;
  const PlantSearchCompanion({
    this.plantId = const Value.absent(),
    this.searchKeys = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantSearchCompanion.insert({
    required String plantId,
    required String searchKeys,
    this.rowid = const Value.absent(),
  }) : plantId = Value(plantId),
       searchKeys = Value(searchKeys);
  static Insertable<PlantSearchData> custom({
    Expression<String>? plantId,
    Expression<String>? searchKeys,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (plantId != null) 'plant_id': plantId,
      if (searchKeys != null) 'search_keys': searchKeys,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantSearchCompanion copyWith({
    Value<String>? plantId,
    Value<String>? searchKeys,
    Value<int>? rowid,
  }) {
    return PlantSearchCompanion(
      plantId: plantId ?? this.plantId,
      searchKeys: searchKeys ?? this.searchKeys,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (searchKeys.present) {
      map['search_keys'] = Variable<String>(searchKeys.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantSearchCompanion(')
          ..write('plantId: $plantId, ')
          ..write('searchKeys: $searchKeys, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SettlementSearch extends Table
    with
        TableInfo<SettlementSearch, SettlementSearchData>,
        VirtualTableInfo<SettlementSearch, SettlementSearchData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SettlementSearch(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settlementIdMeta = const VerificationMeta(
    'settlementId',
  );
  late final GeneratedColumn<String> settlementId = GeneratedColumn<String>(
    'settlement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _searchKeysMeta = const VerificationMeta(
    'searchKeys',
  );
  late final GeneratedColumn<String> searchKeys = GeneratedColumn<String>(
    'search_keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [settlementId, searchKeys];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlement_search';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettlementSearchData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('settlement_id')) {
      context.handle(
        _settlementIdMeta,
        settlementId.isAcceptableOrUnknown(
          data['settlement_id']!,
          _settlementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settlementIdMeta);
    }
    if (data.containsKey('search_keys')) {
      context.handle(
        _searchKeysMeta,
        searchKeys.isAcceptableOrUnknown(data['search_keys']!, _searchKeysMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SettlementSearchData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettlementSearchData(
      settlementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_id'],
      )!,
      searchKeys: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_keys'],
      )!,
    );
  }

  @override
  SettlementSearch createAlias(String alias) {
    return SettlementSearch(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(settlement_id UNINDEXED, search_keys, tokenize = \'unicode61 remove_diacritics 2\')';
}

class SettlementSearchData extends DataClass
    implements Insertable<SettlementSearchData> {
  final String settlementId;
  final String searchKeys;
  const SettlementSearchData({
    required this.settlementId,
    required this.searchKeys,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['settlement_id'] = Variable<String>(settlementId);
    map['search_keys'] = Variable<String>(searchKeys);
    return map;
  }

  SettlementSearchCompanion toCompanion(bool nullToAbsent) {
    return SettlementSearchCompanion(
      settlementId: Value(settlementId),
      searchKeys: Value(searchKeys),
    );
  }

  factory SettlementSearchData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettlementSearchData(
      settlementId: serializer.fromJson<String>(json['settlement_id']),
      searchKeys: serializer.fromJson<String>(json['search_keys']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settlement_id': serializer.toJson<String>(settlementId),
      'search_keys': serializer.toJson<String>(searchKeys),
    };
  }

  SettlementSearchData copyWith({String? settlementId, String? searchKeys}) =>
      SettlementSearchData(
        settlementId: settlementId ?? this.settlementId,
        searchKeys: searchKeys ?? this.searchKeys,
      );
  SettlementSearchData copyWithCompanion(SettlementSearchCompanion data) {
    return SettlementSearchData(
      settlementId: data.settlementId.present
          ? data.settlementId.value
          : this.settlementId,
      searchKeys: data.searchKeys.present
          ? data.searchKeys.value
          : this.searchKeys,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettlementSearchData(')
          ..write('settlementId: $settlementId, ')
          ..write('searchKeys: $searchKeys')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settlementId, searchKeys);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettlementSearchData &&
          other.settlementId == this.settlementId &&
          other.searchKeys == this.searchKeys);
}

class SettlementSearchCompanion extends UpdateCompanion<SettlementSearchData> {
  final Value<String> settlementId;
  final Value<String> searchKeys;
  final Value<int> rowid;
  const SettlementSearchCompanion({
    this.settlementId = const Value.absent(),
    this.searchKeys = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementSearchCompanion.insert({
    required String settlementId,
    required String searchKeys,
    this.rowid = const Value.absent(),
  }) : settlementId = Value(settlementId),
       searchKeys = Value(searchKeys);
  static Insertable<SettlementSearchData> custom({
    Expression<String>? settlementId,
    Expression<String>? searchKeys,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settlementId != null) 'settlement_id': settlementId,
      if (searchKeys != null) 'search_keys': searchKeys,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementSearchCompanion copyWith({
    Value<String>? settlementId,
    Value<String>? searchKeys,
    Value<int>? rowid,
  }) {
    return SettlementSearchCompanion(
      settlementId: settlementId ?? this.settlementId,
      searchKeys: searchKeys ?? this.searchKeys,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settlementId.present) {
      map['settlement_id'] = Variable<String>(settlementId.value);
    }
    if (searchKeys.present) {
      map['search_keys'] = Variable<String>(searchKeys.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementSearchCompanion(')
          ..write('settlementId: $settlementId, ')
          ..write('searchKeys: $searchKeys, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CatalogueDatabase extends GeneratedDatabase {
  _$CatalogueDatabase(QueryExecutor e) : super(e);
  $CatalogueDatabaseManager get managers => $CatalogueDatabaseManager(this);
  late final Meta meta = Meta(this);
  late final Categories categories = Categories(this);
  late final ClimateZones climateZones = ClimateZones(this);
  late final Plants plants = Plants(this);
  late final Index plantsCategoryId = Index(
    'plants_category_id',
    'CREATE INDEX plants_category_id ON plants (category_id)',
  );
  late final PlantTranslations plantTranslations = PlantTranslations(this);
  late final PlantAliases plantAliases = PlantAliases(this);
  late final Index plantAliasesPlantId = Index(
    'plant_aliases_plant_id',
    'CREATE INDEX plant_aliases_plant_id ON plant_aliases (plant_id)',
  );
  late final PlantCalendars plantCalendars = PlantCalendars(this);
  late final Index plantCalendarsZone = Index(
    'plant_calendars_zone',
    'CREATE INDEX plant_calendars_zone ON plant_calendars (climate_zone_id, activity)',
  );
  late final Index plantCalendarsPlantId = Index(
    'plant_calendars_plant_id',
    'CREATE INDEX plant_calendars_plant_id ON plant_calendars (plant_id)',
  );
  late final Companions companions = Companions(this);
  late final Index companionsPlantId = Index(
    'companions_plant_id',
    'CREATE INDEX companions_plant_id ON companions (plant_id)',
  );
  late final CareIntervals careIntervals = CareIntervals(this);
  late final Index careIntervalsPlantId = Index(
    'care_intervals_plant_id',
    'CREATE INDEX care_intervals_plant_id ON care_intervals (plant_id)',
  );
  late final PlantPhotos plantPhotos = PlantPhotos(this);
  late final Index plantPhotosPlantId = Index(
    'plant_photos_plant_id',
    'CREATE INDEX plant_photos_plant_id ON plant_photos (plant_id)',
  );
  late final FactSources factSources = FactSources(this);
  late final Index factSourcesPlantId = Index(
    'fact_sources_plant_id',
    'CREATE INDEX fact_sources_plant_id ON fact_sources (plant_id)',
  );
  late final Tips tips = Tips(this);
  late final Settlements settlements = Settlements(this);
  late final PlantSearch plantSearch = PlantSearch(this);
  late final SettlementSearch settlementSearch = SettlementSearch(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    meta,
    categories,
    climateZones,
    plants,
    plantsCategoryId,
    plantTranslations,
    plantAliases,
    plantAliasesPlantId,
    plantCalendars,
    plantCalendarsZone,
    plantCalendarsPlantId,
    companions,
    companionsPlantId,
    careIntervals,
    careIntervalsPlantId,
    plantPhotos,
    plantPhotosPlantId,
    factSources,
    factSourcesPlantId,
    tips,
    settlements,
    plantSearch,
    settlementSearch,
  ];
}

typedef $MetaCreateCompanionBuilder =
    MetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $MetaUpdateCompanionBuilder =
    MetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $MetaFilterComposer extends Composer<_$CatalogueDatabase, Meta> {
  $MetaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $MetaOrderingComposer extends Composer<_$CatalogueDatabase, Meta> {
  $MetaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MetaAnnotationComposer extends Composer<_$CatalogueDatabase, Meta> {
  $MetaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $MetaTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          Meta,
          CatalogueMetaEntry,
          $MetaFilterComposer,
          $MetaOrderingComposer,
          $MetaAnnotationComposer,
          $MetaCreateCompanionBuilder,
          $MetaUpdateCompanionBuilder,
          (
            CatalogueMetaEntry,
            BaseReferences<_$CatalogueDatabase, Meta, CatalogueMetaEntry>,
          ),
          CatalogueMetaEntry,
          PrefetchHooks Function()
        > {
  $MetaTableManager(_$CatalogueDatabase db, Meta table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MetaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MetaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MetaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Meta, CatalogueMetaEntry>(table),
                  BaseReferences<_$CatalogueDatabase, Meta, CatalogueMetaEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $MetaProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      Meta,
      CatalogueMetaEntry,
      $MetaFilterComposer,
      $MetaOrderingComposer,
      $MetaAnnotationComposer,
      $MetaCreateCompanionBuilder,
      $MetaUpdateCompanionBuilder,
      (
        CatalogueMetaEntry,
        BaseReferences<_$CatalogueDatabase, Meta, CatalogueMetaEntry>,
      ),
      CatalogueMetaEntry,
      PrefetchHooks Function()
    >;
typedef $CategoriesCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String code,
      required String nameEl,
      required String nameEn,
      Value<String?> parentId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });
typedef $CategoriesUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> nameEl,
      Value<String> nameEn,
      Value<String?> parentId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });

class $CategoriesFilterComposer
    extends Composer<_$CatalogueDatabase, Categories> {
  $CategoriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEl => $composableBuilder(
    column: $table.nameEl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $CategoriesOrderingComposer
    extends Composer<_$CatalogueDatabase, Categories> {
  $CategoriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEl => $composableBuilder(
    column: $table.nameEl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CategoriesAnnotationComposer
    extends Composer<_$CatalogueDatabase, Categories> {
  $CategoriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameEl =>
      $composableBuilder(column: $table.nameEl, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $CategoriesTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          Categories,
          CatalogueCategory,
          $CategoriesFilterComposer,
          $CategoriesOrderingComposer,
          $CategoriesAnnotationComposer,
          $CategoriesCreateCompanionBuilder,
          $CategoriesUpdateCompanionBuilder,
          (
            CatalogueCategory,
            BaseReferences<_$CatalogueDatabase, Categories, CatalogueCategory>,
          ),
          CatalogueCategory,
          PrefetchHooks Function()
        > {
  $CategoriesTableManager(_$CatalogueDatabase db, Categories table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CategoriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CategoriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CategoriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> nameEl = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                code: code,
                nameEl: nameEl,
                nameEn: nameEn,
                parentId: parentId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String nameEl,
                required String nameEn,
                Value<String?> parentId = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                code: code,
                nameEl: nameEl,
                nameEn: nameEn,
                parentId: parentId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Categories, CatalogueCategory>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    Categories,
                    CatalogueCategory
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CategoriesProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      Categories,
      CatalogueCategory,
      $CategoriesFilterComposer,
      $CategoriesOrderingComposer,
      $CategoriesAnnotationComposer,
      $CategoriesCreateCompanionBuilder,
      $CategoriesUpdateCompanionBuilder,
      (
        CatalogueCategory,
        BaseReferences<_$CatalogueDatabase, Categories, CatalogueCategory>,
      ),
      CatalogueCategory,
      PrefetchHooks Function()
    >;
typedef $ClimateZonesCreateCompanionBuilder =
    ClimateZonesCompanion Function({
      required String id,
      required String code,
      required String nameEl,
      required String nameEn,
      Value<String?> description,
      required String rules,
      Value<int> rowid,
    });
typedef $ClimateZonesUpdateCompanionBuilder =
    ClimateZonesCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> nameEl,
      Value<String> nameEn,
      Value<String?> description,
      Value<String> rules,
      Value<int> rowid,
    });

class $ClimateZonesFilterComposer
    extends Composer<_$CatalogueDatabase, ClimateZones> {
  $ClimateZonesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEl => $composableBuilder(
    column: $table.nameEl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnFilters(column),
  );
}

class $ClimateZonesOrderingComposer
    extends Composer<_$CatalogueDatabase, ClimateZones> {
  $ClimateZonesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEl => $composableBuilder(
    column: $table.nameEl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rules => $composableBuilder(
    column: $table.rules,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ClimateZonesAnnotationComposer
    extends Composer<_$CatalogueDatabase, ClimateZones> {
  $ClimateZonesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameEl =>
      $composableBuilder(column: $table.nameEl, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rules =>
      $composableBuilder(column: $table.rules, builder: (column) => column);
}

class $ClimateZonesTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          ClimateZones,
          CatalogueClimateZone,
          $ClimateZonesFilterComposer,
          $ClimateZonesOrderingComposer,
          $ClimateZonesAnnotationComposer,
          $ClimateZonesCreateCompanionBuilder,
          $ClimateZonesUpdateCompanionBuilder,
          (
            CatalogueClimateZone,
            BaseReferences<
              _$CatalogueDatabase,
              ClimateZones,
              CatalogueClimateZone
            >,
          ),
          CatalogueClimateZone,
          PrefetchHooks Function()
        > {
  $ClimateZonesTableManager(_$CatalogueDatabase db, ClimateZones table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ClimateZonesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ClimateZonesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ClimateZonesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> nameEl = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> rules = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClimateZonesCompanion(
                id: id,
                code: code,
                nameEl: nameEl,
                nameEn: nameEn,
                description: description,
                rules: rules,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String nameEl,
                required String nameEn,
                Value<String?> description = const Value.absent(),
                required String rules,
                Value<int> rowid = const Value.absent(),
              }) => ClimateZonesCompanion.insert(
                id: id,
                code: code,
                nameEl: nameEl,
                nameEn: nameEn,
                description: description,
                rules: rules,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ClimateZones, CatalogueClimateZone>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    ClimateZones,
                    CatalogueClimateZone
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ClimateZonesProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      ClimateZones,
      CatalogueClimateZone,
      $ClimateZonesFilterComposer,
      $ClimateZonesOrderingComposer,
      $ClimateZonesAnnotationComposer,
      $ClimateZonesCreateCompanionBuilder,
      $ClimateZonesUpdateCompanionBuilder,
      (
        CatalogueClimateZone,
        BaseReferences<_$CatalogueDatabase, ClimateZones, CatalogueClimateZone>,
      ),
      CatalogueClimateZone,
      PrefetchHooks Function()
    >;
typedef $PlantsCreateCompanionBuilder =
    PlantsCompanion Function({
      required String id,
      required String scientificName,
      Value<int?> gbifId,
      required String categoryId,
      Value<double?> tempMinC,
      Value<double?> tempOptC,
      Value<double?> tempMaxC,
      Value<int?> waterNeed,
      Value<String?> sun,
      Value<String?> soilTypes,
      Value<double?> phMin,
      Value<double?> phMax,
      Value<String?> frostHardiness,
      Value<String?> propagation,
      Value<double?> sowDepthCm,
      Value<int?> spacingCm,
      Value<int?> rowSpacingCm,
      Value<int?> daysToHarvest,
      Value<String?> publishedAt,
      Value<String?> updatedAt,
      required String searchKeys,
      Value<int> rowid,
    });
typedef $PlantsUpdateCompanionBuilder =
    PlantsCompanion Function({
      Value<String> id,
      Value<String> scientificName,
      Value<int?> gbifId,
      Value<String> categoryId,
      Value<double?> tempMinC,
      Value<double?> tempOptC,
      Value<double?> tempMaxC,
      Value<int?> waterNeed,
      Value<String?> sun,
      Value<String?> soilTypes,
      Value<double?> phMin,
      Value<double?> phMax,
      Value<String?> frostHardiness,
      Value<String?> propagation,
      Value<double?> sowDepthCm,
      Value<int?> spacingCm,
      Value<int?> rowSpacingCm,
      Value<int?> daysToHarvest,
      Value<String?> publishedAt,
      Value<String?> updatedAt,
      Value<String> searchKeys,
      Value<int> rowid,
    });

class $PlantsFilterComposer extends Composer<_$CatalogueDatabase, Plants> {
  $PlantsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gbifId => $composableBuilder(
    column: $table.gbifId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempMinC => $composableBuilder(
    column: $table.tempMinC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempOptC => $composableBuilder(
    column: $table.tempOptC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempMaxC => $composableBuilder(
    column: $table.tempMaxC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waterNeed => $composableBuilder(
    column: $table.waterNeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sun => $composableBuilder(
    column: $table.sun,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soilTypes => $composableBuilder(
    column: $table.soilTypes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phMin => $composableBuilder(
    column: $table.phMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get phMax => $composableBuilder(
    column: $table.phMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frostHardiness => $composableBuilder(
    column: $table.frostHardiness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propagation => $composableBuilder(
    column: $table.propagation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sowDepthCm => $composableBuilder(
    column: $table.sowDepthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spacingCm => $composableBuilder(
    column: $table.spacingCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowSpacingCm => $composableBuilder(
    column: $table.rowSpacingCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysToHarvest => $composableBuilder(
    column: $table.daysToHarvest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnFilters(column),
  );
}

class $PlantsOrderingComposer extends Composer<_$CatalogueDatabase, Plants> {
  $PlantsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gbifId => $composableBuilder(
    column: $table.gbifId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempMinC => $composableBuilder(
    column: $table.tempMinC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempOptC => $composableBuilder(
    column: $table.tempOptC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempMaxC => $composableBuilder(
    column: $table.tempMaxC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waterNeed => $composableBuilder(
    column: $table.waterNeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sun => $composableBuilder(
    column: $table.sun,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soilTypes => $composableBuilder(
    column: $table.soilTypes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phMin => $composableBuilder(
    column: $table.phMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get phMax => $composableBuilder(
    column: $table.phMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frostHardiness => $composableBuilder(
    column: $table.frostHardiness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propagation => $composableBuilder(
    column: $table.propagation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sowDepthCm => $composableBuilder(
    column: $table.sowDepthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spacingCm => $composableBuilder(
    column: $table.spacingCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowSpacingCm => $composableBuilder(
    column: $table.rowSpacingCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysToHarvest => $composableBuilder(
    column: $table.daysToHarvest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PlantsAnnotationComposer extends Composer<_$CatalogueDatabase, Plants> {
  $PlantsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gbifId =>
      $composableBuilder(column: $table.gbifId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tempMinC =>
      $composableBuilder(column: $table.tempMinC, builder: (column) => column);

  GeneratedColumn<double> get tempOptC =>
      $composableBuilder(column: $table.tempOptC, builder: (column) => column);

  GeneratedColumn<double> get tempMaxC =>
      $composableBuilder(column: $table.tempMaxC, builder: (column) => column);

  GeneratedColumn<int> get waterNeed =>
      $composableBuilder(column: $table.waterNeed, builder: (column) => column);

  GeneratedColumn<String> get sun =>
      $composableBuilder(column: $table.sun, builder: (column) => column);

  GeneratedColumn<String> get soilTypes =>
      $composableBuilder(column: $table.soilTypes, builder: (column) => column);

  GeneratedColumn<double> get phMin =>
      $composableBuilder(column: $table.phMin, builder: (column) => column);

  GeneratedColumn<double> get phMax =>
      $composableBuilder(column: $table.phMax, builder: (column) => column);

  GeneratedColumn<String> get frostHardiness => $composableBuilder(
    column: $table.frostHardiness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get propagation => $composableBuilder(
    column: $table.propagation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sowDepthCm => $composableBuilder(
    column: $table.sowDepthCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get spacingCm =>
      $composableBuilder(column: $table.spacingCm, builder: (column) => column);

  GeneratedColumn<int> get rowSpacingCm => $composableBuilder(
    column: $table.rowSpacingCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get daysToHarvest => $composableBuilder(
    column: $table.daysToHarvest,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => column,
  );
}

class $PlantsTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          Plants,
          CataloguePlant,
          $PlantsFilterComposer,
          $PlantsOrderingComposer,
          $PlantsAnnotationComposer,
          $PlantsCreateCompanionBuilder,
          $PlantsUpdateCompanionBuilder,
          (
            CataloguePlant,
            BaseReferences<_$CatalogueDatabase, Plants, CataloguePlant>,
          ),
          CataloguePlant,
          PrefetchHooks Function()
        > {
  $PlantsTableManager(_$CatalogueDatabase db, Plants table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlantsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlantsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlantsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<int?> gbifId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double?> tempMinC = const Value.absent(),
                Value<double?> tempOptC = const Value.absent(),
                Value<double?> tempMaxC = const Value.absent(),
                Value<int?> waterNeed = const Value.absent(),
                Value<String?> sun = const Value.absent(),
                Value<String?> soilTypes = const Value.absent(),
                Value<double?> phMin = const Value.absent(),
                Value<double?> phMax = const Value.absent(),
                Value<String?> frostHardiness = const Value.absent(),
                Value<String?> propagation = const Value.absent(),
                Value<double?> sowDepthCm = const Value.absent(),
                Value<int?> spacingCm = const Value.absent(),
                Value<int?> rowSpacingCm = const Value.absent(),
                Value<int?> daysToHarvest = const Value.absent(),
                Value<String?> publishedAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String> searchKeys = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantsCompanion(
                id: id,
                scientificName: scientificName,
                gbifId: gbifId,
                categoryId: categoryId,
                tempMinC: tempMinC,
                tempOptC: tempOptC,
                tempMaxC: tempMaxC,
                waterNeed: waterNeed,
                sun: sun,
                soilTypes: soilTypes,
                phMin: phMin,
                phMax: phMax,
                frostHardiness: frostHardiness,
                propagation: propagation,
                sowDepthCm: sowDepthCm,
                spacingCm: spacingCm,
                rowSpacingCm: rowSpacingCm,
                daysToHarvest: daysToHarvest,
                publishedAt: publishedAt,
                updatedAt: updatedAt,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scientificName,
                Value<int?> gbifId = const Value.absent(),
                required String categoryId,
                Value<double?> tempMinC = const Value.absent(),
                Value<double?> tempOptC = const Value.absent(),
                Value<double?> tempMaxC = const Value.absent(),
                Value<int?> waterNeed = const Value.absent(),
                Value<String?> sun = const Value.absent(),
                Value<String?> soilTypes = const Value.absent(),
                Value<double?> phMin = const Value.absent(),
                Value<double?> phMax = const Value.absent(),
                Value<String?> frostHardiness = const Value.absent(),
                Value<String?> propagation = const Value.absent(),
                Value<double?> sowDepthCm = const Value.absent(),
                Value<int?> spacingCm = const Value.absent(),
                Value<int?> rowSpacingCm = const Value.absent(),
                Value<int?> daysToHarvest = const Value.absent(),
                Value<String?> publishedAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                required String searchKeys,
                Value<int> rowid = const Value.absent(),
              }) => PlantsCompanion.insert(
                id: id,
                scientificName: scientificName,
                gbifId: gbifId,
                categoryId: categoryId,
                tempMinC: tempMinC,
                tempOptC: tempOptC,
                tempMaxC: tempMaxC,
                waterNeed: waterNeed,
                sun: sun,
                soilTypes: soilTypes,
                phMin: phMin,
                phMax: phMax,
                frostHardiness: frostHardiness,
                propagation: propagation,
                sowDepthCm: sowDepthCm,
                spacingCm: spacingCm,
                rowSpacingCm: rowSpacingCm,
                daysToHarvest: daysToHarvest,
                publishedAt: publishedAt,
                updatedAt: updatedAt,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Plants, CataloguePlant>(table),
                  BaseReferences<_$CatalogueDatabase, Plants, CataloguePlant>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PlantsProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      Plants,
      CataloguePlant,
      $PlantsFilterComposer,
      $PlantsOrderingComposer,
      $PlantsAnnotationComposer,
      $PlantsCreateCompanionBuilder,
      $PlantsUpdateCompanionBuilder,
      (
        CataloguePlant,
        BaseReferences<_$CatalogueDatabase, Plants, CataloguePlant>,
      ),
      CataloguePlant,
      PrefetchHooks Function()
    >;
typedef $PlantTranslationsCreateCompanionBuilder =
    PlantTranslationsCompanion Function({
      required String id,
      required String plantId,
      required String lang,
      required String name,
      Value<String?> description,
      Value<String?> planting,
      Value<String?> care,
      Value<String?> seedSaving,
      Value<String?> tips,
      Value<int> rowid,
    });
typedef $PlantTranslationsUpdateCompanionBuilder =
    PlantTranslationsCompanion Function({
      Value<String> id,
      Value<String> plantId,
      Value<String> lang,
      Value<String> name,
      Value<String?> description,
      Value<String?> planting,
      Value<String?> care,
      Value<String?> seedSaving,
      Value<String?> tips,
      Value<int> rowid,
    });

class $PlantTranslationsFilterComposer
    extends Composer<_$CatalogueDatabase, PlantTranslations> {
  $PlantTranslationsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planting => $composableBuilder(
    column: $table.planting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get care => $composableBuilder(
    column: $table.care,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seedSaving => $composableBuilder(
    column: $table.seedSaving,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tips => $composableBuilder(
    column: $table.tips,
    builder: (column) => ColumnFilters(column),
  );
}

class $PlantTranslationsOrderingComposer
    extends Composer<_$CatalogueDatabase, PlantTranslations> {
  $PlantTranslationsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planting => $composableBuilder(
    column: $table.planting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get care => $composableBuilder(
    column: $table.care,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seedSaving => $composableBuilder(
    column: $table.seedSaving,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tips => $composableBuilder(
    column: $table.tips,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PlantTranslationsAnnotationComposer
    extends Composer<_$CatalogueDatabase, PlantTranslations> {
  $PlantTranslationsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planting =>
      $composableBuilder(column: $table.planting, builder: (column) => column);

  GeneratedColumn<String> get care =>
      $composableBuilder(column: $table.care, builder: (column) => column);

  GeneratedColumn<String> get seedSaving => $composableBuilder(
    column: $table.seedSaving,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tips =>
      $composableBuilder(column: $table.tips, builder: (column) => column);
}

class $PlantTranslationsTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          PlantTranslations,
          CataloguePlantTranslation,
          $PlantTranslationsFilterComposer,
          $PlantTranslationsOrderingComposer,
          $PlantTranslationsAnnotationComposer,
          $PlantTranslationsCreateCompanionBuilder,
          $PlantTranslationsUpdateCompanionBuilder,
          (
            CataloguePlantTranslation,
            BaseReferences<
              _$CatalogueDatabase,
              PlantTranslations,
              CataloguePlantTranslation
            >,
          ),
          CataloguePlantTranslation,
          PrefetchHooks Function()
        > {
  $PlantTranslationsTableManager(
    _$CatalogueDatabase db,
    PlantTranslations table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlantTranslationsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlantTranslationsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlantTranslationsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> planting = const Value.absent(),
                Value<String?> care = const Value.absent(),
                Value<String?> seedSaving = const Value.absent(),
                Value<String?> tips = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantTranslationsCompanion(
                id: id,
                plantId: plantId,
                lang: lang,
                name: name,
                description: description,
                planting: planting,
                care: care,
                seedSaving: seedSaving,
                tips: tips,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plantId,
                required String lang,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> planting = const Value.absent(),
                Value<String?> care = const Value.absent(),
                Value<String?> seedSaving = const Value.absent(),
                Value<String?> tips = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantTranslationsCompanion.insert(
                id: id,
                plantId: plantId,
                lang: lang,
                name: name,
                description: description,
                planting: planting,
                care: care,
                seedSaving: seedSaving,
                tips: tips,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PlantTranslations, CataloguePlantTranslation>(
                    table,
                  ),
                  BaseReferences<
                    _$CatalogueDatabase,
                    PlantTranslations,
                    CataloguePlantTranslation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PlantTranslationsProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      PlantTranslations,
      CataloguePlantTranslation,
      $PlantTranslationsFilterComposer,
      $PlantTranslationsOrderingComposer,
      $PlantTranslationsAnnotationComposer,
      $PlantTranslationsCreateCompanionBuilder,
      $PlantTranslationsUpdateCompanionBuilder,
      (
        CataloguePlantTranslation,
        BaseReferences<
          _$CatalogueDatabase,
          PlantTranslations,
          CataloguePlantTranslation
        >,
      ),
      CataloguePlantTranslation,
      PrefetchHooks Function()
    >;
typedef $PlantAliasesCreateCompanionBuilder =
    PlantAliasesCompanion Function({
      required String id,
      required String plantId,
      Value<String?> lang,
      required String alias,
      Value<String?> kind,
      Value<int> rowid,
    });
typedef $PlantAliasesUpdateCompanionBuilder =
    PlantAliasesCompanion Function({
      Value<String> id,
      Value<String> plantId,
      Value<String?> lang,
      Value<String> alias,
      Value<String?> kind,
      Value<int> rowid,
    });

class $PlantAliasesFilterComposer
    extends Composer<_$CatalogueDatabase, PlantAliases> {
  $PlantAliasesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );
}

class $PlantAliasesOrderingComposer
    extends Composer<_$CatalogueDatabase, PlantAliases> {
  $PlantAliasesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PlantAliasesAnnotationComposer
    extends Composer<_$CatalogueDatabase, PlantAliases> {
  $PlantAliasesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);
}

class $PlantAliasesTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          PlantAliases,
          CataloguePlantAlias,
          $PlantAliasesFilterComposer,
          $PlantAliasesOrderingComposer,
          $PlantAliasesAnnotationComposer,
          $PlantAliasesCreateCompanionBuilder,
          $PlantAliasesUpdateCompanionBuilder,
          (
            CataloguePlantAlias,
            BaseReferences<
              _$CatalogueDatabase,
              PlantAliases,
              CataloguePlantAlias
            >,
          ),
          CataloguePlantAlias,
          PrefetchHooks Function()
        > {
  $PlantAliasesTableManager(_$CatalogueDatabase db, PlantAliases table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlantAliasesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlantAliasesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlantAliasesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<String?> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantAliasesCompanion(
                id: id,
                plantId: plantId,
                lang: lang,
                alias: alias,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plantId,
                Value<String?> lang = const Value.absent(),
                required String alias,
                Value<String?> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantAliasesCompanion.insert(
                id: id,
                plantId: plantId,
                lang: lang,
                alias: alias,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PlantAliases, CataloguePlantAlias>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    PlantAliases,
                    CataloguePlantAlias
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PlantAliasesProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      PlantAliases,
      CataloguePlantAlias,
      $PlantAliasesFilterComposer,
      $PlantAliasesOrderingComposer,
      $PlantAliasesAnnotationComposer,
      $PlantAliasesCreateCompanionBuilder,
      $PlantAliasesUpdateCompanionBuilder,
      (
        CataloguePlantAlias,
        BaseReferences<_$CatalogueDatabase, PlantAliases, CataloguePlantAlias>,
      ),
      CataloguePlantAlias,
      PrefetchHooks Function()
    >;
typedef $PlantCalendarsCreateCompanionBuilder =
    PlantCalendarsCompanion Function({
      required String id,
      required String plantId,
      required String climateZoneId,
      required String activity,
      required int monthFrom,
      required int monthTo,
      Value<int> rowid,
    });
typedef $PlantCalendarsUpdateCompanionBuilder =
    PlantCalendarsCompanion Function({
      Value<String> id,
      Value<String> plantId,
      Value<String> climateZoneId,
      Value<String> activity,
      Value<int> monthFrom,
      Value<int> monthTo,
      Value<int> rowid,
    });

class $PlantCalendarsFilterComposer
    extends Composer<_$CatalogueDatabase, PlantCalendars> {
  $PlantCalendarsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get climateZoneId => $composableBuilder(
    column: $table.climateZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthFrom => $composableBuilder(
    column: $table.monthFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthTo => $composableBuilder(
    column: $table.monthTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $PlantCalendarsOrderingComposer
    extends Composer<_$CatalogueDatabase, PlantCalendars> {
  $PlantCalendarsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get climateZoneId => $composableBuilder(
    column: $table.climateZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthFrom => $composableBuilder(
    column: $table.monthFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthTo => $composableBuilder(
    column: $table.monthTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PlantCalendarsAnnotationComposer
    extends Composer<_$CatalogueDatabase, PlantCalendars> {
  $PlantCalendarsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get climateZoneId => $composableBuilder(
    column: $table.climateZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<int> get monthFrom =>
      $composableBuilder(column: $table.monthFrom, builder: (column) => column);

  GeneratedColumn<int> get monthTo =>
      $composableBuilder(column: $table.monthTo, builder: (column) => column);
}

class $PlantCalendarsTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          PlantCalendars,
          CataloguePlantCalendar,
          $PlantCalendarsFilterComposer,
          $PlantCalendarsOrderingComposer,
          $PlantCalendarsAnnotationComposer,
          $PlantCalendarsCreateCompanionBuilder,
          $PlantCalendarsUpdateCompanionBuilder,
          (
            CataloguePlantCalendar,
            BaseReferences<
              _$CatalogueDatabase,
              PlantCalendars,
              CataloguePlantCalendar
            >,
          ),
          CataloguePlantCalendar,
          PrefetchHooks Function()
        > {
  $PlantCalendarsTableManager(_$CatalogueDatabase db, PlantCalendars table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlantCalendarsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlantCalendarsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlantCalendarsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String> climateZoneId = const Value.absent(),
                Value<String> activity = const Value.absent(),
                Value<int> monthFrom = const Value.absent(),
                Value<int> monthTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantCalendarsCompanion(
                id: id,
                plantId: plantId,
                climateZoneId: climateZoneId,
                activity: activity,
                monthFrom: monthFrom,
                monthTo: monthTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plantId,
                required String climateZoneId,
                required String activity,
                required int monthFrom,
                required int monthTo,
                Value<int> rowid = const Value.absent(),
              }) => PlantCalendarsCompanion.insert(
                id: id,
                plantId: plantId,
                climateZoneId: climateZoneId,
                activity: activity,
                monthFrom: monthFrom,
                monthTo: monthTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PlantCalendars, CataloguePlantCalendar>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    PlantCalendars,
                    CataloguePlantCalendar
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PlantCalendarsProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      PlantCalendars,
      CataloguePlantCalendar,
      $PlantCalendarsFilterComposer,
      $PlantCalendarsOrderingComposer,
      $PlantCalendarsAnnotationComposer,
      $PlantCalendarsCreateCompanionBuilder,
      $PlantCalendarsUpdateCompanionBuilder,
      (
        CataloguePlantCalendar,
        BaseReferences<
          _$CatalogueDatabase,
          PlantCalendars,
          CataloguePlantCalendar
        >,
      ),
      CataloguePlantCalendar,
      PrefetchHooks Function()
    >;
typedef $CompanionsCreateCompanionBuilder =
    CompanionsCompanion Function({
      required String id,
      required String plantId,
      required String otherPlantId,
      required String relation,
      Value<int> rowid,
    });
typedef $CompanionsUpdateCompanionBuilder =
    CompanionsCompanion Function({
      Value<String> id,
      Value<String> plantId,
      Value<String> otherPlantId,
      Value<String> relation,
      Value<int> rowid,
    });

class $CompanionsFilterComposer
    extends Composer<_$CatalogueDatabase, Companions> {
  $CompanionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherPlantId => $composableBuilder(
    column: $table.otherPlantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );
}

class $CompanionsOrderingComposer
    extends Composer<_$CatalogueDatabase, Companions> {
  $CompanionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherPlantId => $composableBuilder(
    column: $table.otherPlantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CompanionsAnnotationComposer
    extends Composer<_$CatalogueDatabase, Companions> {
  $CompanionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get otherPlantId => $composableBuilder(
    column: $table.otherPlantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);
}

class $CompanionsTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          Companions,
          CatalogueCompanion,
          $CompanionsFilterComposer,
          $CompanionsOrderingComposer,
          $CompanionsAnnotationComposer,
          $CompanionsCreateCompanionBuilder,
          $CompanionsUpdateCompanionBuilder,
          (
            CatalogueCompanion,
            BaseReferences<_$CatalogueDatabase, Companions, CatalogueCompanion>,
          ),
          CatalogueCompanion,
          PrefetchHooks Function()
        > {
  $CompanionsTableManager(_$CatalogueDatabase db, Companions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CompanionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CompanionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CompanionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String> otherPlantId = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanionsCompanion(
                id: id,
                plantId: plantId,
                otherPlantId: otherPlantId,
                relation: relation,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plantId,
                required String otherPlantId,
                required String relation,
                Value<int> rowid = const Value.absent(),
              }) => CompanionsCompanion.insert(
                id: id,
                plantId: plantId,
                otherPlantId: otherPlantId,
                relation: relation,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Companions, CatalogueCompanion>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    Companions,
                    CatalogueCompanion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CompanionsProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      Companions,
      CatalogueCompanion,
      $CompanionsFilterComposer,
      $CompanionsOrderingComposer,
      $CompanionsAnnotationComposer,
      $CompanionsCreateCompanionBuilder,
      $CompanionsUpdateCompanionBuilder,
      (
        CatalogueCompanion,
        BaseReferences<_$CatalogueDatabase, Companions, CatalogueCompanion>,
      ),
      CatalogueCompanion,
      PrefetchHooks Function()
    >;
typedef $CareIntervalsCreateCompanionBuilder =
    CareIntervalsCompanion Function({
      required String id,
      required String plantId,
      required String action,
      required int intervalDays,
      Value<int?> monthFrom,
      Value<int?> monthTo,
      Value<int> rowid,
    });
typedef $CareIntervalsUpdateCompanionBuilder =
    CareIntervalsCompanion Function({
      Value<String> id,
      Value<String> plantId,
      Value<String> action,
      Value<int> intervalDays,
      Value<int?> monthFrom,
      Value<int?> monthTo,
      Value<int> rowid,
    });

class $CareIntervalsFilterComposer
    extends Composer<_$CatalogueDatabase, CareIntervals> {
  $CareIntervalsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthFrom => $composableBuilder(
    column: $table.monthFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthTo => $composableBuilder(
    column: $table.monthTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $CareIntervalsOrderingComposer
    extends Composer<_$CatalogueDatabase, CareIntervals> {
  $CareIntervalsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthFrom => $composableBuilder(
    column: $table.monthFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthTo => $composableBuilder(
    column: $table.monthTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CareIntervalsAnnotationComposer
    extends Composer<_$CatalogueDatabase, CareIntervals> {
  $CareIntervalsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthFrom =>
      $composableBuilder(column: $table.monthFrom, builder: (column) => column);

  GeneratedColumn<int> get monthTo =>
      $composableBuilder(column: $table.monthTo, builder: (column) => column);
}

class $CareIntervalsTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          CareIntervals,
          CatalogueCareInterval,
          $CareIntervalsFilterComposer,
          $CareIntervalsOrderingComposer,
          $CareIntervalsAnnotationComposer,
          $CareIntervalsCreateCompanionBuilder,
          $CareIntervalsUpdateCompanionBuilder,
          (
            CatalogueCareInterval,
            BaseReferences<
              _$CatalogueDatabase,
              CareIntervals,
              CatalogueCareInterval
            >,
          ),
          CatalogueCareInterval,
          PrefetchHooks Function()
        > {
  $CareIntervalsTableManager(_$CatalogueDatabase db, CareIntervals table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CareIntervalsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CareIntervalsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CareIntervalsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<int?> monthFrom = const Value.absent(),
                Value<int?> monthTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareIntervalsCompanion(
                id: id,
                plantId: plantId,
                action: action,
                intervalDays: intervalDays,
                monthFrom: monthFrom,
                monthTo: monthTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plantId,
                required String action,
                required int intervalDays,
                Value<int?> monthFrom = const Value.absent(),
                Value<int?> monthTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareIntervalsCompanion.insert(
                id: id,
                plantId: plantId,
                action: action,
                intervalDays: intervalDays,
                monthFrom: monthFrom,
                monthTo: monthTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<CareIntervals, CatalogueCareInterval>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    CareIntervals,
                    CatalogueCareInterval
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CareIntervalsProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      CareIntervals,
      CatalogueCareInterval,
      $CareIntervalsFilterComposer,
      $CareIntervalsOrderingComposer,
      $CareIntervalsAnnotationComposer,
      $CareIntervalsCreateCompanionBuilder,
      $CareIntervalsUpdateCompanionBuilder,
      (
        CatalogueCareInterval,
        BaseReferences<
          _$CatalogueDatabase,
          CareIntervals,
          CatalogueCareInterval
        >,
      ),
      CatalogueCareInterval,
      PrefetchHooks Function()
    >;
typedef $PlantPhotosCreateCompanionBuilder =
    PlantPhotosCompanion Function({
      required String id,
      required String plantId,
      required String credit,
      required String licence,
      Value<String?> sourceUrl,
      Value<int> rowid,
    });
typedef $PlantPhotosUpdateCompanionBuilder =
    PlantPhotosCompanion Function({
      Value<String> id,
      Value<String> plantId,
      Value<String> credit,
      Value<String> licence,
      Value<String?> sourceUrl,
      Value<int> rowid,
    });

class $PlantPhotosFilterComposer
    extends Composer<_$CatalogueDatabase, PlantPhotos> {
  $PlantPhotosFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licence => $composableBuilder(
    column: $table.licence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $PlantPhotosOrderingComposer
    extends Composer<_$CatalogueDatabase, PlantPhotos> {
  $PlantPhotosOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credit => $composableBuilder(
    column: $table.credit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licence => $composableBuilder(
    column: $table.licence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PlantPhotosAnnotationComposer
    extends Composer<_$CatalogueDatabase, PlantPhotos> {
  $PlantPhotosAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get credit =>
      $composableBuilder(column: $table.credit, builder: (column) => column);

  GeneratedColumn<String> get licence =>
      $composableBuilder(column: $table.licence, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);
}

class $PlantPhotosTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          PlantPhotos,
          CataloguePlantPhoto,
          $PlantPhotosFilterComposer,
          $PlantPhotosOrderingComposer,
          $PlantPhotosAnnotationComposer,
          $PlantPhotosCreateCompanionBuilder,
          $PlantPhotosUpdateCompanionBuilder,
          (
            CataloguePlantPhoto,
            BaseReferences<
              _$CatalogueDatabase,
              PlantPhotos,
              CataloguePlantPhoto
            >,
          ),
          CataloguePlantPhoto,
          PrefetchHooks Function()
        > {
  $PlantPhotosTableManager(_$CatalogueDatabase db, PlantPhotos table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlantPhotosFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlantPhotosOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlantPhotosAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String> credit = const Value.absent(),
                Value<String> licence = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantPhotosCompanion(
                id: id,
                plantId: plantId,
                credit: credit,
                licence: licence,
                sourceUrl: sourceUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plantId,
                required String credit,
                required String licence,
                Value<String?> sourceUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantPhotosCompanion.insert(
                id: id,
                plantId: plantId,
                credit: credit,
                licence: licence,
                sourceUrl: sourceUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PlantPhotos, CataloguePlantPhoto>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    PlantPhotos,
                    CataloguePlantPhoto
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PlantPhotosProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      PlantPhotos,
      CataloguePlantPhoto,
      $PlantPhotosFilterComposer,
      $PlantPhotosOrderingComposer,
      $PlantPhotosAnnotationComposer,
      $PlantPhotosCreateCompanionBuilder,
      $PlantPhotosUpdateCompanionBuilder,
      (
        CataloguePlantPhoto,
        BaseReferences<_$CatalogueDatabase, PlantPhotos, CataloguePlantPhoto>,
      ),
      CataloguePlantPhoto,
      PrefetchHooks Function()
    >;
typedef $FactSourcesCreateCompanionBuilder =
    FactSourcesCompanion Function({
      required String id,
      required String plantId,
      required String field,
      required String sourceName,
      Value<String?> sourceUrl,
      required String licence,
      Value<String?> importedAt,
      Value<int> rowid,
    });
typedef $FactSourcesUpdateCompanionBuilder =
    FactSourcesCompanion Function({
      Value<String> id,
      Value<String> plantId,
      Value<String> field,
      Value<String> sourceName,
      Value<String?> sourceUrl,
      Value<String> licence,
      Value<String?> importedAt,
      Value<int> rowid,
    });

class $FactSourcesFilterComposer
    extends Composer<_$CatalogueDatabase, FactSources> {
  $FactSourcesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licence => $composableBuilder(
    column: $table.licence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $FactSourcesOrderingComposer
    extends Composer<_$CatalogueDatabase, FactSources> {
  $FactSourcesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licence => $composableBuilder(
    column: $table.licence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $FactSourcesAnnotationComposer
    extends Composer<_$CatalogueDatabase, FactSources> {
  $FactSourcesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get licence =>
      $composableBuilder(column: $table.licence, builder: (column) => column);

  GeneratedColumn<String> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $FactSourcesTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          FactSources,
          CatalogueFactSource,
          $FactSourcesFilterComposer,
          $FactSourcesOrderingComposer,
          $FactSourcesAnnotationComposer,
          $FactSourcesCreateCompanionBuilder,
          $FactSourcesUpdateCompanionBuilder,
          (
            CatalogueFactSource,
            BaseReferences<
              _$CatalogueDatabase,
              FactSources,
              CatalogueFactSource
            >,
          ),
          CatalogueFactSource,
          PrefetchHooks Function()
        > {
  $FactSourcesTableManager(_$CatalogueDatabase db, FactSources table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FactSourcesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FactSourcesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FactSourcesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> licence = const Value.absent(),
                Value<String?> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactSourcesCompanion(
                id: id,
                plantId: plantId,
                field: field,
                sourceName: sourceName,
                sourceUrl: sourceUrl,
                licence: licence,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String plantId,
                required String field,
                required String sourceName,
                Value<String?> sourceUrl = const Value.absent(),
                required String licence,
                Value<String?> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FactSourcesCompanion.insert(
                id: id,
                plantId: plantId,
                field: field,
                sourceName: sourceName,
                sourceUrl: sourceUrl,
                licence: licence,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FactSources, CatalogueFactSource>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    FactSources,
                    CatalogueFactSource
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $FactSourcesProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      FactSources,
      CatalogueFactSource,
      $FactSourcesFilterComposer,
      $FactSourcesOrderingComposer,
      $FactSourcesAnnotationComposer,
      $FactSourcesCreateCompanionBuilder,
      $FactSourcesUpdateCompanionBuilder,
      (
        CatalogueFactSource,
        BaseReferences<_$CatalogueDatabase, FactSources, CatalogueFactSource>,
      ),
      CatalogueFactSource,
      PrefetchHooks Function()
    >;
typedef $TipsCreateCompanionBuilder =
    TipsCompanion Function({
      required String id,
      required String textEl,
      required String textEn,
      Value<int?> monthFrom,
      Value<int?> monthTo,
      Value<String?> climateZoneId,
      Value<String?> plantId,
      Value<int> rowid,
    });
typedef $TipsUpdateCompanionBuilder =
    TipsCompanion Function({
      Value<String> id,
      Value<String> textEl,
      Value<String> textEn,
      Value<int?> monthFrom,
      Value<int?> monthTo,
      Value<String?> climateZoneId,
      Value<String?> plantId,
      Value<int> rowid,
    });

class $TipsFilterComposer extends Composer<_$CatalogueDatabase, Tips> {
  $TipsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textEl => $composableBuilder(
    column: $table.textEl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthFrom => $composableBuilder(
    column: $table.monthFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthTo => $composableBuilder(
    column: $table.monthTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get climateZoneId => $composableBuilder(
    column: $table.climateZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );
}

class $TipsOrderingComposer extends Composer<_$CatalogueDatabase, Tips> {
  $TipsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textEl => $composableBuilder(
    column: $table.textEl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textEn => $composableBuilder(
    column: $table.textEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthFrom => $composableBuilder(
    column: $table.monthFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthTo => $composableBuilder(
    column: $table.monthTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get climateZoneId => $composableBuilder(
    column: $table.climateZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TipsAnnotationComposer extends Composer<_$CatalogueDatabase, Tips> {
  $TipsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get textEl =>
      $composableBuilder(column: $table.textEl, builder: (column) => column);

  GeneratedColumn<String> get textEn =>
      $composableBuilder(column: $table.textEn, builder: (column) => column);

  GeneratedColumn<int> get monthFrom =>
      $composableBuilder(column: $table.monthFrom, builder: (column) => column);

  GeneratedColumn<int> get monthTo =>
      $composableBuilder(column: $table.monthTo, builder: (column) => column);

  GeneratedColumn<String> get climateZoneId => $composableBuilder(
    column: $table.climateZoneId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);
}

class $TipsTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          Tips,
          CatalogueTip,
          $TipsFilterComposer,
          $TipsOrderingComposer,
          $TipsAnnotationComposer,
          $TipsCreateCompanionBuilder,
          $TipsUpdateCompanionBuilder,
          (
            CatalogueTip,
            BaseReferences<_$CatalogueDatabase, Tips, CatalogueTip>,
          ),
          CatalogueTip,
          PrefetchHooks Function()
        > {
  $TipsTableManager(_$CatalogueDatabase db, Tips table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TipsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TipsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TipsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> textEl = const Value.absent(),
                Value<String> textEn = const Value.absent(),
                Value<int?> monthFrom = const Value.absent(),
                Value<int?> monthTo = const Value.absent(),
                Value<String?> climateZoneId = const Value.absent(),
                Value<String?> plantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipsCompanion(
                id: id,
                textEl: textEl,
                textEn: textEn,
                monthFrom: monthFrom,
                monthTo: monthTo,
                climateZoneId: climateZoneId,
                plantId: plantId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String textEl,
                required String textEn,
                Value<int?> monthFrom = const Value.absent(),
                Value<int?> monthTo = const Value.absent(),
                Value<String?> climateZoneId = const Value.absent(),
                Value<String?> plantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TipsCompanion.insert(
                id: id,
                textEl: textEl,
                textEn: textEn,
                monthFrom: monthFrom,
                monthTo: monthTo,
                climateZoneId: climateZoneId,
                plantId: plantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Tips, CatalogueTip>(table),
                  BaseReferences<_$CatalogueDatabase, Tips, CatalogueTip>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TipsProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      Tips,
      CatalogueTip,
      $TipsFilterComposer,
      $TipsOrderingComposer,
      $TipsAnnotationComposer,
      $TipsCreateCompanionBuilder,
      $TipsUpdateCompanionBuilder,
      (CatalogueTip, BaseReferences<_$CatalogueDatabase, Tips, CatalogueTip>),
      CatalogueTip,
      PrefetchHooks Function()
    >;
typedef $SettlementsCreateCompanionBuilder =
    SettlementsCompanion Function({
      required String id,
      required String nameEl,
      Value<String?> nameEn,
      Value<String?> region,
      required double lat,
      required double lon,
      required String searchKeys,
      Value<int> rowid,
    });
typedef $SettlementsUpdateCompanionBuilder =
    SettlementsCompanion Function({
      Value<String> id,
      Value<String> nameEl,
      Value<String?> nameEn,
      Value<String?> region,
      Value<double> lat,
      Value<double> lon,
      Value<String> searchKeys,
      Value<int> rowid,
    });

class $SettlementsFilterComposer
    extends Composer<_$CatalogueDatabase, Settlements> {
  $SettlementsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEl => $composableBuilder(
    column: $table.nameEl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettlementsOrderingComposer
    extends Composer<_$CatalogueDatabase, Settlements> {
  $SettlementsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEl => $composableBuilder(
    column: $table.nameEl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettlementsAnnotationComposer
    extends Composer<_$CatalogueDatabase, Settlements> {
  $SettlementsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameEl =>
      $composableBuilder(column: $table.nameEl, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => column,
  );
}

class $SettlementsTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          Settlements,
          CatalogueSettlement,
          $SettlementsFilterComposer,
          $SettlementsOrderingComposer,
          $SettlementsAnnotationComposer,
          $SettlementsCreateCompanionBuilder,
          $SettlementsUpdateCompanionBuilder,
          (
            CatalogueSettlement,
            BaseReferences<
              _$CatalogueDatabase,
              Settlements,
              CatalogueSettlement
            >,
          ),
          CatalogueSettlement,
          PrefetchHooks Function()
        > {
  $SettlementsTableManager(_$CatalogueDatabase db, Settlements table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettlementsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettlementsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettlementsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameEl = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<String> searchKeys = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettlementsCompanion(
                id: id,
                nameEl: nameEl,
                nameEn: nameEn,
                region: region,
                lat: lat,
                lon: lon,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameEl,
                Value<String?> nameEn = const Value.absent(),
                Value<String?> region = const Value.absent(),
                required double lat,
                required double lon,
                required String searchKeys,
                Value<int> rowid = const Value.absent(),
              }) => SettlementsCompanion.insert(
                id: id,
                nameEl: nameEl,
                nameEn: nameEn,
                region: region,
                lat: lat,
                lon: lon,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Settlements, CatalogueSettlement>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    Settlements,
                    CatalogueSettlement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettlementsProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      Settlements,
      CatalogueSettlement,
      $SettlementsFilterComposer,
      $SettlementsOrderingComposer,
      $SettlementsAnnotationComposer,
      $SettlementsCreateCompanionBuilder,
      $SettlementsUpdateCompanionBuilder,
      (
        CatalogueSettlement,
        BaseReferences<_$CatalogueDatabase, Settlements, CatalogueSettlement>,
      ),
      CatalogueSettlement,
      PrefetchHooks Function()
    >;
typedef $PlantSearchCreateCompanionBuilder =
    PlantSearchCompanion Function({
      required String plantId,
      required String searchKeys,
      Value<int> rowid,
    });
typedef $PlantSearchUpdateCompanionBuilder =
    PlantSearchCompanion Function({
      Value<String> plantId,
      Value<String> searchKeys,
      Value<int> rowid,
    });

class $PlantSearchFilterComposer
    extends Composer<_$CatalogueDatabase, PlantSearch> {
  $PlantSearchFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnFilters(column),
  );
}

class $PlantSearchOrderingComposer
    extends Composer<_$CatalogueDatabase, PlantSearch> {
  $PlantSearchOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get plantId => $composableBuilder(
    column: $table.plantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PlantSearchAnnotationComposer
    extends Composer<_$CatalogueDatabase, PlantSearch> {
  $PlantSearchAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get plantId =>
      $composableBuilder(column: $table.plantId, builder: (column) => column);

  GeneratedColumn<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => column,
  );
}

class $PlantSearchTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          PlantSearch,
          PlantSearchData,
          $PlantSearchFilterComposer,
          $PlantSearchOrderingComposer,
          $PlantSearchAnnotationComposer,
          $PlantSearchCreateCompanionBuilder,
          $PlantSearchUpdateCompanionBuilder,
          (
            PlantSearchData,
            BaseReferences<_$CatalogueDatabase, PlantSearch, PlantSearchData>,
          ),
          PlantSearchData,
          PrefetchHooks Function()
        > {
  $PlantSearchTableManager(_$CatalogueDatabase db, PlantSearch table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PlantSearchFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PlantSearchOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PlantSearchAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> plantId = const Value.absent(),
                Value<String> searchKeys = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantSearchCompanion(
                plantId: plantId,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String plantId,
                required String searchKeys,
                Value<int> rowid = const Value.absent(),
              }) => PlantSearchCompanion.insert(
                plantId: plantId,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PlantSearch, PlantSearchData>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    PlantSearch,
                    PlantSearchData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PlantSearchProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      PlantSearch,
      PlantSearchData,
      $PlantSearchFilterComposer,
      $PlantSearchOrderingComposer,
      $PlantSearchAnnotationComposer,
      $PlantSearchCreateCompanionBuilder,
      $PlantSearchUpdateCompanionBuilder,
      (
        PlantSearchData,
        BaseReferences<_$CatalogueDatabase, PlantSearch, PlantSearchData>,
      ),
      PlantSearchData,
      PrefetchHooks Function()
    >;
typedef $SettlementSearchCreateCompanionBuilder =
    SettlementSearchCompanion Function({
      required String settlementId,
      required String searchKeys,
      Value<int> rowid,
    });
typedef $SettlementSearchUpdateCompanionBuilder =
    SettlementSearchCompanion Function({
      Value<String> settlementId,
      Value<String> searchKeys,
      Value<int> rowid,
    });

class $SettlementSearchFilterComposer
    extends Composer<_$CatalogueDatabase, SettlementSearch> {
  $SettlementSearchFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settlementId => $composableBuilder(
    column: $table.settlementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettlementSearchOrderingComposer
    extends Composer<_$CatalogueDatabase, SettlementSearch> {
  $SettlementSearchOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settlementId => $composableBuilder(
    column: $table.settlementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettlementSearchAnnotationComposer
    extends Composer<_$CatalogueDatabase, SettlementSearch> {
  $SettlementSearchAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settlementId => $composableBuilder(
    column: $table.settlementId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchKeys => $composableBuilder(
    column: $table.searchKeys,
    builder: (column) => column,
  );
}

class $SettlementSearchTableManager
    extends
        RootTableManager<
          _$CatalogueDatabase,
          SettlementSearch,
          SettlementSearchData,
          $SettlementSearchFilterComposer,
          $SettlementSearchOrderingComposer,
          $SettlementSearchAnnotationComposer,
          $SettlementSearchCreateCompanionBuilder,
          $SettlementSearchUpdateCompanionBuilder,
          (
            SettlementSearchData,
            BaseReferences<
              _$CatalogueDatabase,
              SettlementSearch,
              SettlementSearchData
            >,
          ),
          SettlementSearchData,
          PrefetchHooks Function()
        > {
  $SettlementSearchTableManager(_$CatalogueDatabase db, SettlementSearch table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettlementSearchFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettlementSearchOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettlementSearchAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settlementId = const Value.absent(),
                Value<String> searchKeys = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettlementSearchCompanion(
                settlementId: settlementId,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settlementId,
                required String searchKeys,
                Value<int> rowid = const Value.absent(),
              }) => SettlementSearchCompanion.insert(
                settlementId: settlementId,
                searchKeys: searchKeys,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SettlementSearch, SettlementSearchData>(table),
                  BaseReferences<
                    _$CatalogueDatabase,
                    SettlementSearch,
                    SettlementSearchData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettlementSearchProcessedTableManager =
    ProcessedTableManager<
      _$CatalogueDatabase,
      SettlementSearch,
      SettlementSearchData,
      $SettlementSearchFilterComposer,
      $SettlementSearchOrderingComposer,
      $SettlementSearchAnnotationComposer,
      $SettlementSearchCreateCompanionBuilder,
      $SettlementSearchUpdateCompanionBuilder,
      (
        SettlementSearchData,
        BaseReferences<
          _$CatalogueDatabase,
          SettlementSearch,
          SettlementSearchData
        >,
      ),
      SettlementSearchData,
      PrefetchHooks Function()
    >;

class $CatalogueDatabaseManager {
  final _$CatalogueDatabase _db;
  $CatalogueDatabaseManager(this._db);
  $MetaTableManager get meta => $MetaTableManager(_db, _db.meta);
  $CategoriesTableManager get categories =>
      $CategoriesTableManager(_db, _db.categories);
  $ClimateZonesTableManager get climateZones =>
      $ClimateZonesTableManager(_db, _db.climateZones);
  $PlantsTableManager get plants => $PlantsTableManager(_db, _db.plants);
  $PlantTranslationsTableManager get plantTranslations =>
      $PlantTranslationsTableManager(_db, _db.plantTranslations);
  $PlantAliasesTableManager get plantAliases =>
      $PlantAliasesTableManager(_db, _db.plantAliases);
  $PlantCalendarsTableManager get plantCalendars =>
      $PlantCalendarsTableManager(_db, _db.plantCalendars);
  $CompanionsTableManager get companions =>
      $CompanionsTableManager(_db, _db.companions);
  $CareIntervalsTableManager get careIntervals =>
      $CareIntervalsTableManager(_db, _db.careIntervals);
  $PlantPhotosTableManager get plantPhotos =>
      $PlantPhotosTableManager(_db, _db.plantPhotos);
  $FactSourcesTableManager get factSources =>
      $FactSourcesTableManager(_db, _db.factSources);
  $TipsTableManager get tips => $TipsTableManager(_db, _db.tips);
  $SettlementsTableManager get settlements =>
      $SettlementsTableManager(_db, _db.settlements);
  $PlantSearchTableManager get plantSearch =>
      $PlantSearchTableManager(_db, _db.plantSearch);
  $SettlementSearchTableManager get settlementSearch =>
      $SettlementSearchTableManager(_db, _db.settlementSearch);
}
