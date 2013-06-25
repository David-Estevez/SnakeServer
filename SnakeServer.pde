//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//-- Snake Server
//------------------------------------------------------------------------------
//-- Let your computer make all the work! This server is in charge of the basic 
//-- movements of the oscillators, communicate to it throught a serial connection
//-- and your computer can take care of the algorithms, waves and movements.
//-- 
//-- For more info, read README.md
//------------------------------------------------------------------------------
//-- Author: 
//-- David Estévez-Fernández, May 2012
//-- GPL license
//------------------------------------------------------------------------------
//-- Requires ArduSnake, made by Juan González-Gómez (Obijuan):
//-- https://github.com/Obijuan/ArduSnake
//------------------------------------------------------------------------------

#include "skymega.h"

#include <Servo.h>
#include <Oscillator.h>
#include <Worm.h>


//-- CONFIGURATION ------------------------------------------------------------
//-----------------------------------------------------------------------------

//-- Communication configuration:
//-----------------------------------------------------
#define BAUD_RATE 9600
#define INIT_KEY 1234
#define BUFFER_SIZE 16

char buffer[BUFFER_SIZE];

//-- Servo configuration
//-----------------------------------------------------
//--Define the possible orientations:
#define X_AXIS 0
#define Y_AXIS 1

//--Number of servos using in each orientation
#define SERVO_ORIENT_1 3
#define SERVO_ORIENT_2 2

//-- One Worm by orientation
Worm snake[2]; 

//-- The whole snake has only one period, T:
int T = 4000;

//-- The rest of the servo configuration has to be done
//-- at the setup() function


//-- Sensor configuration
//-----------------------------------------------------
//-- Defining type "Sensor":
struct Sensor{
	int pin;
	int type; //-- Analog (0) or ultrasonic (PING) (1)
	};
typedef struct Sensor Sensor;

//-- Define the sensors:
#define NUM_SENSOR 0

Sensor sensor[NUM_SENSOR] = {
	//{SERVO4, 0}
};

//-- END OF CONFIGURATION



//-- SETUP -----------------------------------------------------------
//--------------------------------------------------------------------

void setup()
{
	//-- This is the configuration I work with in my snake, you
	//-- will have to define your own structure:
	//-- X-axis modules:
	snake[X_AXIS].add_servo(SERVO2);
	snake[X_AXIS].add_servo(SERVO1);
	snake[X_AXIS].add_servo(SERVO8);

	//-- Y-axis modules:
	snake[Y_AXIS].add_servo(SERVO4);
	snake[Y_AXIS].add_servo(SERVO6);

	//-- Put all the modules in a straight, waiting state:
	Wave straight = {T, 0, 0, 0, 0};
	snake[X_AXIS].set_wave( straight );
	snake[Y_AXIS].set_wave( straight );

	//-- Set the communication:
	bool connected = false;
	Serial.begin(BAUD_RATE);
        Serial.println("Ready!");
	Serial.flush();

	while( !connected )
		connected = autentication();
}

//-- END OF SETUP



//-- MAIN LOOP ------------------------------------------------------
//-------------------------------------------------------------------

void loop()
{
	if ( Serial.available() > 0 )
	{
		//-- Recieve the command:
		delay(20); //-- Waits for the buffer to be filled

		int data = Serial.available(); //-- Number of bytes recieved
		
		if (data > BUFFER_SIZE) //--Avoid overflow
			data = BUFFER_SIZE;

		for ( int i = 0; i < data; i++) //-- Write the data on the buffer
			buffer[i] = Serial.read(); 

		//-- Decrypt the command:
		if ( buffer[0] == 'X' || buffer[0] == 'Y')
		{
			//-- Manage "XY" codes: movements
			xy_code( buffer );
		}
		else if ( buffer[0] == 'T')
		{
			//-- T code: change period of the snake
			//-------------------------------------------
			//-- Retrieve the period:
			T = strtol( buffer+1 , NULL, 10);

			//-- Set the new period:			
			snake[X_AXIS].SetT( T );
			snake[Y_AXIS].SetT( T );
		}
		else if (buffer[0] == 'S')
		{
			//-- Manage "S" codes: sensor data
			s_code( buffer );
		}
		else if (buffer[0] == 'P' && buffer[1] == 'I'
				&& buffer[2] == 'N' && buffer[3] == 'G')
		{	
			//-- PING: checks the connection
			Serial.println("Ok");
		}

		//-- If it doesn't recognize the command, or has received it correctly
		//-- prepare for a new command:
		Serial.flush();
		erase(buffer);
	}
	
	//-- Update/refresh snake movement
	snake[X_AXIS].refresh();
	snake[Y_AXIS].refresh();
}

//-- END OF MAIN LOOP



//-- PROGRAM FUNCTIONS ---------------------------------------------
//-- ---------------------------------------------------------------

//-- This erases the buffer when needed
void erase( char *buffer)
{
	for (int i; i < BUFFER_SIZE ; i++) { buffer[i] = '\0';}
}


//-- This takes charge of stablishing a moreless secure communication at the beginning
bool autentication()
{
	if ( Serial.available() > 0)
	{
		delay(20); //-- Waits for the buffer to be filled

		int data = Serial.available(); //-- Number of bytes recieved
		
		if (data > BUFFER_SIZE) //--Avoid overflow
			data = BUFFER_SIZE;

		for ( int i = 0; i < data; i++) //-- Write the data on the buffer
			buffer[i] = Serial.read(); 
		
		//--  If it is not recieving an autentication code (code starting by
		//-- 'i', it can not be autenticated, return false:

		if ( buffer[0] != 'i')
			return false; 	
		else
		{	
			//-- Check the key number
			if ( atoi( buffer+1) == INIT_KEY)
			{
				Serial.println("Ok!");
				Serial.flush();
				erase(buffer);
				return true;
			}
			else
			{
				Serial.println("Autentication error!");
				Serial.flush();
				erase(buffer);
				return false;
			}
		}
	}
	else
		return false;
}

