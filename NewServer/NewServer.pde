#include <Servo.h>

  static const int NUM_SERVOS = 3;
  static const int PIN_SERVOS[NUM_SERVOS] = { 9, 10, 8};
  static Servo servo[ NUM_SERVOS];
  static int servo_pos[NUM_SERVOS] = { 90, 90, 90};
  
  static const int BAUD_RATE = 9600;
  static const int BUFFER_SIZE = 20;

  static char buffer[BUFFER_SIZE];
  
void setup()
{
  for (int i = 0; i < NUM_SERVOS; i++)
  {
    servo[i].attach( PIN_SERVOS[i] );
    servo[i].write( 0);
  }
  
  Serial.begin( BAUD_RATE);
  Serial.flush();
  Serial.println( "Connected. Waiting for commands.");
  
}
void loop()
{
    if ( Serial.available() > 0)
    {
	delay(20); //-- Waits for the buffer to be filled

	int data = Serial.available(); //-- Number of bytes recieved
        
        //Serial.print( "\tReceived: ");
        //Serial.println( data, DEC);
        
        if (data > BUFFER_SIZE) //--Avoid overflow
			data = BUFFER_SIZE;

        //Serial.print("\tString:");
	for ( int i = 0; i < data; i++) //-- Write the data on the buffer
		{
                  buffer[i] = Serial.read();
                  //Serial.print( buffer[i] );
                }
        //Serial.print("\tTokens:"); 
        Serial.print( "Angles: ");
        
	int length = strcspn( buffer, "\0");
        char * last = buffer;
        
        for (int i = 0; i < NUM_SERVOS; i++)
        {
            servo_pos[i]=strtol(last, &last, 10);
           // Serial.print( servo_pos[i]);
        }
        
        Serial.flush();
        erase( buffer);
        
        for ( int i = 0; i < NUM_SERVOS; i++) //-- Write the data on the buffer
		{
                Serial.print( servo_pos[i], DEC);
                Serial.print( " ");
                }
                
       Serial.println("");
    }
  setValues( servo, servo_pos);
}

//-- This erases the buffer when needed
void erase( char *buffer)
{
	for (int i; i < BUFFER_SIZE ; i++) { buffer[i] = '\0';}
}

void setValues( Servo * servo, int * angle )
{
  for (int i = 0; i < NUM_SERVOS; i++)
      servo[i].write( angle[i]);
}

