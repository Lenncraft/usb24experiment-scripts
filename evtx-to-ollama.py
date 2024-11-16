from ollama import Client
import pandas as pd
from tqdm import tqdm

ollama_model = '' # Enter model name here!

source_types = [
    "application",
    "system",
    "security"
]

client = Client(host='http://localhost:11434')
relevant_lines = []

source_path = input("Input folder name (e.g. dryrun-1): ")

for source_type in source_types:
    df1 = pd.read_csv("exp/"+source_path+"/init/"+source_type+".csv", encoding = 'cp1252').drop_duplicates(keep='first')
    df2 = pd.read_csv("exp/"+source_path+"/reboot/"+source_type+".csv", encoding = 'cp1252').drop_duplicates(keep='first')

    print()
    diff = pd.concat([df1,df2]).drop_duplicates(keep=False)
    print(diff)
    print()


    df_result = pd.DataFrame()
    pbar = tqdm(diff.iterrows(),total=len(diff.index))

    counter: int = 0

    with open("output-"+source_path+"-"+source_type+".csv", 'a') as output_file:
        for index, row in pbar:
            text_line = row.to_csv().replace('\n', '')

            response = client.chat(model=ollama_model, messages=[
            {
                'role': 'system',
                'content': 'You are an analyst for forensic Windows aritfacts. You will only respond with YES or NO.',
            },
            {
                'role': 'user',
                'content': 'The following is a line from the Windows '+source_type+' in a german system, respond with YES if this line is relevant for USB identification: '+text_line,
            },
            ])
        #    print(response["message"]["content"])
            if "YES" in response["message"]["content"]:
                relevant_lines.append(text_line)
    #           df_result.append(row)
                output_file.write(text_line+"\n")
                counter+=1
                pbar.set_description("Found "+str(counter)+" Hits")
            elif "NO" in response["message"]["content"]:
                pbar.set_description("Found "+str(counter)+" Hits")
            else:
                print("[ERROR] Invalid response! Defaulting to relevant.")
                output_file.write(text_line+"\n")
                #break

print("------DONE-----")
