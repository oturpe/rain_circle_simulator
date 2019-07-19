/**
 * Drop pattern simulator for As above, so below installation.
 *
 * Author: Otto Urpelainen
 * Date: 2018-06-29
 *
 * Coordinates are centimeters. 
 */
 
// One centimeter in pixels
final float cm = 4.0;

// Size of screen
// These have to match values used in call to size()
final float myHeight = 150*cm;
final float myWidth = 150*cm;

// Diameter of the pool
final float poolDiameter = 148*cm;

// Speed of wave in the pool
final int fps = 20;
final float speed = poolDiameter/(2*3.66*fps);

// Distance between two adjacent drop points
final float dropDistance = (37.5/2)*cm;

// Stroke properties in animation
final int strokeColor = 50;
final int strokeWeight = 3;

// Positions of all drop points, indexed as [ring][clockwise position].
// Ring 0 middle, coordinates are ordered {x, y} as usual.
final float[][][] dropPositions = {
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

// Time after which the sequence starts from the beginning.
int maxTime = 0;
// The frameCount where animation starts. Setting this value to current
// frameCount can be used to reset the animation.
int startTime = 0;

// Predefined drop patterns
final static int PATTERN_SINGLE_DROP = 1;
final static int PATTERN_TREE_OF_LIFE = 2;
final static int PATTERN_FLOWER_OF_LIFE = 3;
final static int PATTERN_FIRE_TRIANGLE = 4;
final static int PATTERN_WATER_TRIANGLE = 5;
final static int PATTERN_HEXAGON = 6;
final static int PATTERN_LARGE_HEXAGON = 7;
final static int PATTERN_SWASTIKA = 8;
final static int PATTERN_SPINDLE = 9;
final static int PATTERN_BAR = 10;
final static int PATTERN_SCEPTER = 11;
final static int PATTERN_SPIRAL = 12;
final static int PATTERN_OFF_CENTER_DROP = 13;
final static int PATTERN_SEMI_SWASTIKA = 14;
final static int PATTERN_RECTANGLE = 15;
final static int PATTERN_LIGHTNING = 16;

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

final Ring RING_MIDDLE = new Ring(0, 1);
final Ring RING_INNER = new Ring(1, 6);
final Ring RING_OUTER = new Ring(2, 13);
  
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
final ArrayList<Drop> drops = new ArrayList<Drop>();
final ArrayList<Legend> legends = new ArrayList<Legend>();

/**
 * Return a moment in time when it is guaranteed that a circle made
 * by drop impact at given time has disappeared.
 * 
 * @param impactFrame
 *    Time of impact
 *
 * @return
 *    When drop cicle has disappeared
 */
public int lastsUntil(int impactFrame) {
  int lastsUntil = impactFrame + (int)(poolDiameter/speed);
  return lastsUntil + 5*fps;  
}

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
  maxTime = max(maxTime, lastsUntil(impactFrame));
}

/**
 * Add given pattern to animation, starting at given frame. Optionally legend
 * can be displayed.
 *
 * @param pattern
 *    Index of pattern to add
 *
 * @param startFrame
 *    Frame where the pattern starts
 *
 * @param displayLegend
 *    If legend is displayed
 */
