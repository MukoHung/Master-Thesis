import os


file_path = '..\\1_raw_benign_scripts\\'
files_list = os.listdir(file_path)
count = 0
for file in files_list:
    #os.rename(file_path+file, file_path+"ben_"+str(count)+".ps1")
    count+=1
