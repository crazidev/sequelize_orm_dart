abstract class SqlExpression {
  Map<String, dynamic> toJson();
}

class SqlFn extends SqlExpression {
  final String fn;
  final List<dynamic>? args;

  SqlFn(this.fn, [this.args]);

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': 'fn',
      'fn': fn,
      'args': args?.map((arg) {
        if (arg is SqlExpression) {
          return arg.toJson();
        }
        return arg;
      }).toList(),
    };
  }
}

class SqlCol extends SqlExpression {
  final String col;

  SqlCol(this.col);

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': 'col',
      'col': col,
    };
  }
}

class SqlLiteral extends SqlExpression {
  final String value;

  SqlLiteral(this.value);

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': 'literal',
      'value': value,
    };
  }
}

class SqlAttribute extends SqlExpression {
  final String attribute;

  SqlAttribute(this.attribute);

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': 'attribute',
      'attribute': attribute,
    };
  }
}

class SqlIdentifier extends SqlExpression {
  final String identifier;

  SqlIdentifier(this.identifier);

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': 'identifier',
      'identifier': identifier,
    };
  }
}

class SqlCast extends SqlExpression {
  final dynamic expression;
  final String type;

  SqlCast(this.expression, this.type);

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': 'cast',
      'expression': expression is SqlExpression
          ? expression.toJson()
          : expression,
      'type': type,
    };
  }
}

class SqlRandom extends SqlExpression {
  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': 'random',
    };
  }
}
