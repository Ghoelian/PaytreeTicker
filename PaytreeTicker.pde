JSONObject variables;

static int refreshInterval = 5;

PFont roboto;
static int primaryTextSize = 80;
static int secondaryTextSize = 40;

static int primaryTextColor = 255;
static int disabledTextColor = 128;

static String apiKey = System.getenv("PAYTREE_API_KEY");

private long lastTotalTimestamp = 0;

Ticker ticker;
Graph graph;

void setup() {
  if (args != null && args.length > 0) {
    try {
      refreshInterval = Integer.parseInt(args[0]);
    }
    catch (NumberFormatException e) {
      refreshInterval = 5;
    }
  }

  size(800, 480);
  noCursor();

  roboto = createFont("noto-sans-mono.ttf", 32);
  textFont(roboto);

  colorMode(HSB, 360, 100, 100);

  ticker = new Ticker();
  graph = new Graph();

  // Set framerate so that a new frame gets drawn twice between data refreshes.
  frameRate(2 / parseFloat(refreshInterval));

  drawStuff(true);
}

void drawStuff(boolean skipInterval) {
  long now = Instant.ofEpochSecond(0L).until(Instant.now(), ChronoUnit.SECONDS);

  if (skipInterval || (lastTotalTimestamp == 0 || (now - lastTotalTimestamp) > refreshInterval)) {
    background(0);

    try {
      graph.drawGraph(now);
      ticker.drawTicker(now);
    }
    catch(Exception e) {
      delay(5000);

      textAlign(CENTER, CENTER);
      textSize(16);
      e.printStackTrace();
      text(e.toString(), width/2, height/2);
    }

    lastTotalTimestamp = now;
  }
}

void draw() {
  drawStuff(false);
}
