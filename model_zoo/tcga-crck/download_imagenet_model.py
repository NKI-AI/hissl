import torch
import torchvision


def main():
    torch.save(torchvision.models.resnet18(pretrained=True).state_dict(), "resnet18_imagenet_statedict.torch")


if __name__ == "__main__":
    main()
