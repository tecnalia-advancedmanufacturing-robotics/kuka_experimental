# Notes on KUK RSI interface

## Found problems

* ros_rsi.src - line 69: RSI_CREATE("ros_rsi.rsi",CONTID,TRUE) - the .rsi extension is required
* ros_rsi.src - line 66: PTP {A1 0, A2 -90, A3 90, A4 0, A5 90, A6 0} - the start position should have A5 at 90 degrees to avoid singularity at the start position, otherwise the robot will crash with A4 velocity exceeded
* ros_rsi.src - line 69: PTP {A1 0, A2 -90, A3 90, A4 0, A5 90, A6 0} - the start position should be within the limits defined in the urdf
* ros_rsi_ethernet.xml - line 3: <IP_NUMBER> should have an IP address in the rsi subnet
* ros_rsi.rsi - LowerLimA* and UpperLimA* should be set high to avoid hitting the limits
* ros_rsi.rsi - AXISCORRMON MaxA* should be set high to avoid hitting the limits