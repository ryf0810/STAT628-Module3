from torch.utils.data import DataLoader
from model import myCNN, train
from dataloader import CarsDataset
from torchvision import transforms
import torch
import torch.nn as nn




num_workers = 4
batch_size = 128
learning_rate = 0.01
epochs = 50
criterion = nn.CrossEntropyLoss()

data_transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.CenterCrop(size=(200,200)),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

dataset = CarsDataset(root_dir='./data/carImages/', csv_file='./data/cars.csv', transform=data_transform)
train_set, test_set = torch.utils.data.random_split(dataset, [int(len(dataset) * 0.75), len(dataset) - int(len(dataset) * 0.75)])
train_loader = DataLoader(dataset=train_set, 
                          batch_size=batch_size, 
                          shuffle=True,
                          num_workers=num_workers)
test_loader = DataLoader(dataset=test_set,
                         batch_size=batch_size, 
                         shuffle=True,
                         num_workers=num_workers)

mycnn = myCNN()

if __name__ == '__main__':
# will autosave the model
    train(
        model=mycnn,
        train_loader=train_loader,
        epochs=epochs,
        learning_rate=learning_rate,
        criterion=criterion
    )






