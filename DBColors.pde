color[] colors;
Integer cursor;

color getColor(int i) {
  if ( colors == null ) {
    colors = colorArray();
  }
  i = i % 22;
  return colors[i];
}

color[] colorArray() {
  color[] colorArray = new color[22]; 
  colorArray[0] = #E6194B;
  colorArray[1] = #3cb44b;
  colorArray[2] = #ffe119;
  colorArray[3] = #4363d8;
  colorArray[4] = #f58231;
  colorArray[5] = #911eb4;
  colorArray[6] = #46f0f0;
  colorArray[7] = #f032e6;
  colorArray[8] = #bcf60c;
  colorArray[9] = #fabebe;
  colorArray[10] = #008080;
  colorArray[11] = #e6beff;
  colorArray[12] = #9a6324;
  colorArray[13] = #fffac8;
  colorArray[14] = #800000;
  colorArray[15] = #aaffc3;
  colorArray[16] = #808000;
  colorArray[17] = #ffd8b1;
  colorArray[18] = #000075;
  colorArray[19] = #808080;
  colorArray[20] = #ffffff;
  colorArray[21] = #000000;
  return colorArray;
}

color nextColor() {
  color[] colorArray = colorArray();
  if ( cursor == null ) cursor = 0;
  color toReturn = colorArray[cursor % 22];
  cursor += 1;
  return toReturn;
}
