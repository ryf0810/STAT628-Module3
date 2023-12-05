# Create label file for customized image dataloader
import pandas as pd
import numpy as np
import os
from PIL import Image

def generate(start_folder, data):
    df = pd.DataFrame()
    path_lst = []
    label_lst = []
    if os.path.exists(start_folder):
        for root, dirs, files in os.walk(start_folder, topdown=True):
            folder_name = str(root).split('/')[-1]
            # the car image subfolders are named by integers, correpond the ID in data.csv
            if folder_name.isdigit():
                folder_name = int(folder_name)
                if folder_name in data['ID'].values:
                    row_idx = data.index[data['ID']==folder_name].tolist()[0]
                    label = data.loc[row_idx, 'Manufacturer']

                    # ignore labels are not english and nan
                    if (label not in ['90', 'სხვა']): # do not consider these two
                        for file in files:
                            path = 'images/' + str(folder_name) +'/' + file
                            path_lst.append(path)
                            label_lst.append(label)

        cars = np.unique(label_lst).tolist()
        idx_lst = list(range(len(cars)))
        mapping_dict = {car: num for car, num in zip(cars, idx_lst)}

        new_label = []
        for car in label_lst:
            new_label.append(mapping_dict[car])

        df['path'] = path_lst
        df['encoded_label'] = new_label
        df['original_label'] = label_lst


        # remove all the damaged image paths
        rows_to_drop = []
        for i in range(len(df)):
            try:
                img_path = os.path.join('./data/carImages/', df.loc[i, 'path'])
                img = Image.open(img_path).convert('RGB')
            except:
                # drop the corresponding column based on the row idx
                rows_to_drop.append(i)

        new_cars = df.drop(index=rows_to_drop, inplace=False) # inplcae=F returns a copy
        new_cars.to_csv('./data/cars.csv', header=True, index=False) # do not write column names and row index
        print(f'Data Frame Shape: {new_cars.shape}')
    else:
        print('data folder does not exist!')


if __name__ == '__main__':
    data = pd.read_csv('./data/data.csv', encoding='utf-8')
    data = data[data['Manufacturer'].notna()] # remove NaN values
    generate(start_folder='./data', data=data)
