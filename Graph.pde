import com.google.gson.Gson;

class Graph {
  private Gson gson = new Gson();

  private int[] data;

  private int highest;
  private int middle;
  private int lowest;

  private int stepSize;

  private int tickerOffsetY = 120;
  private int legendOffset = 60;

  private long lastDataTimestamp = 0;

  void getData() {
    long now = Instant.ofEpochSecond(0L).until(Instant.now(), ChronoUnit.SECONDS);

    if (lastDataTimestamp == 0 || (now - lastDataTimestamp) > refreshInterval) {
      GetRequest request = new GetRequest("https://api.paytree-network.nl/v1/status/stats");
      request.addHeader("Authorization", apiKey);
      request.send();

      String result = request.getContent();

      int[] arr = gson.fromJson(result, int[].class);
      this.data = arr;

      this.highest = this.findHighest(data);
      this.lowest = this.findLowest(data);
      this.middle = (this.highest + this.lowest) / 2;
      
      this.legendOffset = String.valueOf(this.highest).length() * 30;

      if (this.data != null && this.data.length > 0) {
        this.stepSize = (width - legendOffset) / this.data.length;
      }

      this.lastDataTimestamp = now;
    }
  }

  void drawGraph() {
    this.getData();

    fill(255);
    stroke(255);

    line(this.legendOffset, 10, this.legendOffset, height - this.tickerOffsetY);
    line(this.legendOffset, height - this.tickerOffsetY, width - 10, height - this.tickerOffsetY);

    textSize(secondaryTextSize);

    textAlign(LEFT, TOP);
    text(this.highest, 10, 10);

    textAlign(LEFT, CENTER);
    text(this.middle, 10, (height - this.tickerOffsetY) / 2);

    textAlign(LEFT, BOTTOM);
    text(this.lowest, 10, height - this.tickerOffsetY);


    if (this.data != null) {
      stroke(242, 105, 13);
      strokeWeight(2);
      for (int i = 0; i < this.data.length; i++) {
        int current = this.data[i];

        if (i < this.data.length - 1) {
          int next = this.data[i + 1];

          line(
            (i * this.stepSize) + this.legendOffset + 4,
            map(current, lowest, this.highest, height - this.tickerOffsetY - 4, 10),
            ((i + 1) * this.stepSize) + this.legendOffset + 4,
            map(next, this.lowest, this.highest, height - this.tickerOffsetY - 4, 10)
            );
        }
      }
    }
  }

  int findHighest(int[] data) {
    if (data == null) {
      return highest;
    }

    int result = -1;

    for (int i = 0; i < data.length; i++) {
      if (data[i] > result) {
        result = data[i];
      }
    }

    return result;
  }

  int findLowest(int[] data) {
    if (data == null) {
      return lowest;
    }

    int result = -1;

    for (int i = 0; i < data.length; i++) {
      if (result == -1) {
        result = data[i];
        continue;
      }

      if (data[i] < result) {
        result = data[i];
      }
    }

    return result;
  }
}
