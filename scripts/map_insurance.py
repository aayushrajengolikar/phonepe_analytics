# ------------------ MAP INSURANCE ------------------
import os
import json
import pandas as pd

base_path = "pulse/data/"
map_ins_data = []
path = base_path + "map/insurance/hover/country/india/state/"

for state in os.listdir(path):
    state_path = os.path.join(path, state)

    for year in os.listdir(state_path):
        year_path = os.path.join(state_path, year)

        for file in os.listdir(year_path):
            file_path = os.path.join(year_path, file)

            with open(file_path, 'r') as f:
                content = json.load(f)

                try:
                    for item in content["data"]["hoverDataList"]:
                        map_ins_data.append([
                            state,
                            int(year),
                            int(file.strip(".json")),
                            item["name"],
                            item["metric"][0]["count"],
                            item["metric"][0]["amount"]
                        ])
                except:
                    pass

df = pd.DataFrame(map_ins_data, columns=[
    "state","year","quarter","district","insurance_count","insurance_amount"
])

df.to_csv("map_insurance.csv", index=False)