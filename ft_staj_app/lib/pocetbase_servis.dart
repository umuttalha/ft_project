import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

class PocetbaseServis {
  final pb = PocketBase(dotenv.env['BACKEND_URL'] ?? 'http://localhost:8090');
}
