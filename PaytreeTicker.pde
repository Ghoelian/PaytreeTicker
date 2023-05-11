JSONObject variables;

static int refreshInterval = 5;

PFont roboto;
static int primaryTextSize = 100;
static int secondaryTextSize = 40;

static String apiKey = "";

Ticker ticker;
Graph graph;

void setup() {
  size(800, 480);
  noCursor();
  frameRate(10);
  
  variables = loadJSONObject("variables.json");
  
  apiKey = variables.getString("apiKey");
  
  roboto = createFont("roboto.ttf", 32);
  textFont(roboto);
  
  ticker = new Ticker();
  graph = new Graph();
}

void draw() {
  try {
  background(0);
  
  ticker.drawTicker();
  graph.drawGraph();
  } catch(Exception e) {
    delay(5000);
    
    textAlign(CENTER, CENTER);
    textSize(16);
    System.out.println(e.getMessage());
    text(e.getMessage(), width/2, height/2);
  }
}
