import json
from multiprocessing import cpu_count

with open("../0_crawler_and_rawdata/ps_encodedcommand_data.txt", 'rb') as f:
    all_data = str(f.read()).split("##################### START #########################")
    all_data.pop(0)
    all_data[-1] = all_data[-1][0:all_data[-1].find("#########################  END  #########################")]

# 完整資料
# {filename: {"orig_code": orig_code, "Args": Args, "b64_decode": b64_decode, "family_name": family_name}}
'''
for file in all_data:
    file_list = file.split('\\n\\n')
    file_name = file_list[file_list.index("[Filename]")+1]
    orig_code = file_list[file_list.index("[Original Code]")+1].replace('\\\\','\\')
    Args = file_list[file_list.index("[Arguments]")+1].replace('\\\'','').strip('[').strip(']').split(',')
    b64_decode = file_list[file_list.index("[B64 Decoded]")+1].replace('\\','')
    family_name = file_list[file_list.index("[Family Name]")+1]
    info = {"orig_code": orig_code, "Args": Args, "b64_decode": b64_decode, "family_name": family_name}
    data_json[file_name] = info

with open("../1_raw_malicious_scripts/ps_encodedcommand_data.json", 'w') as f:
    f.write(json.dumps(data_json))
'''

# 只抓解混淆過的腳本
# {filename: b64_decode} 

count = 0
for file in all_data:
    file_list = file.split('\\n\\n')
    b64_decode = file_list[file_list.index("[B64 Decoded]")+1].replace('\\','')

    with open("../1_raw_malicious_scripts/mal_"+ str(count) +".ps1", 'w') as f:
        f.write(str(b64_decode))

    count += 1

    
