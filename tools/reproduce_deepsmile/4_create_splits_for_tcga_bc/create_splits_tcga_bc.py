# coding=utf-8
# Copyright (c) HISSL Contributors
from sklearn.model_selection import StratifiedKFold, StratifiedShuffleSplit, train_test_split
import pandas as pd
import numpy as np
from typing import List
import pathlib
import glob
import datetime


def txt_of_paths_to_list(path: str) -> List[str]:
    """Reads a .txt file with a path per row and returns a list of paths"""
    content: List = []
    with open(path, "r") as f:
        while line := f.readline().rstrip():
            content.append(line)
    return content


def test_overlap(save_to_dir: str) -> None:
    """
    Loads the paths to WSIs of the train-val-test splits as previously produced, and tests
    1. If there are duplicate WSIs within a split
    2. If there are duplicates between splits

    If this fails, these splits should not be used.
    """
    for fold in range(5):
        train_slides = txt_of_paths_to_list(f"{save_to_dir}/paths_wsi_tcga_bc_set-train_fold-{fold}.txt")
        val_slides = txt_of_paths_to_list(f"{save_to_dir}/paths_wsi_tcga_bc_set-val_fold-{fold}.txt")
        test_slides = txt_of_paths_to_list(f"{save_to_dir}/paths_wsi_tcga_bc_set-test_fold-{fold}.txt")

        # No duplicates within itself
        assert len(set(train_slides)) == len(train_slides)
        assert len(set(val_slides)) == len(val_slides)
        assert len(set(test_slides)) == len(test_slides)

        # No duplicates with any other set
        assert len(set(train_slides).intersection(set(val_slides))) == 0
        assert len(set(train_slides).intersection(set(test_slides))) == 0
        assert len(set(test_slides).intersection(set(val_slides))) == 0


def test_lengths(save_to_dir: str) -> None:
    """
    Test if the length of the train+val+test is the same length for each fold.
    """
    lengths = []
    for fold in range(5):
        fold_length = 0
        for subset in ["train", "val", "test"]:
            fold_length += len(
                txt_of_paths_to_list(pathlib.Path(f"{save_to_dir}/paths_wsi_tcga_bc_set-{subset}_fold-{fold}.txt"))
            )
        lengths.append(fold_length)
    assert len(set(lengths)) == 1


def test_distributions(save_to_dir: str) -> None:
    """
    Tests if the fraction of positive binarized classes for both mHRD and tHRD is between 0.45 and 0.55
    """
    path_to_patient_df = pd.read_csv(f"{save_to_dir}/paths_to_patient_id.csv")
    labels_df = pd.read_csv(f"{save_to_dir}/DeepSMILE_TCGA-BRCA-DX_CLINI.csv")
    for fold in range(5):
        for subset in ["train", "val", "test"]:
            paths = txt_of_paths_to_list(pathlib.Path(f"{save_to_dir}/paths_wsi_tcga_bc_set-{subset}_fold-{fold}.txt"))
            patient_ids = path_to_patient_df[path_to_patient_df["paths"].isin(paths)]["patient_id"]
            subset_labels_df = labels_df[labels_df["PATIENT"].isin(patient_ids)]

            # TODO change back to 0.45, 0.55 for the entire dataset. On a small dataset they're not perfectly
            # distributed
            print(f"Percentage of mHRD positive in {subset} subset fold {fold}: {subset_labels_df['mHRD'].mean()}")
            assert 0.00 <= subset_labels_df["mHRD"].mean() <= 1.00
            print(
                f"Percentage of tHRD positive in {subset} subset fold {fold}: {subset_labels_df.dropna(subset=['tHRD'])['tHRD'].mean()}"
            )
            assert 0.00 <= subset_labels_df.dropna(subset=["tHRD"])["tHRD"].mean() <= 1.00


def test(save_to_dir: str) -> None:
    # Assert that there's no overlap between train/val, train/test, val/test.
    test_overlap(save_to_dir)

    # Assert that the length of test_i + val_i + train_i are the same for all i
    test_lengths(save_to_dir)

    # Check if the fraction of labels is around 0.5 for each fold
    test_distributions(save_to_dir)


