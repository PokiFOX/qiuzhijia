import datetime
import json
import os
import shutil
import zipfile

shutil.copyfile('./main.wechat', 'miniapp/lib/main.dart')
os.chdir('miniapp')
os.system('dart scripts/build_wechat.dart')

with open('build/wechat/app.json', 'r') as f:
    appdata = json.loads(f.read())
    appdata['window']['navigationBarTitleText'] = '求职家小程序'
with open('build/wechat/app.json', 'w') as f:
    f.write(json.dumps(appdata, ensure_ascii = False, indent = '\t'))

with open('build/wechat/project.config.json', 'r') as f:
	projectdata = json.loads(f.read())
	projectdata['setting']['appid'] = 'wxb0b1ae0733a3c160'
	projectdata['setting']['projectname'] = '求职家小程序'
	projectdata['appid'] = 'wxb0b1ae0733a3c160'
	projectdata['projectname'] = '求职家小程序'
with open('build/wechat/project.config.json', 'w') as f:
	f.write(json.dumps(projectdata, ensure_ascii = False, indent = '\t'))

with open('build/wechat/pages/index/index.json', 'r') as f:
	indexdata = json.loads(f.read())
	indexdata['pageOrientation'] = 'portrait'
 
with open('build/wechat/pages/index/index.json', 'w') as f:
	f.write(json.dumps(indexdata, ensure_ascii = False, indent = '\t'))

os.chdir('..')
shutil.copyfile('./main.web', 'miniapp/lib/main.dart')

with zipfile.ZipFile(f'wechat.{datetime.datetime.now().strftime("%Y%m%d.%H%M")}.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
	for root, dirs, files in os.walk('miniapp/build/wechat'):
		for file in files:
			file_path = os.path.join(root, file)
			arcname = os.path.relpath(file_path, 'miniapp/build')
			zipf.write(file_path, arcname)
