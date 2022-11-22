# propriostim

## Requirements

-   MATLAB R2020b or higher
-   Download and extract `data.zip` from [Zenodo](https://doi.org/10.5281/zenodo.5159752) in `data` folder in this directory.
-   For neuron-demo: NEURON 7.7 or higher

## Main usage

The `main` script allows to visualize joint kinematics, muscle elongations, and to compute corresponding ProprioStim and linear-charge stimulation parameters
for 10 different movements: Walking (ground level), Walking slow (ground level), Walking fast (ground level), Walking (downslope), Walking (upslope), 
Initial step walking,  Final step walking, Standing, Sit to stand, Squatting.
The ProprioStim encoding uses recruitment curves computed as logistic curves fit to modeling results for pre-selected, exemplary active site-fascicle combinations.
A higher level of customization, including the possibility to repopulate the nerve with custom fiber populations and to re-run NEURON simulations,
is available through `neuron-demo`.

## Usage of neuron-demo

The code in `neuron-demo` allows to visualize the detailed results of the simulations for 4 exemplary electrode placements,
and to recompute fiber thresholds and ProprioStim stimulation parameters for custom fiber distributions.
Here are detailed the functions of interest for the end user:

### view_stored_data()
Visualizes previously computed recruitments and allows to run the proprioceptive stimulation.

Select subject, electrode, and active site from the dropdown menus and press Load.

After loading a model, a motor fascicle must be selected. A reference fascicle can be selected at will.
It can be done by pressing the button _Select ** fascicle_ and clicking on the desired fascicle on the cross-section.

The fibers within the motor fascicle can then be split by type using one of the two proposed methods:
-   **Random**, to choose all the fibers completely randomly, within their correct diameter range.
-   **Cluster**, to cluster *Ia* and *Ib* fibers around two chosen centers, and the _Alpha Motor_ as the others in the same diameter range.
    Since MATLAB function _ginput_ appears to give a strong offset error, a guided calibration phase is necessary. In this first calibration phase superimpose the cursor aiming-cross over the background plot-cross and perform a left-click. After the calibration the user selects first the cluster center for the Ia fibers, and then the center of Ib fibers.

II and III fibers are always chosen as all the fibers within their respective diameter ranges.

The recruitment plot is automatically updated during the selection of fascicles and fibers.

After assigning the fiber type, a walking pace can be selected and
the simulation of proprioceptive stimulation started by pressing on _Run stimulation_.

### run_neuron()
Loads a nerve model with precomputed potentials, allows the selection of fibers per group, and runs NEURON simulations.

At the first execution it runs _make\_config_ to specify NEURON parameters, they are saved in _config.mat_ and can be edited by running _make\_config_ again.
Lets the user select active site, fascicle, and specify fiber population by number of fibers per each type. The fibers are chosen randomly or by clustering.
Plots a cross-section to visualize the chosen fibers and runs the simulations (in multithreading if the Parallel Computing Toolbox is installed).
Finally shows recruitment curves and saves the model in the _data/runs_ folder.

### view_run()
Displays the results of simulations run with _run_neuron()_

### proprio_stim()
Runs and visualize a ProprioStim simulation from the results of a NEURON run.
