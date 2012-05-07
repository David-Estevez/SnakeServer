
			SnakeServer
=====================================================================

 Author: [David Estévez-Fernández](http://github.com/David-Estevez)

 Released under GPL license , May 2012



Firmware for robotics snake that manages movement and sensor data.

---------------------------------------------------------------------

* 1.Introduction
* 2.Installation
* 3.Usage
	* 3.1.Configuration
	* 3.2.Commands
* 4.Version log

----------------------------------------------------------------------



1.Introduction
----------------------------------------------------------------------
Inspired by CNC machines firmware, driven by Gcodes, I have made this
firmware for modular robots based on Arduino and the ArduSnake library.

This firmware communicates through a serial port with a computer, 
managing just the oscillations and the sensor data capturing and 
letting the computer deal with the motion algorithms. There is no need
to upload several firmwares to the robot with different algorithms, 
just change the computer software and Snake Server takes care of the rest.

PC server for controlling the robot coming soon!

2.Installation
------------------------------------------------------------------------
* First of all, Arduino IDE is needed to compile the sketch and upload it 
to the Skymega / Arduino board. You can download it here:
[Arduino IDE](http://arduino.cc/hu/Main/Software)

* ArduSnake, made by Juan González-Gómez (Obijuan), is also needed. It can
be downloaded here:

[ArduSnake](http://github.com/Obijuan/ArduSnake)

It has to be installed as an Arduino library, in your libraries folder.

* Once the previous requirements are installed, you have to configure the
.pde file with the values according to your robot, and then you can open
the sketch with the Arduino IDE and upload it to your modular robot.

3.Usage
------------------------------------------------------------------------
3.1.Configuration

Inside the .pde file there are some parameters that need to be adjusted:

-Communication parameters:
.BAUD_RATE: choose the apropiate for your serial connection.
.INIT_KEY: key that identifies your robot. It is used for stablishing a
"secure" connection.


- Modules and arrangement configuration:
	* Number of axis (1/2): linear modular robot or 2D robot. In the future
support for more axes will be implemented. 

	* Define the number of servos/modules in each orientation. Then,
on setup() you add/remove the ones you are using and select pin and type 
of servo (genuine futaba/chinese futaba servo).

	* Define the number of sensors, the pin in which are connected and its
type. Currently are implemented "analog" which returns the value from
0-1023 that the analog input reads and "ultrasound" which return the 
distance in cm read by the sensor.

3.2.Commands
- Stablishing connection
	* The firmware accepts commands when it recieves a string that starts with
i and contains the init key (i.e "i1234")
	* It is possible to check a connection by sending "PING". The firmware 
returns "Ok" as answer to that command.

- Movements:

	- "XY"codes:
		* Are composed by the identifier of the axis (X, Y, or both) plus a number
selecting a position inside that axis. If no position is specified it
affects to all servos in that axis.

		* After that goes the identifier of the parameter plus the value:
			A for amplitude
			P for phase
			O for offset

		* Examples of XY codes:
			XYA60 (sets the amplitude of all servos to 60 degrees)
			YO45 (sets the offset of all servos in Y axis to 45 degrees)
			X0P-180 (sets the phase of the first X axis servo to -180 degrees)

		*It is possible to specify more than one parameter at a time:
			X0A60O15P120 (sets amplitude, phase and offset of first servo)

- "S" codes:
	* Are use to retrieve the value of a sensor. It sintax is S + index of sensor
I.e:
	S0 (returns the value measured by the first sensor)

- "T" (period)
	* Sets the value of the period of the oscillations
	I.e:
		T1000 

	* Affects to all modules of the robot
  
4.Version Log
------------------------------------------------------------------------

v1.0 Just released!
