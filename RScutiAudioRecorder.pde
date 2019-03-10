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
float audioDuration = 3000; //em contagem de frames (verifique o framerate configurado no método setup)
int minFreq = 20;
int maxFreq = 300;


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
  recorder = minim.createRecorder(out, "RScutiGrealidades.wav");
  
  wave = new Oscil( 4.0f,  1.0f, Waves.SINE );
  wave.patch( out );
  
  wave2 = new Oscil( 4.0f,  1.0f, Waves.SINE );
  //wave2.patch( out );
  
  recorder.beginRecord();
}

void draw() {
  
  if(frameCount <= audioDuration) {  
    curMag = interpolator.interpolate(map(frameCount,1,audioDuration,initTime,endTime));
    //if(frameCount % 10 == 0) {
    //  println(curMag);
    //}
    if (!Float.isNaN(curMag)) {
      curFreq = map(curMag, min, max, minFreq, maxFreq);
      wave.setFrequency(curFreq);
      wave2.setFrequency(curFreq*2);
    } else {
      println("error in line " + (frameCount - 1));
    }
  } else {
    recorder.endRecord();
  }
}
