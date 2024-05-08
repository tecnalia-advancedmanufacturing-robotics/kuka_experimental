# Configuring RSI on the controller

This guide highlights the steps needed in order to successfully configure the **RSI interface** on the controller to work with the **kuka_rsi_hardware_interface** on your PC with ROS.

## 1. Controller network configuration

Windows runs behind the SmartHMI on the teach pad. Make sure that the **Windows interface** of the controller and the **PC with ROS** is connected to the same subnet.

1. Log in as **Expert** or **Administrator** on the teach pad and navigate to **Network configuration** (**Start-up > Network configuration > Activate advanced configuration**).
2. There should already be an interface checked out as the **Windows interface**. For example:
   * **IP**: 192.168.250.20 :speech_balloon: Here I found that the windows interface was set at the IP 195.168.3.50
   * **Subnet mask**: 255.255.255.0
   * **Default gateway**: 192.168.250.20 :speech_balloon: I set the default gateway to 195.168.3.20 to match the IP that was set. Now that I'm writing this i see it probably should be 192.168.3.50 instead.
   * **Windows interface checkbox** should be checked.

   * :speech_balloon: I also found an other network named "RSI" network which seems to relate to step 6. It was set with:

     * **IP**: 192.168.4.50
     * **Subnet mask**: 255.255.255.0
     * **Default gateway**: 0.0.0.0 :speech_balloon: maybe I should have tried to change this
     * **Windows interface checkbox** unchecked

3. Minimize the SmartHMI (**Start-up > Service > Minimize HMI**). :speech_balloon: This opens up a windows desktop. There was a program there from tekniker.
4. Run **RSI-Network** from the Windows Start menu (**All Programs > RSI-Network**). :speech_balloon: RSI-Network was not found in all programs.
5. Check that the **Network - Kuka User Interface** show the Windows interface with the specified IP address. :speech_balloon: Skipped this step as it seems that the RSI subnet was already added
6. Add a new IP address on another subnet (e.g. 192.168.1.20) for the **RSI interface**.
   * Select the entry **New** under **RSI Ethernet** in the tree structure and press **Edit**.
   * Enter the IP address and confirm with **OK**.
   * Close **RSI-Network** and maximize the SmartHMI.
7. Reboot the controller with a cold restart (**Shutdown > Check *Force cold start* and *Reload files* > Reboot control PC**). :speech_balloon: Didn't do this as I didn't change any setting, but maybe I should have anyway.
8. After reboot, minimize the SmartHMI (**Start-up > Service > Minimize HMI**).
9. Run **cmd.exe** and ping the PC you want to communicate with on the same subnet (e.g. 192.168.250.xx). :speech_balloon: Couldn't figure out how to write on the terminal, as there was no virtual keyboard for windows. I tried plugging in a keyboard but it didn't work.

If your **PC** has an IP address on the same subnet as the **Windows interface** on the controller, the controller should receive answers from the PC:

* If this is the case, add another IP address to the current PC connection (e.g. 192.168.1.xx) on the same subnet as the **RSI** interface.

 :speech_balloon: Not really sure what this means, I set my computer's IP address to be on the same subnet as **RSI**: 192.168.4.54

## 2. KRL Files

The files included in this folder specifies the data transferred via RSI. Some of the files needs to be modified to work for your specific configuration.

##### ros_rsi_ethernet.xml

1. Edit the `IP_NUMBER` tag so that it corresponds to the IP address (192.168.1.xx) previously added for your PC. :speech_balloon: Set it to 192.168.4.54
2. Keep the `PORT` tag as it is (49152) or change it if you want to use another port. :speech_balloon: When trying out different forks, I noticed that one of them had a different PORT in this file, 59152. Maybe I forgot to revert it back to 49152?

Note that the `rsi/listen_address` and `rsi/listen_port` parameters of the `kuka_rsi_hw_interface` must correspond to the `IP_NUMBER`and `PORT` set in these KRL files.

##### ros_rsi.rsi.xml for RSI 3.x OR ros_rsi.rsix for RSI 4.x

