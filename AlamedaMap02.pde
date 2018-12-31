OSMMap theMap;

PrintWriter output;
StringList drawnWayIDs;

// Interactive Mode Flags
boolean clickableWays;
String inFocusWay;

// UI
color backgroundColor;

void setup() {
  size(1200, 1400, P3D);
  backgroundColor = 200;
  background(backgroundColor);
  frameRate(120);


  theMap = new OSMMap(loadXML("tinymap.xml"));
  //theMap = new OSMMap(loadXML("alameda.xml"));
  drawnWayIDs = new StringList();
  println(theMap.statsString());
  
  // Interactive Mode Flags
  clickableWays = true;
    
  noSmooth();
  drawMap();

}

void draw() {
  camera(mouseX, height / 2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  drawMap();
}

void drawMap() {
  /* Generating map01.png */ // Basic Display v2
  //for ( Way way : theMap.ways.values() ) {
  //  drawWay(way, 255, 0);
  //}
  
  /* map02.png */ // Top Highway Tags v1
  //drawTopTagValues("highway", 60);
  //save("map02_topHighways.png");
  
  /* map03.png */ // Top Building Tags V2
  //drawTopTagValues("building", 7);
  //save("map03_topBuildings.png");

  /* map04.png */ // No Buildings v2
  //for ( Way way : theMap.waysWithoutTagKey("building") ) {
  //  drawWay(way, 255, 0);
  //}
  //save("map04_noBuildings.png");
  
  /* map05.png */ // No Highways v2
  //for ( Way way : theMap.waysWithoutTagKey("highway") ) {
  //  drawWay(way, 255, 0);
  //}
  //save("map05_noHighways.png");
  
  /* map06.png */ // No Buildings, Only Closed Ways v1
  //for ( Way way : theMap.waysWithoutTagKey("building") ) {
  //  if ( way.closed ) drawWay(way, 255, 0);
  //}
  //save("map06_noBuildingsOnlyClosedWays.png");
  
  /* map07.png */ // Natural Tags v.05
  //drawTopTagValues("natural", 0);
  
  /* map08.png */ // Coastline v0.5
  //drawTag(theMap.tagWithKeyAndValue("natural", "coastline"));
  
  /* map09.png */ // Draw nodes without ways
  //for ( Node n : theMap.nodes.values() ) {
  //  if ( n.wayIDs.size() == 0 ) {
  //    drawNode(n, 0);
  //  }
  //}
  
  /* map10.png */ // Draw all nodes
  //for ( Node n : theMap.nodes.values() ) {
  //  drawNode(n, 0);
  //}
  //save("map10_onlyNodes.png");
  
  /* map11.png */ // Draw relations
  //for ( Relation relation : theMap.relations.values() ) {
  //  drawRelation(relation, 0, 255);
  //}
  
  
  // drawTopTagValues("population", 0);
}

void mouseClicked() {
  if ( clickableWays ) {
    // Draw a rect over any old text
    // Find the way clicked
    boolean redraw = false;
    for ( String wayID : drawnWayIDs ) {
      Way way = theMap.ways.get(wayID);
      java.awt.Polygon wayPoly = new java.awt.Polygon();
      for ( String nodeID : way.nodeIDs ) {
        Node node = theMap.nodes.get(nodeID);
        Coordinates coords = theMap.remap(node);
        wayPoly.addPoint(int(coords.lon), int(coords.lat));
      }
      if ( wayPoly.contains(mouseX, mouseY) ) {
        inFocusWay = way.id;
        redraw = true;
        println(way);
      }
    }
    if ( redraw ) {
      background(backgroundColor);
      drawMap();
      displayInFocusWayInfo();
    }
    //mouseX, mouseY
  }
}

//
// Drawing Functions
//

void displayInFocusWayInfo() {
  if ( inFocusWay != null ) {
    Way way = theMap.ways.get(inFocusWay);
    // Figure out spacing
    float rowHeight  = 25;
    float rowGap     = 10;
    float xPos       = 20;
    float yPos       = height - ((rowHeight + rowGap) * way.tagIDs.size()) - (xPos - rowGap);
    float countXPos  = 300;
    noStroke();
    for ( String tagID : way.tagIDs ) {
      fill(0);
      Tag tag = theMap.tags.get(tagID);
      textSize(14);
      String textString = tag.keyString + " : " + tag.valueString;
      text(textString, xPos, yPos + 16);
      text(tag.wayIDs.size(), countXPos, yPos + 16);
      yPos += rowHeight + rowGap;
    }
  }
}

void drawRelation(Relation relation, color fillColor, color strokeColor) {
  for ( RelationMember m : relation.members ) {
  if ( m.type.equals("way") ) {
      Way w = theMap.ways.get(m.id);
      if ( w != null ) drawWay(w, fillColor, strokeColor, 0);
    }
  }
}

void drawNode(Node node, color strokeColor) {
  stroke(strokeColor);
  Coordinates coords = theMap.remap(node);
  point(coords.lon, coords.lat);
}

void drawWay(Way way, color fillColor, color strokeColor, float z) {
  if (way.closed) {
    fill(fillColor);
    if ( clickableWays && inFocusWay != null ) {
      if (way.id.equals(inFocusWay)) fill(#FF0000);
    }
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
  drawnWayIDs.append(way.id);
}

void drawTopTagValues(String keyString, Integer minCount) {
  StringList topValues = new StringList();
  for ( Tag tag : theMap.tags.values() ) {
    if ( tag.keyString.equals(keyString) && tag.wayIDs.size() > minCount ) topValues.append(tag.id);
    if ( tag.keyString.equals(keyString) && tag.relationIDs.size() > minCount ) topValues.append(tag.id);
  }
  HashMap<String, Integer> topValueColors = zipIDsWithColors(topValues.array(), colorArray());
  for ( Tag tag : theMap.tags.values() ) {
    if ( tag.keyString.equals(keyString) && tag.wayIDs.size() > minCount ) {
      for ( String wayID : tag.wayIDs ) {
        Way way = theMap.ways.get(wayID);
        drawWay(way, topValueColors.get(tag.id), topValueColors.get(tag.id), 0);
      }
    }
    if ( tag.keyString.equals(keyString) && tag.relationIDs.size() > minCount ) {
      for ( String relationID : tag.relationIDs ) {
        Relation relation = theMap.relations.get(relationID);
        drawRelation(relation, topValueColors.get(tag.id), topValueColors.get(tag.id));
      }
    }
  }
  drawTagLegend(topValueColors);
}

void drawTag(Tag tag) {
  for ( String wayID : tag.wayIDs ) {
    Way way = theMap.ways.get(wayID);
    drawWay(way, 255, nextColor(), 0);
  }
  for ( String relationID : tag.relationIDs ) {
    Relation relation = theMap.relations.get(relationID);
    drawRelation(relation, 255, nextColor());
  }
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

//
// Helper Functions
//

HashMap<String, Integer> zipIDsWithColors(String[] ids, color[] colors) {
  HashMap<String, Integer> zipped = new HashMap<String, Integer>();
  for ( int i = 0; i < ids.length; i++ ) {
    zipped.put(ids[i], colors[i % colors.length]);
  } 
  return zipped;
}
