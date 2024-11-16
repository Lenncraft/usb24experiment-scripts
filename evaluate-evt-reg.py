# all saved results have to be located in ./exp/
# text file with Registry Keys to ignore located at ./eval.ignore
import pandas as pd
from tqdm import tqdm

evt_logs = source_types = [
    "application.csv",
    "system.csv",
    "security.csv"
]
registry_diff_file = "~res-x64.txt"
ID_REGISTRY_FILE = "REG"
stages = [
    "/init/",
    "/mid/",
    "/final/",
    "/reboot/"
]

path_compare_1 = input("Enter 1. run (eg. lan-1): ")
path_compare_2 = input("Enter 2. run (eg. lan-2): ")

paths_compare = ["exp/"+path_compare_1,"exp/"+path_compare_2]

raw_dfs = {}
# Start
for dir_path in paths_compare:
    print("Reading "+dir_path)
    hits = {}
    raw_dfs[dir_path] = {}
    for stage in tqdm(stages):
        raw_dfs[dir_path][stage] = {}
        for file_name in evt_logs:
            raw_dfs[dir_path][stage][file_name] = pd.read_csv(dir_path+stage+file_name, encoding = 'cp1252').drop_duplicates(keep='first')
        if not stage == stages[0]:
            with open(dir_path+stage+registry_diff_file,encoding='utf-16-le') as f:
                raw_dfs[dir_path][stage][ID_REGISTRY_FILE] = f.readlines()


# Lookup Targets
scan_evtx: list[int] = [
    # Fill in EventIDs here! Example:
    20003
]

scan_reg = [
    #Fill in Registry Keys here! Example:
    "HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceClasses"
]

ignore_reg:list[str] = []
with open("eval.ignore","r")as ignorefile:
    ignore_reg = ignorefile.readlines()

hits_evtx = []
hits_reg = {}

# Writing File_output
def writeToFile(filename: str, content: list[str]):
    with open("eval-out_"+filename,"w") as file:
        file.writelines(content)


# Scan Evtx
print("Scanning Event Logs by ID")
for dir_path in paths_compare:
    for evtx in evt_logs:
        tqdm_counter: int = 0
        diff = pd.concat([raw_dfs[dir_path][stages[0]][evtx],raw_dfs[dir_path][stages[3]][evtx]]).drop_duplicates(keep=False)
        res = diff.loc[diff['EventID'].isin(scan_evtx)]
        writeToFile(dir_path.split("/")[1]+evtx,res.to_csv())
    
for dir_path in paths_compare:
    break
    for evtx in evt_logs:
        diff = pd.concat([raw_dfs[dir_path][stages[0]][evtx],raw_dfs[dir_path][stages[3]][evtx]]).drop_duplicates(keep=False)
        pbar = tqdm(diff.iterrows(),total=len(diff.index))
        tqdm_counter: int = 0
        for index, row in pbar:
            raw_text_line = row.to_csv().replace('\n', '')
            for scan_obj in scan_evtx:
                if scan_obj in raw_text_line:
                    hits_evtx.append(raw_text_line)
                    tqdm_counter+=1
                pbar.set_description("Found "+str(counter)+" Hits")
        pbar.close()

print("Scanning Registry")
for dir_path in paths_compare:
    hits_reg[dir_path] = []
    pbar = tqdm(raw_dfs[dir_path][stages[3]][ID_REGISTRY_FILE],total=len(raw_dfs[dir_path][stages[3]][ID_REGISTRY_FILE]))
    tqdm_counter: int = 0
    for line in pbar:
        for scan_obj in scan_reg:
            if (scan_obj in line) and (not line in ignore_reg):
                hits_reg[dir_path].append(line)
                tqdm_counter+=1
                pbar.set_description("Found "+str(tqdm_counter)+" Hits")
                break # find only once
    pbar.close()
hits_reg["STABLE"] = []
for line in tqdm(hits_reg[paths_compare[0]],desc="Comparing"): #There are no Timestamps in lines
    if line in hits_reg[paths_compare[1]]:
        hits_reg["STABLE"].append(line)

print("Stable in Registry: "+str(len(hits_reg["STABLE"])))


writeToFile("reg-stable",hits_reg["STABLE"])
writeToFile("reg-one",hits_reg[paths_compare[0]])
writeToFile("reg-two",hits_reg[paths_compare[1]])
print("### done ###")
raw_dfs = 0
hits_reg = 0
