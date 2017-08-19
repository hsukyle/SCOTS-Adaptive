# Welcome to SCOTS-Adaptive

**SCOTS**, by Matthias Rungger et al., is a C++ tool (with a small Matlab interface) to synthesize controllers for
possibly perturbed nonlinear control systems with respect to safety and reachability specifications.

**SCOTS-Adaptive** enables multi-layer abstractions to expedite the fixed point procedure in the synthesis.


### Requirements

- A C++ development environment where you can compile C++ source code.

- The CUDD library by Fabio Somenzi, which can be downloaded at
    http://vlsi.colorado.edu/~fabio/. 
    SCOTS uses the dddmp and C++ wrapper of the CUDD library.

    In the example computations we used cudd-3.0.0 which we configured with 

    `$./configure --enable-shared --enable-obj --enable-dddmp --prefix=/opt/local/`

- SCOTS-Adaptive is a header only library. You need only add the SCOTS source
  directory to the include directory in the compiler command. 

    Further details are found in the readme files in example directories and in the manual.

### Directory structure

- ./bdd/
    Contains the source C++ source code for the SCOTS, SCOTS-Adaptive classes 
    which use Binary Decision Diagrams as the underlying data structure

- ./doxygen/
    C++ Class documentation directory
  
- ./examples/
    Some C++/Matlab programs demonstrating the usage of basic SCOTS
  
- ./test/
    Examples demonstrating the usage and performance of SCOTS-Adaptive
  
- ./mfiles
    Contains an mfile as a wrapper to the mex-file functions
  
- ./mfiles/mexfiles/
    mex-file to read the C++ output from file 
