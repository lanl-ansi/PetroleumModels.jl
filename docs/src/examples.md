# Examples Documentation

The examples folder contains a library network instances which have been developed in the literature.

These examples can be run using the `pf.jl` script which executes various problems and formulations on the library of instances and verifies that `PetroleumModels` returns solutions which were reported in the literature.

Long term, the plan is to move the examples out of the `PetroleumModels` repository and maintain a special `PetroleumModelsLib` repository specifically for warehousing models developed in the literature.


| Problems                       | Source               |
| ----------------------------   | -------------------- |
| case                           | [1]                  |
| example_from_article           | [2]                  |
| one_pipe                       | [1]                  |
| pipeline_2012_seaway_m3_per_h  | [3]                  |
| small_case                     | [1]                  |

## Sources

[1] Unknown

[2] Bekker L.M., Shtukaturov K.Y. "THE CALCULATION OF THE OPTIMAL MODE OF OPERATION OF THE OIL PIPELINE, EQUIPPED WITH FREQUENCY-CONTROLLED ACTUATOR" (in Russian). *JSC Giprotruboprovod*, 3 (11): 27-33, 2013.

[3] https://www.seawaypipeline.com/faqs/
