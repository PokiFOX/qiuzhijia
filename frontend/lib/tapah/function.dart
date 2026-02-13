import 'package:frontend/tapah/reserved.dart';

String parseimage(String name) {
	return '$urlheader/images/$name';
}

String parseurl(String url) {
	return 'http://$backendHost:$backendPort/$url';
}
