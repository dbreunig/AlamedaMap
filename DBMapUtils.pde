// 
// A collection of utilities for working with OSM XML files
//

// Class for the map state
class OSMMap {
  float minLat, minLon, maxLat, maxLon;
  XML mapXML;
  HashMap<String, Node> nodes;
  HashMap<String, Way> ways;
  HashMap<String, Tag> tags;
  OSMMap (XML osmXML) {
    mapXML = osmXML;
    Coordinates[] bounds  = boundingBox();
    minLat = bounds[0].lat;
    minLon = bounds[0].lon;
    maxLat = bounds[1].lat;
    maxLon = bounds[1].lon;
    nodes  = new HashMap<String, Node>();
    ways   = new ArrayList<Way>();
    tags   = new ArrayList<Tag>();
    loadNodes();
  }
  // Get bounding box for OSM XML
  Coordinates[] boundingBox() {
    XML bounds      = mapXML.getChildren("bounds")[0];
    Coordinates min = new Coordinates(bounds.getFloat("minlat"), bounds.getFloat("minlon"));
    Coordinates max = new Coordinates(bounds.getFloat("maxlat"), bounds.getFloat("maxlon"));
    Coordinates[] boundingBox = new Coordinates[2];
    boundingBox[0]  = min;
    boundingBox[1]  = max;
    return boundingBox;
  }
  // Load nodes
  void loadNodes() {
    // Iterate through all nodes
    XML[] nodeXMLs = mapXML.getChildren("node");
    for ( XML n : nodeXMLs ) {
      Node node = new Node(n);
      nodes.put(node.id, node);
    }
    println("Loaded " + nodes.size() + " nodes.");
  }
  // Load ways
  // Print stats
  String statsString() {
    String stats = "Bounding Box: (" + minLat + ", " + minLon + "), (" + maxLat + ", " + maxLon + ")";
    return stats;
  }
}

// Class for coordinates
class Coordinates {
  float lat, lon;
  Coordinates (float latitude, float longitude) {
    lat = latitude;
    lon = longitude;
  }
}

// Class for node
class Node {
  String id;
  Coordinates coords;
  StringList tagIDs, wayIDs;
  Node (XML nodeXML) {
    id         = nodeXML.getString("id");
    float lat  = nodeXML.getFloat("lat");
    float lon  = nodeXML.getFloat("lon");
    coords     = new Coordinates(lat, lon);
    wayIDs     = new StringList();
    tagIDs     = new StringList();
  }
}

// Class for way
class Way {
  String id;
  boolean visible;
  StringList tagIDs, nodeIDs;
  Way (XML wayXML) {
    id         = wayXML.getString("id");
    visible    = wayXML.getString("visible").equals("true") ? true : false;
    nodeIDs    = new StringList();
    tagIDs     = new StringList();
  }
}

// Class for tag
class Tag {
  String keyString, valueString, id;
  Tag (XML tagXML) {
    keyString    = tagXML.getString("k");
    valueString  = tagXML.getString("v");
    id           = keyString + ":" + valueString; // A filthy hack
  }
}
