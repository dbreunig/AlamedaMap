OSMMap theMap;

void setup() {
  size(1200, 1400);
  background(#808080);

  theMap = new OSMMap(loadXML("tinymap.xml"));
  Coordinates[] boundingBox = theMap.boundingBox();

  println(theMap.statsString());

}

void draw() {
}
