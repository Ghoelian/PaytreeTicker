import com.google.gson.Gson;

int legendOffset = 60;

class Graph {
  private Gson gson = new Gson();

  private int[] data;

  private int highest;
  private int middle;
  private int lowest;

  private int stepSize;

  void getData() {
    GetRequest request = new GetRequest("https://api.paytree.nl/v1/status/stats");
    request.addHeader("Authorization", apiKey);
    request.send();

    String result = request.getContent();

    int[] arr = gson.fromJson(result, int[].class);
    data = arr;

    highest = findHighest(data);
    lowest = findLowest(data);
    middle = (highest + lowest) / 2;

    legendOffset = String.valueOf(highest).length() * 36;

    if (data != null && data.length > 0) {
      stepSize = (width - legendOffset) / data.length;
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
      stroke(24, 94.6, 94.9);
      strokeWeight(2);

      for (int i = 0; i < data.length; i++) {
        int current = this.data[i];

        if (i < data.length - 1) {
          int next = data[i + 1];

          float currentLineY = map(current, lowest, highest, height - tickerOffsetY - 4, 10);
          float nextLineY = map(next, lowest, highest, height - tickerOffsetY - 4, 10);

          if (Float.isNaN(currentLineY)) {
            currentLineY = height - tickerOffsetY;
          }

          if (Float.isNaN(nextLineY)) {
            nextLineY = height - tickerOffsetY;
          }

          line(
            (i * stepSize) + legendOffset + 4,
            currentLineY,
            ((i + 1) * stepSize) + legendOffset + 4,
            nextLineY
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
