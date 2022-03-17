import pandas as pd
import glob


def main():
    txt_files = glob.glob("splits/*.txt")
    for txt_file in txt_files:
        wsi_paths = pd.read_csv(txt_file, header=None)
        # We save the masks in a similar structure as the WSIs are saved, but the
        # slide name is a directory, and the slide directory contains a file 'mask.png' that holds
        # the mask.
        mask_paths = wsi_paths[0].str.replace(
            ".svs$", "/mask.png", regex=True
        )  # .svs$ matches .svs only if the filename ends with it.
        save_as = txt_file[:-4] + "_masks.txt"  # save this file as '{original_filename_without_extensions}_masks.txt'
        mask_paths.to_csv(save_as, header=False, index=False)  # Save as a plain text file


if __name__ == "__main__":
    main()
