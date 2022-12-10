import requests
import openai
import json

with open('config.json', 'r') as jsonfile:
  json_string = json.load(jsonfile)
  api_key = json_string['api_key']

openai.api_key = api_key

def reply_msg(msg):
    completion = openai.Completion.create(
        model="text-davinci-003",
        prompt=f"{msg}",
        max_tokens=2048,
        temperature=0.7,
        top_p=1,
        presence_penalty=0,
        frequency_penalty=0
    )

    if completion.choices[0].text[0:1]=='\n':
        return completion.choices[0].text[2:]
    else:
        return completion.choices[0].text

def keyword(msg, uid, gid):
    if gid is None:
        send_private_msg(msg,uid)
    if gid:
        send_group_msg(msg,gid)
def send_private_msg(msg,uid):
    res = reply_msg(msg)
    url = "http://127.0.0.1:5700/send_private_msg"
    data = {
        "user_id": uid,
        "message": f"{res}"
    }
    try:
        requests.post(url, data=data, timeout=5)
    except:
        pass
def send_group_msg(msg,gid):
    res = reply_msg(msg)
    url = "http://127.0.0.1:5700/send_group_msg"
    data = {
        "group_id": gid,
        "message": f"{res}"
    }
    try:
        requests.post(url, data=data, timeout=5)
    except:
        pass
