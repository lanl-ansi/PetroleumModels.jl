# Examples Documentation

The test/data folder contains a library network instances which have been developed in the literature.

These examples can be run using the `opf.jl` script which executes various problems and formulations on the library of instances and verifies that `PetroleumModels` returns solutions which were reported in the literature.

Long term, the plan is to move the examples out of the `PetroleumModels` repository and maintain a special `PetroleumModelsLib` repository specifically for warehousing models developed in the literature.


| Problems                       | Source               |
| ----------------------------   | -------------------- |
| case_tank                      | [1]                  |
| case_bekker                    | [2]                  |
| case_one_pipe                  | [1]                  |
| case_seaway                    | [3]                  |
| case5                          | [1]                  |

## Sources

[1] Unknown

[2] Bekker L.M., Shtukaturov K.Y. "The Calculation of the Optimal Mode of Operation of the Oil Pipeline, Equipped with Frequency-Controlled Actuator" (in Russian). *JSC Giprotruboprovod*, 3 (11): 27-33, 2013.

[3] https://www.seawaypipeline.com/faqs/ as implemented in E. Khlebnikova, K. Sundar, A. Zlotnik, R. Bent, M. Ewers, and B. Tasseff. "Optimal Economic Operation of Liquid Petroleum Products Pipeline Systems", AIChE Journal, forthcoming
