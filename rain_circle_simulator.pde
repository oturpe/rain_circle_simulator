/**
 * Drop pattern simulator for As above, so below installation.
 *
 * Author: Otto Urpelainen
 * Date: 2018-06-29
 *
 * Coordinates are centimeters. 
 */
 
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

/**
 * A single drop impacting the surface at a specified moment of time and
 * the ring wave created by it.
 *
 * Drop position is given by specifying the ring to which it belongs and
 * position on that ring. Time of impact is given as animation frame number.
 *
 * The ring caused by the drop is drawn by calling the draw() method. 
 */
class Drop {
  // Ring of impact
  Ring ring;
  // Position index in the ring
  int position;
  // Moment of impact
  int impactFrame;
  
  /**
   * Initialize a new drop.
   *
   * @param ring
   *    Ring of this drop
   *
   * @param position
   *    Position index
   *
   * @param impactFrame
   *    Time of impact
   */
  Drop(Ring ring, int position, int impactFrame) {
    this.ring = ring;
    this.position = position % ring.getDropCount();
    this.impactFrame = impactFrame;
  }

  /**
   * Draws the ring caused by this drop.
   *
   * Current frame is passed in as parameter so that internal
   * frameNumber parameter can be preprocessed before passing it here.
   * This can be used to make the animation cyclic.
   *
   * @param currentFrame
   *    Current running frame
   */
  void draw(int currentFrame) {
    int duration = currentFrame - impactFrame;
    if (duration < 0) {
      // Nothing to draw
      return;
    }
    
    float ringRadius = speed*duration;
    ellipse(
      dropPositions[ring.getIndex()][position][0],
      dropPositions[ring.getIndex()][position][1],
      ringRadius,
      ringRadius
    );
  } 
}

// List of drops in simulation.
ArrayList<Drop> drops = new ArrayList<Drop>();

/**
 * Add drop with given properties to the drop list using simple
 * syntax.
 *
 * @param ring
 *    Drop ring
 *
 * @param position
 *    Position in the ring
 *
 * @param impactFrame
 *    Time of impact
 */
void addDrop(Ring ring, int position, int impactFrame) {
  drops.add(new Drop(ring, position, impactFrame));
}

// Stroke color in animation
int strokeColor = 80;

void setup() {
  // Have to do centimeter conversion here, since e.g. 200*cm cannot be
  // written into this particular call.
  size(800, 800);

  // Modify setDropPattern() method to define simulated pattern
  setDropPattern();
  frameRate(fps);
  
  noFill();
  stroke(strokeColor);
  ellipseMode(RADIUS);
}

void draw() {
  background(strokeColor);
  // Pool shape
  fill(0);
  ellipse(width/2, height/2, poolDiameter/2, poolDiameter/2);
  noFill();

  // Drops, 
  for (Drop drop: drops) {
    drop.draw(frameCount % maxTime);
  }
}

/**
 * Sets the drop sequence. This is the only function that should need
 * any modification in normal use of this simulator.
 */
void setDropPattern() {
  // Two triangles
  /*
  addDrop(Ring.INNER, 0, 10);
  addDrop(Ring.INNER, 2, 10);
  addDrop(Ring.INNER, 4, 10);
  
  addDrop(Ring.INNER, 1, 10);
  addDrop(Ring.INNER, 3, 10);
  addDrop(Ring.INNER, 5, 10);
   */
   
  // Spiral
  addDrop(Ring.INNER, 6, 2);
  addDrop(Ring.INNER, 1, 4);
  addDrop(Ring.INNER, 2, 6);
  addDrop(Ring.INNER, 3, 8);
  addDrop(Ring.INNER, 4, 10);
  addDrop(Ring.INNER, 5, 12); 
}
