import processing.serial.*;
import oscP5.*;
import netP5.*;

int[] list; //Lista de valores que entran por serial
Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
float[] fadein = new float[2];
//float[] fadeout;
float[] segundos = new float [2];
int []timers = new int[2];
int []timersfocos = new int[2];
boolean[] booltimer = new boolean[2];
boolean[] prevbooltimer = new boolean[2];
boolean[] focoencendido = new boolean[2];
int []sensor = new int[2];

int valor1, valor2, valor3;
int fRate = 30;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup()
{
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  frameRate(fRate);

  for (int i=0; i<2; i++) {
    timers[i] = 0;
    segundos[i] = 0;
    prevbooltimer[i] = false;
    booltimer[i] = true;
    fadein[i] = 0;
    focoencendido[i]= true;
    //fadeout = 100;
  }
  //OSC
  oscP5 = new OscP5(this, 7000);
  myRemoteLocation = new NetAddress("127.0.0.1", 7000);
}

void draw() {

  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n');         // Lee los valores que entran por serial y los pone en un string.

    //println(val);
    if (val != null) {
      int[] list = int(split(val, ",")); 
      //Con split separa los valores que llegan por serial (ahora son 2, el [0] es el del sensor). 
      //Como tendremos que mandar varios sensores pensé que esta podía ser una manera 
      //fácil de mandarlos todos por el mismo serial.

      if (list.length >= 3) { // nos llegan 2 valores
        valor1 = list[0]; // valor del sensor
        //println("Sensor 1: " +valor1);
        valor2 = list[1]; // valor sensor2
        //println("Sensor 2: " + valor2);
        //valor3 = list[3]; //valro sensor3
        //println(valor3);
      }
    }
  }



  //print("prevbooltimer: "+prevbooltimer[0]+", ");
  //println("booltimer[0]: "+ booltimer[0]);
  //println("segundos[0]: " + segundos[0]);
  //println("ultrasonidos 1: " + valor1);
  //println("ultrasonidos 2: " + valor2);
  //println("ultrasonidos 2: " + valor3);



  //Aqui empieza la máquina de estados.

  //CASOS SENSOR 1

  if ((prevbooltimer[0]==false) && (booltimer[0]==true)) {
    sensor[0]= 0;

    //println("OPTION 1");
  } 
  if ((prevbooltimer[0]==true) && (booltimer[0]==true)) {
    sensor[0]= 0;

    //println("OPTION 2");
  } 
  if ((prevbooltimer[0]==true) && (booltimer[0]==false)) {
    sensor[0] = 1;

    //println("OPTION 3");
  }

  //CASOS SENSOR 2

  if ((prevbooltimer[1]==false) && (booltimer[1]==true)) {
    sensor[1]= 0;

    //println("CASE 1");
  } 
  if ((prevbooltimer[1]==true) && (booltimer[1]==true)) {
    sensor[1]= 0;

    //println("CASE 2");
  } 
  if ((prevbooltimer[1]==true) && (booltimer[1]==false)) {
    sensor[1]= 1;

    //println("CASE 3");
  }

  //CASOS SENSOR 3

  //if ((prevbooltimer[1]==false) && (booltimer[1]==true)) {
  //  sensor[2]= 0;

  //  println("CASE 1");
  //} 
  //if ((prevbooltimer[1]==true) && (booltimer[1]==true)) {
  //  sensor[2]= 0;

  //  println("CASE 2");
  //} 
  //if ((prevbooltimer[1]==true) && (booltimer[1]==false)) {
  //  sensor[2]= 1;

  //  println("CASE 3");
  //}



  //} else if ((prevbooltimer[0]=false) && (booltimer[0]=false)) {
  //  sensor[0] = 3;
  //} //Creo que esta condicion no se cumple nunca, así que la he comentado

  //SWITCH PARA EL PRIMER SENSOR
  switch(sensor[0]) {

  case 0: 
    //Solo he puesto dos casos porque creo que true+true y false+true hacen lo mismo.
    //println("sensor[0] " + sensor[0]);
    if (segundos[0]<10) {

      timers[0]++;

      if (fadein[0] < 1) {
        fadein[0] = fadein[0] + 0.01;
        //OSC
        OscMessage myMessage = new OscMessage("/composition/layers/1/video/opacity"); //VIDEO FADE IN
        myMessage.add(fadein[0]); 
        //send the message
        oscP5.send(myMessage, myRemoteLocation);

        OscMessage myMessage2 = new OscMessage("/composition/layers/3/audio/volume"); //AUDIO FADE IN
        myMessage2.add(fadein[0]); 
        //send the message
        oscP5.send(myMessage2, myRemoteLocation);
      }
      if (focoencendido[0]==true) {
        OscMessage myMessage = new OscMessage("/composition/layers/2/clips/2/connect"); //CAMBIA AL PLANO ANIMACION FOCOS
        myMessage.add(1); 
        oscP5.send(myMessage, myRemoteLocation);      
        focoencendido[0]=false;
      }

      if ((valor1>=15) && (valor1<=30)) {
        prevbooltimer[0] = booltimer[0];
        booltimer[0] = true;
        break;
      }
    } else if (segundos[0]>=10) {
      timers[0] = 0;
      prevbooltimer[0] = booltimer[0];
      booltimer[0] = false;
      focoencendido[0] = true;
      //CAMBIA OTRA VEZ AL ESTADO DE REPOSO
      OscMessage myMessage2 = new OscMessage("/composition/layers/2/clips/1/connect"); //CAMBIA AL PLANO POSICION INICIAL FOCOS
      myMessage2.add(1);
      oscP5.send(myMessage2, myRemoteLocation);

      //println("Mas de 10 segundos");
      for (int i=0; i<=1; i++) {
        fadein[0] = fadein[0] - 0.01;
        //OSC
        OscMessage myMessage = new OscMessage("/composition/layers/1/video/opacity"); // VIDEO FADE OUT
        myMessage.add(fadein[0]);
        oscP5.send(myMessage, myRemoteLocation);

        OscMessage myMessage3 = new OscMessage("/composition/layers/3/audio/volume"); //AUDIO FADE OUT
        myMessage3.add(fadein[0]); 
        oscP5.send(myMessage3, myRemoteLocation);
      }

      break;
    }
    break;

  case 1: 
    //println("sensor[0] " + sensor[0]);
    if ((valor1>=15) && (valor1<=30)) {
      prevbooltimer[0] = booltimer[0];
      booltimer[0] = true;

      break;
    } 

    break;
  }

  //SWITCH PARA EL SEGUNDO SENSOR

  switch(sensor[1]) {

  case 0: 
    //Solo he puesto dos casos porque creo que true+true y false+true hacen lo mismo.
    //println("sensor[1] " + sensor[1]);
    if (segundos[1]<10) {

      timers[1]++;

      if (fadein[1] < 1) {
        fadein[1] = fadein[1] + 0.01;
        //OSC
        OscMessage myMessage = new OscMessage("/composition/layers/4/video/opacity"); //VIDEO FADE IN
        myMessage.add(fadein[1]); 
        //send the message
        oscP5.send(myMessage, myRemoteLocation);

        OscMessage myMessage2 = new OscMessage("/composition/layers/6/audio/volume"); //AUDIO FADE OUT
        myMessage2.add(fadein[1]); 
        //send the message
        oscP5.send(myMessage2, myRemoteLocation);
      }
      if (focoencendido[1]==true) {
        OscMessage myMessage = new OscMessage("/composition/layers/5/clips/2/connect"); //CAMBIA AL PLANO ANIMACION FOCOS
        myMessage.add(1); 
        oscP5.send(myMessage, myRemoteLocation);      
        focoencendido[1]=false;
      }

      if ((valor2>=15) && (valor2<=30)) {
        prevbooltimer[1] = booltimer[1];
        booltimer[1] = true;
        break;
      }
    } else if (segundos[1]>=10) {
      timers[1] = 0;
      prevbooltimer[1] = booltimer[1];
      booltimer[1] = false;
      focoencendido[1] = true;
      //CAMBIA OTRA VEZ AL ESTADO DE REPOSO
      OscMessage myMessage2 = new OscMessage("/composition/layers/5/clips/1/connect"); //CAMBIA AL PLANO POSICION INICIAL FOCOS
      myMessage2.add(1);
      oscP5.send(myMessage2, myRemoteLocation);

      //println("Mas de 10 segundos");
      for (int i=0; i<=1; i++) {
        fadein[1] = fadein[1] - 0.01;
        //OSC
        OscMessage myMessage = new OscMessage("/composition/layers/4/video/opacity");
        myMessage.add(fadein[1]); /* add an int to the osc message */
        /* send the message */
        oscP5.send(myMessage, myRemoteLocation);

        OscMessage myMessage3 = new OscMessage("/composition/layers/6/audio/volume"); //AUDIO
        myMessage3.add(fadein[1]); 
        //send the message
        oscP5.send(myMessage3, myRemoteLocation);
      }

      break;
    }
    break;

  case 1: 
    //println("sensor[1] " + sensor[1]);
    if ((valor2>=15) && (valor2<=30)) {
      prevbooltimer[1] = booltimer[1];
      booltimer[1] = true;

      break;
    } 

    break;
  }

  // SWITCH PARA EL SENSOR 3

  //switch(sensor[2]) {

  //  case 0: 
  //    //Solo he puesto dos casos porque creo que true+true y false+true hacen lo mismo.
  //    //println("sensor[2] " + sensor[2]);
  //    if (segundos[2]<10) {

  //      timers[2]++;

  //      if (fadein[2] < 1) {
  //        fadein[2] = fadein[2] + 0.01;
  //        //OSC
  //        OscMessage myMessage = new OscMessage("/composition/layers/7/video/opacity"); //VIDEO
  //        myMessage.add(fadein[2]); 
  //        //send the message
  //        oscP5.send(myMessage, myRemoteLocation);

  //        OscMessage myMessage2 = new OscMessage("/composition/layers/9/audio/volume"); //AUDIO
  //        myMessage2.add(fadein[2]); 
  //        //send the message
  //        oscP5.send(myMessage2, myRemoteLocation);
  //      }
  //      if (focoencendido[2]==true) {
  //        OscMessage myMessage = new OscMessage("/composition/layers/8/clips/2/connect"); //CAMBIA AL PLANO ANIMACION FOCOS
  //        myMessage.add(1); 
  //        oscP5.send(myMessage, myRemoteLocation);      
  //        focoencendido[2]=false;
  //      }

  //      if ((valor1>=15) && (valor1<=30)) {
  //        prevbooltimer[2] = booltimer[2];
  //        booltimer[2] = true;
  //        break;
  //      }
  //    } else if (segundos[2]>=10) {
  //      timers[2] = 0;
  //      prevbooltimer[2] = booltimer[2];
  //      booltimer[2] = false;
  //      focoencendido[2] = true;
  //      //CAMBIA OTRA VEZ AL ESTADO DE REPOSO
  //      OscMessage myMessage2 = new OscMessage("/composition/layers/8/clips/1/connect"); //CAMBIA AL PLANO POSICION INICIAL FOCOS
  //      myMessage2.add(1);
  //      oscP5.send(myMessage2, myRemoteLocation);

  //      //println("Mas de 10 segundos");
  //      for (int i=0; i<=1; i++) {
  //        fadein[2] = fadein[2] - 0.01;
  //        //OSC
  //        OscMessage myMessage = new OscMessage("/composition/layers/7/video/opacity");
  //        myMessage.add(fadein[2]); /* add an int to the osc message */
  //        /* send the message */
  //        oscP5.send(myMessage, myRemoteLocation);

  //        OscMessage myMessage3 = new OscMessage("/composition/layers/9/audio/volume"); //AUDIO
  //        myMessage3.add(fadein[2]); 
  //        //send the message
  //        oscP5.send(myMessage3, myRemoteLocation);
  //      }

  //      break;
  //    }
  //    break;

  //  case 1: 
  //    //println("sensor[2] " + sensor[2]);
  //    if ((valor1>=15) && (valor1<=30)) {
  //      prevbooltimer[2] = booltimer[2];
  //      booltimer[2] = true;

  //      break;
  //    } 

  //    break;
  //  }



  for (int j=0; j<=1; j++) {
    segundos[j] = timers[j]/fRate;
  }
  println("ESTADO SENSOR 1: cm="+valor1+ " caso= "+sensor[0]+ " segundos= "+segundos[0]);
  println("ESTADO SENSOR 2: cm="+valor2+ " caso=: "+sensor[1]+ " segundos= "+segundos[1]);
  //println("ESTADO SENSOR 3: cm="+valor3+ " caso=: "+sensor[2]+ " segundos= "+segundos[2]);
}