//-- Manage "XY" codes: movements
int xy_code( char *buffer )
{
	int index_x = -2, index_y = -2; //-- ("-2" simply means: "no servo selected")
 
	if ( buffer[0] == 'X' )
	{
		if ( buffer[1] == 'Y' )
		{
			//-- Modifications affect all servos in both axis:
			//-- "All servos" is represented by "-1" position.
			index_x = -1;
			index_x = -1;
		}
		else
		{
                         Serial.println( (int)buffer[1]);
			//-- Modifications that affect only servos in x axis:
			if ( buffer[1] > 47 && buffer[1] < 58 ) //-- If the next character is a digit
			{
				//-- A single servo is specified:
				index_x = strtol( buffer + 1, NULL, 10);
                                Serial.print( "Index: "); 
                                Serial.println( index_x);
			}
			else
			{
				//-- All servos in X axis are affected:
				//-- "All servos" is represented by "-1" position.
				index_x = -1;
			}
		}
	}
	else if ( buffer[0] == 'Y')
	{
		//-- Modifications that affect only servos in y axis:
		if ( buffer[1] > 47 && buffer[1] < 58 ) //-- If the next character is a digit
		{
			//-- A single servo is specified:
			index_y = strtol( buffer + 1, NULL, 10);
		}
		else
		{
			//-- All servos in X axis are affected:
			//-- "All servos" is represented by "-1" position.
			index_y = -1;
		}
	}

	//-- Make changes
	//-- Get the length of the command:
	int command_length = strcspn( buffer, "\0");
	
	//-- Get the position of the possible commands:	
	int a_pos = strcspn ( buffer, "A");
     	int p_pos = strcspn ( buffer, "P");
     	int o_pos = strcspn ( buffer, "O");
	
	if ( a_pos < command_length )
	{
		//-- Get the new value:
		int new_amplitude = strtol( buffer + a_pos +1, NULL, 10);

		//-- Apply the new value:
		if (index_x != -2)
			snake[X_AXIS].SetA( new_amplitude, index_x );
		if (index_y != -2)
			snake[Y_AXIS].SetA( new_amplitude, index_y );
			
	}

	if (p_pos < command_length )
	{
		//-- Get the new value:
		int new_phase = strtol( buffer + p_pos +1, NULL, 10);

		//-- Apply the new value:
		if (index_x != -2)
			snake[X_AXIS].SetPd( new_phase , index_x);
		if (index_y != -2)
			snake[Y_AXIS].SetPd( new_phase , index_y);
	}
	
	if (o_pos < command_length )
	{
		//-- Get the new value:
		int new_offset = strtol( buffer + o_pos +1, NULL, 10);

		//-- Apply the new value:
		if (index_x != -2)
			snake[X_AXIS].SetO( new_offset, index_x );
		if (index_y != -2)
			snake[Y_AXIS].SetO( new_offset, index_y );
	}


	return 0;
}

//-- Manage "S" codes: sensor data
int s_code( char *buffer )
{	
	//-- Get index of sensor
	int index = strtol( buffer+1, NULL, 10);
	
	if (index > NUM_SENSOR - 1)
	{
		//-- Trying to access a nonexistent sensor.
		//-- Exit the function returning an error:		
		return -1; 
	}
	else
	{
		//-- Different kinds of sensor have different kinds of
		//-- ways of returning the measure
 
		if ( sensor[index].type == 0)
		{
			//-- Analog sensor managing:
			int signal = analogRead( sensor[index].pin );
			//Serial.print( "Sensor read: "); //-- Just for debugging
			Serial.println( signal );
		}
		else if (sensor[index].type == 1)
		{
			//-- Utrasonic sensor
			//Serial.print("Distance: "); //-- Just for debugging
			Serial.println( ultrasound_sensor( sensor[index].pin ));		
		}

		//-- More kinds of sensor actions would go here

		return 0;
	}
}

long ultrasound_sensor( int pingPin )
{	
	//-- Ultrasonic sensor read
	//--------------------------------------------------
	//--  http://www.arduino.cc/en/Tutorial/Ping
	//--------------------------------------------------
	
	// establish variables for duration of the ping, 
  	// and the distance result in inches and centimeters:
  	long microseconds, cm;

  	// The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
	// Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
	pinMode(pingPin, OUTPUT);
	digitalWrite(pingPin, LOW);
	delayMicroseconds(2);
	digitalWrite(pingPin, HIGH);
	delayMicroseconds(5);
	digitalWrite(pingPin, LOW);

	// The same pin is used to read the signal from the PING))): a HIGH
	// pulse whose duration is the time (in microseconds) from the sending
	// of the ping to the reception of its echo off of an object.
	pinMode(pingPin, INPUT);
	microseconds = pulseIn(pingPin, HIGH);

	// The speed of sound is 340 m/s or 29 microseconds per centimeter.
	// The ping travels out and back, so to find the distance of the
	// object we take half of the distance travelled.
	cm =  microseconds / 29 / 2;

	return cm;
}

//-- END OF PROGRAM FUNCTIONS


