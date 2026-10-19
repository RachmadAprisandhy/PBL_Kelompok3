"""Randomly sample 300 training images per class; retain full test/validation."""
from pathlib import Path
import random
import shutil

ROOT = Path(__file__).resolve().parent.parent
SOURCE = Path(r"C:\Users\USER\Downloads\archive\Banana Images\Real Dataset")
OUTPUT = ROOT / "dataset" / "random_300"
CLASSES = ("Class A", "Class B", "Class C", "Class D")
EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
SEED = 42


def images(folder: Path) -> list[Path]:
    return sorted(p for p in folder.rglob("*") if p.is_file() and p.suffix.lower() in EXTENSIONS)


def main() -> None:
    if OUTPUT.exists() and any(OUTPUT.iterdir()):
        raise FileExistsError(f"Output is not empty; refusing to overwrite: {OUTPUT}")
    rng = random.Random(SEED)
    plan: list[tuple[Path, str, str]] = []
    for class_name in CLASSES:
        source_train = SOURCE / "train" / class_name
        candidates = images(source_train)
        if len(candidates) < 300:
            raise ValueError(f"{class_name} has only {len(candidates)} train images; 300 required")
        chosen = rng.sample(candidates, 300)
        plan.extend((p, "train", class_name) for p in chosen)
        print(f"train/{class_name}: sampled 300 of {len(candidates)}")

        for split in ("test", "validation"):
            source_folder = SOURCE / split / class_name
            if not source_folder.is_dir():
                raise FileNotFoundError(f"Missing folder: {source_folder}")
            held_out = images(source_folder)
            plan.extend((p, split, class_name) for p in held_out)
            print(f"{split}/{class_name}: copied all {len(held_out)}")

    targets = [OUTPUT / split / class_name / src.name for src, split, class_name in plan]
    if len(targets) != len(set(targets)):
        raise FileExistsError("Duplicate filenames found in a target class folder; no files copied")
    for (src, split, class_name), target in zip(plan, targets):
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, target)
    print(f"Copied {len(plan)} images to {OUTPUT}; source data was not modified. Seed={SEED}")


if __name__ == "__main__":
    main()
