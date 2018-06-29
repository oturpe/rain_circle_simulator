/**
 * Drop pattern simulator for As above, so below installation.
 *
 * Author: Otto Urpelainen
 * Date: 2018-06-29
 *
 * Coordinates are centimeters. 
 */
 
float ringRadius;

// One centimeter in pixels
float cm = 4.0;

// Size of screen
// These have to match values used in call to size()
float myHeight = 200*cm;
float myWidth = 200*cm;

// Diameter of the pool
float poolDiameter = 148*cm;

// Speed of wave in the pool
int fps = 20;
float speed = poolDiameter/(2*3.66*fps);

// Time after which the sequence starts from the beginning.
int maxTime = 10*fps;

// Distance between two adjacent drop points
float dropDistance = (37.5/2)*cm;

// Positions of all drop points, indexed as [ring][clockwise position].
// Ring 0 middle, coordinates are ordered {x, y} as usual.
float[][][] dropPositions = {
  // Center
  {
    {myWidth/2,                    myHeight/2}
  },
  // First ring
  {
    {myWidth/2 - 0.5*dropDistance, myHeight/2 - 0.5*sqrt(3)*dropDistance},
    {myWidth/2 + 0.5*dropDistance, myHeight/2 - 0.5*sqrt(3)*dropDistance},
    {myWidth/2 + 1*dropDistance,   myHeight/2},
    {myWidth/2 + 0.5*dropDistance, myHeight/2 + 0.5*sqrt(3)*dropDistance},
    {myWidth/2 - 0.5*dropDistance, myHeight/2 + 0.5*sqrt(3)*dropDistance},
    {myWidth/2 - 1*dropDistance,   myHeight/2},
  },
  // Second ring
  {
    {myWidth/2 - 1*dropDistance,   myHeight/2 - sqrt(3)*dropDistance},
    {myWidth/2,                    myHeight/2 - sqrt(3)*dropDistance},
    {myWidth/2 + 1*dropDistance,   myHeight/2 - sqrt(3)*dropDistance},
    {myWidth/2 + 1.5*dropDistance, myHeight/2 - 0.5*sqrt(3)*dropDistance},
    {myWidth/2 + 2*dropDistance,   myHeight/2},
    {myWidth/2 + 1.5*dropDistance, myHeight/2 + 0.5*sqrt(3)*dropDistance},
    {myWidth/2 + 1*dropDistance,   myHeight/2 + sqrt(3)*dropDistance},
    {myWidth/2,                    myHeight/2 + sqrt(3)*dropDistance},
    {myWidth/2 - 1*dropDistance,   myHeight/2 + sqrt(3)*dropDistance},
    {myWidth/2 - 1.5*dropDistance, myHeight/2 + 0.5*sqrt(3)*dropDistance},
    {myWidth/2 - 2*dropDistance,   myHeight/2},
    {myWidth/2 - 1.5*dropDistance, myHeight/2 - 0.5*sqrt(3)*dropDistance},
  }
};

class Drop {
  // Moment of impact
  int impactTime;
  // Ring of impact
  int ring;
  // Number of drop
  int dropNumber;
  
  Drop(int impactTime, int ring, int dropNumber) {
    this.impactTime = impactTime;
    this.ring = ring;
    this.dropNumber = dropNumber;
  }
  
  void draw(int currentTime) {
    int duration = currentTime - impactTime;
    if (duration < 0) {
      // Nothing to draw
      return;
    }
    
    ringRadius = speed*duration;
    ellipse(
      dropPositions[ring][dropNumber][0],
      dropPositions[ring][dropNumber][1],
      ringRadius,
      ringRadius
    );
  } 
}

ArrayList<Drop> drops = new ArrayList<Drop>();

int strokeColor = 80;

void setup() {
  // Have to do centimeter conversion here, since e.g. 200*cm cannot be
  // written into this particular call.
  size(800, 800);

  setDropSequence();
  frameRate(fps);
  // Start from moment of drop
  ringRadius = 0;
  
  noFill();
  stroke(strokeColor);
  ellipseMode(RADIUS);
}

void setDropSequence() {
  // Spiral
  /*
  drops.add(new Drop(0, 1, 0));
  drops.add(new Drop(4, 1, 1));
  drops.add(new Drop(8, 1, 2));
  drops.add(new Drop(12, 1, 3));
  drops.add(new Drop(16, 1, 4));
  drops.add(new Drop(20, 1, 5));
  */

  // Two triangles
  drops.add(new Drop(10, 1, 0));
  drops.add(new Drop(10, 1, 2));
  drops.add(new Drop(10, 1, 4));
  
  drops.add(new Drop(15, 1, 1));
  drops.add(new Drop(15, 1, 3));
  drops.add(new Drop(15, 1, 5));
}

int currentTime = 0;

void draw() {
  background(strokeColor);
  fill(0);
  ellipse(width/2, height/2, poolDiameter/2, poolDiameter/2);
  noFill();

  currentTime += 1;
  if (currentTime > maxTime) {
    currentTime = 0;
  }

  for (Drop drop: drops) {
    drop.draw(currentTime);
  }

  // Example pattern: one whole ring
  /*
  ringRadius = ringRadius + speed;
  float dropRing[][] = dropPositionsCentric[2];
  for (int i=0; i<dropRing.length; i++) {
    ellipse(dropRing[i][0], dropRing[i][1], ringRadius, ringRadius);
  }
  */
}
