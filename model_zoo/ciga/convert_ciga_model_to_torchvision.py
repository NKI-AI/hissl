import torchvision
import torch

MODEL_PATH = 'pytorchnative_tenpercent_resnet18.ckpt'
RETURN_PREACTIVATION = False  # return features from the model, if false return classification logits
NUM_CLASSES = 4  # only used if RETURN_PREACTIVATION = False


def load_model_weights(model, weights):

    model_dict = model.state_dict()
    weights = {k: v for k, v in weights.items() if k in model_dict}
    if weights == {}:
        print('No weight could be loaded..')
    model_dict.update(weights)
    model.load_state_dict(model_dict)

    return model


if __name__== "__main__":
    # This script expects to be run from within ~/hissl/model_zoo/ while the pytorchnative_tenpercent_resnet18.ckpt is already downloaded
    # Code taken from https://github.com/ozanciga/self-supervised-histopathology with minor adjustments
    # Model downloaded from https://github.com/ozanciga/self-supervised-histopathology/releases/tag/nativetenpercent

    model = torchvision.models.__dict__['resnet18'](pretrained=False)

    state = torch.load(MODEL_PATH, map_location='cpu')

    state_dict = state['state_dict']
    for key in list(state_dict.keys()):
        state_dict[key.replace('model.', '').replace('resnet.', '')] = state_dict.pop(key)

    model = load_model_weights(model, state_dict)

    if RETURN_PREACTIVATION:
        model.fc = torch.nn.Sequential()
    else:
        model.fc = torch.nn.Linear(model.fc.in_features, NUM_CLASSES)

    torch.save(
        model.state_dict(),
        "resnet18_ciga_statedict.torch",
    )

