import torch
import torchvision


def main():
    torch.save(
        torchvision.models.shufflenet_v2_x1_0(pretrained=True).state_dict(),
        "shufflenet_v2_x1_0_imagenet_statedict.torch",
    )


if __name__ == "__main__":
    main()
