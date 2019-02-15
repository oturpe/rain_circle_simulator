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
float myHeight = 150*cm;
float myWidth = 150*cm;

// Diameter of the pool
float poolDiameter = 148*cm;

// Speed of wave in the pool
int fps = 20;
float speed = poolDiameter/(2*3.66*fps);

// Time after which the sequence starts from the beginning.
int maxTime = 0;

// Distance between two adjacent drop points
float dropDistance = (37.5/2)*cm;

// Stroke properties in animation
int strokeColor = 50;
int strokeWeight = 3;

// Positions of all drop points, indexed as [ring][clockwise position].
// Ring 0 middle, coordinates are ordered {x, y} as usual.
float[][][] dropPositions = {
  // Center
  {
    {0, 0}
  },
  // First ring
  {
    {- 0.5*dropDistance, - 0.5*sqrt(3)*dropDistance},
    {+ 0.5*dropDistance, - 0.5*sqrt(3)*dropDistance},
    {+ 1*dropDistance,   0},
    {+ 0.5*dropDistance, + 0.5*sqrt(3)*dropDistance},
    {- 0.5*dropDistance, + 0.5*sqrt(3)*dropDistance},
    {- 1*dropDistance,   0},
  },
  // Second ring
  {
    {- 1*dropDistance,   - sqrt(3)*dropDistance},
    {0,                  - sqrt(3)*dropDistance},
    {+ 1*dropDistance,   - sqrt(3)*dropDistance},
    {+ 1.5*dropDistance, - 0.5*sqrt(3)*dropDistance},
    {+ 2*dropDistance,   0},
    {+ 1.5*dropDistance, + 0.5*sqrt(3)*dropDistance},
    {+ 1*dropDistance,   + sqrt(3)*dropDistance},
    {0,                  + sqrt(3)*dropDistance},
    {- 1*dropDistance,   + sqrt(3)*dropDistance},
    {- 1.5*dropDistance, + 0.5*sqrt(3)*dropDistance},
    {- 2*dropDistance,   0},
    {- 1.5*dropDistance, - 0.5*sqrt(3)*dropDistance},
  }
};

// Predefined drop pattens
static int PATTERN_TRIANGLE_EVEN = 0;
static int PATTERN_TRIANGLE_ODD = 1;
static int PATTERN_HEXAGON = 2;
static int PATTERN_SPIRAL =3;

/**
 * Enumeration of the three drop rings of the machine.
 */
public class Ring {
  // Ring index
  int index;
  // Number of drop position in this ring
  int dropCount;
  
  /**
   * Initialize a new Ring enum.
   *
   * @param index
   *    Ring index
   *
   * @param dropCount
   *    Count of drop positions
   */
  private Ring(int index, int dropCount) {
    this.index = index;
    this.dropCount = dropCount;
  }

  /**
   * Return ring index.
   *
   * @return
   *    Ring index
   */
  public int getIndex() {
    return index;
  }

  /**
   * Return drop count.
   *
   * @return
   *    Drop count
   */
  public int getDropCount() {
    return dropCount;
  }
}

Ring RING_MIDDLE = new Ring(0, 1);
Ring RING_INNER = new Ring(1, 6);
Ring RING_OUTER = new Ring(2, 13);
  
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

/**
 * A piece of text to be shown alongside animation for a 
 * specified time.
 */
public class Legend {
  // The text to display
  String text;
  // First moment display
  int startFrame;
  // Last moment display
  int endFrame;
  
  /**
   * Initialize a new legend.
   *
   * @param text
   *    Text to display
   *
   * @param startFrame
   *    First moment of display
   *
   * @param endFrame
   *    Last moment of display
   */
  Legend(String text, int startFrame, int endFrame) {
    this.text = text;
    this.startFrame = startFrame;
    this.endFrame = endFrame;
  }
  
  /**
   * Draws the legend.
   *
   * Current frame is passed in as parameter so that internal
   * frameNumber parameter can be preprocessed before passing it here.
   * This can be used to make the animation cyclic.
   *
   * @param currentFrame
   *    Current running frame
   */
  void draw(int currentFrame) {  
    if (startFrame > currentFrame || currentFrame > endFrame) {
      // Nothing to draw
      return;
    }

    text(text, 0, 0);
  }
}

