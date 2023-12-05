from torch.utils.data import Dataset
from PIL import Image
import os
import pandas as pd


class CarsDataset(Dataset):
    def __init__(self, csv_file, root_dir, transform=None):
        self.annotations = pd.read_csv(csv_file)
        self.root_dir = root_dir
        self.transform = transform

    def __len__(self):
        return len(self.annotations)
    
    def get(self):
        return self.annotations
    
    def __getitem__(self, index):
        img_path = os.path.join(self.root_dir, self.annotations.loc[index, 'path']) # first column is subfolder path
        y_label = self.annotations.loc[index, 'encoded_label'] # corresponds to 'encoded_label' column
        image = Image.open(img_path).convert('RGB') # use transforms to tensor gonna be [3, Height, Width, 3 channels 'RGB'

        if self.transform: # when the input is None, treat as True
            image = self.transform(image)
            
        return (image, y_label)