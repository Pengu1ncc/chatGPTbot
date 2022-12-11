from flask import Flask, request
import json
from api import keyword
with open('config.json', 'r') as jsonfile:
  json_string = json.load(jsonfile)
  qq_code = json_string['qq_code']

app = Flask(__name__)

'''监听端口，获取QQ信息'''
@app.route('/', methods=["POST"])
def post_data():
    data = request.get_json()
    uid = data.get('user_id')
    msg = data.get('raw_message')
    if data.get('message_type') == 'private':
        keyword(msg, uid, gid=None)
    elif data.get('message_type') == 'group'and f"[CQ:at,qq={qq_code}]" in data.get('raw_message'):
        gid = data.get('group_id')
        keyword(msg, uid, gid)
    return 'OK'

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5701)