// List of drops in simulation.
ArrayList<Drop> drops = new ArrayList<Drop>();
ArrayList<Legend> legends = new ArrayList<Legend>();


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
  
  // A moment in time when it is guaranteed that the wave has disappeared...
  int lastsUntil = impactFrame +  (int)(poolDiameter/speed);
  // ...padded with some silent time
  lastsUntil += 5*fps;
  
  maxTime = max(maxTime, lastsUntil);
}

void addPattern(int pattern, int startFrame, boolean displayLegend) {
  String legend = "undefined_legend";
  if (pattern == PATTERN_TRIANGLE_EVEN) {
    legend = "Fire triangle";
    addDrop(RING_INNER, 0, startFrame);
    addDrop(RING_INNER, 2, startFrame);
    addDrop(RING_INNER, 4, startFrame);
  }
  else if (pattern == PATTERN_TRIANGLE_ODD) {
    legend = "Water triangle";
    addDrop(RING_INNER, 1, startFrame);
    addDrop(RING_INNER, 3, startFrame);
    addDrop(RING_INNER, 5, startFrame);
  }
  else if (pattern == PATTERN_HEXAGON) {
    legend = "Hexagon";
    addPattern(PATTERN_TRIANGLE_EVEN, startFrame, false);
    addPattern(PATTERN_TRIANGLE_ODD, startFrame, false);
  }
  else if (pattern == PATTERN_SPIRAL) {
    legend = "Spiral";
    addDrop(RING_INNER, 6, startFrame);
    addDrop(RING_INNER, 1, startFrame + 2);
    addDrop(RING_INNER, 2, startFrame + 4);
    addDrop(RING_INNER, 3, startFrame + 6);
    addDrop(RING_INNER, 4, startFrame + 8);
    addDrop(RING_INNER, 5, startFrame + 10);
  }

  if (displayLegend) {
      addLegend(legend, startFrame, startFrame + 100);
  }
}

/**
 * Add legend with given properties to the legend list using simple
 * syntax.
 *
 * @param text
 *    Legend text
 *
 * @param startFrame
 *    First moment of display
 *
 * @param endFrame
 *    Last moment of display
 */
void addLegend(String text, int startFrame, int endFrame)
{
  legends.add(new Legend(text, startFrame, endFrame));

  // Last moment of display padded with some silent time
  int lastsUntil = endFrame + 5*fps;

  maxTime = max(maxTime, lastsUntil);
}

void setup() {
  // Have to do centimeter conversion here, since e.g. 200*cm cannot be
  // written into this particular call.
  size(600, 600);

  // Modify setDropPattern() method to define simulated pattern
  setDropPattern();
  frameRate(fps);
  
  noFill();
  stroke(strokeColor);
  strokeWeight(strokeWeight);
  ellipseMode(RADIUS);
  textSize(16);
  textAlign(LEFT, TOP);
}

void draw() {
  translate(myWidth/2, myHeight/2);

  background(strokeColor);
  // Pool shape
  fill(0);
  ellipse(0, 0, poolDiameter/2, poolDiameter/2);
  noFill();

  rotate(PI/6.0);
  // Drops, 
  for (Drop drop: drops) {
    drop.draw(frameCount % maxTime);
  }
  rotate(-PI/6.0);
  
  translate(-myWidth/2 + 10, -myHeight/2 + 10);
  fill(0xd0);
  for (Legend legend: legends) {
    legend.draw(frameCount % maxTime);
  }
}

/**
 * Sets the drop sequence. This is the only function that should need
 * any modification in normal use of this simulator.
 */
void setDropPattern() {
  // Define any number of drops using the following syntax:
  // addDrop(circle, position, time) OR
  // addPattern(DropPattern.pattern, time)

  // Single drop in the middle
  addPattern(PATTERN_HEXAGON, 0, true);
  
  // Two triangles
  /*
  addDrop(Ring.INNER, 0, 10);
  addDrop(Ring.INNER, 2, 10);
  addDrop(Ring.INNER, 4, 10);
  
  addDrop(Ring.INNER, 1, 20);
  addDrop(Ring.INNER, 3, 20);
  addDrop(Ring.INNER, 5, 20);
  */

  // Some ready made patterns (see DropPattern.java for complete
  // list).
  /*
  addPattern(DropPattern.HEXAGON, 5);
  addPattern(DropPattern.SPIRAL, 80);
  */
}
