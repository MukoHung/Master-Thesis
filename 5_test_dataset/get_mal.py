import shutil
import re
import json
import subprocess

# def cleanContent(output):
#     if output[2].find("Unknown") == -1:
#         f_list = output[-1].strip(' [').strip(']').split("|")
#         fea_list = []
#         for f in f_list:
#             fea = f.replace(" ","")[0:f.replace(" ","").find("-")]
#             fea_list.append(fea)
#         return fea_list
#     else:
#         return None

# with open("..\\2_data_preprocessing\\ben_features.json") as f:
#         data = json.loads(f.read())

# Regex = re.compile(r'_\d*')
# key_list = []
# for key in data:
#     number = Regex.findall(key)
#     key_list.append(number[0][1:])

# is_mal = []
# for n in range(5189):
#     if str(n) not in key_list:
#         is_mal.append(str(n))


# fea_dict = {}
# for n in is_mal:
#     path = "..\\1_raw_benign_scripts\\"
#     name = "ben_" + n + ".ps1"
#     try:
#         p1 = subprocess.check_output(["python", "..\\2_data_preprocessing\\PowerShellProfiler.py", "-f", path + name])
#         output = p1.decode('utf-8').strip('\r\n').split(',')
#         fea_list = cleanContent(output)
#         if fea_list != None:
#             fea_dict[name] = fea_list
#     except:
#         pass

# print(fea_dict)

with open("..\\5_test_dataset\\123.json") as f:
        data = json.loads(f.read())

for n in data:
    src = "..\\1_raw_benign_scripts\\"+n
    dst = ".\\mal-2\\"+n
    shutil.copyfile(src, dst)