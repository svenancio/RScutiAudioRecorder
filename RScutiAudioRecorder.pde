import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.List;

Minim         minim;
AudioOutput   out;
AudioRecorder recorder;

//CONFIGS
//números coletados a partir da amostragem de 1910-2019 das magnitudes da estrela R Scuti (fonte AAVSO.org)
float initTime = 2418859.6;
float endTime = 2458528.94155;
float min = 1.0;
float max = 11.8;
float startPoint = 0;//usar acima de 0 apenas para gravar a partir de um ponto à frente 
float audioDuration = 108000; //em contagem de frames (verifique o framerate configurado no método setup)
int minFreq = 20;
int maxFreq = 200;


float curFreq;
float curMag;
Oscil wave, wave2;

String[] lines;
List<Float> RScutiTimes;
List<Float> RScutiMags;
SplineInterpolator interpolator;

void setup() {
  frameRate(30);
  
  lines = loadStrings("files/1910_2019.txt");
  RScutiTimes = new ArrayList<Float>();
  RScutiMags = new ArrayList<Float>();
  for(int i=0;i<lines.length;i++) {
    RScutiTimes.add(float(split(lines[i],';')[0]));
    RScutiMags.add(float(split(lines[i],';')[1]));
  }
  
  //cria a interpolação
  interpolator = SplineInterpolator.createMonotoneCubicSpline(RScutiTimes, RScutiMags);
  
  minim = new Minim(this);
  out = minim.getLineOut();
  recorder = minim.createRecorder(out, "RScuti_1hora.wav");
  
  wave = new Oscil( 4.0f,  1.0f, Waves.SINE );
  wave.patch( out );
  
  wave2 = new Oscil( 4.0f,  1.0f, Waves.SINE );
  //wave2.patch( out );
  
  recorder.beginRecord();
  
  println("starting record at "+hour()+":"+minute()+":"+second());
}

void draw() {
  
  if(frameCount+startPoint <= audioDuration) {// - audioDuration*0.1) {  
    curMag = interpolator.interpolate(map(frameCount+startPoint,1,audioDuration,initTime,endTime));
    //if(frameCount % 10 == 0) {
    //  println(curMag);
    //}
    if (!Float.isNaN(curMag)) {
      curFreq = map(curMag, min, max, minFreq, maxFreq);
      wave.setFrequency(curFreq);
      //wave2.setFrequency(curFreq*10);
    } else {
      println("error in line " + (frameCount+startPoint - 1));
    }
  } else {
    recorder.endRecord(); //<>//
    exit();
  }
}
