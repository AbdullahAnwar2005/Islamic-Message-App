// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, slug, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
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
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      slug:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}slug'],
          )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final int id;
  final String title;
  final String slug;
  final int? sortOrder;
  const Section({
    required this.id,
    required this.title,
    required this.slug,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['slug'] = Variable<String>(slug);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      title: Value(title),
      slug: Value(slug),
      sortOrder:
          sortOrder == null && nullToAbsent
              ? const Value.absent()
              : Value(sortOrder),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      slug: serializer.fromJson<String>(json['slug']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'slug': serializer.toJson<String>(slug),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  Section copyWith({
    int? id,
    String? title,
    String? slug,
    Value<int?> sortOrder = const Value.absent(),
  }) => Section(
    id: id ?? this.id,
    title: title ?? this.title,
    slug: slug ?? this.slug,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      slug: data.slug.present ? data.slug.value : this.slug,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, slug, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.title == this.title &&
          other.slug == this.slug &&
          other.sortOrder == this.sortOrder);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> slug;
  final Value<int?> sortOrder;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.slug = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SectionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String slug,
    this.sortOrder = const Value.absent(),
  }) : title = Value(title),
       slug = Value(slug);
  static Insertable<Section> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? slug,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (slug != null) 'slug': slug,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? slug,
    Value<int?>? sortOrder,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPublishedMeta = const VerificationMeta(
    'isPublished',
  );
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
    'is_published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_published" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id)',
    ),
  );
  static const VerificationMeta _titleArMeta = const VerificationMeta(
    'titleAr',
  );
  @override
  late final GeneratedColumn<String> titleAr = GeneratedColumn<String>(
    'title_ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleEnMeta = const VerificationMeta(
    'titleEn',
  );
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
    'title_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    title,
    isPublished,
    createdAt,
    updatedAt,
    sectionId,
    titleAr,
    titleEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_published')) {
      context.handle(
        _isPublishedMeta,
        isPublished.isAcceptableOrUnknown(
          data['is_published']!,
          _isPublishedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    }
    if (data.containsKey('title_ar')) {
      context.handle(
        _titleArMeta,
        titleAr.isAcceptableOrUnknown(data['title_ar']!, _titleArMeta),
      );
    }
    if (data.containsKey('title_en')) {
      context.handle(
        _titleEnMeta,
        titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      slug:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}slug'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      isPublished:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_published'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      ),
      titleAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_ar'],
      ),
      titleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_en'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final String slug;
  final String title;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? sectionId;
  final String? titleAr;
  final String? titleEn;
  const Message({
    required this.id,
    required this.slug,
    required this.title,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.sectionId,
    this.titleAr,
    this.titleEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['title'] = Variable<String>(title);
    map['is_published'] = Variable<bool>(isPublished);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<int>(sectionId);
    }
    if (!nullToAbsent || titleAr != null) {
      map['title_ar'] = Variable<String>(titleAr);
    }
    if (!nullToAbsent || titleEn != null) {
      map['title_en'] = Variable<String>(titleEn);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      slug: Value(slug),
      title: Value(title),
      isPublished: Value(isPublished),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sectionId:
          sectionId == null && nullToAbsent
              ? const Value.absent()
              : Value(sectionId),
      titleAr:
          titleAr == null && nullToAbsent
              ? const Value.absent()
              : Value(titleAr),
      titleEn:
          titleEn == null && nullToAbsent
              ? const Value.absent()
              : Value(titleEn),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      title: serializer.fromJson<String>(json['title']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sectionId: serializer.fromJson<int?>(json['sectionId']),
      titleAr: serializer.fromJson<String?>(json['titleAr']),
      titleEn: serializer.fromJson<String?>(json['titleEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'title': serializer.toJson<String>(title),
      'isPublished': serializer.toJson<bool>(isPublished),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sectionId': serializer.toJson<int?>(sectionId),
      'titleAr': serializer.toJson<String?>(titleAr),
      'titleEn': serializer.toJson<String?>(titleEn),
    };
  }

  Message copyWith({
    int? id,
    String? slug,
    String? title,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> sectionId = const Value.absent(),
    Value<String?> titleAr = const Value.absent(),
    Value<String?> titleEn = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    title: title ?? this.title,
    isPublished: isPublished ?? this.isPublished,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sectionId: sectionId.present ? sectionId.value : this.sectionId,
    titleAr: titleAr.present ? titleAr.value : this.titleAr,
    titleEn: titleEn.present ? titleEn.value : this.titleEn,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      title: data.title.present ? data.title.value : this.title,
      isPublished:
          data.isPublished.present ? data.isPublished.value : this.isPublished,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      titleAr: data.titleAr.present ? data.titleAr.value : this.titleAr,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('isPublished: $isPublished, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sectionId: $sectionId, ')
          ..write('titleAr: $titleAr, ')
          ..write('titleEn: $titleEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    title,
    isPublished,
    createdAt,
    updatedAt,
    sectionId,
    titleAr,
    titleEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.title == this.title &&
          other.isPublished == this.isPublished &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sectionId == this.sectionId &&
          other.titleAr == this.titleAr &&
          other.titleEn == this.titleEn);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> title;
  final Value<bool> isPublished;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> sectionId;
  final Value<String?> titleAr;
  final Value<String?> titleEn;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.title = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.titleAr = const Value.absent(),
    this.titleEn = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String title,
    this.isPublished = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.titleAr = const Value.absent(),
    this.titleEn = const Value.absent(),
  }) : slug = Value(slug),
       title = Value(title);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? title,
    Expression<bool>? isPublished,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? sectionId,
    Expression<String>? titleAr,
    Expression<String>? titleEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (title != null) 'title': title,
      if (isPublished != null) 'is_published': isPublished,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sectionId != null) 'section_id': sectionId,
      if (titleAr != null) 'title_ar': titleAr,
      if (titleEn != null) 'title_en': titleEn,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? slug,
    Value<String>? title,
    Value<bool>? isPublished,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? sectionId,
    Value<String?>? titleAr,
    Value<String?>? titleEn,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sectionId: sectionId ?? this.sectionId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (titleAr.present) {
      map['title_ar'] = Variable<String>(titleAr.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('isPublished: $isPublished, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sectionId: $sectionId, ')
          ..write('titleAr: $titleAr, ')
          ..write('titleEn: $titleEn')
          ..write(')'))
        .toString();
  }
}

class $TranslationsTable extends Translations
    with TableInfo<$TranslationsTable, Translation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    languageCode,
    title,
    content,
    audioUrl,
    audioPath,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Translation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, languageCode};
  @override
  Translation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Translation(
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}message_id'],
          )!,
      languageCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}language_code'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      ),
      audioPath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}audio_path'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $TranslationsTable createAlias(String alias) {
    return $TranslationsTable(attachedDatabase, alias);
  }
}

