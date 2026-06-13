import 'package:frontend/tapah/reserved.dart';

String parseimage(String name) {
	return '$urlheader/images/$name';
}

String parseurl(String url) {
	return 'https://$backendHost:$backendPort/$url';
}
