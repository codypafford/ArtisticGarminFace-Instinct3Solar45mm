import Toybox.Graphics;

module ShapeHelpers {
    function drawRunner(dc, x, y) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        // 1. The Head
        dc.drawCircle(x, y - 8, 2);

        // 2. The Body (leaning forward slightly)
        dc.drawLine(x, y - 6, x + 2, y - 1);

        // 3. The Arms (Pumping)
        dc.drawLine(x + 2, y - 5, x + 5, y - 3); // Front arm
        dc.drawLine(x + 2, y - 5, x - 2, y - 2); // Back arm

        // 4. The Legs (In mid-stride)
        dc.drawLine(x + 2, y - 1, x + 5, y + 3); // Front leg (landing)
        dc.drawLine(x + 2, y - 1, x - 2, y + 1); // Back leg (lifting)
        dc.drawLine(x - 2, y + 1, x + 1, y + 4); // Back foot/calf
    }

    function drawCheckMark(dc, startingX) {
        dc.setPenWidth(2);
        var x = startingX;
        var y = startingX + 44;
        dc.drawLine(x, y, x + 4, y + 4); // downwards stroke
        dc.drawLine(x + 4, y + 4, x + 12, y - 6); // upwards stroke
        dc.setPenWidth(1);
    }
}