:speech_balloon: Didn't touch these files as I didn't really understand them. I noticed ros_rsi.rsi.xml was not working, but I found found forks [#152](https://github.com/ros-industrial/kuka_experimental/pull/152) and [#155](https://github.com/ros-industrial/kuka_experimental/pull/155). 152 Didn't seem to work, giving some errors when loading the file `RSI_CREATE: index not valid, output signal`. 155 seemed to work better.

Note: from KSS 8.5 the version of RSI is changed to 4.x and the format of the file is a little changed. The new file extension on RSI 4.x is .rsix. So to use this driver on KSS 8.5 and above use ros_rsi.rsix instead of ros_rsi.rsi.xml
This file may be edited with application specific joint limits in degrees.

* Edit the parameters within the RSIObject `AXISCORR` to specify joint limits such as **LowerLimA1**, **UpperLimA1** etc. Note that these limits are in reference to the start position of the robot.
* Edit the parameters within `AXISCORRMON` to specify the overall correction limitation. If this limit is exceeded in either of the joint directions, RSI is stopped. The values of **MaxA1**, **MaxA2** etc. may be large to allow free movement within the specified joint limits in `AXISCORR`.

Notice the RSIObject of type `ETHERNET`. Within this object is a parameter called **Timeout**. This parameter is set to **100** by default. The RSI interface operates at `250 Hz` (4ms cycle). The **kuka_rsi_hardware_interface** does not have a period configured and is completely driven by the controller's output. Every controller RSI output has a IPOC timestamp which increments for every cycle. The **kuka_rsi_hardware_interface** will answer as quickly as possible. The answer includes the last IPOC received. If the connected **PC with ROS** did not manage to answer within the RSI cycle of **4ms**, the IPOC timestamp of RSI has incremented. The IPOC included in the answer is not matched and the controller will increment a counter. When this counter hits the **Timeout** parameter (**100**), the RSI connection will shut down. If this parameter is lowered, the demand for real-time computation will increase. :speech_balloon:
Maybe I should have tried increasing the timeout

If you have problems with the connection to RSI shutting down now and then while moving the robot it is suggested to:

* Compile and install a [RT-Preempt](https://rt.wiki.kernel.org/index.php/RT_PREEMPT_HOWTO) kernel for your PC.
* Give **kuka_rsi_hardware_interface** on your PC real-time priority when the RSI connection is established.

##### ros_rsi.src

This should only be edited if the start position specified within the file is not desirable for your application.
:speech_balloon: I had to edit two things:

* add E1 (the extra joint of the horizontal conveyor) to the PTP movement.
* Change the name on RSI_CREATE from `ros_rsi.rsi` to just `ros_rsi`, as it was complaining on not finding `ros_rsi.rsi.rsix` which should be `ros_rsi.rsix`

##### Copy files to controller

The files **ros_rsi.rsi** and **ros_rsi.rsi.diagram** should not be edited. All files are now ready to be copied to the Kuka controller:

1. Copy the files to a USB-stick.
2. Plug it into the teach pad or controller.
3. Log in as **Expert** or **Administrator**.
4. Copy the `ros_rsi.src` file to `KRC:\R1\Program`.
5. Copy the rest of the files to `C:\KRC\ROBOTER\Config\User\Common\SensorInterface`.

* for RSI 3.x : Copy ros_rsi.rsi.xml  to the above folder
* for RSI 4.x : Copy ros_rsi.rsix  to the above folder

## 3. Configure the kuka_rsi_hw_interface

The **kuka_rsi_hardware_interface** needs to be configured in order to successfully communicate with RSI. Inside `/kuka_rsi_hw_interface/test` and `/kuka_rsi_hw_interface/config` in this repository is a set of `*.yaml` files. These configuration files may be loaded into a launch-file used to start the **kuka_rsi_hardware_interface** with correct parameters, such as:

* **Joint names** corresponding to the robot description (URDF or .xacro).
* **IP address** and **port** corresponding to the RSI setup specified in **ros_rsi_ethernet.xml**.

We recommend that you copy the configuration files, edit the copies for your needs and use these files to create your own launch file. A template will be provided at a later time. However, at this time, have a look at `test_hardware_interface.launch`, `test_params.yaml`, `controller_joint_names.yaml` and `hardware_controllers.yaml` to achieve a working test-launch.
:speech_balloon: I used `aerobotics_workcell aerobotics_workcell.launch`, which I had already configured to contain the robot_description and the controllers. I set the `reverse_ip` to `192.168.4.54`.

In order to successfully launch the **kuka_rsi_hardware_interface** a parameter `robot_description` needs to be present on the ROS parameter server. This parameter can be set manually or by adding this line inside the launch file (replace support package and .xacro to match your application):

```
<param name="robot_description" command="$(find xacro)/xacro '$(find kuka_kr6_support)/urdf/kr6r900sixx.xacro'"/>
```

Make sure that the line is added before the `kuka_hardware_interface` itself is loaded.

## 4. Testing

At this point you are ready to test the RSI interface. Before the test, make sure that:

* You have specified the `rsi/listen_address` and `rsi/listen_port` of the **kuka_rsi_hardware_interface** to correspond with the KRL files on the controller.
* You have a launch-file loading the network parameters, robot description, kuka_hardware_interface, hardware controller and controller joint names.

The next steps describe how to launch the test file:

* In a new terminal:

```
$ roscore
```

* Open a new terminal and roslaunch the previously configured launch-file:

```
$ roslaunch kuka_rsi_hw_interface test_hardware_interface.launch sim:=false
```

The **kuka_rsi_hardware_interface** is now waiting for the robot controller to connect. Follow the next steps to connect RSI:

1. On the teach pad, enter mode **T1** for testing purposes.
2. Navigate to `KRC:\R1\Program` and select `ros_rsi.src`.
3. Press and hold an enabling switch and the run/play-button. The robot will first move to the start position. :speech_balloon: Noticed that the initial position was not the same as the initial position with the simulated robot (joint 5 was rotated by 90 degrees). Maybe I built the urdf wrong.
   * A message like **Programmed path reached (BCO)** will be shown at the teach pad.
4. Press and hold again. The teach pad will post a warning **!!! Attention - Sensor correction goes active !!!**.
5. Confirm the warning and press and hold the buttons again. This time the terminal where **kuka_rsi_hardware_interface** is running should output **Got connection from robot**. The RSI connection is now up and running. :speech_balloon: Here I got the error `Object Ethernet_1 returns error RSITimeout`.
6. In a new terminal:

```
$ rosrun rqt_joint_trajectory_controller rqt_joint_trajectory_controller
```

Choose **controller manager ns** and **controller** and you should be able to move each robot joint.

* Note that T1-mode limits the robot movement velocity and is intended for testing purposes.
