# Palaeoclimate and hydrological modelling of the Qa' Shubayqa, eastern Jordan

[![DOI](https://zenodo.org/badge/321489935.svg)](https://doi.org/10.5281/zenodo.17482936)

Joe Roe, University of Copenhagen <<jar@hum.ku.dk>>

This research compendium contains the data and code for a model of the palaeoclimate and hydrology of the Qa' Shubayqa, a seasonal water body in eastern Jordan, between 17,000 and 8000 BP.
It forms the basis of a paper to be published in a forthcoming edited volume.

## Usage

The analysis is structured as a numbered R scripts under `analysis/`.
To reproduce the results presented in our paper, `source()` these scripts.
The dependencies listed in `analysis/00-setup.R` must be installed first.

Raw data required for the analysis is located under `analysis/data/raw_data`.
Note that the palaeoclimate files are too large to commit to a `git` repository and will be redownloaded from their original sources by `03-data_palaeoclim.R` – this takes quite some time.

`analysis/badia_qa_hydrology/` contains an earlier hydrological analysis of Shubayqa and two other qa'en (Wisad and Qattafi).
This consists of an Rmarkdown document describing the analysis.
