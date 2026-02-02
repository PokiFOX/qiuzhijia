import json
import os
import shutil

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
	projectdata['setting']['appid'] = 'wx5335f863950c8aa4'
	projectdata['setting']['projectname'] = '求职家小程序'
	projectdata['appid'] = 'wx5335f863950c8aa4'
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
