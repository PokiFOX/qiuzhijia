import 'package:frontend/tapah/reserved.dart';

String parseimage(String name) {
	return '$urlheader/images/$name';
}

String parseurl(String url) {
	var prefix = backendPathPrefix.trim();
	if (prefix.startsWith('/')) {
		prefix = prefix.substring(1);
	}
	while (prefix.endsWith('/') && prefix.isNotEmpty) {
		prefix = prefix.substring(0, prefix.length - 1);
	}
	final path = prefix.isEmpty ? url : '$prefix/$url';
	return 'https://$backendHost:$backendPort/$path';
}
