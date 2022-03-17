import numpy as np


def main(partition: str):
    paths = []
    with open(f"{partition}_paths.txt", "r") as f:
        while line := f.readline().rstrip():
            paths.append(line)
    paths_np = np.array(paths, dtype="<U128")
    filename = f"{partition}_paths.npy"
    np.save(filename, paths_np)
    print(f"Saved {filename} object.")


if __name__ == "__main__":
    main("train")
    main("test")
