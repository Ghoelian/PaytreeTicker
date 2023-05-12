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
      data = arr;

      highest = findHighest(data);
      lowest = findLowest(data);
      middle = (highest + lowest) / 2;
      
      legendOffset = String.valueOf(highest).length() * 30;

      if (data != null && data.length > 0) {
        stepSize = (width - legendOffset) / data.length;
      }

      lastDataTimestamp = now;
    }
  }

  void drawGraph() {
    getData();

    fill(255);
    stroke(255);

    line(legendOffset, 10, legendOffset, height - tickerOffsetY);
    line(legendOffset, height - tickerOffsetY, width - 10, height - tickerOffsetY);

    textSize(secondaryTextSize);

    textAlign(LEFT, TOP);
    text(highest, 10, 10);

    textAlign(LEFT, CENTER);
    text(middle, 10, (height - tickerOffsetY) / 2);

    textAlign(LEFT, BOTTOM);
    text(lowest, 10, height - tickerOffsetY);


    if (data != null) {
      stroke(242, 105, 13);
      strokeWeight(2);
      for (int i = 0; i < data.length; i++) {
        int current = this.data[i];

        if (i < data.length - 1) {
          int next = data[i + 1];

          line(
            (i * stepSize) + legendOffset + 4,
            map(current, lowest, highest, height - tickerOffsetY - 4, 10),
            ((i + 1) * stepSize) + legendOffset + 4,
            map(next, lowest, highest, height - tickerOffsetY - 4, 10)
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
