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
  HashMap<String, Relation> relations;
  OSMMap (XML osmXML) {
    mapXML = osmXML;
    Coordinates[] bounds  = boundingBox();
    minLat = bounds[0].lat;
    minLon = bounds[0].lon;
    maxLat = bounds[1].lat;
    maxLon = bounds[1].lon;
    nodes     = new HashMap<String, Node>();
    ways      = new HashMap<String, Way>();
    tags      = new HashMap<String, Tag>();
    relations = new HashMap<String, Relation>();
    loadNodes();
    loadWays();
    loadRelations();
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
  void saveTagWithRelation(Tag tag, Relation relation) {
    Tag t = tags.get(tag.id);
    if ( t == null ) {
      tag.relationIDs.append(relation.id);
      tags.put(tag.id, tag);
    } else {
      t.relationIDs.append(relation.id);
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
        Node node = nodes.get(nodeID);
        if ( node != null ) node.wayIDs.append(way.id);
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
  
  // Load relations
  void loadRelations() {
    // Iterate through all the relations
    XML[] relationXMLs = mapXML.getChildren("relation");
    for ( XML r : relationXMLs ) {
      Relation relation = new Relation(r);
      XML[] members = r.getChildren("member");
      for ( XML m : members ) {
        String type = m.getString("type");
        String id = m.getString("ref");
        String role = m.getString("role");
        RelationMember rm = new RelationMember(type, id, role);
        relation.members.add(rm);
        // Assign to existing node or way
        if ( type.equals("node") ) {
          Node node = nodes.get(id);
          if ( node != null ) {
            node.relationIDs.append(relation.id);
          }
        } else if ( type.equals("way") ) {
          Way way = ways.get(id);
          if ( way != null ) {
            way.relationIDs.append(relation.id);
          }
        }
        // Handle tags
        XML[] tagXMLs = r.getChildren("tag");
        for ( XML t : tagXMLs ) {
          Tag tag = new Tag(t);
          relation.tagIDs.append(tag.id);
          saveTagWithRelation(tag, relation);
        }
      }
      relations.put(relation.id, relation);
    }
  }
  
  // Tag Search functions
  Tag [] tagsWithKey(String keyString) {
    ArrayList<Tag> compliantTags = new ArrayList<Tag>();
    for ( Tag t : tags.values() ) {
      if ( t.keyString.equals(keyString) ) compliantTags.add(t);
    }
    return compliantTags.toArray(new Tag[compliantTags.size()]);
  }
  
  Tag [] tagsWithoutKey(String keyString) {
    ArrayList<Tag> compliantTags = new ArrayList<Tag>();
    for ( Tag t : tags.values() ) {
      if ( !t.keyString.equals(keyString) ) compliantTags.add(t);
    }
    return compliantTags.toArray(new Tag[compliantTags.size()]);
  }
  
  Tag tagWithKeyAndValue(String keyString, String valueString) {
    return tags.get(keyString + ":" + valueString);
  }
  
  // Way Search Functions
  Way [] waysWithoutTagKey(String keyString) {
    ArrayList<Way> compliantWays = new ArrayList<Way>();
    for ( Way w : ways.values() ) {
      boolean isCompliant = true;
      for ( String tagID : w.tagIDs ) {
        if ( tags.get(tagID).keyString.equals(keyString) ) isCompliant = false;
      }
      if ( isCompliant ) compliantWays.add(w);
    }
    return compliantWays.toArray(new Way[compliantWays.size()]);
  }
  
  // Print stats
  String statsString() {
    println("Loaded:");
    println("- " + nodes.size() + " nodes");
    println("- " + ways.size() + " ways");
    println("- " + tags.size() + " tags");
    println("- " + relations.size() + " relations");
    String stats = "Bounding Box: (" + minLat + ", " + minLon + "), (" + maxLat + ", " + maxLon + ")";
    return stats;
  }
  
  // Write tag categories to file
  void writeTagsToCSV(String filename) {
    // Write the categories out
    output = createWriter(filename);
    for ( Tag tag : tags.values() ) {
      output.println(tag.keyString + ", " + "\"" + tag.valueString + "\"" + ", " + tag.wayIDs.size() );
    }
    output.flush();
    output.close();
  }
  void writeRelationTagsToCSV(String filename) {
    output = createWriter(filename);
    for ( Tag tag : tag.values() ) {
      if ( tag.relationID.size() > 0 ) {
        output.println(tag.keyString + ", " + "\"" + tag.valueString + "\"" + ", " + tag.relationIDs.size() );
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
  StringList tagIDs, wayIDs, relationIDs;
  Node (XML nodeXML) {
    id         = nodeXML.getString("id");
    float lat  = nodeXML.getFloat("lat");
    float lon  = nodeXML.getFloat("lon");
    coords      = new Coordinates(lat, lon);
    wayIDs      = new StringList();
    tagIDs      = new StringList();
    relationIDs = new StringList();
  }
}

// Class for way
class Way {
  String id;
  boolean visible, closed;
  StringList tagIDs, nodeIDs, relationIDs;;
  Way (XML wayXML) {
    id         = wayXML.getString("id");
    if ( wayXML.getString("visible") != null ) {
      visible    = wayXML.getString("visible").equals("true") ? true : false;
    }
    nodeIDs     = new StringList();
    tagIDs      = new StringList();
    relationIDs = new StringList();
  }
}

class Relation {
  String id;
  ArrayList<RelationMember> members;
  StringList tagIDs;
  Relation(XML relationXML) {
    members  = new ArrayList<RelationMember>();
    tagIDs   = new StringList();
    id = relationXML.getString("id");
  }
  
}

class RelationMember {
  String type, id, role;
  RelationMember (String t, String i, String r) {
    type = t;
    id = i;
    role = r;
  }
}

// Class for tag
class Tag {
  String keyString, valueString, id;
  StringList wayIDs, nodeIDs, relationIDs;
  Tag (XML tagXML) {
    keyString    = tagXML.getString("k");
    valueString  = tagXML.getString("v");
    id           = keyString + ":" + valueString; // A filthy hack
    nodeIDs      = new StringList();
    wayIDs       = new StringList();
    relationIDs  = new StringList();
  }
}
