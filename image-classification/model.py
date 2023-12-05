import torch.nn as nn
import torch.optim as optim
from tqdm import tqdm
import time
import torch


class myCNN(nn.Module):
    def __init__(self, input_shape=(200,200), num_classes=179):
        super(myCNN, self).__init__()

        self.layer1 = nn.Sequential(
            nn.Conv2d(in_channels=3, out_channels=6, kernel_size=5, stride=1),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=6, stride=2)
        )
        self.layer2 = nn.Sequential(
            nn.Conv2d(in_channels=6, out_channels=16, kernel_size=9, stride=1),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=6, stride=2)
        )
        self.layer3 = nn.Sequential(
            nn.Conv2d(in_channels=16, out_channels=24, kernel_size=15, stride=1),
            nn.ReLU(),
            nn.MaxPool2d(kernel_size=8, stride=5)
        )
        self.flatten = nn.Flatten()
        # 24 is the number of output channels, 5*5 is the shape of image after first 3 layers
        self.fc1 = nn.Linear(in_features=24*5*5, out_features=256)
        self.relu1 = nn.ReLU()
        self.fc2 = nn.Linear(in_features=256, out_features=num_classes)

        '''
        128 could be 64/256/... it is user-defined
        After layer1: torch.Size([128, 6, 96, 96])
        After layer2: torch.Size([128, 16, 42, 42])
        After layer3: torch.Size([128, 24, 5, 5])

        Here 128 is batch size, flatten to 600 neurons ---> 256 neurons ---> 179 neurons (representing each class)
        After flatten: torch.Size([128, 600])
        After fc1: torch.Size([128, 256])
        After fc2: torch.Size([128, 179])
        '''

    def forward(self, x):
        out = self.layer1(x)
        # print("After layer1:", out.shape)
        out = self.layer2(out)
        # print("After layer2:", out.shape)
        out = self.layer3(out)
        # print("After layer3:", out.shape)
        out = self.flatten(out)
        # print("After flatten:", out.shape)
        out = self.fc1(out)
        # print("After fc1:", out.shape)
        out = self.relu1(out)
        out = self.fc2(out)
        # print("After fc2:", out.shape)

        return out
    

def train(model, train_loader, epochs, learning_rate, criterion):
    start = time.time()
    loss_values = []
    accuracy_values = []

    optimizer = optim.SGD(model.parameters(), lr=learning_rate)

    model.train()
    for epoch in range(epochs):
        train_loss = 0.0
        total_correct_labels = 0
        for batch in tqdm(train_loader, total=len(train_loader)):
            inputs, targets = batch

            optimizer.zero_grad()
            outputs = model(inputs)
            _, predictions = torch.max(outputs, dim=1)
            correct_labels = (predictions == targets).sum().item()
            total_correct_labels += correct_labels

            loss = criterion(outputs, targets)
            loss.backward()
            optimizer.step()

            train_loss += loss.item()

        train_loss /= len(train_loader)
        accuracy = total_correct_labels / len(train_loader.dataset) * 100
        # add to list
        loss_values.append(train_loss)
        accuracy_values.append(accuracy)
        print(f'Train Epoch: {epoch+1}    '
              f'Accuracy: {total_correct_labels}/{len(train_loader.dataset)}({round(accuracy, 2)}%)    '
              f'Loss: {round(train_loss, 3)}')
    end = time.time()
    # add to model
    model.training_time = end - start
    model.loss_history = loss_values
    model.accuracy_history = accuracy_values
    torch.save(model, './trained_model.pth')