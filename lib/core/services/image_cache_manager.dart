import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsImageCacheManager extends CacheManager with ImageCacheManager {
  static NewsImageCacheManager? _instance;
  static NewsImageCacheManager get instance {
    _instance ??= NewsImageCacheManager._();
    return _instance!;
  }

  static const String _cacheKey = 'news_image_cache';

  NewsImageCacheManager._()
      : super(
    Config(
      _cacheKey,
      stalePeriod: Duration(
        days: int.parse(dotenv.env['CACHE_MAX_AGE_DAYS'] ?? '7'),
      ),
      maxNrOfCacheObjects: int.parse(
        dotenv.env['CACHE_MAX_SIZE_MB'] ?? '100',
      ),
      repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      fileService: HttpFileService(),
    ),
  );

  Future<bool> isExpired(String url) async {
    final info = await getFileFromCache(url);
    if (info == null) return true;

    final age = DateTime.now().difference(info.validTill);
    return age.isNegative ? false : true;
  }
}