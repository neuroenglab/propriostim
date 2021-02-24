# proprio

## Usage

Here are detailed the functions of interest for the end user:

### view_stored_data()
Visualizes previously computed recruitments and allows to run the proprioceptive stimulation.

Select subject, electrode, and active site from the dropdown menus and press Load.

After loading a model a motor fascicle must be selected. A reference fasicle can be selected at will.
It can be done by pressing the button _Select ** fascicle_ and clicking on the desired fascicle on the cross-section.

The fibers within the motor fascicle can then be split by type using one of the two proposed methods:
-   **Random**, to choose all the fibers completely randomly, within their correct diameter range.
-   **Cluster**, to cluster *Ia* and *Ib* fibers around two chosen centers, and the _Alpha Motor_ as the others in the same diameter range.
    Since MATLAB function _ginput_ appears to give a strong offset error, a guided calibration phase is necessary. After the calibration the
    user selects first the cluster center for the Ia fibers, and then the center of Ib fibers.

II and III fibers are always chosen as all the fibers within their respective diameter ranges.

The recruitment plot is automatically updated during the selection of fascicles and fibers.

After assigning the fiber type, a walking pace can be selected and
the simulation of proprioceptive stimulation started by pressing on _Run stimulation_.

### run_neuron()
