import os
import json
import subprocess

from pyrsistent import s


def cleanBenData():
    with open(".\\ben_features.json") as f:
        data = json.loads(f.read())
    
    new_tag = data
    for key in list(data):
        tag = data[key]
        if "CodeInjection" in tag or "NegativeContext" in tag or "Ransomware" in tag or "MaliciousBehaviorCombo" in tag or "Disabled Protections" in tag or "Coin Miner" in tag or "Embedded File" in tag:
            new_tag.pop(key)
        else:
            if tag[-1].find("KnownMalware") != -1 :
                new_tag.pop(key)

    with open('ben_features.json', 'w') as f:
        f.write(json.dumps(new_tag))


def cleanContent(output):
    if output[2].find("Unknown") == -1:
        f_list = output[-1].strip(' [').strip(']').split("|")
        fea_list = []
        for f in f_list:
            fea = f.replace(" ","")[0:f.replace(" ","").find("-")]
            fea_list.append(fea)
        return fea_list
    else:
        return None


def getFeature(path):
    result = {}
    dir_list = os.listdir(path)
    for file in dir_list:
        try:
            p1 = subprocess.check_output(["python", "PowerShellProfiler.py", "-f", path+file])
            output = p1.decode('utf-8').strip('\r\n').split(',')
            fea_list = cleanContent(output)
            if fea_list != None:
                result[file] = fea_list
        except:
            pass
    return result
    

def main():
    # ben_path = "..\\1_raw_benign_scripts\\" 
    # ben_features = getFeature(ben_path)
    # with open('ben_features.json', 'w') as f:
    #     f.write(json.dumps(ben_features))

    # cleanBenData()

    mal_path = "..\\1_raw_malicious_scripts\\"
    mal_features = getFeature(mal_path)
    with open('mal_features.json', 'w') as f:
        f.write(json.dumps(mal_features))

    

if __name__ == '__main__':
    main()
