# Splits from published experiments

The directory `20211207` contains the exact splits used for DeepSMILE.

Note, however, that these files refer to WSIs downloaded from TCGA in 2020, whereas in 2021
the filenames of the WSIs have been altered.

The TCGA barcode remained the same, e.g. `TCGA-AN-A0AS-01Z-00-DX1`. However, the case UID and file UID have changed, i.e.

```
020743ed-c87a-41d7-9441-90868b785061/TCGA-AN-A0AS-01Z-00-DX1.51E551E9-E5F4-4C94-9B25-71DA41109E92.svs
^----------------------------------^ ^---------------------^ ^-----------------------------------^
    case UID (changed in 2021)        TCGA barcode (unchanged)    slide UID (changed in 2021)
```
If you wish to use these exact splits instead of creating new ones, while download the latest data, please map
these paths to the new paths using the TCGA barcode as identifier, as this is unique per WSI.