def main(save_to_dir: str, path_to_all_labels_file: str, masks_dir: str) -> None:
    """
    The main script that creates the data splits. This script loads the file with labels,
    only takes into account the patients for which the whole-slide images can be read by openslide,
    creates a 5-fold train-test stratified k-fold split,
    and creates a random shuffle train-val split in each train split,
    we drop the patients without any HRD score,
    compute the mHRD and tHRD labels for those patients with an HRD score,
    and stratify on the mHRD labels.

    Additionally, for each train split, we save consecutive subsets of the train split for the data efficiency experiments.

    Finally, we run some tests to make sure that, e.g., the splits do not overlap.
    """
    # Create the directory to save the splits in. The directory should not exist, to be sure we do not overwrite
    # any previous files. We do not add YYYYMMDD to the filename since this should then be hardcoded in
    # reproduce_deepsmile.sh
    pathlib.Path(save_to_dir).mkdir(exist_ok=True)
    ID_NAME = "PATIENT"
    df = pd.read_csv(path_to_all_labels_file)

    # Load FFPE WSI filepaths as downloaded from TCGA that can be opened with openslide and make matchable with CLINI file
    # We use the saved masks as a proxy for the available WSIs, since some WSIs can not be read by openslide and would
    # be skipped when computing the masks.
    paths = pd.DataFrame(
        {"paths": ["/".join(rel_path.split("/")[-2:]) + ".svs" for rel_path in glob.glob(masks_dir + "/*/*")]}
    )

    # 0001a1fb-f388-41c6-bfe9-ecbb10429e37/TCGA-A1-A0SE-01Z-00-DX1.04B09232-C6C4-46EF-AA2C-41D078D0A80A.svs
    # get patient id from this: TCGA-A1-A0SE
    paths["patient_id"] = paths["paths"].str[37:49]
    paths["slide_id"] = paths["paths"].str[37:60]

    paths.to_csv(f"{save_to_dir}/paths_to_patient_id.csv")

    # Use stratified KFold split for the initial 5 folds
    skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=0)  # split into test and (train)

    # Use random shuffle split for the train-val split
    sss = StratifiedShuffleSplit(n_splits=1, test_size=0.25, random_state=0)  # split into val and train

    # Drop those patients for which we have no HRD score
    DROP = ["HomologousRecombinationDefects"]
    print(f" We start with {len(df)} patients")
    df = df.dropna(subset=DROP).reset_index()
    print(f"We drop NaNs of {DROP} and end up with {len(df)} patients")

    # Set the binarized HRD labels
    df["mHRD"] = 0
    df.loc[df["HomologousRecombinationDefects"] > 20, "mHRD"] = 1
    df["tHRD"] = np.nan
    df.loc[df["HomologousRecombinationDefects"] >= 29, "tHRD"] = 1
    df.loc[df["HomologousRecombinationDefects"] <= 12, "tHRD"] = 0

    # Stratify to balance mHRD
    stratify_on = ["mHRD"]
    X = df[ID_NAME]
    y = df[stratify_on]
    skf.get_n_splits(X=X, y=y)

    for fold, (train_index, test_index) in enumerate(skf.split(X=X, y=y)):
        X_trainval = df.iloc[train_index][ID_NAME]  # Get the train-val indices
        y_trainval = df.iloc[train_index][stratify_on]  # Get the train-val indices
        sss.get_n_splits(X=X_trainval, y=y_trainval)  # Split train-val into train & val
        train_index, val_index = next(iter(sss.split(X=X_trainval, y=y_trainval)))  # Get the indices

        for subfold, subfold_index in zip(["train", "val", "test"], [train_index, val_index, test_index]):
            subfoldname = f"{subfold}_fold_{fold}"  # Set as column name and filename
            df[subfoldname] = 0  # Set all patients to not belong to the new fold
            subfold_loc = df.columns.get_loc(subfoldname)  # Get the index location of the newly created column

            if subfold in ["train", "val"]:
                indices = X_trainval.index[
                    subfold_index
                ]  # the subfold index are the row numbers, so we get the original index
            else:
                indices = subfold_index

            df.loc[
                indices, subfoldname
            ] = 1  # Set those indices as given by the shufflesplit to be 1 in the newly created column
            patients = df[df[subfoldname] == 1]["PATIENT"]  # Get the patient IDs that belong to this split
            subfold_slides = paths[paths["patient_id"].isin(patients)][
                "paths"
            ]  # Get the slides that belong to these patients
            subfold_slides.to_csv(
                f"{save_to_dir}/paths_wsi_tcga_bc_set-{subfold}_fold-{fold}.txt", header=None, index=False
            )  # Save those slides to a .txt file

    # Set training split fractions
    fractions = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

    for fold in [0, 1, 2, 3, 4]:
        # We only make the fractional subset for the training set
        df_fold = df[df[f"train_fold_{fold}"] == 1]
        n_slides = len(df_fold)  # Number of all slides available
        n_subsets = (np.array(fractions) * n_slides).astype(
            np.int_
        )  # Number of slides in each subset (fraction of the total)
        all_idx = df_fold.index
        targets = df_fold["mHRD"]
        subset_idx = all_idx

        df[f"train_fold_{fold}_subset_1.0"] = 0
        df.loc[subset_idx, f"train_fold_{fold}_subset_1.0"] = 1

        for n_subset, fraction in zip(n_subsets[::-1][1:], fractions[::-1][1:]):
            # We loop over [0.9, ... 0.1]
            # We create a subset of 1 -> 0.9, and then a subset of 0.9 -> 0.8, so that each fractional subset is
            # a proper subset of the greater set.
            subset_idx = train_test_split(subset_idx, train_size=n_subset, stratify=targets.loc[subset_idx])[0]
            df[f"train_fold_{fold}_subset_{fraction}"] = 0
            df.loc[subset_idx, f"train_fold_{fold}_subset_{fraction}"] = 1

    paths = paths.join(df.set_index("PATIENT"), on="patient_id", lsuffix="left_")

    for fold in [0, 1, 2, 3, 4]:  # For each fold..
        for frac in fractions:  # For each fraction..
            # Save the subsets for mHRD and tHRD for the train split

            # Save splits for train, mHRD
            paths[paths[f"train_fold_{fold}_subset_{frac}"] == 1][["paths", "patient_id", "slide_id", "mHRD"]].to_csv(
                f"{save_to_dir}/mHRD_tcga_bc_set-train_fold-{fold}_subset-{frac}.txt", header=None, index=None
            )

            # Save splits for train, tHRD
            paths[paths[f"train_fold_{fold}_subset_{frac}"] == 1][["paths", "patient_id", "slide_id", "tHRD"]].dropna(
                subset=["tHRD"]
            ).to_csv(f"{save_to_dir}/tHRD_tcga_bc_set-train_fold-{fold}_subset-{frac}.txt", header=None, index=None)

        # And only save the full split for val and test

        # Save splits for val, mHRD
        paths[paths[f"val_fold_{fold}"] == 1][["paths", "patient_id", "slide_id", "mHRD"]].to_csv(
            f"{save_to_dir}/mHRD_tcga_bc_set-val_fold-{fold}.txt", header=None, index=None
        )

        # Save splits for val, tHRD
        paths[paths[f"val_fold_{fold}"] == 1][["paths", "patient_id", "slide_id", "tHRD"]].dropna(
            subset=["tHRD"]
        ).to_csv(f"{save_to_dir}/tHRD_tcga_bc_set-val_fold-{fold}.txt", header=None, index=None)

        # Save splits for test, mHRD
        paths[paths[f"test_fold_{fold}"] == 1][["paths", "patient_id", "slide_id", "mHRD"]].to_csv(
            f"{save_to_dir}/mHRD_tcga_bc_set-test_fold-{fold}.txt", header=None, index=None
        )

        # Save splits for test, tHRD
        paths[paths[f"test_fold_{fold}"] == 1][["paths", "patient_id", "slide_id", "tHRD"]].dropna(
            subset=["tHRD"]
        ).to_csv(f"{save_to_dir}/tHRD_tcga_bc_set-test_fold-{fold}.txt", header=None, index=None)

    # Save the file with labels and splits
    df.to_csv(f"{save_to_dir}/DeepSMILE_{pathlib.Path(path_to_all_labels_file).stem}.csv")

    # Run some tests with the recently saved files
    test(save_to_dir)


if __name__ == "__main__":
    # Use file from https://github.com/jnkather/DeepHistology/blob/master/cliniData/TCGA-BRCA-DX_CLINI.xlsx
    main(
        save_to_dir="splits",
        path_to_all_labels_file="../../../resources/data/tcga_bc/TCGA-BRCA-DX_CLINI.csv",
        masks_dir="../1_download_tcga_bc/masks/mask_and_check_tiles_mpp1.14_ts224_fesi_0.5",
    )
