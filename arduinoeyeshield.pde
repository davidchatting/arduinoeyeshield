//David Chatting - david@davidchatting.com
//29th March 2010
//---

#define compSyncPin 14  //A0  LM1881N:  PIN 1
#define vertSyncPin 15  //A1            PIN 3
#define burstPin    16  //A2            PIN 5
#define oddEvenPin  17  //A3            PIN 7
#define videoPin    18  //A4

#define refVoltagePin 5

#define linesInPicture 625  //PAL
#define numSamplesX 8
#define numSamplesY 8

int lineCount=1;
int picture[numSamplesX][numSamplesY];

int everyNthLine = floor((linesInPicture/2)/numSamplesY);

void setup() {
  pinMode(compSyncPin,INPUT);
  pinMode(vertSyncPin,INPUT);
  pinMode(burstPin,INPUT);
  pinMode(oddEvenPin,INPUT);
  
  pinMode(videoPin,INPUT);
  
  pinMode(refVoltagePin,OUTPUT);
  pinMode(3,OUTPUT);
  setRefVoltage(2.5f);
  
  Serial.begin(57600);
}

void loop(){
  int y=0;
  
  if(!digitalRead(oddEvenPin)){
    while(!digitalRead(oddEvenPin));
    while(!digitalRead(vertSyncPin));
    
    while(digitalRead(oddEvenPin)){
      if((lineCount%everyNthLine)==0){
        //off the shelf analogRead: takes approx 0.1 mS = 100 uS on Decimilla, but 1 line takes 64 uS - boo!
        //hacked version (16) 16 samples in 1000 17ms => 1 sample and write in 17 uS'ish => can do 3 samples of video signal
        //a digital read does 1000 samples and writes in 4mS => 4us per sample => good! => 16 samples
        //line=0;
        
        for(int x=0;x<numSamplesX;++x){
          picture[x][y]=digitalRead(videoPin);
        }
        
        ++y;
      }
      ++lineCount;
      
      while(digitalRead(burstPin));
    }
    //this now happens on the odd frame...
    
    setLEDs();
    lineCount=1;
  }
}

void setLEDs(){
  int i=0;
  for(int y=0;y<numSamplesY;++y){
    for(int x=0;x<numSamplesX;++x){
      if(picture[x][y]) Serial.print(1);
      else Serial.print(0);
    }
    Serial.println();
  }
  Serial.println();
}

void setRefVoltage(float v){
  if(v>=0 && v<=5.0){
    analogWrite(refVoltagePin,(255*v)/5);
    analogWrite(3,(255*v)/5);
  }
}
