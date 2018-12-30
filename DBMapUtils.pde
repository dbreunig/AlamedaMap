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
    ways   = new HashMap<String, Way>();
    tags   = new HashMap<String, Tag>();
    loadNodes();
    loadWays();
  }
  
  // Remap a node
  Coordinates remap(Node node) {
    float longitude = map(node.coords.lon, minLon, maxLon, 0, width); // lon
    float latitude = map(node.coords.lat, maxLat, minLat, 0, height); // lat
    //println(node.coords.lon + " " + node.coords.lat);
    //println(longitude + " " + latitude);
    //println(width + " " + height + "\n");
    Coordinates newCoords = new Coordinates(latitude, longitude);
    return newCoords;
  }
  
  // Save a tag
  void saveTag(Tag tag) {
    Tag t = tags.get(tag.id);
    if ( t == null ) {
      tags.put(tag.id, tag);
    }
  }
  void saveTagWithNode(Tag tag, Node node) {
    Tag t = tags.get(tag.id);
    if ( t == null ) {
      tag.nodeIDs.append(node.id);
      tags.put(tag.id, tag);
    } else {
      t.nodeIDs.append(node.id);
    }
  }
  void saveTagWithWay(Tag tag, Way way) {
    Tag t = tags.get(tag.id);
    if ( t == null ) {
      tag.wayIDs.append(way.id);
      tags.put(tag.id, tag);
    } else {
      t.wayIDs.append(way.id);
    }
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
      // Get tags
      XML[] tagXMLs = n.getChildren("tag");
      for ( XML t : tagXMLs ) {
        Tag tag = new Tag(t);
        node.tagIDs.append(tag.id);
        saveTagWithNode(tag, node);
      }
      // Save the node
      nodes.put(node.id, node);
    }
  }
  
  // Load ways
  void loadWays() {
    // Iterate through all the ways
    XML[] wayXMLs = mapXML.getChildren("way");
    for ( XML w : wayXMLs ) {
      Way way = new Way(w);
      // Iterate through the way's nodes
      XML[] nds = w.getChildren("nd");
      way.closed = nds[0].getDouble("ref") == nds[nds.length - 1].getDouble("ref") ? true : false;
      for ( XML n : nds ) {
        String nodeID = n.getString("ref");
        way.nodeIDs.append(nodeID);
      }
      // Get tags
      XML[] tagXMLs = w.getChildren("tag");
      for ( XML t : tagXMLs ) {
        Tag tag = new Tag(t);
        way.tagIDs.append(tag.id);
        saveTagWithWay(tag, way);
      }
      // Save the way
      ways.put(way.id, way);
    }
  }
  
  // Search functions
  Tag [] tagsWithKey(String keyString) {
    ArrayList<Tag> compliantTags = new ArrayList<Tag>();
    for ( Tag t : tags.values() ) {
      if ( t.keyString.equals(keyString) ) {
        compliantTags.add(t);
      }
    }
    return compliantTags.toArray(new Tag[compliantTags.size()]);
  }
  
  Tag [] tagsWithKeyAndValue(String keyString, String valueString) {
    ArrayList<Tag> compliantTags = new ArrayList<Tag>();
    for ( Tag t : tags.values() ) {
      if ( t.keyString.equals(keyString) && t.valueString.equals(valueString)) {
        compliantTags.add(t);
      }
    }
    return compliantTags.toArray(new Tag[compliantTags.size()]);
  }
  
  // Print stats
  String statsString() {
    println("Loaded:");
    println("- " + nodes.size() + " nodes");
    println("- " + ways.size() + " ways");
    println("- " + tags.size() + " tags");
    String stats = "Bounding Box: (" + minLat + ", " + minLon + "), (" + maxLat + ", " + maxLon + ")";
    return stats;
  }
  
  // Write tag categories to file
  void writeTagsToCSV(String filename) {
    // Write the categories out
    output = createWriter(filename);
    for ( Tag tag : tags.values().toArray(new Tag[tags.size()]) ) {
      output.println(tag.keyString + ", " + "\"" + tag.valueString + "\"" + ", " + tag.wayIDs.size() );
    }
    output.flush();
    output.close();
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
  boolean visible, closed;
  StringList tagIDs, nodeIDs;
  Way (XML wayXML) {
    id         = wayXML.getString("id");
    if ( wayXML.getString("visible") != null ) {
      visible    = wayXML.getString("visible").equals("true") ? true : false;
    }
    nodeIDs    = new StringList();
    tagIDs     = new StringList();
  }
}

// Class for tag
class Tag {
  String keyString, valueString, id;
  StringList wayIDs, nodeIDs;
  Tag (XML tagXML) {
    keyString    = tagXML.getString("k");
    valueString  = tagXML.getString("v");
    id           = keyString + ":" + valueString; // A filthy hack
    nodeIDs      = new StringList();
    wayIDs       = new StringList();
  }
}
