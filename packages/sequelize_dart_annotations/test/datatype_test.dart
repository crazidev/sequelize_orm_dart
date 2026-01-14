import 'package:sequelize_dart_annotations/src/datatype.dart';
import 'package:test/test.dart';

void main() {
  group('IntegerDataType', () {
    test('Default INTEGER should have correct name and no extras', () {
      const type = DataType.INTEGER;
      expect(type.name, equals('INTEGER'));
      expect(type.toString(), equals('INTEGER'));
    });

    test('INTEGER(10) should have length but no extras', () {
      final type = DataType.INTEGER(10);
      expect(type.toString(), equals('INTEGER(10)'));
    });

    test('INTEGER.UNSIGNED should have UNSIGNED suffix', () {
      final type = DataType.INTEGER.UNSIGNED;
      expect(type.toString(), equals('INTEGER UNSIGNED'));
    });

    test('INTEGER(10).UNSIGNED.ZEROFILL should have everything', () {
      final type = DataType.INTEGER(10).UNSIGNED.ZEROFILL;
      expect(type.toString(), equals('INTEGER(10) UNSIGNED ZEROFILL'));
    });

    test('Equality and HashCode', () {
      expect(
        DataType.INTEGER(10).UNSIGNED,
        equals(DataType.INTEGER(10).UNSIGNED),
      );
      expect(
        DataType.INTEGER(10).UNSIGNED.hashCode,
        equals(DataType.INTEGER(10).UNSIGNED.hashCode),
      );
      expect(DataType.INTEGER(5), isNot(equals(DataType.INTEGER(10))));
    });
  });

  group('DecimalDataType', () {
    test('DECIMAL(10, 2) should have precision and scale', () {
      final type = DataType.DECIMAL(10, 2);
      expect(type.toString(), equals('DECIMAL(10, 2)'));
    });

    test('DECIMAL(10, 2).UNSIGNED.ZEROFILL should have everything', () {
      final type = DataType.DECIMAL(10, 2).UNSIGNED.ZEROFILL;
      expect(type.toString(), equals('DECIMAL(10, 2) UNSIGNED ZEROFILL'));
    });

    test('Equality', () {
      expect(
        DataType.DECIMAL(10, 2).UNSIGNED,
        equals(DataType.DECIMAL(10, 2).UNSIGNED),
      );
      expect(
        DataType.DECIMAL(10, 2).UNSIGNED,
        isNot(equals(DataType.DECIMAL(10, 1).UNSIGNED)),
      );
    });
  });

  group('StringDataType', () {
    test('STRING(255) BINARY', () {
      final type = DataType.STRING(255).BINARY;
      expect(type.toString(), equals('STRING(255) BINARY'));
    });

    test('CHAR(10)', () {
      final type = DataType.CHAR(10);
      expect(type.toString(), equals('CHAR(10)'));
    });
  });

  group('TextDataType', () {
    test('TEXT variants', () {
      expect(DataType.TEXT.tiny.toString(), equals("TEXT('tiny')"));
      expect(DataType.TEXT.medium.toString(), equals("TEXT('medium')"));
      expect(DataType.TEXT.long.toString(), equals("TEXT('long')"));
      expect(DataType.TEXT.toString(), equals('TEXT'));
    });
  });

  group('BlobDataType', () {
    test('BLOB variants', () {
      expect(DataType.BLOB.tiny.toString(), equals("BLOB('tiny')"));
      expect(DataType.BLOB.medium.toString(), equals("BLOB('medium')"));
      expect(DataType.BLOB.long.toString(), equals("BLOB('long')"));
    });
  });

  group('StandardDataType', () {
    test('BOOLEAN, DATE, UUID', () {
      expect(DataType.BOOLEAN.toString(), equals('BOOLEAN'));
      expect(DataType.DATE.toString(), equals('DATE'));
      expect(DataType.UUID.toString(), equals('UUID'));
    });
  });
}