class Translation extends DataClass implements Insertable<Translation> {
  final int messageId;
  final String languageCode;
  final String title;
  final String content;
  final String? audioUrl;
  final String audioPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Translation({
    required this.messageId,
    required this.languageCode,
    required this.title,
    required this.content,
    this.audioUrl,
    required this.audioPath,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<int>(messageId);
    map['language_code'] = Variable<String>(languageCode);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    map['audio_path'] = Variable<String>(audioPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TranslationsCompanion toCompanion(bool nullToAbsent) {
    return TranslationsCompanion(
      messageId: Value(messageId),
      languageCode: Value(languageCode),
      title: Value(title),
      content: Value(content),
      audioUrl:
          audioUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(audioUrl),
      audioPath: Value(audioPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Translation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Translation(
      messageId: serializer.fromJson<int>(json['messageId']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'languageCode': serializer.toJson<String>(languageCode),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'audioPath': serializer.toJson<String>(audioPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Translation copyWith({
    int? messageId,
    String? languageCode,
    String? title,
    String? content,
    Value<String?> audioUrl = const Value.absent(),
    String? audioPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Translation(
    messageId: messageId ?? this.messageId,
    languageCode: languageCode ?? this.languageCode,
    title: title ?? this.title,
    content: content ?? this.content,
    audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
    audioPath: audioPath ?? this.audioPath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Translation copyWithCompanion(TranslationsCompanion data) {
    return Translation(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      languageCode:
          data.languageCode.present
              ? data.languageCode.value
              : this.languageCode,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Translation(')
          ..write('messageId: $messageId, ')
          ..write('languageCode: $languageCode, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    messageId,
    languageCode,
    title,
    content,
    audioUrl,
    audioPath,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Translation &&
          other.messageId == this.messageId &&
          other.languageCode == this.languageCode &&
          other.title == this.title &&
          other.content == this.content &&
          other.audioUrl == this.audioUrl &&
          other.audioPath == this.audioPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TranslationsCompanion extends UpdateCompanion<Translation> {
  final Value<int> messageId;
  final Value<String> languageCode;
  final Value<String> title;
  final Value<String> content;
  final Value<String?> audioUrl;
  final Value<String> audioPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TranslationsCompanion({
    this.messageId = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationsCompanion.insert({
    required int messageId,
    required String languageCode,
    this.title = const Value.absent(),
    required String content,
    this.audioUrl = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       languageCode = Value(languageCode),
       content = Value(content);
  static Insertable<Translation> custom({
    Expression<int>? messageId,
    Expression<String>? languageCode,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? audioUrl,
    Expression<String>? audioPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (languageCode != null) 'language_code': languageCode,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (audioPath != null) 'audio_path': audioPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationsCompanion copyWith({
    Value<int>? messageId,
    Value<String>? languageCode,
    Value<String>? title,
    Value<String>? content,
    Value<String?>? audioUrl,
    Value<String>? audioPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TranslationsCompanion(
      messageId: messageId ?? this.messageId,
      languageCode: languageCode ?? this.languageCode,
      title: title ?? this.title,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationsCompanion(')
          ..write('messageId: $messageId, ')
          ..write('languageCode: $languageCode, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<DateTime> value = GeneratedColumn<DateTime>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
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
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String key;
  final DateTime value;
  const SyncStateData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<DateTime>(value);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(key: Value(key), value: Value(value));
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<DateTime>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<DateTime>(value),
    };
  }

  SyncStateData copyWith({String? key, DateTime? value}) =>
      SyncStateData(key: key ?? this.key, value: value ?? this.value);
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
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
      (other is SyncStateData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> key;
  final Value<DateTime> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String key,
    required DateTime value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncStateData> custom({
    Expression<String>? key,
    Expression<DateTime>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? key,
    Value<DateTime>? value,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
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
      map['value'] = Variable<DateTime>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSettingsTableTable extends ReadingSettingsTable
    with TableInfo<$ReadingSettingsTableTable, ReadingSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _pageStyleMeta = const VerificationMeta(
    'pageStyle',
  );
  @override
  late final GeneratedColumn<String> pageStyle = GeneratedColumn<String>(
    'page_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scroll'),
  );
  static const VerificationMeta _fontSizeMeta = const VerificationMeta(
    'fontSize',
  );
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
    'font_size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(18.0),
  );
  static const VerificationMeta _lineHeightMeta = const VerificationMeta(
    'lineHeight',
  );
  @override
  late final GeneratedColumn<double> lineHeight = GeneratedColumn<double>(
    'line_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.5),
  );
  static const VerificationMeta _fontFamilyMeta = const VerificationMeta(
    'fontFamily',
  );
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
    'font_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NotoNaskhArabic'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    theme,
    pageStyle,
    fontSize,
    lineHeight,
    fontFamily,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('page_style')) {
      context.handle(
        _pageStyleMeta,
        pageStyle.isAcceptableOrUnknown(data['page_style']!, _pageStyleMeta),
      );
    }
    if (data.containsKey('font_size')) {
      context.handle(
        _fontSizeMeta,
        fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta),
      );
    }
    if (data.containsKey('line_height')) {
      context.handle(
        _lineHeightMeta,
        lineHeight.isAcceptableOrUnknown(data['line_height']!, _lineHeightMeta),
      );
    }
    if (data.containsKey('font_family')) {
      context.handle(
        _fontFamilyMeta,
        fontFamily.isAcceptableOrUnknown(data['font_family']!, _fontFamilyMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSettingsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSettingsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      theme:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}theme'],
          )!,
      pageStyle:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}page_style'],
          )!,
      fontSize:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}font_size'],
          )!,
      lineHeight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}line_height'],
          )!,
      fontFamily:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}font_family'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $ReadingSettingsTableTable createAlias(String alias) {
    return $ReadingSettingsTableTable(attachedDatabase, alias);
  }
}

class ReadingSettingsTableData extends DataClass
    implements Insertable<ReadingSettingsTableData> {
  final int id;
  final String theme;
  final String pageStyle;
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final DateTime updatedAt;
  const ReadingSettingsTableData({
    required this.id,
    required this.theme,
    required this.pageStyle,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme'] = Variable<String>(theme);
    map['page_style'] = Variable<String>(pageStyle);
    map['font_size'] = Variable<double>(fontSize);
    map['line_height'] = Variable<double>(lineHeight);
    map['font_family'] = Variable<String>(fontFamily);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return ReadingSettingsTableCompanion(
      id: Value(id),
      theme: Value(theme),
      pageStyle: Value(pageStyle),
      fontSize: Value(fontSize),
      lineHeight: Value(lineHeight),
      fontFamily: Value(fontFamily),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      theme: serializer.fromJson<String>(json['theme']),
      pageStyle: serializer.fromJson<String>(json['pageStyle']),
      fontSize: serializer.fromJson<double>(json['fontSize']),
      lineHeight: serializer.fromJson<double>(json['lineHeight']),
      fontFamily: serializer.fromJson<String>(json['fontFamily']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'theme': serializer.toJson<String>(theme),
      'pageStyle': serializer.toJson<String>(pageStyle),
      'fontSize': serializer.toJson<double>(fontSize),
      'lineHeight': serializer.toJson<double>(lineHeight),
      'fontFamily': serializer.toJson<String>(fontFamily),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingSettingsTableData copyWith({
    int? id,
    String? theme,
    String? pageStyle,
    double? fontSize,
    double? lineHeight,
    String? fontFamily,
    DateTime? updatedAt,
  }) => ReadingSettingsTableData(
    id: id ?? this.id,
    theme: theme ?? this.theme,
    pageStyle: pageStyle ?? this.pageStyle,
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    fontFamily: fontFamily ?? this.fontFamily,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingSettingsTableData copyWithCompanion(
    ReadingSettingsTableCompanion data,
  ) {
    return ReadingSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      theme: data.theme.present ? data.theme.value : this.theme,
      pageStyle: data.pageStyle.present ? data.pageStyle.value : this.pageStyle,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      lineHeight:
          data.lineHeight.present ? data.lineHeight.value : this.lineHeight,
      fontFamily:
          data.fontFamily.present ? data.fontFamily.value : this.fontFamily,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSettingsTableData(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('pageStyle: $pageStyle, ')
          ..write('fontSize: $fontSize, ')
          ..write('lineHeight: $lineHeight, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    theme,
    pageStyle,
    fontSize,
    lineHeight,
    fontFamily,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSettingsTableData &&
          other.id == this.id &&
          other.theme == this.theme &&
          other.pageStyle == this.pageStyle &&
          other.fontSize == this.fontSize &&
          other.lineHeight == this.lineHeight &&
          other.fontFamily == this.fontFamily &&
          other.updatedAt == this.updatedAt);
}

class ReadingSettingsTableCompanion
    extends UpdateCompanion<ReadingSettingsTableData> {
  final Value<int> id;
  final Value<String> theme;
  final Value<String> pageStyle;
  final Value<double> fontSize;
  final Value<double> lineHeight;
  final Value<String> fontFamily;
  final Value<DateTime> updatedAt;
  const ReadingSettingsTableCompanion({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.pageStyle = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.lineHeight = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReadingSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.pageStyle = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.lineHeight = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<ReadingSettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? theme,
    Expression<String>? pageStyle,
    Expression<double>? fontSize,
    Expression<double>? lineHeight,
    Expression<String>? fontFamily,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (theme != null) 'theme': theme,
      if (pageStyle != null) 'page_style': pageStyle,
      if (fontSize != null) 'font_size': fontSize,
      if (lineHeight != null) 'line_height': lineHeight,
      if (fontFamily != null) 'font_family': fontFamily,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReadingSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? theme,
    Value<String>? pageStyle,
    Value<double>? fontSize,
    Value<double>? lineHeight,
    Value<String>? fontFamily,
    Value<DateTime>? updatedAt,
  }) {
    return ReadingSettingsTableCompanion(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      pageStyle: pageStyle ?? this.pageStyle,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (pageStyle.present) {
      map['page_style'] = Variable<String>(pageStyle.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (lineHeight.present) {
      map['line_height'] = Variable<double>(lineHeight.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('pageStyle: $pageStyle, ')
          ..write('fontSize: $fontSize, ')
          ..write('lineHeight: $lineHeight, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTableTable extends ReadingProgressTable
    with TableInfo<$ReadingProgressTableTable, ReadingProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textLanguageCodeMeta = const VerificationMeta(
    'textLanguageCode',
  );
  @override
  late final GeneratedColumn<String> textLanguageCode = GeneratedColumn<String>(
    'text_language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ar'),
  );
  static const VerificationMeta _percentMeta = const VerificationMeta(
    'percent',
  );
  @override
  late final GeneratedColumn<double> percent = GeneratedColumn<double>(
    'percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _scrollOffsetMeta = const VerificationMeta(
    'scrollOffset',
  );
  @override
  late final GeneratedColumn<double> scrollOffset = GeneratedColumn<double>(
    'scroll_offset',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    textLanguageCode,
    percent,
    scrollOffset,
    pageIndex,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('text_language_code')) {
      context.handle(
        _textLanguageCodeMeta,
        textLanguageCode.isAcceptableOrUnknown(
          data['text_language_code']!,
          _textLanguageCodeMeta,
        ),
      );
    }
    if (data.containsKey('percent')) {
      context.handle(
        _percentMeta,
        percent.isAcceptableOrUnknown(data['percent']!, _percentMeta),
      );
    }
    if (data.containsKey('scroll_offset')) {
      context.handle(
        _scrollOffsetMeta,
        scrollOffset.isAcceptableOrUnknown(
          data['scroll_offset']!,
          _scrollOffsetMeta,
        ),
      );
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId, textLanguageCode},
  ];
  @override
  ReadingProgressTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      textLanguageCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}text_language_code'],
          )!,
      percent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}percent'],
          )!,
      scrollOffset:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}scroll_offset'],
          )!,
      pageIndex:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}page_index'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $ReadingProgressTableTable createAlias(String alias) {
    return $ReadingProgressTableTable(attachedDatabase, alias);
  }
}

class ReadingProgressTableData extends DataClass
    implements Insertable<ReadingProgressTableData> {
  final int id;
  final String messageId;
  final String textLanguageCode;
  final double percent;
  final double scrollOffset;
  final int pageIndex;
  final DateTime updatedAt;
  const ReadingProgressTableData({
    required this.id,
    required this.messageId,
    required this.textLanguageCode,
    required this.percent,
    required this.scrollOffset,
    required this.pageIndex,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['text_language_code'] = Variable<String>(textLanguageCode);
    map['percent'] = Variable<double>(percent);
    map['scroll_offset'] = Variable<double>(scrollOffset);
    map['page_index'] = Variable<int>(pageIndex);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingProgressTableCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressTableCompanion(
      id: Value(id),
      messageId: Value(messageId),
      textLanguageCode: Value(textLanguageCode),
      percent: Value(percent),
      scrollOffset: Value(scrollOffset),
      pageIndex: Value(pageIndex),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressTableData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      textLanguageCode: serializer.fromJson<String>(json['textLanguageCode']),
      percent: serializer.fromJson<double>(json['percent']),
      scrollOffset: serializer.fromJson<double>(json['scrollOffset']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'textLanguageCode': serializer.toJson<String>(textLanguageCode),
      'percent': serializer.toJson<double>(percent),
      'scrollOffset': serializer.toJson<double>(scrollOffset),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingProgressTableData copyWith({
    int? id,
    String? messageId,
    String? textLanguageCode,
    double? percent,
    double? scrollOffset,
    int? pageIndex,
    DateTime? updatedAt,
  }) => ReadingProgressTableData(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    textLanguageCode: textLanguageCode ?? this.textLanguageCode,
    percent: percent ?? this.percent,
    scrollOffset: scrollOffset ?? this.scrollOffset,
    pageIndex: pageIndex ?? this.pageIndex,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingProgressTableData copyWithCompanion(
    ReadingProgressTableCompanion data,
  ) {
    return ReadingProgressTableData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      textLanguageCode:
          data.textLanguageCode.present
              ? data.textLanguageCode.value
              : this.textLanguageCode,
      percent: data.percent.present ? data.percent.value : this.percent,
      scrollOffset:
          data.scrollOffset.present
              ? data.scrollOffset.value
              : this.scrollOffset,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressTableData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('textLanguageCode: $textLanguageCode, ')
          ..write('percent: $percent, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    textLanguageCode,
    percent,
    scrollOffset,
    pageIndex,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressTableData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.textLanguageCode == this.textLanguageCode &&
          other.percent == this.percent &&
          other.scrollOffset == this.scrollOffset &&
          other.pageIndex == this.pageIndex &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressTableCompanion
    extends UpdateCompanion<ReadingProgressTableData> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> textLanguageCode;
  final Value<double> percent;
  final Value<double> scrollOffset;
  final Value<int> pageIndex;
  final Value<DateTime> updatedAt;
  const ReadingProgressTableCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.textLanguageCode = const Value.absent(),
    this.percent = const Value.absent(),
    this.scrollOffset = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReadingProgressTableCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    this.textLanguageCode = const Value.absent(),
    this.percent = const Value.absent(),
    this.scrollOffset = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : messageId = Value(messageId);
  static Insertable<ReadingProgressTableData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? textLanguageCode,
    Expression<double>? percent,
    Expression<double>? scrollOffset,
    Expression<int>? pageIndex,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (textLanguageCode != null) 'text_language_code': textLanguageCode,
      if (percent != null) 'percent': percent,
      if (scrollOffset != null) 'scroll_offset': scrollOffset,
      if (pageIndex != null) 'page_index': pageIndex,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReadingProgressTableCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? textLanguageCode,
    Value<double>? percent,
    Value<double>? scrollOffset,
    Value<int>? pageIndex,
    Value<DateTime>? updatedAt,
  }) {
    return ReadingProgressTableCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      textLanguageCode: textLanguageCode ?? this.textLanguageCode,
      percent: percent ?? this.percent,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      pageIndex: pageIndex ?? this.pageIndex,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (textLanguageCode.present) {
      map['text_language_code'] = Variable<String>(textLanguageCode.value);
    }
    if (percent.present) {
      map['percent'] = Variable<double>(percent.value);
    }
    if (scrollOffset.present) {
      map['scroll_offset'] = Variable<double>(scrollOffset.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('textLanguageCode: $textLanguageCode, ')
          ..write('percent: $percent, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AudioProgressTableTable extends AudioProgressTable
    with TableInfo<$AudioProgressTableTable, AudioProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioLanguageCodeMeta = const VerificationMeta(
    'audioLanguageCode',
  );
  @override
  late final GeneratedColumn<String> audioLanguageCode =
      GeneratedColumn<String>(
        'audio_language_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastAudioPositionMsMeta =
      const VerificationMeta('lastAudioPositionMs');
  @override
  late final GeneratedColumn<int> lastAudioPositionMs = GeneratedColumn<int>(
    'last_audio_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playbackRateMeta = const VerificationMeta(
    'playbackRate',
  );
  @override
  late final GeneratedColumn<double> playbackRate = GeneratedColumn<double>(
    'playback_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    audioLanguageCode,
    lastAudioPositionMs,
    playbackRate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('audio_language_code')) {
      context.handle(
        _audioLanguageCodeMeta,
        audioLanguageCode.isAcceptableOrUnknown(
          data['audio_language_code']!,
          _audioLanguageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioLanguageCodeMeta);
    }
    if (data.containsKey('last_audio_position_ms')) {
      context.handle(
        _lastAudioPositionMsMeta,
        lastAudioPositionMs.isAcceptableOrUnknown(
          data['last_audio_position_ms']!,
          _lastAudioPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('playback_rate')) {
      context.handle(
        _playbackRateMeta,
        playbackRate.isAcceptableOrUnknown(
          data['playback_rate']!,
          _playbackRateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId, audioLanguageCode},
  ];
  @override
  AudioProgressTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioProgressTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      audioLanguageCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}audio_language_code'],
          )!,
      lastAudioPositionMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}last_audio_position_ms'],
          )!,
      playbackRate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}playback_rate'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $AudioProgressTableTable createAlias(String alias) {
    return $AudioProgressTableTable(attachedDatabase, alias);
  }
}

class AudioProgressTableData extends DataClass
    implements Insertable<AudioProgressTableData> {
  final int id;
  final String messageId;
  final String audioLanguageCode;
  final int lastAudioPositionMs;
  final double playbackRate;
  final DateTime updatedAt;
  const AudioProgressTableData({
    required this.id,
    required this.messageId,
    required this.audioLanguageCode,
    required this.lastAudioPositionMs,
    required this.playbackRate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['audio_language_code'] = Variable<String>(audioLanguageCode);
    map['last_audio_position_ms'] = Variable<int>(lastAudioPositionMs);
    map['playback_rate'] = Variable<double>(playbackRate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AudioProgressTableCompanion toCompanion(bool nullToAbsent) {
    return AudioProgressTableCompanion(
      id: Value(id),
      messageId: Value(messageId),
      audioLanguageCode: Value(audioLanguageCode),
      lastAudioPositionMs: Value(lastAudioPositionMs),
      playbackRate: Value(playbackRate),
      updatedAt: Value(updatedAt),
    );
  }

  factory AudioProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioProgressTableData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      audioLanguageCode: serializer.fromJson<String>(json['audioLanguageCode']),
      lastAudioPositionMs: serializer.fromJson<int>(
        json['lastAudioPositionMs'],
      ),
      playbackRate: serializer.fromJson<double>(json['playbackRate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'audioLanguageCode': serializer.toJson<String>(audioLanguageCode),
      'lastAudioPositionMs': serializer.toJson<int>(lastAudioPositionMs),
      'playbackRate': serializer.toJson<double>(playbackRate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AudioProgressTableData copyWith({
    int? id,
    String? messageId,
    String? audioLanguageCode,
    int? lastAudioPositionMs,
    double? playbackRate,
    DateTime? updatedAt,
  }) => AudioProgressTableData(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    audioLanguageCode: audioLanguageCode ?? this.audioLanguageCode,
    lastAudioPositionMs: lastAudioPositionMs ?? this.lastAudioPositionMs,
    playbackRate: playbackRate ?? this.playbackRate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AudioProgressTableData copyWithCompanion(AudioProgressTableCompanion data) {
    return AudioProgressTableData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      audioLanguageCode:
          data.audioLanguageCode.present
              ? data.audioLanguageCode.value
              : this.audioLanguageCode,
      lastAudioPositionMs:
          data.lastAudioPositionMs.present
              ? data.lastAudioPositionMs.value
              : this.lastAudioPositionMs,
      playbackRate:
          data.playbackRate.present
              ? data.playbackRate.value
              : this.playbackRate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioProgressTableData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('audioLanguageCode: $audioLanguageCode, ')
          ..write('lastAudioPositionMs: $lastAudioPositionMs, ')
          ..write('playbackRate: $playbackRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    audioLanguageCode,
    lastAudioPositionMs,
    playbackRate,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioProgressTableData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.audioLanguageCode == this.audioLanguageCode &&
          other.lastAudioPositionMs == this.lastAudioPositionMs &&
          other.playbackRate == this.playbackRate &&
          other.updatedAt == this.updatedAt);
}

class AudioProgressTableCompanion
    extends UpdateCompanion<AudioProgressTableData> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> audioLanguageCode;
  final Value<int> lastAudioPositionMs;
  final Value<double> playbackRate;
  final Value<DateTime> updatedAt;
  const AudioProgressTableCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.audioLanguageCode = const Value.absent(),
    this.lastAudioPositionMs = const Value.absent(),
    this.playbackRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AudioProgressTableCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String audioLanguageCode,
    this.lastAudioPositionMs = const Value.absent(),
    this.playbackRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : messageId = Value(messageId),
       audioLanguageCode = Value(audioLanguageCode);
  static Insertable<AudioProgressTableData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? audioLanguageCode,
    Expression<int>? lastAudioPositionMs,
    Expression<double>? playbackRate,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (audioLanguageCode != null) 'audio_language_code': audioLanguageCode,
      if (lastAudioPositionMs != null)
        'last_audio_position_ms': lastAudioPositionMs,
      if (playbackRate != null) 'playback_rate': playbackRate,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AudioProgressTableCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? audioLanguageCode,
    Value<int>? lastAudioPositionMs,
    Value<double>? playbackRate,
    Value<DateTime>? updatedAt,
  }) {
    return AudioProgressTableCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      audioLanguageCode: audioLanguageCode ?? this.audioLanguageCode,
      lastAudioPositionMs: lastAudioPositionMs ?? this.lastAudioPositionMs,
      playbackRate: playbackRate ?? this.playbackRate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (audioLanguageCode.present) {
      map['audio_language_code'] = Variable<String>(audioLanguageCode.value);
    }
    if (lastAudioPositionMs.present) {
      map['last_audio_position_ms'] = Variable<int>(lastAudioPositionMs.value);
    }
    if (playbackRate.present) {
      map['playback_rate'] = Variable<double>(playbackRate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('audioLanguageCode: $audioLanguageCode, ')
          ..write('lastAudioPositionMs: $lastAudioPositionMs, ')
          ..write('playbackRate: $playbackRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTableTable extends BookmarksTable
    with TableInfo<$BookmarksTableTable, BookmarksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paragraphKeyMeta = const VerificationMeta(
    'paragraphKey',
  );
  @override
  late final GeneratedColumn<String> paragraphKey = GeneratedColumn<String>(
    'paragraph_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    paragraphKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('paragraph_key')) {
      context.handle(
        _paragraphKeyMeta,
        paragraphKey.isAcceptableOrUnknown(
          data['paragraph_key']!,
          _paragraphKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paragraphKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId, paragraphKey},
  ];
  @override
  BookmarksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarksTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      paragraphKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}paragraph_key'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $BookmarksTableTable createAlias(String alias) {
    return $BookmarksTableTable(attachedDatabase, alias);
  }
}

class BookmarksTableData extends DataClass
    implements Insertable<BookmarksTableData> {
  final int id;
  final String messageId;
  final String paragraphKey;
  final DateTime createdAt;
  const BookmarksTableData({
    required this.id,
    required this.messageId,
    required this.paragraphKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['paragraph_key'] = Variable<String>(paragraphKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksTableCompanion toCompanion(bool nullToAbsent) {
    return BookmarksTableCompanion(
      id: Value(id),
      messageId: Value(messageId),
      paragraphKey: Value(paragraphKey),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarksTableData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      paragraphKey: serializer.fromJson<String>(json['paragraphKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'paragraphKey': serializer.toJson<String>(paragraphKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarksTableData copyWith({
    int? id,
    String? messageId,
    String? paragraphKey,
    DateTime? createdAt,
  }) => BookmarksTableData(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    paragraphKey: paragraphKey ?? this.paragraphKey,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarksTableData copyWithCompanion(BookmarksTableCompanion data) {
    return BookmarksTableData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      paragraphKey:
          data.paragraphKey.present
              ? data.paragraphKey.value
              : this.paragraphKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('paragraphKey: $paragraphKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, paragraphKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarksTableData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.paragraphKey == this.paragraphKey &&
          other.createdAt == this.createdAt);
}

class BookmarksTableCompanion extends UpdateCompanion<BookmarksTableData> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> paragraphKey;
  final Value<DateTime> createdAt;
  const BookmarksTableCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.paragraphKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksTableCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String paragraphKey,
    this.createdAt = const Value.absent(),
  }) : messageId = Value(messageId),
       paragraphKey = Value(paragraphKey);
  static Insertable<BookmarksTableData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? paragraphKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (paragraphKey != null) 'paragraph_key': paragraphKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksTableCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? paragraphKey,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksTableCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      paragraphKey: paragraphKey ?? this.paragraphKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (paragraphKey.present) {
      map['paragraph_key'] = Variable<String>(paragraphKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('paragraphKey: $paragraphKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HighlightsTableTable extends HighlightsTable
    with TableInfo<$HighlightsTableTable, HighlightsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighlightsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startParagraphKeyMeta = const VerificationMeta(
    'startParagraphKey',
  );
  @override
  late final GeneratedColumn<String> startParagraphKey =
      GeneratedColumn<String>(
        'start_paragraph_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endParagraphKeyMeta = const VerificationMeta(
    'endParagraphKey',
  );
  @override
  late final GeneratedColumn<String> endParagraphKey = GeneratedColumn<String>(
    'end_paragraph_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startCharOffsetMeta = const VerificationMeta(
    'startCharOffset',
  );
  @override
  late final GeneratedColumn<int> startCharOffset = GeneratedColumn<int>(
    'start_char_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endCharOffsetMeta = const VerificationMeta(
    'endCharOffset',
  );
  @override
  late final GeneratedColumn<int> endCharOffset = GeneratedColumn<int>(
    'end_char_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('yellow'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    startParagraphKey,
    endParagraphKey,
    startCharOffset,
    endCharOffset,
    color,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'highlights_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HighlightsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('start_paragraph_key')) {
      context.handle(
        _startParagraphKeyMeta,
        startParagraphKey.isAcceptableOrUnknown(
          data['start_paragraph_key']!,
          _startParagraphKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startParagraphKeyMeta);
    }
    if (data.containsKey('end_paragraph_key')) {
      context.handle(
        _endParagraphKeyMeta,
        endParagraphKey.isAcceptableOrUnknown(
          data['end_paragraph_key']!,
          _endParagraphKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endParagraphKeyMeta);
    }
    if (data.containsKey('start_char_offset')) {
      context.handle(
        _startCharOffsetMeta,
        startCharOffset.isAcceptableOrUnknown(
          data['start_char_offset']!,
          _startCharOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startCharOffsetMeta);
    }
    if (data.containsKey('end_char_offset')) {
      context.handle(
        _endCharOffsetMeta,
        endCharOffset.isAcceptableOrUnknown(
          data['end_char_offset']!,
          _endCharOffsetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endCharOffsetMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HighlightsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HighlightsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      startParagraphKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}start_paragraph_key'],
          )!,
      endParagraphKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}end_paragraph_key'],
          )!,
      startCharOffset:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}start_char_offset'],
          )!,
      endCharOffset:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}end_char_offset'],
          )!,
      color:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}color'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $HighlightsTableTable createAlias(String alias) {
    return $HighlightsTableTable(attachedDatabase, alias);
  }
}

class HighlightsTableData extends DataClass
    implements Insertable<HighlightsTableData> {
  final int id;
  final String messageId;
  final String startParagraphKey;
  final String endParagraphKey;
  final int startCharOffset;
  final int endCharOffset;
  final String color;
  final DateTime createdAt;
  const HighlightsTableData({
    required this.id,
    required this.messageId,
    required this.startParagraphKey,
    required this.endParagraphKey,
    required this.startCharOffset,
    required this.endCharOffset,
    required this.color,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['start_paragraph_key'] = Variable<String>(startParagraphKey);
    map['end_paragraph_key'] = Variable<String>(endParagraphKey);
    map['start_char_offset'] = Variable<int>(startCharOffset);
    map['end_char_offset'] = Variable<int>(endCharOffset);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HighlightsTableCompanion toCompanion(bool nullToAbsent) {
    return HighlightsTableCompanion(
      id: Value(id),
      messageId: Value(messageId),
      startParagraphKey: Value(startParagraphKey),
      endParagraphKey: Value(endParagraphKey),
      startCharOffset: Value(startCharOffset),
      endCharOffset: Value(endCharOffset),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory HighlightsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HighlightsTableData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      startParagraphKey: serializer.fromJson<String>(json['startParagraphKey']),
      endParagraphKey: serializer.fromJson<String>(json['endParagraphKey']),
      startCharOffset: serializer.fromJson<int>(json['startCharOffset']),
      endCharOffset: serializer.fromJson<int>(json['endCharOffset']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'startParagraphKey': serializer.toJson<String>(startParagraphKey),
      'endParagraphKey': serializer.toJson<String>(endParagraphKey),
      'startCharOffset': serializer.toJson<int>(startCharOffset),
      'endCharOffset': serializer.toJson<int>(endCharOffset),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HighlightsTableData copyWith({
    int? id,
    String? messageId,
    String? startParagraphKey,
    String? endParagraphKey,
    int? startCharOffset,
    int? endCharOffset,
    String? color,
    DateTime? createdAt,
  }) => HighlightsTableData(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    startParagraphKey: startParagraphKey ?? this.startParagraphKey,
    endParagraphKey: endParagraphKey ?? this.endParagraphKey,
    startCharOffset: startCharOffset ?? this.startCharOffset,
    endCharOffset: endCharOffset ?? this.endCharOffset,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
  );
  HighlightsTableData copyWithCompanion(HighlightsTableCompanion data) {
    return HighlightsTableData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      startParagraphKey:
          data.startParagraphKey.present
              ? data.startParagraphKey.value
              : this.startParagraphKey,
      endParagraphKey:
          data.endParagraphKey.present
              ? data.endParagraphKey.value
              : this.endParagraphKey,
      startCharOffset:
          data.startCharOffset.present
              ? data.startCharOffset.value
              : this.startCharOffset,
      endCharOffset:
          data.endCharOffset.present
              ? data.endCharOffset.value
              : this.endCharOffset,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HighlightsTableData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('startParagraphKey: $startParagraphKey, ')
          ..write('endParagraphKey: $endParagraphKey, ')
          ..write('startCharOffset: $startCharOffset, ')
          ..write('endCharOffset: $endCharOffset, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    startParagraphKey,
    endParagraphKey,
    startCharOffset,
    endCharOffset,
    color,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HighlightsTableData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.startParagraphKey == this.startParagraphKey &&
          other.endParagraphKey == this.endParagraphKey &&
          other.startCharOffset == this.startCharOffset &&
          other.endCharOffset == this.endCharOffset &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class HighlightsTableCompanion extends UpdateCompanion<HighlightsTableData> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> startParagraphKey;
  final Value<String> endParagraphKey;
  final Value<int> startCharOffset;
  final Value<int> endCharOffset;
  final Value<String> color;
  final Value<DateTime> createdAt;
  const HighlightsTableCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.startParagraphKey = const Value.absent(),
    this.endParagraphKey = const Value.absent(),
    this.startCharOffset = const Value.absent(),
    this.endCharOffset = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HighlightsTableCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String startParagraphKey,
    required String endParagraphKey,
    required int startCharOffset,
    required int endCharOffset,
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : messageId = Value(messageId),
       startParagraphKey = Value(startParagraphKey),
       endParagraphKey = Value(endParagraphKey),
       startCharOffset = Value(startCharOffset),
       endCharOffset = Value(endCharOffset);
  static Insertable<HighlightsTableData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? startParagraphKey,
    Expression<String>? endParagraphKey,
    Expression<int>? startCharOffset,
    Expression<int>? endCharOffset,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (startParagraphKey != null) 'start_paragraph_key': startParagraphKey,
      if (endParagraphKey != null) 'end_paragraph_key': endParagraphKey,
      if (startCharOffset != null) 'start_char_offset': startCharOffset,
      if (endCharOffset != null) 'end_char_offset': endCharOffset,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HighlightsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? startParagraphKey,
    Value<String>? endParagraphKey,
    Value<int>? startCharOffset,
    Value<int>? endCharOffset,
    Value<String>? color,
    Value<DateTime>? createdAt,
  }) {
    return HighlightsTableCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      startParagraphKey: startParagraphKey ?? this.startParagraphKey,
      endParagraphKey: endParagraphKey ?? this.endParagraphKey,
      startCharOffset: startCharOffset ?? this.startCharOffset,
      endCharOffset: endCharOffset ?? this.endCharOffset,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (startParagraphKey.present) {
      map['start_paragraph_key'] = Variable<String>(startParagraphKey.value);
    }
    if (endParagraphKey.present) {
      map['end_paragraph_key'] = Variable<String>(endParagraphKey.value);
    }
    if (startCharOffset.present) {
      map['start_char_offset'] = Variable<int>(startCharOffset.value);
    }
    if (endCharOffset.present) {
      map['end_char_offset'] = Variable<int>(endCharOffset.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighlightsTableCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('startParagraphKey: $startParagraphKey, ')
          ..write('endParagraphKey: $endParagraphKey, ')
          ..write('startCharOffset: $startCharOffset, ')
          ..write('endCharOffset: $endCharOffset, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AudioSessionsTableTable extends AudioSessionsTable
    with TableInfo<$AudioSessionsTableTable, AudioSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _lastPositionMsMeta = const VerificationMeta(
    'lastPositionMs',
  );
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
    'last_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playbackRateMeta = const VerificationMeta(
    'playbackRate',
  );
  @override
  late final GeneratedColumn<double> playbackRate = GeneratedColumn<double>(
    'playback_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    lastPositionMs,
    playbackRate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioSessionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
        _lastPositionMsMeta,
        lastPositionMs.isAcceptableOrUnknown(
          data['last_position_ms']!,
          _lastPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('playback_rate')) {
      context.handle(
        _playbackRateMeta,
        playbackRate.isAcceptableOrUnknown(
          data['playback_rate']!,
          _playbackRateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioSessionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioSessionsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      lastPositionMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}last_position_ms'],
          )!,
      playbackRate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}playback_rate'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $AudioSessionsTableTable createAlias(String alias) {
    return $AudioSessionsTableTable(attachedDatabase, alias);
  }
}

class AudioSessionsTableData extends DataClass
    implements Insertable<AudioSessionsTableData> {
  final int id;
  final String messageId;
  final int lastPositionMs;
  final double playbackRate;
  final DateTime updatedAt;
  const AudioSessionsTableData({
    required this.id,
    required this.messageId,
    required this.lastPositionMs,
    required this.playbackRate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['last_position_ms'] = Variable<int>(lastPositionMs);
    map['playback_rate'] = Variable<double>(playbackRate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AudioSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return AudioSessionsTableCompanion(
      id: Value(id),
      messageId: Value(messageId),
      lastPositionMs: Value(lastPositionMs),
      playbackRate: Value(playbackRate),
      updatedAt: Value(updatedAt),
    );
  }

  factory AudioSessionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioSessionsTableData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      lastPositionMs: serializer.fromJson<int>(json['lastPositionMs']),
      playbackRate: serializer.fromJson<double>(json['playbackRate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'lastPositionMs': serializer.toJson<int>(lastPositionMs),
      'playbackRate': serializer.toJson<double>(playbackRate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AudioSessionsTableData copyWith({
    int? id,
    String? messageId,
    int? lastPositionMs,
    double? playbackRate,
    DateTime? updatedAt,
  }) => AudioSessionsTableData(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    lastPositionMs: lastPositionMs ?? this.lastPositionMs,
    playbackRate: playbackRate ?? this.playbackRate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AudioSessionsTableData copyWithCompanion(AudioSessionsTableCompanion data) {
    return AudioSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      lastPositionMs:
          data.lastPositionMs.present
              ? data.lastPositionMs.value
              : this.lastPositionMs,
      playbackRate:
          data.playbackRate.present
              ? data.playbackRate.value
              : this.playbackRate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioSessionsTableData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('playbackRate: $playbackRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, messageId, lastPositionMs, playbackRate, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioSessionsTableData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.lastPositionMs == this.lastPositionMs &&
          other.playbackRate == this.playbackRate &&
          other.updatedAt == this.updatedAt);
}

class AudioSessionsTableCompanion
    extends UpdateCompanion<AudioSessionsTableData> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<int> lastPositionMs;
  final Value<double> playbackRate;
  final Value<DateTime> updatedAt;
  const AudioSessionsTableCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.playbackRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AudioSessionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    this.lastPositionMs = const Value.absent(),
    this.playbackRate = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : messageId = Value(messageId);
  static Insertable<AudioSessionsTableData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<int>? lastPositionMs,
    Expression<double>? playbackRate,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (playbackRate != null) 'playback_rate': playbackRate,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AudioSessionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<int>? lastPositionMs,
    Value<double>? playbackRate,
    Value<DateTime>? updatedAt,
  }) {
    return AudioSessionsTableCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      playbackRate: playbackRate ?? this.playbackRate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (playbackRate.present) {
      map['playback_rate'] = Variable<double>(playbackRate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('playbackRate: $playbackRate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AudioCuesTableTable extends AudioCuesTable
    with TableInfo<$AudioCuesTableTable, AudioCuesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioCuesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paragraphKeyMeta = const VerificationMeta(
    'paragraphKey',
  );
  @override
  late final GeneratedColumn<String> paragraphKey = GeneratedColumn<String>(
    'paragraph_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    paragraphKey,
    startMs,
    endMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_cues_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioCuesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('paragraph_key')) {
      context.handle(
        _paragraphKeyMeta,
        paragraphKey.isAcceptableOrUnknown(
          data['paragraph_key']!,
          _paragraphKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paragraphKeyMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId, paragraphKey, startMs},
  ];
  @override
  AudioCuesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioCuesTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      paragraphKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}paragraph_key'],
          )!,
      startMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}start_ms'],
          )!,
      endMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}end_ms'],
          )!,
    );
  }

  @override
  $AudioCuesTableTable createAlias(String alias) {
    return $AudioCuesTableTable(attachedDatabase, alias);
  }
}

class AudioCuesTableData extends DataClass
    implements Insertable<AudioCuesTableData> {
  final int id;
  final String messageId;
  final String paragraphKey;
  final int startMs;
  final int endMs;
  const AudioCuesTableData({
    required this.id,
    required this.messageId,
    required this.paragraphKey,
    required this.startMs,
    required this.endMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['paragraph_key'] = Variable<String>(paragraphKey);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    return map;
  }

  AudioCuesTableCompanion toCompanion(bool nullToAbsent) {
    return AudioCuesTableCompanion(
      id: Value(id),
      messageId: Value(messageId),
      paragraphKey: Value(paragraphKey),
      startMs: Value(startMs),
      endMs: Value(endMs),
    );
  }

  factory AudioCuesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioCuesTableData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      paragraphKey: serializer.fromJson<String>(json['paragraphKey']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'paragraphKey': serializer.toJson<String>(paragraphKey),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
    };
  }

  AudioCuesTableData copyWith({
    int? id,
    String? messageId,
    String? paragraphKey,
    int? startMs,
    int? endMs,
  }) => AudioCuesTableData(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    paragraphKey: paragraphKey ?? this.paragraphKey,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
  );
  AudioCuesTableData copyWithCompanion(AudioCuesTableCompanion data) {
    return AudioCuesTableData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      paragraphKey:
          data.paragraphKey.present
              ? data.paragraphKey.value
              : this.paragraphKey,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioCuesTableData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('paragraphKey: $paragraphKey, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, paragraphKey, startMs, endMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioCuesTableData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.paragraphKey == this.paragraphKey &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs);
}

class AudioCuesTableCompanion extends UpdateCompanion<AudioCuesTableData> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> paragraphKey;
  final Value<int> startMs;
  final Value<int> endMs;
  const AudioCuesTableCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.paragraphKey = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
  });
  AudioCuesTableCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String paragraphKey,
    required int startMs,
    required int endMs,
  }) : messageId = Value(messageId),
       paragraphKey = Value(paragraphKey),
       startMs = Value(startMs),
       endMs = Value(endMs);
  static Insertable<AudioCuesTableData> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? paragraphKey,
    Expression<int>? startMs,
    Expression<int>? endMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (paragraphKey != null) 'paragraph_key': paragraphKey,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
    });
  }

  AudioCuesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? paragraphKey,
    Value<int>? startMs,
    Value<int>? endMs,
  }) {
    return AudioCuesTableCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      paragraphKey: paragraphKey ?? this.paragraphKey,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (paragraphKey.present) {
      map['paragraph_key'] = Variable<String>(paragraphKey.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioCuesTableCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('paragraphKey: $paragraphKey, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs')
          ..write(')'))
        .toString();
  }
}

class $ContactOutboxTable extends ContactOutbox
    with TableInfo<$ContactOutboxTable, ContactOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceModelMeta = const VerificationMeta(
    'deviceModel',
  );
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
    'device_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    message,
    email,
    appVersion,
    platform,
    locale,
    deviceModel,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('device_model')) {
      context.handle(
        _deviceModelMeta,
        deviceModel.isAcceptableOrUnknown(
          data['device_model']!,
          _deviceModelMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactOutboxData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      message:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message'],
          )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      appVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}app_version'],
          )!,
      platform:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}platform'],
          )!,
      locale:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}locale'],
          )!,
      deviceModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_model'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $ContactOutboxTable createAlias(String alias) {
    return $ContactOutboxTable(attachedDatabase, alias);
  }
}

class ContactOutboxData extends DataClass
    implements Insertable<ContactOutboxData> {
  final int id;
  final String category;
  final String message;
  final String? email;
  final String appVersion;
  final String platform;
  final String locale;
  final String? deviceModel;
  final DateTime createdAt;
  final bool synced;
  const ContactOutboxData({
    required this.id,
    required this.category,
    required this.message,
    this.email,
    required this.appVersion,
    required this.platform,
    required this.locale,
    this.deviceModel,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['app_version'] = Variable<String>(appVersion);
    map['platform'] = Variable<String>(platform);
    map['locale'] = Variable<String>(locale);
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ContactOutboxCompanion toCompanion(bool nullToAbsent) {
    return ContactOutboxCompanion(
      id: Value(id),
      category: Value(category),
      message: Value(message),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      appVersion: Value(appVersion),
      platform: Value(platform),
      locale: Value(locale),
      deviceModel:
          deviceModel == null && nullToAbsent
              ? const Value.absent()
              : Value(deviceModel),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory ContactOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactOutboxData(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      message: serializer.fromJson<String>(json['message']),
      email: serializer.fromJson<String?>(json['email']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      platform: serializer.fromJson<String>(json['platform']),
      locale: serializer.fromJson<String>(json['locale']),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'message': serializer.toJson<String>(message),
      'email': serializer.toJson<String?>(email),
      'appVersion': serializer.toJson<String>(appVersion),
      'platform': serializer.toJson<String>(platform),
      'locale': serializer.toJson<String>(locale),
      'deviceModel': serializer.toJson<String?>(deviceModel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ContactOutboxData copyWith({
    int? id,
    String? category,
    String? message,
    Value<String?> email = const Value.absent(),
    String? appVersion,
    String? platform,
    String? locale,
    Value<String?> deviceModel = const Value.absent(),
    DateTime? createdAt,
    bool? synced,
  }) => ContactOutboxData(
    id: id ?? this.id,
    category: category ?? this.category,
    message: message ?? this.message,
    email: email.present ? email.value : this.email,
    appVersion: appVersion ?? this.appVersion,
    platform: platform ?? this.platform,
    locale: locale ?? this.locale,
    deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  ContactOutboxData copyWithCompanion(ContactOutboxCompanion data) {
    return ContactOutboxData(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      message: data.message.present ? data.message.value : this.message,
      email: data.email.present ? data.email.value : this.email,
      appVersion:
          data.appVersion.present ? data.appVersion.value : this.appVersion,
      platform: data.platform.present ? data.platform.value : this.platform,
      locale: data.locale.present ? data.locale.value : this.locale,
      deviceModel:
          data.deviceModel.present ? data.deviceModel.value : this.deviceModel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactOutboxData(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('message: $message, ')
          ..write('email: $email, ')
          ..write('appVersion: $appVersion, ')
          ..write('platform: $platform, ')
          ..write('locale: $locale, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    message,
    email,
    appVersion,
    platform,
    locale,
    deviceModel,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactOutboxData &&
          other.id == this.id &&
          other.category == this.category &&
          other.message == this.message &&
          other.email == this.email &&
          other.appVersion == this.appVersion &&
          other.platform == this.platform &&
          other.locale == this.locale &&
          other.deviceModel == this.deviceModel &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class ContactOutboxCompanion extends UpdateCompanion<ContactOutboxData> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> message;
  final Value<String?> email;
  final Value<String> appVersion;
  final Value<String> platform;
  final Value<String> locale;
  final Value<String?> deviceModel;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const ContactOutboxCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.message = const Value.absent(),
    this.email = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.platform = const Value.absent(),
    this.locale = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  ContactOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String message,
    this.email = const Value.absent(),
    required String appVersion,
    required String platform,
    required String locale,
    this.deviceModel = const Value.absent(),
    required DateTime createdAt,
    this.synced = const Value.absent(),
  }) : category = Value(category),
       message = Value(message),
       appVersion = Value(appVersion),
       platform = Value(platform),
       locale = Value(locale),
       createdAt = Value(createdAt);
  static Insertable<ContactOutboxData> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? message,
    Expression<String>? email,
    Expression<String>? appVersion,
    Expression<String>? platform,
    Expression<String>? locale,
    Expression<String>? deviceModel,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (message != null) 'message': message,
      if (email != null) 'email': email,
      if (appVersion != null) 'app_version': appVersion,
      if (platform != null) 'platform': platform,
      if (locale != null) 'locale': locale,
      if (deviceModel != null) 'device_model': deviceModel,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  ContactOutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<String>? message,
    Value<String?>? email,
    Value<String>? appVersion,
    Value<String>? platform,
    Value<String>? locale,
    Value<String?>? deviceModel,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
  }) {
    return ContactOutboxCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      message: message ?? this.message,
      email: email ?? this.email,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      locale: locale ?? this.locale,
      deviceModel: deviceModel ?? this.deviceModel,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactOutboxCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('message: $message, ')
          ..write('email: $email, ')
          ..write('appVersion: $appVersion, ')
          ..write('platform: $platform, ')
          ..write('locale: $locale, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $ContentReportsOutboxTable extends ContentReportsOutbox
    with TableInfo<$ContentReportsOutboxTable, ContentReportsOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentReportsOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportTypeMeta = const VerificationMeta(
    'reportType',
  );
  @override
  late final GeneratedColumn<String> reportType = GeneratedColumn<String>(
    'report_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    languageCode,
    reportType,
    comment,
    appVersion,
    platform,
    locale,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_reports_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentReportsOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('report_type')) {
      context.handle(
        _reportTypeMeta,
        reportType.isAcceptableOrUnknown(data['report_type']!, _reportTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_reportTypeMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentReportsOutboxData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentReportsOutboxData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}message_id'],
          )!,
      languageCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}language_code'],
          )!,
      reportType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}report_type'],
          )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      appVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}app_version'],
          )!,
      platform:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}platform'],
          )!,
      locale:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}locale'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      synced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}synced'],
          )!,
    );
  }

  @override
  $ContentReportsOutboxTable createAlias(String alias) {
    return $ContentReportsOutboxTable(attachedDatabase, alias);
  }
}

class ContentReportsOutboxData extends DataClass
    implements Insertable<ContentReportsOutboxData> {
  final int id;
  final int messageId;
  final String languageCode;
  final String reportType;
  final String? comment;
  final String appVersion;
  final String platform;
  final String locale;
  final DateTime createdAt;
  final bool synced;
  const ContentReportsOutboxData({
    required this.id,
    required this.messageId,
    required this.languageCode,
    required this.reportType,
    this.comment,
    required this.appVersion,
    required this.platform,
    required this.locale,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<int>(messageId);
    map['language_code'] = Variable<String>(languageCode);
    map['report_type'] = Variable<String>(reportType);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['app_version'] = Variable<String>(appVersion);
    map['platform'] = Variable<String>(platform);
    map['locale'] = Variable<String>(locale);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ContentReportsOutboxCompanion toCompanion(bool nullToAbsent) {
    return ContentReportsOutboxCompanion(
      id: Value(id),
      messageId: Value(messageId),
      languageCode: Value(languageCode),
      reportType: Value(reportType),
      comment:
          comment == null && nullToAbsent
              ? const Value.absent()
              : Value(comment),
      appVersion: Value(appVersion),
      platform: Value(platform),
      locale: Value(locale),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory ContentReportsOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentReportsOutboxData(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<int>(json['messageId']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      reportType: serializer.fromJson<String>(json['reportType']),
      comment: serializer.fromJson<String?>(json['comment']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      platform: serializer.fromJson<String>(json['platform']),
      locale: serializer.fromJson<String>(json['locale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<int>(messageId),
      'languageCode': serializer.toJson<String>(languageCode),
      'reportType': serializer.toJson<String>(reportType),
      'comment': serializer.toJson<String?>(comment),
      'appVersion': serializer.toJson<String>(appVersion),
      'platform': serializer.toJson<String>(platform),
      'locale': serializer.toJson<String>(locale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ContentReportsOutboxData copyWith({
    int? id,
    int? messageId,
    String? languageCode,
    String? reportType,
    Value<String?> comment = const Value.absent(),
    String? appVersion,
    String? platform,
    String? locale,
    DateTime? createdAt,
    bool? synced,
  }) => ContentReportsOutboxData(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    languageCode: languageCode ?? this.languageCode,
    reportType: reportType ?? this.reportType,
    comment: comment.present ? comment.value : this.comment,
    appVersion: appVersion ?? this.appVersion,
    platform: platform ?? this.platform,
    locale: locale ?? this.locale,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  ContentReportsOutboxData copyWithCompanion(
    ContentReportsOutboxCompanion data,
  ) {
    return ContentReportsOutboxData(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      languageCode:
          data.languageCode.present
              ? data.languageCode.value
              : this.languageCode,
      reportType:
          data.reportType.present ? data.reportType.value : this.reportType,
      comment: data.comment.present ? data.comment.value : this.comment,
      appVersion:
          data.appVersion.present ? data.appVersion.value : this.appVersion,
      platform: data.platform.present ? data.platform.value : this.platform,
      locale: data.locale.present ? data.locale.value : this.locale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentReportsOutboxData(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('languageCode: $languageCode, ')
          ..write('reportType: $reportType, ')
          ..write('comment: $comment, ')
          ..write('appVersion: $appVersion, ')
          ..write('platform: $platform, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    languageCode,
    reportType,
    comment,
    appVersion,
    platform,
    locale,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentReportsOutboxData &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.languageCode == this.languageCode &&
          other.reportType == this.reportType &&
          other.comment == this.comment &&
          other.appVersion == this.appVersion &&
          other.platform == this.platform &&
          other.locale == this.locale &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class ContentReportsOutboxCompanion
    extends UpdateCompanion<ContentReportsOutboxData> {
  final Value<int> id;
  final Value<int> messageId;
  final Value<String> languageCode;
  final Value<String> reportType;
  final Value<String?> comment;
  final Value<String> appVersion;
  final Value<String> platform;
  final Value<String> locale;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const ContentReportsOutboxCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.reportType = const Value.absent(),
    this.comment = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.platform = const Value.absent(),
    this.locale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  ContentReportsOutboxCompanion.insert({
    this.id = const Value.absent(),
    required int messageId,
    required String languageCode,
    required String reportType,
    this.comment = const Value.absent(),
    required String appVersion,
    required String platform,
    required String locale,
    required DateTime createdAt,
    this.synced = const Value.absent(),
  }) : messageId = Value(messageId),
       languageCode = Value(languageCode),
       reportType = Value(reportType),
       appVersion = Value(appVersion),
       platform = Value(platform),
       locale = Value(locale),
       createdAt = Value(createdAt);
  static Insertable<ContentReportsOutboxData> custom({
    Expression<int>? id,
    Expression<int>? messageId,
    Expression<String>? languageCode,
    Expression<String>? reportType,
    Expression<String>? comment,
    Expression<String>? appVersion,
    Expression<String>? platform,
    Expression<String>? locale,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (languageCode != null) 'language_code': languageCode,
      if (reportType != null) 'report_type': reportType,
      if (comment != null) 'comment': comment,
      if (appVersion != null) 'app_version': appVersion,
      if (platform != null) 'platform': platform,
      if (locale != null) 'locale': locale,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  ContentReportsOutboxCompanion copyWith({
    Value<int>? id,
    Value<int>? messageId,
    Value<String>? languageCode,
    Value<String>? reportType,
    Value<String?>? comment,
    Value<String>? appVersion,
    Value<String>? platform,
    Value<String>? locale,
    Value<DateTime>? createdAt,
    Value<bool>? synced,
  }) {
    return ContentReportsOutboxCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      languageCode: languageCode ?? this.languageCode,
      reportType: reportType ?? this.reportType,
      comment: comment ?? this.comment,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      locale: locale ?? this.locale,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (reportType.present) {
      map['report_type'] = Variable<String>(reportType.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentReportsOutboxCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('languageCode: $languageCode, ')
          ..write('reportType: $reportType, ')
          ..write('comment: $comment, ')
          ..write('appVersion: $appVersion, ')
          ..write('platform: $platform, ')
          ..write('locale: $locale, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsEventQueueTable extends AnalyticsEventQueue
    with TableInfo<$AnalyticsEventQueueTable, AnalyticsQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsEventQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientEventIdMeta = const VerificationMeta(
    'clientEventId',
  );
  @override
  late final GeneratedColumn<String> clientEventId = GeneratedColumn<String>(
    'client_event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<String> occurredAt = GeneratedColumn<String>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventNameMeta = const VerificationMeta(
    'eventName',
  );
  @override
  late final GeneratedColumn<String> eventName = GeneratedColumn<String>(
    'event_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<int> nextRetryAt = GeneratedColumn<int>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientEventId,
    occurredAt,
    eventName,
    payloadJson,
    attempts,
    nextRetryAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_event_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalyticsQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_event_id')) {
      context.handle(
        _clientEventIdMeta,
        clientEventId.isAcceptableOrUnknown(
          data['client_event_id']!,
          _clientEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientEventIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('event_name')) {
      context.handle(
        _eventNameMeta,
        eventName.isAcceptableOrUnknown(data['event_name']!, _eventNameMeta),
      );
    } else if (isInserting) {
      context.missing(_eventNameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientEventId};
  @override
  AnalyticsQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsQueueEntry(
      clientEventId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}client_event_id'],
          )!,
      occurredAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}occurred_at'],
          )!,
      eventName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}event_name'],
          )!,
      payloadJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload_json'],
          )!,
      attempts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}attempts'],
          )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_retry_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $AnalyticsEventQueueTable createAlias(String alias) {
    return $AnalyticsEventQueueTable(attachedDatabase, alias);
  }
}

class AnalyticsQueueEntry extends DataClass
    implements Insertable<AnalyticsQueueEntry> {
  /// Unique ID generated by the client (UUID).
  final String clientEventId;

  /// ISO 8601 UTC timestamp of when the event occurred.
  final String occurredAt;

  /// The event name (e.g., 'screen_view').
  final String eventName;

  /// Full JSON payload of the event.
  final String payloadJson;

  /// Number of upload attempts.
  final int attempts;

  /// Next retry timestamp (Unix ms). Null means ready to send immediately.
  final int? nextRetryAt;

  /// When this row was created (Unix ms).
  final int createdAt;
  const AnalyticsQueueEntry({
    required this.clientEventId,
    required this.occurredAt,
    required this.eventName,
    required this.payloadJson,
    required this.attempts,
    this.nextRetryAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_event_id'] = Variable<String>(clientEventId);
    map['occurred_at'] = Variable<String>(occurredAt);
    map['event_name'] = Variable<String>(eventName);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<int>(nextRetryAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AnalyticsEventQueueCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsEventQueueCompanion(
      clientEventId: Value(clientEventId),
      occurredAt: Value(occurredAt),
      eventName: Value(eventName),
      payloadJson: Value(payloadJson),
      attempts: Value(attempts),
      nextRetryAt:
          nextRetryAt == null && nullToAbsent
              ? const Value.absent()
              : Value(nextRetryAt),
      createdAt: Value(createdAt),
    );
  }

  factory AnalyticsQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsQueueEntry(
      clientEventId: serializer.fromJson<String>(json['clientEventId']),
      occurredAt: serializer.fromJson<String>(json['occurredAt']),
      eventName: serializer.fromJson<String>(json['eventName']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextRetryAt: serializer.fromJson<int?>(json['nextRetryAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientEventId': serializer.toJson<String>(clientEventId),
      'occurredAt': serializer.toJson<String>(occurredAt),
      'eventName': serializer.toJson<String>(eventName),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attempts': serializer.toJson<int>(attempts),
      'nextRetryAt': serializer.toJson<int?>(nextRetryAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AnalyticsQueueEntry copyWith({
    String? clientEventId,
    String? occurredAt,
    String? eventName,
    String? payloadJson,
    int? attempts,
    Value<int?> nextRetryAt = const Value.absent(),
    int? createdAt,
  }) => AnalyticsQueueEntry(
    clientEventId: clientEventId ?? this.clientEventId,
    occurredAt: occurredAt ?? this.occurredAt,
    eventName: eventName ?? this.eventName,
    payloadJson: payloadJson ?? this.payloadJson,
    attempts: attempts ?? this.attempts,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    createdAt: createdAt ?? this.createdAt,
  );
  AnalyticsQueueEntry copyWithCompanion(AnalyticsEventQueueCompanion data) {
    return AnalyticsQueueEntry(
      clientEventId:
          data.clientEventId.present
              ? data.clientEventId.value
              : this.clientEventId,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      eventName: data.eventName.present ? data.eventName.value : this.eventName,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsQueueEntry(')
          ..write('clientEventId: $clientEventId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('eventName: $eventName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientEventId,
    occurredAt,
    eventName,
    payloadJson,
    attempts,
    nextRetryAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsQueueEntry &&
          other.clientEventId == this.clientEventId &&
          other.occurredAt == this.occurredAt &&
          other.eventName == this.eventName &&
          other.payloadJson == this.payloadJson &&
          other.attempts == this.attempts &&
          other.nextRetryAt == this.nextRetryAt &&
          other.createdAt == this.createdAt);
}

class AnalyticsEventQueueCompanion
    extends UpdateCompanion<AnalyticsQueueEntry> {
  final Value<String> clientEventId;
  final Value<String> occurredAt;
  final Value<String> eventName;
  final Value<String> payloadJson;
  final Value<int> attempts;
  final Value<int?> nextRetryAt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AnalyticsEventQueueCompanion({
    this.clientEventId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.eventName = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnalyticsEventQueueCompanion.insert({
    required String clientEventId,
    required String occurredAt,
    required String eventName,
    required String payloadJson,
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : clientEventId = Value(clientEventId),
       occurredAt = Value(occurredAt),
       eventName = Value(eventName),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<AnalyticsQueueEntry> custom({
    Expression<String>? clientEventId,
    Expression<String>? occurredAt,
    Expression<String>? eventName,
    Expression<String>? payloadJson,
    Expression<int>? attempts,
    Expression<int>? nextRetryAt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientEventId != null) 'client_event_id': clientEventId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (eventName != null) 'event_name': eventName,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attempts != null) 'attempts': attempts,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnalyticsEventQueueCompanion copyWith({
    Value<String>? clientEventId,
    Value<String>? occurredAt,
    Value<String>? eventName,
    Value<String>? payloadJson,
    Value<int>? attempts,
    Value<int?>? nextRetryAt,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AnalyticsEventQueueCompanion(
      clientEventId: clientEventId ?? this.clientEventId,
      occurredAt: occurredAt ?? this.occurredAt,
      eventName: eventName ?? this.eventName,
      payloadJson: payloadJson ?? this.payloadJson,
      attempts: attempts ?? this.attempts,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientEventId.present) {
      map['client_event_id'] = Variable<String>(clientEventId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<String>(occurredAt.value);
    }
    if (eventName.present) {
      map['event_name'] = Variable<String>(eventName.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<int>(nextRetryAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsEventQueueCompanion(')
          ..write('clientEventId: $clientEventId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('eventName: $eventName, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $TranslationsTable translations = $TranslationsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ReadingSettingsTableTable readingSettingsTable =
      $ReadingSettingsTableTable(this);
  late final $ReadingProgressTableTable readingProgressTable =
      $ReadingProgressTableTable(this);
  late final $AudioProgressTableTable audioProgressTable =
      $AudioProgressTableTable(this);
  late final $BookmarksTableTable bookmarksTable = $BookmarksTableTable(this);
  late final $HighlightsTableTable highlightsTable = $HighlightsTableTable(
    this,
  );
  late final $AudioSessionsTableTable audioSessionsTable =
      $AudioSessionsTableTable(this);
  late final $AudioCuesTableTable audioCuesTable = $AudioCuesTableTable(this);
  late final $ContactOutboxTable contactOutbox = $ContactOutboxTable(this);
  late final $ContentReportsOutboxTable contentReportsOutbox =
      $ContentReportsOutboxTable(this);
  late final $AnalyticsEventQueueTable analyticsEventQueue =
      $AnalyticsEventQueueTable(this);
  late final MessageDao messageDao = MessageDao(this as AppDatabase);
  late final ReadingSettingsDao readingSettingsDao = ReadingSettingsDao(
    this as AppDatabase,
  );
  late final ReadingProgressDao readingProgressDao = ReadingProgressDao(
    this as AppDatabase,
  );
  late final AudioProgressDao audioProgressDao = AudioProgressDao(
    this as AppDatabase,
  );
  late final BookmarksDao bookmarksDao = BookmarksDao(this as AppDatabase);
  late final HighlightsDao highlightsDao = HighlightsDao(this as AppDatabase);
  late final AudioDao audioDao = AudioDao(this as AppDatabase);
  late final AnalyticsQueueDao analyticsQueueDao = AnalyticsQueueDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sections,
    messages,
    translations,
    syncState,
    readingSettingsTable,
    readingProgressTable,
    audioProgressTable,
    bookmarksTable,
    highlightsTable,
    audioSessionsTable,
    audioCuesTable,
    contactOutbox,
    contentReportsOutbox,
    analyticsEventQueue,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('translations', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SectionsTableCreateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      required String title,
      required String slug,
      Value<int?> sortOrder,
    });
typedef $$SectionsTableUpdateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> slug,
      Value<int?> sortOrder,
    });

final class $$SectionsTableReferences
    extends BaseReferences<_$AppDatabase, $SectionsTable, Section> {
  $$SectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(db.sections.id, db.messages.sectionId),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, $$SectionsTableReferences),
          Section,
          PrefetchHooks Function({bool messagesRefs})
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                title: title,
                slug: slug,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String slug,
                Value<int?> sortOrder = const Value.absent(),
              }) => SectionsCompanion.insert(
                id: id,
                title: title,
                slug: slug,
                sortOrder: sortOrder,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SectionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData<Section, $SectionsTable, Message>(
                      currentTable: table,
                      referencedTable: $$SectionsTableReferences
                          ._messagesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$SectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.sectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, $$SectionsTableReferences),
      Section,
      PrefetchHooks Function({bool messagesRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required String slug,
      required String title,
      Value<bool> isPublished,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> sectionId,
      Value<String?> titleAr,
      Value<String?> titleEn,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<String> slug,
      Value<String> title,
      Value<bool> isPublished,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> sectionId,
      Value<String?> titleAr,
      Value<String?> titleEn,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SectionsTable _sectionIdTable(_$AppDatabase db) => db.sections
      .createAlias($_aliasNameGenerator(db.messages.sectionId, db.sections.id));

  $$SectionsTableProcessedTableManager? get sectionId {
    final $_column = $_itemColumn<int>('section_id');
    if ($_column == null) return null;
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TranslationsTable, List<Translation>>
  _translationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.translations,
    aliasName: $_aliasNameGenerator(db.messages.id, db.translations.messageId),
  );

  $$TranslationsTableProcessedTableManager get translationsRefs {
    final manager = $$TranslationsTableTableManager(
      $_db,
      $_db.translations,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_translationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleAr => $composableBuilder(
    column: $table.titleAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnFilters(column),
  );

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> translationsRefs(
    Expression<bool> Function($$TranslationsTableFilterComposer f) f,
  ) {
    final $$TranslationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translations,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationsTableFilterComposer(
            $db: $db,
            $table: $db.translations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleAr => $composableBuilder(
    column: $table.titleAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleEn => $composableBuilder(
    column: $table.titleEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get titleAr =>
      $composableBuilder(column: $table.titleAr, builder: (column) => column);

  GeneratedColumn<String> get titleEn =>
      $composableBuilder(column: $table.titleEn, builder: (column) => column);

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> translationsRefs<T extends Object>(
    Expression<T> Function($$TranslationsTableAnnotationComposer a) f,
  ) {
    final $$TranslationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.translations,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranslationsTableAnnotationComposer(
            $db: $db,
            $table: $db.translations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool sectionId, bool translationsRefs})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> sectionId = const Value.absent(),
                Value<String?> titleAr = const Value.absent(),
                Value<String?> titleEn = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                slug: slug,
                title: title,
                isPublished: isPublished,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sectionId: sectionId,
                titleAr: titleAr,
                titleEn: titleEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String slug,
                required String title,
                Value<bool> isPublished = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> sectionId = const Value.absent(),
                Value<String?> titleAr = const Value.absent(),
                Value<String?> titleEn = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                slug: slug,
                title: title,
                isPublished: isPublished,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sectionId: sectionId,
                titleAr: titleAr,
                titleEn: titleEn,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MessagesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            sectionId = false,
            translationsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (translationsRefs) db.translations],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (sectionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.sectionId,
                            referencedTable: $$MessagesTableReferences
                                ._sectionIdTable(db),
                            referencedColumn:
                                $$MessagesTableReferences
                                    ._sectionIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (translationsRefs)
                    await $_getPrefetchedData<
                      Message,
                      $MessagesTable,
                      Translation
                    >(
                      currentTable: table,
                      referencedTable: $$MessagesTableReferences
                          ._translationsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).translationsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.messageId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool sectionId, bool translationsRefs})
    >;
typedef $$TranslationsTableCreateCompanionBuilder =
    TranslationsCompanion Function({
      required int messageId,
      required String languageCode,
      Value<String> title,
      required String content,
      Value<String?> audioUrl,
      Value<String> audioPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TranslationsTableUpdateCompanionBuilder =
    TranslationsCompanion Function({
      Value<int> messageId,
      Value<String> languageCode,
      Value<String> title,
      Value<String> content,
      Value<String?> audioUrl,
      Value<String> audioPath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TranslationsTableReferences
    extends BaseReferences<_$AppDatabase, $TranslationsTable, Translation> {
  $$TranslationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MessagesTable _messageIdTable(_$AppDatabase db) =>
      db.messages.createAlias(
        $_aliasNameGenerator(db.translations.messageId, db.messages.id),
      );

  $$MessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MessagesTableFilterComposer get messageId {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MessagesTableOrderingComposer get messageId {
    final $$MessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableOrderingComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationsTable> {
  $$TranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MessagesTableAnnotationComposer get messageId {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranslationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranslationsTable,
          Translation,
          $$TranslationsTableFilterComposer,
          $$TranslationsTableOrderingComposer,
          $$TranslationsTableAnnotationComposer,
          $$TranslationsTableCreateCompanionBuilder,
          $$TranslationsTableUpdateCompanionBuilder,
          (Translation, $$TranslationsTableReferences),
          Translation,
          PrefetchHooks Function({bool messageId})
        > {
  $$TranslationsTableTableManager(_$AppDatabase db, $TranslationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TranslationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> messageId = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion(
                messageId: messageId,
                languageCode: languageCode,
                title: title,
                content: content,
                audioUrl: audioUrl,
                audioPath: audioPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int messageId,
                required String languageCode,
                Value<String> title = const Value.absent(),
                required String content,
                Value<String?> audioUrl = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationsCompanion.insert(
                messageId: messageId,
                languageCode: languageCode,
                title: title,
                content: content,
                audioUrl: audioUrl,
                audioPath: audioPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TranslationsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({messageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (messageId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.messageId,
                            referencedTable: $$TranslationsTableReferences
                                ._messageIdTable(db),
                            referencedColumn:
                                $$TranslationsTableReferences
                                    ._messageIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranslationsTable,
      Translation,
      $$TranslationsTableFilterComposer,
      $$TranslationsTableOrderingComposer,
      $$TranslationsTableAnnotationComposer,
      $$TranslationsTableCreateCompanionBuilder,
      $$TranslationsTableUpdateCompanionBuilder,
      (Translation, $$TranslationsTableReferences),
      Translation,
      PrefetchHooks Function({bool messageId})
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String key,
      required DateTime value,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> key,
      Value<DateTime> value,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
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

  ColumnFilters<DateTime> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
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

  ColumnOrderings<DateTime> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<DateTime> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required DateTime value,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ReadingSettingsTableTableCreateCompanionBuilder =
    ReadingSettingsTableCompanion Function({
      Value<int> id,
      Value<String> theme,
      Value<String> pageStyle,
      Value<double> fontSize,
      Value<double> lineHeight,
      Value<String> fontFamily,
      Value<DateTime> updatedAt,
    });
typedef $$ReadingSettingsTableTableUpdateCompanionBuilder =
    ReadingSettingsTableCompanion Function({
      Value<int> id,
      Value<String> theme,
      Value<String> pageStyle,
      Value<double> fontSize,
      Value<double> lineHeight,
      Value<String> fontFamily,
      Value<DateTime> updatedAt,
    });

class $$ReadingSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSettingsTableTable> {
  $$ReadingSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageStyle => $composableBuilder(
    column: $table.pageStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSettingsTableTable> {
  $$ReadingSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageStyle => $composableBuilder(
    column: $table.pageStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSettingsTableTable> {
  $$ReadingSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get pageStyle =>
      $composableBuilder(column: $table.pageStyle, builder: (column) => column);

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingSettingsTableTable,
          ReadingSettingsTableData,
          $$ReadingSettingsTableTableFilterComposer,
          $$ReadingSettingsTableTableOrderingComposer,
          $$ReadingSettingsTableTableAnnotationComposer,
          $$ReadingSettingsTableTableCreateCompanionBuilder,
          $$ReadingSettingsTableTableUpdateCompanionBuilder,
          (
            ReadingSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $ReadingSettingsTableTable,
              ReadingSettingsTableData
            >,
          ),
          ReadingSettingsTableData,
          PrefetchHooks Function()
        > {
  $$ReadingSettingsTableTableTableManager(
    _$AppDatabase db,
    $ReadingSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ReadingSettingsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ReadingSettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ReadingSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> pageStyle = const Value.absent(),
                Value<double> fontSize = const Value.absent(),
                Value<double> lineHeight = const Value.absent(),
                Value<String> fontFamily = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReadingSettingsTableCompanion(
                id: id,
                theme: theme,
                pageStyle: pageStyle,
                fontSize: fontSize,
                lineHeight: lineHeight,
                fontFamily: fontFamily,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> pageStyle = const Value.absent(),
                Value<double> fontSize = const Value.absent(),
                Value<double> lineHeight = const Value.absent(),
                Value<String> fontFamily = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReadingSettingsTableCompanion.insert(
                id: id,
                theme: theme,
                pageStyle: pageStyle,
                fontSize: fontSize,
                lineHeight: lineHeight,
                fontFamily: fontFamily,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingSettingsTableTable,
      ReadingSettingsTableData,
      $$ReadingSettingsTableTableFilterComposer,
      $$ReadingSettingsTableTableOrderingComposer,
      $$ReadingSettingsTableTableAnnotationComposer,
      $$ReadingSettingsTableTableCreateCompanionBuilder,
      $$ReadingSettingsTableTableUpdateCompanionBuilder,
      (
        ReadingSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $ReadingSettingsTableTable,
          ReadingSettingsTableData
        >,
      ),
      ReadingSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$ReadingProgressTableTableCreateCompanionBuilder =
    ReadingProgressTableCompanion Function({
      Value<int> id,
      required String messageId,
      Value<String> textLanguageCode,
      Value<double> percent,
      Value<double> scrollOffset,
      Value<int> pageIndex,
      Value<DateTime> updatedAt,
    });
typedef $$ReadingProgressTableTableUpdateCompanionBuilder =
    ReadingProgressTableCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> textLanguageCode,
      Value<double> percent,
      Value<double> scrollOffset,
      Value<int> pageIndex,
      Value<DateTime> updatedAt,
    });

class $$ReadingProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textLanguageCode => $composableBuilder(
    column: $table.textLanguageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrollOffset => $composableBuilder(
    column: $table.scrollOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textLanguageCode => $composableBuilder(
    column: $table.textLanguageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrollOffset => $composableBuilder(
    column: $table.scrollOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressTableTable> {
  $$ReadingProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get textLanguageCode => $composableBuilder(
    column: $table.textLanguageCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);

  GeneratedColumn<double> get scrollOffset => $composableBuilder(
    column: $table.scrollOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressTableTable,
          ReadingProgressTableData,
          $$ReadingProgressTableTableFilterComposer,
          $$ReadingProgressTableTableOrderingComposer,
          $$ReadingProgressTableTableAnnotationComposer,
          $$ReadingProgressTableTableCreateCompanionBuilder,
          $$ReadingProgressTableTableUpdateCompanionBuilder,
          (
            ReadingProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $ReadingProgressTableTable,
              ReadingProgressTableData
            >,
          ),
          ReadingProgressTableData,
          PrefetchHooks Function()
        > {
  $$ReadingProgressTableTableTableManager(
    _$AppDatabase db,
    $ReadingProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ReadingProgressTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ReadingProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ReadingProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> textLanguageCode = const Value.absent(),
                Value<double> percent = const Value.absent(),
                Value<double> scrollOffset = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReadingProgressTableCompanion(
                id: id,
                messageId: messageId,
                textLanguageCode: textLanguageCode,
                percent: percent,
                scrollOffset: scrollOffset,
                pageIndex: pageIndex,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                Value<String> textLanguageCode = const Value.absent(),
                Value<double> percent = const Value.absent(),
                Value<double> scrollOffset = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReadingProgressTableCompanion.insert(
                id: id,
                messageId: messageId,
                textLanguageCode: textLanguageCode,
                percent: percent,
                scrollOffset: scrollOffset,
                pageIndex: pageIndex,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressTableTable,
      ReadingProgressTableData,
      $$ReadingProgressTableTableFilterComposer,
      $$ReadingProgressTableTableOrderingComposer,
      $$ReadingProgressTableTableAnnotationComposer,
      $$ReadingProgressTableTableCreateCompanionBuilder,
      $$ReadingProgressTableTableUpdateCompanionBuilder,
      (
        ReadingProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressTableTable,
          ReadingProgressTableData
        >,
      ),
      ReadingProgressTableData,
      PrefetchHooks Function()
    >;
typedef $$AudioProgressTableTableCreateCompanionBuilder =
    AudioProgressTableCompanion Function({
      Value<int> id,
      required String messageId,
      required String audioLanguageCode,
      Value<int> lastAudioPositionMs,
      Value<double> playbackRate,
      Value<DateTime> updatedAt,
    });
typedef $$AudioProgressTableTableUpdateCompanionBuilder =
    AudioProgressTableCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> audioLanguageCode,
      Value<int> lastAudioPositionMs,
      Value<double> playbackRate,
      Value<DateTime> updatedAt,
    });

class $$AudioProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $AudioProgressTableTable> {
  $$AudioProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioLanguageCode => $composableBuilder(
    column: $table.audioLanguageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAudioPositionMs => $composableBuilder(
    column: $table.lastAudioPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get playbackRate => $composableBuilder(
    column: $table.playbackRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioProgressTableTable> {
  $$AudioProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioLanguageCode => $composableBuilder(
    column: $table.audioLanguageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAudioPositionMs => $composableBuilder(
    column: $table.lastAudioPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get playbackRate => $composableBuilder(
    column: $table.playbackRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioProgressTableTable> {
  $$AudioProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get audioLanguageCode => $composableBuilder(
    column: $table.audioLanguageCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAudioPositionMs => $composableBuilder(
    column: $table.lastAudioPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get playbackRate => $composableBuilder(
    column: $table.playbackRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioProgressTableTable,
          AudioProgressTableData,
          $$AudioProgressTableTableFilterComposer,
          $$AudioProgressTableTableOrderingComposer,
          $$AudioProgressTableTableAnnotationComposer,
          $$AudioProgressTableTableCreateCompanionBuilder,
          $$AudioProgressTableTableUpdateCompanionBuilder,
          (
            AudioProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $AudioProgressTableTable,
              AudioProgressTableData
            >,
          ),
          AudioProgressTableData,
          PrefetchHooks Function()
        > {
  $$AudioProgressTableTableTableManager(
    _$AppDatabase db,
    $AudioProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AudioProgressTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$AudioProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AudioProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> audioLanguageCode = const Value.absent(),
                Value<int> lastAudioPositionMs = const Value.absent(),
                Value<double> playbackRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AudioProgressTableCompanion(
                id: id,
                messageId: messageId,
                audioLanguageCode: audioLanguageCode,
                lastAudioPositionMs: lastAudioPositionMs,
                playbackRate: playbackRate,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String audioLanguageCode,
                Value<int> lastAudioPositionMs = const Value.absent(),
                Value<double> playbackRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AudioProgressTableCompanion.insert(
                id: id,
                messageId: messageId,
                audioLanguageCode: audioLanguageCode,
                lastAudioPositionMs: lastAudioPositionMs,
                playbackRate: playbackRate,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioProgressTableTable,
      AudioProgressTableData,
      $$AudioProgressTableTableFilterComposer,
      $$AudioProgressTableTableOrderingComposer,
      $$AudioProgressTableTableAnnotationComposer,
      $$AudioProgressTableTableCreateCompanionBuilder,
      $$AudioProgressTableTableUpdateCompanionBuilder,
      (
        AudioProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $AudioProgressTableTable,
          AudioProgressTableData
        >,
      ),
      AudioProgressTableData,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableTableCreateCompanionBuilder =
    BookmarksTableCompanion Function({
      Value<int> id,
      required String messageId,
      required String paragraphKey,
      Value<DateTime> createdAt,
    });
typedef $$BookmarksTableTableUpdateCompanionBuilder =
    BookmarksTableCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> paragraphKey,
      Value<DateTime> createdAt,
    });

class $$BookmarksTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paragraphKey => $composableBuilder(
    column: $table.paragraphKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paragraphKey => $composableBuilder(
    column: $table.paragraphKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get paragraphKey => $composableBuilder(
    column: $table.paragraphKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTableTable,
          BookmarksTableData,
          $$BookmarksTableTableFilterComposer,
          $$BookmarksTableTableOrderingComposer,
          $$BookmarksTableTableAnnotationComposer,
          $$BookmarksTableTableCreateCompanionBuilder,
          $$BookmarksTableTableUpdateCompanionBuilder,
          (
            BookmarksTableData,
            BaseReferences<
              _$AppDatabase,
              $BookmarksTableTable,
              BookmarksTableData
            >,
          ),
          BookmarksTableData,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableTableManager(
    _$AppDatabase db,
    $BookmarksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BookmarksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$BookmarksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$BookmarksTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> paragraphKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksTableCompanion(
                id: id,
                messageId: messageId,
                paragraphKey: paragraphKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String paragraphKey,
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksTableCompanion.insert(
                id: id,
                messageId: messageId,
                paragraphKey: paragraphKey,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTableTable,
      BookmarksTableData,
      $$BookmarksTableTableFilterComposer,
      $$BookmarksTableTableOrderingComposer,
      $$BookmarksTableTableAnnotationComposer,
      $$BookmarksTableTableCreateCompanionBuilder,
      $$BookmarksTableTableUpdateCompanionBuilder,
      (
        BookmarksTableData,
        BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarksTableData>,
      ),
      BookmarksTableData,
      PrefetchHooks Function()
    >;
typedef $$HighlightsTableTableCreateCompanionBuilder =
    HighlightsTableCompanion Function({
      Value<int> id,
      required String messageId,
      required String startParagraphKey,
      required String endParagraphKey,
      required int startCharOffset,
      required int endCharOffset,
      Value<String> color,
      Value<DateTime> createdAt,
    });
typedef $$HighlightsTableTableUpdateCompanionBuilder =
    HighlightsTableCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> startParagraphKey,
      Value<String> endParagraphKey,
      Value<int> startCharOffset,
      Value<int> endCharOffset,
      Value<String> color,
      Value<DateTime> createdAt,
    });

class $$HighlightsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HighlightsTableTable> {
  $$HighlightsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startParagraphKey => $composableBuilder(
    column: $table.startParagraphKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endParagraphKey => $composableBuilder(
    column: $table.endParagraphKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startCharOffset => $composableBuilder(
    column: $table.startCharOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endCharOffset => $composableBuilder(
    column: $table.endCharOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HighlightsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HighlightsTableTable> {
  $$HighlightsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startParagraphKey => $composableBuilder(
    column: $table.startParagraphKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endParagraphKey => $composableBuilder(
    column: $table.endParagraphKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startCharOffset => $composableBuilder(
    column: $table.startCharOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endCharOffset => $composableBuilder(
    column: $table.endCharOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HighlightsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HighlightsTableTable> {
  $$HighlightsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get startParagraphKey => $composableBuilder(
    column: $table.startParagraphKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endParagraphKey => $composableBuilder(
    column: $table.endParagraphKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startCharOffset => $composableBuilder(
    column: $table.startCharOffset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endCharOffset => $composableBuilder(
    column: $table.endCharOffset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HighlightsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HighlightsTableTable,
          HighlightsTableData,
          $$HighlightsTableTableFilterComposer,
          $$HighlightsTableTableOrderingComposer,
          $$HighlightsTableTableAnnotationComposer,
          $$HighlightsTableTableCreateCompanionBuilder,
          $$HighlightsTableTableUpdateCompanionBuilder,
          (
            HighlightsTableData,
            BaseReferences<
              _$AppDatabase,
              $HighlightsTableTable,
              HighlightsTableData
            >,
          ),
          HighlightsTableData,
          PrefetchHooks Function()
        > {
  $$HighlightsTableTableTableManager(
    _$AppDatabase db,
    $HighlightsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$HighlightsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HighlightsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$HighlightsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> startParagraphKey = const Value.absent(),
                Value<String> endParagraphKey = const Value.absent(),
                Value<int> startCharOffset = const Value.absent(),
                Value<int> endCharOffset = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HighlightsTableCompanion(
                id: id,
                messageId: messageId,
                startParagraphKey: startParagraphKey,
                endParagraphKey: endParagraphKey,
                startCharOffset: startCharOffset,
                endCharOffset: endCharOffset,
                color: color,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String startParagraphKey,
                required String endParagraphKey,
                required int startCharOffset,
                required int endCharOffset,
                Value<String> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HighlightsTableCompanion.insert(
                id: id,
                messageId: messageId,
                startParagraphKey: startParagraphKey,
                endParagraphKey: endParagraphKey,
                startCharOffset: startCharOffset,
                endCharOffset: endCharOffset,
                color: color,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HighlightsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HighlightsTableTable,
      HighlightsTableData,
      $$HighlightsTableTableFilterComposer,
      $$HighlightsTableTableOrderingComposer,
      $$HighlightsTableTableAnnotationComposer,
      $$HighlightsTableTableCreateCompanionBuilder,
      $$HighlightsTableTableUpdateCompanionBuilder,
      (
        HighlightsTableData,
        BaseReferences<
          _$AppDatabase,
          $HighlightsTableTable,
          HighlightsTableData
        >,
      ),
      HighlightsTableData,
      PrefetchHooks Function()
    >;
typedef $$AudioSessionsTableTableCreateCompanionBuilder =
    AudioSessionsTableCompanion Function({
      Value<int> id,
      required String messageId,
      Value<int> lastPositionMs,
      Value<double> playbackRate,
      Value<DateTime> updatedAt,
    });
typedef $$AudioSessionsTableTableUpdateCompanionBuilder =
    AudioSessionsTableCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<int> lastPositionMs,
      Value<double> playbackRate,
      Value<DateTime> updatedAt,
    });

class $$AudioSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AudioSessionsTableTable> {
  $$AudioSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get playbackRate => $composableBuilder(
    column: $table.playbackRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioSessionsTableTable> {
  $$AudioSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get playbackRate => $composableBuilder(
    column: $table.playbackRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioSessionsTableTable> {
  $$AudioSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get playbackRate => $composableBuilder(
    column: $table.playbackRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AudioSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioSessionsTableTable,
          AudioSessionsTableData,
          $$AudioSessionsTableTableFilterComposer,
          $$AudioSessionsTableTableOrderingComposer,
          $$AudioSessionsTableTableAnnotationComposer,
          $$AudioSessionsTableTableCreateCompanionBuilder,
          $$AudioSessionsTableTableUpdateCompanionBuilder,
          (
            AudioSessionsTableData,
            BaseReferences<
              _$AppDatabase,
              $AudioSessionsTableTable,
              AudioSessionsTableData
            >,
          ),
          AudioSessionsTableData,
          PrefetchHooks Function()
        > {
  $$AudioSessionsTableTableTableManager(
    _$AppDatabase db,
    $AudioSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AudioSessionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$AudioSessionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AudioSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<double> playbackRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AudioSessionsTableCompanion(
                id: id,
                messageId: messageId,
                lastPositionMs: lastPositionMs,
                playbackRate: playbackRate,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                Value<int> lastPositionMs = const Value.absent(),
                Value<double> playbackRate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AudioSessionsTableCompanion.insert(
                id: id,
                messageId: messageId,
                lastPositionMs: lastPositionMs,
                playbackRate: playbackRate,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioSessionsTableTable,
      AudioSessionsTableData,
      $$AudioSessionsTableTableFilterComposer,
      $$AudioSessionsTableTableOrderingComposer,
      $$AudioSessionsTableTableAnnotationComposer,
      $$AudioSessionsTableTableCreateCompanionBuilder,
      $$AudioSessionsTableTableUpdateCompanionBuilder,
      (
        AudioSessionsTableData,
        BaseReferences<
          _$AppDatabase,
          $AudioSessionsTableTable,
          AudioSessionsTableData
        >,
      ),
      AudioSessionsTableData,
      PrefetchHooks Function()
    >;
typedef $$AudioCuesTableTableCreateCompanionBuilder =
    AudioCuesTableCompanion Function({
      Value<int> id,
      required String messageId,
      required String paragraphKey,
      required int startMs,
      required int endMs,
    });
typedef $$AudioCuesTableTableUpdateCompanionBuilder =
    AudioCuesTableCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> paragraphKey,
      Value<int> startMs,
      Value<int> endMs,
    });

class $$AudioCuesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AudioCuesTableTable> {
  $$AudioCuesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paragraphKey => $composableBuilder(
    column: $table.paragraphKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioCuesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioCuesTableTable> {
  $$AudioCuesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paragraphKey => $composableBuilder(
    column: $table.paragraphKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioCuesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioCuesTableTable> {
  $$AudioCuesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get paragraphKey => $composableBuilder(
    column: $table.paragraphKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);
}

class $$AudioCuesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioCuesTableTable,
          AudioCuesTableData,
          $$AudioCuesTableTableFilterComposer,
          $$AudioCuesTableTableOrderingComposer,
          $$AudioCuesTableTableAnnotationComposer,
          $$AudioCuesTableTableCreateCompanionBuilder,
          $$AudioCuesTableTableUpdateCompanionBuilder,
          (
            AudioCuesTableData,
            BaseReferences<
              _$AppDatabase,
              $AudioCuesTableTable,
              AudioCuesTableData
            >,
          ),
          AudioCuesTableData,
          PrefetchHooks Function()
        > {
  $$AudioCuesTableTableTableManager(
    _$AppDatabase db,
    $AudioCuesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AudioCuesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$AudioCuesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AudioCuesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> paragraphKey = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
              }) => AudioCuesTableCompanion(
                id: id,
                messageId: messageId,
                paragraphKey: paragraphKey,
                startMs: startMs,
                endMs: endMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String paragraphKey,
                required int startMs,
                required int endMs,
              }) => AudioCuesTableCompanion.insert(
                id: id,
                messageId: messageId,
                paragraphKey: paragraphKey,
                startMs: startMs,
                endMs: endMs,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioCuesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioCuesTableTable,
      AudioCuesTableData,
      $$AudioCuesTableTableFilterComposer,
      $$AudioCuesTableTableOrderingComposer,
      $$AudioCuesTableTableAnnotationComposer,
      $$AudioCuesTableTableCreateCompanionBuilder,
      $$AudioCuesTableTableUpdateCompanionBuilder,
      (
        AudioCuesTableData,
        BaseReferences<_$AppDatabase, $AudioCuesTableTable, AudioCuesTableData>,
      ),
      AudioCuesTableData,
      PrefetchHooks Function()
    >;
typedef $$ContactOutboxTableCreateCompanionBuilder =
    ContactOutboxCompanion Function({
      Value<int> id,
      required String category,
      required String message,
      Value<String?> email,
      required String appVersion,
      required String platform,
      required String locale,
      Value<String?> deviceModel,
      required DateTime createdAt,
      Value<bool> synced,
    });
typedef $$ContactOutboxTableUpdateCompanionBuilder =
    ContactOutboxCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<String> message,
      Value<String?> email,
      Value<String> appVersion,
      Value<String> platform,
      Value<String> locale,
      Value<String?> deviceModel,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });

class $$ContactOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $ContactOutboxTable> {
  $$ContactOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactOutboxTable> {
  $$ContactOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactOutboxTable> {
  $$ContactOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ContactOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactOutboxTable,
          ContactOutboxData,
          $$ContactOutboxTableFilterComposer,
          $$ContactOutboxTableOrderingComposer,
          $$ContactOutboxTableAnnotationComposer,
          $$ContactOutboxTableCreateCompanionBuilder,
          $$ContactOutboxTableUpdateCompanionBuilder,
          (
            ContactOutboxData,
            BaseReferences<
              _$AppDatabase,
              $ContactOutboxTable,
              ContactOutboxData
            >,
          ),
          ContactOutboxData,
          PrefetchHooks Function()
        > {
  $$ContactOutboxTableTableManager(_$AppDatabase db, $ContactOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ContactOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ContactOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ContactOutboxTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => ContactOutboxCompanion(
                id: id,
                category: category,
                message: message,
                email: email,
                appVersion: appVersion,
                platform: platform,
                locale: locale,
                deviceModel: deviceModel,
                createdAt: createdAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required String message,
                Value<String?> email = const Value.absent(),
                required String appVersion,
                required String platform,
                required String locale,
                Value<String?> deviceModel = const Value.absent(),
                required DateTime createdAt,
                Value<bool> synced = const Value.absent(),
              }) => ContactOutboxCompanion.insert(
                id: id,
                category: category,
                message: message,
                email: email,
                appVersion: appVersion,
                platform: platform,
                locale: locale,
                deviceModel: deviceModel,
                createdAt: createdAt,
                synced: synced,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactOutboxTable,
      ContactOutboxData,
      $$ContactOutboxTableFilterComposer,
      $$ContactOutboxTableOrderingComposer,
      $$ContactOutboxTableAnnotationComposer,
      $$ContactOutboxTableCreateCompanionBuilder,
      $$ContactOutboxTableUpdateCompanionBuilder,
      (
        ContactOutboxData,
        BaseReferences<_$AppDatabase, $ContactOutboxTable, ContactOutboxData>,
      ),
      ContactOutboxData,
      PrefetchHooks Function()
    >;
typedef $$ContentReportsOutboxTableCreateCompanionBuilder =
    ContentReportsOutboxCompanion Function({
      Value<int> id,
      required int messageId,
      required String languageCode,
      required String reportType,
      Value<String?> comment,
      required String appVersion,
      required String platform,
      required String locale,
      required DateTime createdAt,
      Value<bool> synced,
    });
typedef $$ContentReportsOutboxTableUpdateCompanionBuilder =
    ContentReportsOutboxCompanion Function({
      Value<int> id,
      Value<int> messageId,
      Value<String> languageCode,
      Value<String> reportType,
      Value<String?> comment,
      Value<String> appVersion,
      Value<String> platform,
      Value<String> locale,
      Value<DateTime> createdAt,
      Value<bool> synced,
    });

class $$ContentReportsOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $ContentReportsOutboxTable> {
  $$ContentReportsOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportType => $composableBuilder(
    column: $table.reportType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentReportsOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentReportsOutboxTable> {
  $$ContentReportsOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportType => $composableBuilder(
    column: $table.reportType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentReportsOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentReportsOutboxTable> {
  $$ContentReportsOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportType => $composableBuilder(
    column: $table.reportType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ContentReportsOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentReportsOutboxTable,
          ContentReportsOutboxData,
          $$ContentReportsOutboxTableFilterComposer,
          $$ContentReportsOutboxTableOrderingComposer,
          $$ContentReportsOutboxTableAnnotationComposer,
          $$ContentReportsOutboxTableCreateCompanionBuilder,
          $$ContentReportsOutboxTableUpdateCompanionBuilder,
          (
            ContentReportsOutboxData,
            BaseReferences<
              _$AppDatabase,
              $ContentReportsOutboxTable,
              ContentReportsOutboxData
            >,
          ),
          ContentReportsOutboxData,
          PrefetchHooks Function()
        > {
  $$ContentReportsOutboxTableTableManager(
    _$AppDatabase db,
    $ContentReportsOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ContentReportsOutboxTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ContentReportsOutboxTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ContentReportsOutboxTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> reportType = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => ContentReportsOutboxCompanion(
                id: id,
                messageId: messageId,
                languageCode: languageCode,
                reportType: reportType,
                comment: comment,
                appVersion: appVersion,
                platform: platform,
                locale: locale,
                createdAt: createdAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int messageId,
                required String languageCode,
                required String reportType,
                Value<String?> comment = const Value.absent(),
                required String appVersion,
                required String platform,
                required String locale,
                required DateTime createdAt,
                Value<bool> synced = const Value.absent(),
              }) => ContentReportsOutboxCompanion.insert(
                id: id,
                messageId: messageId,
                languageCode: languageCode,
                reportType: reportType,
                comment: comment,
                appVersion: appVersion,
                platform: platform,
                locale: locale,
                createdAt: createdAt,
                synced: synced,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentReportsOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentReportsOutboxTable,
      ContentReportsOutboxData,
      $$ContentReportsOutboxTableFilterComposer,
      $$ContentReportsOutboxTableOrderingComposer,
      $$ContentReportsOutboxTableAnnotationComposer,
      $$ContentReportsOutboxTableCreateCompanionBuilder,
      $$ContentReportsOutboxTableUpdateCompanionBuilder,
      (
        ContentReportsOutboxData,
        BaseReferences<
          _$AppDatabase,
          $ContentReportsOutboxTable,
          ContentReportsOutboxData
        >,
      ),
      ContentReportsOutboxData,
      PrefetchHooks Function()
    >;
typedef $$AnalyticsEventQueueTableCreateCompanionBuilder =
    AnalyticsEventQueueCompanion Function({
      required String clientEventId,
      required String occurredAt,
      required String eventName,
      required String payloadJson,
      Value<int> attempts,
      Value<int?> nextRetryAt,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AnalyticsEventQueueTableUpdateCompanionBuilder =
    AnalyticsEventQueueCompanion Function({
      Value<String> clientEventId,
      Value<String> occurredAt,
      Value<String> eventName,
      Value<String> payloadJson,
      Value<int> attempts,
      Value<int?> nextRetryAt,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$AnalyticsEventQueueTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyticsEventQueueTable> {
  $$AnalyticsEventQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientEventId => $composableBuilder(
    column: $table.clientEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnalyticsEventQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyticsEventQueueTable> {
  $$AnalyticsEventQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientEventId => $composableBuilder(
    column: $table.clientEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnalyticsEventQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyticsEventQueueTable> {
  $$AnalyticsEventQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientEventId => $composableBuilder(
    column: $table.clientEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventName =>
      $composableBuilder(column: $table.eventName, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AnalyticsEventQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalyticsEventQueueTable,
          AnalyticsQueueEntry,
          $$AnalyticsEventQueueTableFilterComposer,
          $$AnalyticsEventQueueTableOrderingComposer,
          $$AnalyticsEventQueueTableAnnotationComposer,
          $$AnalyticsEventQueueTableCreateCompanionBuilder,
          $$AnalyticsEventQueueTableUpdateCompanionBuilder,
          (
            AnalyticsQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $AnalyticsEventQueueTable,
              AnalyticsQueueEntry
            >,
          ),
          AnalyticsQueueEntry,
          PrefetchHooks Function()
        > {
  $$AnalyticsEventQueueTableTableManager(
    _$AppDatabase db,
    $AnalyticsEventQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AnalyticsEventQueueTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$AnalyticsEventQueueTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AnalyticsEventQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clientEventId = const Value.absent(),
                Value<String> occurredAt = const Value.absent(),
                Value<String> eventName = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int?> nextRetryAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnalyticsEventQueueCompanion(
                clientEventId: clientEventId,
                occurredAt: occurredAt,
                eventName: eventName,
                payloadJson: payloadJson,
                attempts: attempts,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientEventId,
                required String occurredAt,
                required String eventName,
                required String payloadJson,
                Value<int> attempts = const Value.absent(),
                Value<int?> nextRetryAt = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AnalyticsEventQueueCompanion.insert(
                clientEventId: clientEventId,
                occurredAt: occurredAt,
                eventName: eventName,
                payloadJson: payloadJson,
                attempts: attempts,
                nextRetryAt: nextRetryAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnalyticsEventQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalyticsEventQueueTable,
      AnalyticsQueueEntry,
      $$AnalyticsEventQueueTableFilterComposer,
      $$AnalyticsEventQueueTableOrderingComposer,
      $$AnalyticsEventQueueTableAnnotationComposer,
      $$AnalyticsEventQueueTableCreateCompanionBuilder,
      $$AnalyticsEventQueueTableUpdateCompanionBuilder,
      (
        AnalyticsQueueEntry,
        BaseReferences<
          _$AppDatabase,
          $AnalyticsEventQueueTable,
          AnalyticsQueueEntry
        >,
      ),
      AnalyticsQueueEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$TranslationsTableTableManager get translations =>
      $$TranslationsTableTableManager(_db, _db.translations);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ReadingSettingsTableTableTableManager get readingSettingsTable =>
      $$ReadingSettingsTableTableTableManager(_db, _db.readingSettingsTable);
  $$ReadingProgressTableTableTableManager get readingProgressTable =>
      $$ReadingProgressTableTableTableManager(_db, _db.readingProgressTable);
  $$AudioProgressTableTableTableManager get audioProgressTable =>
      $$AudioProgressTableTableTableManager(_db, _db.audioProgressTable);
  $$BookmarksTableTableTableManager get bookmarksTable =>
      $$BookmarksTableTableTableManager(_db, _db.bookmarksTable);
  $$HighlightsTableTableTableManager get highlightsTable =>
      $$HighlightsTableTableTableManager(_db, _db.highlightsTable);
  $$AudioSessionsTableTableTableManager get audioSessionsTable =>
      $$AudioSessionsTableTableTableManager(_db, _db.audioSessionsTable);
  $$AudioCuesTableTableTableManager get audioCuesTable =>
      $$AudioCuesTableTableTableManager(_db, _db.audioCuesTable);
  $$ContactOutboxTableTableManager get contactOutbox =>
      $$ContactOutboxTableTableManager(_db, _db.contactOutbox);
  $$ContentReportsOutboxTableTableManager get contentReportsOutbox =>
      $$ContentReportsOutboxTableTableManager(_db, _db.contentReportsOutbox);
  $$AnalyticsEventQueueTableTableManager get analyticsEventQueue =>
      $$AnalyticsEventQueueTableTableManager(_db, _db.analyticsEventQueue);
}
