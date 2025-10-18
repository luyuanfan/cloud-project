# cloud-project

To install all dependencies at once, run: 
```
source install.sh
```

## Important
To build OMNeT++, you must set the following three options in `omnetpp-5.6.2/configure.user` from **yes** to **no** (you cannot enable these modes simply because JHU's system does not have these dependencies installed; if you are using a system where you are the root, this step is not necessary): 
```
WITH_OSG=no
WITH_TKENV=no
WITH_QTENV=no
```