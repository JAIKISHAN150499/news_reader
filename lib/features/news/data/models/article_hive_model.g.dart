
part of 'article_hive_model.dart';


class ArticleHiveModelAdapter extends TypeAdapter<ArticleHiveModel> {
  @override
  final typeId = 0;

  @override
  ArticleHiveModel read(BinaryReader reader) {
    reader.readByte();
    return ArticleHiveModel();
  }

  @override
  void write(BinaryWriter writer, ArticleHiveModel obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
