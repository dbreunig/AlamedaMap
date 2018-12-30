OSMMap theMap;

PrintWriter output;

void setup() {
  size(1200, 1400);
  background(200);
  frameRate(120);


  //theMap = new OSMMap(loadXML("tinymap.xml"));
  theMap = new OSMMap(loadXML("alameda.xml"));

  println(theMap.statsString());
 
  /* Generating map01.png */
  //for ( Way way : theMap.ways.values() ) {
  //  drawWay(way, 255, 0);
  //}
  
  /* Generating map02.png */
  StringList highways = new StringList();
  for ( Tag tag : theMap.tags.values() ) {
    if ( tag.keyString.equals("highway") && tag.wayIDs.size() > 60 ) {
      highways.append(tag.id);
    }
  }
  HashMap<String, Integer> highwayColors = zipIDsWithColors(highways.array(), colorArray());
  for ( Tag tag : theMap.tags.values() ) {
    if ( tag.keyString.equals("highway") && tag.wayIDs.size() > 60 ) {
      for ( String wayID : tag.wayIDs ) {
        Way way = theMap.ways.get(wayID);
        drawWay(way, 255, highwayColors.get(tag.id));
      }
    }
  }
  drawTagLegend(highwayColors);

  //save("map02.png");
}

void draw() {

}

void drawWay(Way way, color fillColor, color strokeColor) {
  if (way.closed) {
    fill(fillColor);
  } else {
    noFill();
  }
  stroke(strokeColor);
  beginShape();
  for ( String nodeID : way.nodeIDs ) {
    Node node = theMap.nodes.get(nodeID);
    Coordinates coords = theMap.remap(node);
    vertex(coords.lon, coords.lat);
  }
  endShape(); 
}

void drawTagLegend(HashMap<String, Integer> tagColors) {
  // Figure out spacing
  float rowHeight  = 25;
  float rowGap     = 10;
  float xPos       = 20;
  float yPos       = height - ((rowHeight + rowGap) * tagColors.size()) - (xPos - rowGap);
  float countXPos  = 300;
  noStroke();
  for ( String tagID : tagColors.keySet() ) {
    fill(tagColors.get(tagID));
    rect(xPos, yPos, rowHeight, rowHeight);
    fill(0);
    Tag tag = theMap.tags.get(tagID);
    textSize(14);
    String textString = tag.keyString + " : " + tag.valueString;
    text(textString, xPos + rowHeight + rowGap, yPos + 16);
    text(tag.wayIDs.size(), countXPos, yPos + 16);
    yPos += rowHeight + rowGap;
  }
}

HashMap<String, Integer> zipIDsWithColors(String[] ids, color[] colors) {
  HashMap<String, Integer> zipped = new HashMap<String, Integer>();
  for ( int i = 0; i < ids.length; i++ ) {
    zipped.put(ids[i], colors[i]);
  } 
  return zipped;
}