void addPattern(int pattern, int startFrame, boolean displayLegend) {
  String legend = "undefined_legend";
  if (pattern == PATTERN_SINGLE_DROP) {
    legend = "Single drop";
    addDrop(RING_MIDDLE, 0, startFrame);
  }
  else if (pattern == PATTERN_TREE_OF_LIFE) {
    legend = "Tree of Life";
    addDrop(RING_OUTER, 0, startFrame);
    addDrop(RING_OUTER, 1, startFrame);
    addDrop(RING_OUTER, 11, startFrame);
    addDrop(RING_INNER, 1, startFrame);
    addDrop(RING_INNER, 5, startFrame);
    addDrop(RING_MIDDLE, 0, startFrame);
    addDrop(RING_INNER, 2, startFrame);
    addDrop(RING_INNER, 4, startFrame);
    addDrop(RING_INNER, 3, startFrame);
    addDrop(RING_OUTER, 6, startFrame);
  }
  else if (pattern == PATTERN_FLOWER_OF_LIFE) {
    legend = "Flower of Life";
    addDrop(RING_MIDDLE, 0, startFrame);
    addDrop(RING_INNER, 0, startFrame);
    addDrop(RING_INNER, 1, startFrame);
    addDrop(RING_INNER, 2, startFrame);
    addDrop(RING_INNER, 3, startFrame);
    addDrop(RING_INNER, 4, startFrame);
    addDrop(RING_INNER, 5, startFrame);
    addDrop(RING_OUTER, 0, startFrame);
    addDrop(RING_OUTER, 1, startFrame);
    addDrop(RING_OUTER, 2, startFrame);
    addDrop(RING_OUTER, 3, startFrame);
    addDrop(RING_OUTER, 4, startFrame);
    addDrop(RING_OUTER, 5, startFrame);
    addDrop(RING_OUTER, 6, startFrame);
    addDrop(RING_OUTER, 7, startFrame);
    addDrop(RING_OUTER, 8, startFrame);
    addDrop(RING_OUTER, 9, startFrame);
    addDrop(RING_OUTER, 10, startFrame);
    addDrop(RING_OUTER, 11, startFrame);
  }
  else if (pattern == PATTERN_FIRE_TRIANGLE) {
    legend = "Fire triangle";
    addDrop(RING_INNER, 0, startFrame);
    addDrop(RING_INNER, 2, startFrame);
    addDrop(RING_INNER, 4, startFrame);
  }
  else if (pattern == PATTERN_WATER_TRIANGLE) {
    legend = "Water triangle";
    addDrop(RING_INNER, 1, startFrame);
    addDrop(RING_INNER, 3, startFrame);
    addDrop(RING_INNER, 5, startFrame);
  }
  else if (pattern == PATTERN_HEXAGON) {
    legend = "Hexagon";
    addPattern(PATTERN_FIRE_TRIANGLE, startFrame, false);
    addPattern(PATTERN_WATER_TRIANGLE, startFrame, false);
  }
  else if (pattern == PATTERN_LARGE_HEXAGON) {
    legend = "Large hexagon";
    addDrop(RING_OUTER, 0, startFrame);
    addDrop(RING_OUTER, 1, startFrame);
    addDrop(RING_OUTER, 2, startFrame);
    addDrop(RING_OUTER, 3, startFrame);
    addDrop(RING_OUTER, 4, startFrame);
    addDrop(RING_OUTER, 5, startFrame);
    addDrop(RING_OUTER, 6, startFrame);
    addDrop(RING_OUTER, 7, startFrame);
    addDrop(RING_OUTER, 8, startFrame);
    addDrop(RING_OUTER, 9, startFrame);
    addDrop(RING_OUTER, 10, startFrame);
    addDrop(RING_OUTER, 11, startFrame);
  }
  else if (pattern == PATTERN_SWASTIKA) {
    legend = "Swastika";
    addDrop(RING_MIDDLE, 0, startFrame);
    addDrop(RING_INNER, 0, startFrame);
    addDrop(RING_INNER, 2, startFrame);
    addDrop(RING_INNER, 4, startFrame);
    addDrop(RING_OUTER, 1, startFrame);
    addDrop(RING_OUTER, 5, startFrame);
    addDrop(RING_OUTER, 9, startFrame);
  }
  else if (pattern == PATTERN_SPINDLE) {
    legend = "Spindle";
    addDrop(RING_MIDDLE, 0, startFrame);
    addDrop(RING_INNER, 0, startFrame + 8);
    addDrop(RING_INNER, 3, startFrame + 8);
  }
  else if (pattern == PATTERN_BAR) {
    legend = "Bar";
    addDrop(RING_MIDDLE, 0, startFrame);
    addDrop(RING_INNER, 1, startFrame);
    addDrop(RING_INNER, 4, startFrame);
    addDrop(RING_OUTER, 2, startFrame);
    addDrop(RING_OUTER, 8, startFrame);
  }
  else if (pattern == PATTERN_SCEPTER) {
    legend = "Scepter";
    addDrop(RING_OUTER, 1, startFrame + 5);
    addDrop(RING_OUTER, 11, startFrame + 5);
    addDrop(RING_INNER, 0, startFrame);
    addDrop(RING_MIDDLE, 0, startFrame + 5);
    addDrop(RING_INNER, 3, startFrame + 5);
  }
  else if (pattern == PATTERN_SPIRAL) {
    legend = "Spiral";
    addDrop(RING_INNER, 6, startFrame);
    addDrop(RING_INNER, 1, startFrame + 3);
    addDrop(RING_INNER, 2, startFrame + 6);
    addDrop(RING_INNER, 3, startFrame + 9);
    addDrop(RING_INNER, 4, startFrame + 12);
    addDrop(RING_INNER, 5, startFrame + 15);
  }
  else if (pattern == PATTERN_OFF_CENTER_DROP) {
    legend = "Off-center drop";
    addDrop(RING_OUTER, 2, startFrame);
  }
  else if (pattern == PATTERN_RECTANGLE) {
    legend = "Rectangle";
    addDrop(RING_INNER, 1, startFrame);
    addDrop(RING_INNER, 2, startFrame);
    addDrop(RING_INNER, 4, startFrame);
    addDrop(RING_INNER, 5, startFrame);
  }
  else if (pattern == PATTERN_SEMI_SWASTIKA) {
    legend = "Semi-swastika";
    addDrop(RING_OUTER, 8, startFrame);
    addDrop(RING_INNER, 3, startFrame);
    addDrop(RING_MIDDLE, 0, startFrame);
    addDrop(RING_INNER, 0, startFrame);
    addDrop(RING_OUTER, 2, startFrame);
  }
  else if (pattern == PATTERN_LIGHTNING) {
    legend = "Lightning bolt";
    addDrop(RING_OUTER, 1, startFrame + 2);
    addDrop(RING_INNER, 0, startFrame);
    addDrop(RING_MIDDLE, 0, startFrame);
    addDrop(RING_INNER, 3, startFrame);
    addDrop(RING_OUTER, 7, startFrame + 2);
  }
  
  if (displayLegend) {
      addLegend(pattern + " " + legend, startFrame, startFrame + 100);
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

  frameRate(fps);
  
  noFill();
  stroke(strokeColor);
  strokeWeight(strokeWeight);
  ellipseMode(RADIUS);
  textSize(16);
  textAlign(LEFT, TOP);

  // Modify setDropPattern() method to define simulated pattern
  setDropPattern();
}

void draw() {
  // Move to the center, makes easier to work in precense of circular symmetry.
  translate(myWidth/2, myHeight/2);

  background(strokeColor);
  // Pool shape
  fill(0);
  ellipse(0, 0, poolDiameter/2, poolDiameter/2);
  noFill();

  int animationFrame = ((frameCount - startTime) % maxTime);

  // Quick fix for shape orientation: Rotate before drawing the circles
  rotate(PI/6.0);
  for (Drop drop: drops) {
    drop.draw(animationFrame);
  }
  rotate(-PI/6.0);
  
  // Draw legend in top left corner
  translate(-myWidth/2 + 10, -myHeight/2 + 10);
  fill(0xd0);
  for (Legend legend: legends) {
    legend.draw(animationFrame);
  }
}

/**
 * Sets the drop sequence. This is the only function that should need
 * any modification in normal use of this simulator.
 */
void setDropPattern() {
  int frame = 0;
  int patternLength = 200;

  addPattern(1, frame, true);
  addPattern(2, frame += patternLength, true);
  addPattern(3, frame += patternLength, true);
  addPattern(4, frame += patternLength, true);
  addPattern(5, frame += patternLength, true);
  addPattern(6, frame += patternLength, true);
  addPattern(7, frame += patternLength, true);
  addPattern(8, frame += patternLength, true);
  addPattern(9, frame += patternLength, true);
  addPattern(10, frame += patternLength, true);
  addPattern(11, frame += patternLength, true);
  addPattern(12, frame += patternLength, true);
  addPattern(13, frame += patternLength, true);
  addPattern(14, frame += patternLength, true);
}
