# modified version of https://github.com/nicknochnack/PyTorchin15
# 98.62% for 1,432KB

# Import dependencies
import torch 
from PIL import Image
from torch import nn, save, load
from torch.optim import Adam
from torch.utils.data import DataLoader
from torchvision import datasets
from torchvision.transforms import ToTensor
import os

# Get data 
data_train = datasets.MNIST(root="data", download=True, train=True, transform=ToTensor())
dataset_train = DataLoader(data_train, 32)
data_test = datasets.MNIST(root="data", download=True, train=False, transform=ToTensor())
dataset_test = DataLoader(data_test, 32)
#1,28,28 - classes 0-9

# Image Classifier Neural Network
class ImageClassifier(nn.Module): 
    def __init__(self):
        super().__init__()
        self.model = nn.Sequential(
            nn.Conv2d(1, 32, (3,3)), 
            nn.ReLU(),
            nn.Conv2d(32, 64, (3,3)), 
            nn.ReLU(),
            nn.Conv2d(64, 64, (3,3)), 
            nn.ReLU(),
            nn.Flatten(), 
            nn.Linear(64*(28-6)*(28-6), 10)  
        )

        # Show layer sizes
        # output = torch.randn(1, 28, 28)
        # for i, layer in enumerate(self.model):
        #     print(type(layer).__name__)
        #     output = layer(output)
        #     print(f"Layer {i}: {type(layer).__name__}, Output shape: {output.shape}")

    def forward(self, x): 
        return self.model(x)

# Instance of the neural network, loss, optimizer 
clf = ImageClassifier().to('cuda')
opt = Adam(clf.parameters(), lr=1e-3)
loss_fn = nn.CrossEntropyLoss() 

def test(model, device, test_loader):
    model.eval()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += torch.nn.functional.cross_entropy(output, target, reduction='sum').item()  # sum up batch loss
            pred = output.argmax(dim=1, keepdim=True)  # get the index of the max log-probability
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader.dataset)

    print('\nTest set: Average loss: {:.4f}, Accuracy: {}/{} ({:.0f}%)\n'.format(
        test_loss, correct, len(test_loader.dataset),
        100. * correct / len(test_loader.dataset)))

# Training flow 
if __name__ == "__main__": 

    if (not os.path.exists("train.pt")):
        for epoch in range(10): # train for 10 epochs
            for batch in dataset_train: 
                X,y = batch 
                X, y = X.to('cuda'), y.to('cuda') 
                yhat = clf(X) 
                loss = loss_fn(yhat, y) 

                # Apply backprop 
                opt.zero_grad()
                loss.backward() 
                opt.step() 

            print(f"Epoch:{epoch} loss is {loss.item()}")

        with open('train.pt', 'wb') as f: 
            save(clf.state_dict(), f) 

    with open('train.pt', 'rb') as f: 
        clf.load_state_dict(load(f))  

    # img = Image.open('img_1.jpg') 
    # img_tensor = ToTensor()(img).unsqueeze(0).to('cuda')
    # print(torch.argmax(clf(img_tensor)))

    # img = Image.open('img_2.jpg') 
    # img_tensor = ToTensor()(img).unsqueeze(0).to('cuda')
    # print(torch.argmax(clf(img_tensor)))

    # img = Image.open('img_3.jpg') 
    # img_tensor = ToTensor()(img).unsqueeze(0).to('cuda')
    # print(torch.argmax(clf(img_tensor)))

    # od = clf.state_dict()
    # for key, value in od.items():
    #     print(f"Key: {key}")
    #     #print(f"Key: {key}, Value: {value}")
    #     #print(f"Key: {key}, Value: {theValue}")

    #     theValue = value.cpu().detach().numpy()
    #     theValue.tofile("train." + key + ".bin",)
    
    test(clf, torch.device("cuda"), dataset_test)