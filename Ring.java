/**
 * Enumeration of the three drop rings of the machine.
 */
public enum Ring {
  MIDDLE(0, 1),
  INNER(1, 6),
  OUTER(2, 13);
  
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
