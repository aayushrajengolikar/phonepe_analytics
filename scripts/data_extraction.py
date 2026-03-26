import os
import json
import pandas as pd

base_path = "pulse/data/"

# ------------------ AGGREGATED TRANSACTION ------------------
agg_trans_data = []
path = base_path + "aggregated/transaction/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    for item in content["data"]["transactionData"]:
                        for payment in item["paymentInstruments"]:
                            agg_trans_data.append([
                                state, int(year), int(file.strip(".json")),
                                item["name"], payment["count"], payment["amount"]
                            ])
                except:
                    pass

df = pd.DataFrame(agg_trans_data, columns=[
    "state","year","quarter","transaction_type","transaction_count","transaction_amount"
])
df.to_csv("aggregated_transaction.csv", index=False)


# ------------------ AGGREGATED INSURANCE ------------------
agg_ins_data = []
path = base_path + "aggregated/insurance/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    for item in content["data"]["transactionData"]:
                        for payment in item["paymentInstruments"]:
                            agg_ins_data.append([
                                state, int(year), int(file.strip(".json")),
                                item["name"], payment["count"], payment["amount"]
                            ])
                except:
                    pass

df = pd.DataFrame(agg_ins_data, columns=[
    "state","year","quarter","insurance_type","insurance_count","insurance_amount"
])
df.to_csv("aggregated_insurance.csv", index=False)


# ------------------ AGGREGATED USER ------------------
agg_user_data = []
path = base_path + "aggregated/user/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    agg_user_data.append([
                        state,
                        int(year),
                        int(file.strip(".json")),
                        content["data"]["aggregated"]["registeredUsers"],
                        content["data"]["aggregated"]["appOpens"]
                    ])
                except:
                    pass

df = pd.DataFrame(agg_user_data, columns=[
    "state","year","quarter","registered_users","app_opens"
])
df.to_csv("aggregated_user.csv", index=False)


# ------------------ MAP TRANSACTION ------------------
map_trans_data = []
path = base_path + "map/transaction/hover/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    for item in content["data"]["hoverDataList"]:
                        map_trans_data.append([
                            state,
                            int(year),
                            int(file.strip(".json")),
                            item["name"],
                            item["metric"][0]["count"],
                            item["metric"][0]["amount"]
                        ])
                except:
                    pass

df = pd.DataFrame(map_trans_data, columns=[
    "state","year","quarter","district","transaction_count","transaction_amount"
])
df.to_csv("map_transaction.csv", index=False)


# ------------------ MAP USER ------------------
map_user_data = []
path = base_path + "map/user/hover/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    for district, values in content["data"]["hoverData"].items():
                        map_user_data.append([
                            state,
                            int(year),
                            int(file.strip(".json")),
                            district,
                            values["registeredUsers"],
                            values["appOpens"]
                        ])
                except:
                    pass

df = pd.DataFrame(map_user_data, columns=[
    "state","year","quarter","district","registered_users","app_opens"
])
df.to_csv("map_user.csv", index=False)


# ------------------ TOP TRANSACTION ------------------
top_trans_data = []
path = base_path + "top/transaction/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    for item in content["data"]["pincodes"]:
                        top_trans_data.append([
                            state,
                            int(year),
                            int(file.strip(".json")),
                            item["entityName"],
                            item["metric"]["count"],
                            item["metric"]["amount"]
                        ])
                except:
                    pass

df = pd.DataFrame(top_trans_data, columns=[
    "state","year","quarter","entity_name","transaction_count","transaction_amount"
])
df.to_csv("top_transaction.csv", index=False)


# ------------------ TOP USER ------------------
top_user_data = []
path = base_path + "top/user/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    for item in content["data"]["pincodes"]:
                        top_user_data.append([
                            state,
                            int(year),
                            int(file.strip(".json")),
                            item["name"],
                            item["registeredUsers"]
                        ])
                except:
                    pass

df = pd.DataFrame(top_user_data, columns=[
    "state","year","quarter","entity_name","registered_users"
])
df.to_csv("top_user.csv", index=False)


# ------------------ TOP INSURANCE ------------------
top_ins_data = []
path = base_path + "top/insurance/country/india/state/"

for state in os.listdir(path):
    for year in os.listdir(path + state):
        for file in os.listdir(path + state + "/" + year):
            with open(path + state + "/" + year + "/" + file, 'r') as f:
                content = json.load(f)
                try:
                    for item in content["data"]["pincodes"]:
                        top_ins_data.append([
                            state,
                            int(year),
                            int(file.strip(".json")),
                            item["entityName"],
                            item["metric"]["amount"]
                        ])
                except:
                    pass

df = pd.DataFrame(top_ins_data, columns=[
    "state","year","quarter","entity_name","insurance_amount"
])
df.to_csv("top_insurance.csv", index=False)


print("🔥 ALL CSV FILES CREATED SUCCESSFULLY!")
import os
print("Files saved in:", os.getcwd())