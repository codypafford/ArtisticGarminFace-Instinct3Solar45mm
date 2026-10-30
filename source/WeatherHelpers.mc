import Toybox.Graphics;
using Toybox.Math;

// Wrapping in a module keeps things organized
module WeatherHelpers {
    function drawSun(dc, x, y, weatherPosition) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var size = 30;

        // --- Core ---
        var coreRadius = size * 0.5;
        dc.fillCircle(x, y, coreRadius);

        // Subtle outer glow ring
        dc.drawCircle(x, y, coreRadius + 2);

        // --- Rays ---
        var longInner = coreRadius + 3;
        var longOuter = size * 1.4;

        var shortInner = coreRadius + 3;
        var shortOuter = size * 1.15;

        // 16 rays (every 22.5 degrees)
        // TODO: cody: i could try removing that weeatherPositons logic from thsi and see if that fixes the bug..?
        var drawLongRays = weatherPosition == 0;
        var drawShortRays = weatherPosition == 1;
        var drawAllRays = weatherPosition == 2;
        for (var i = 0; i < 16; i++) {

            var isLongRay = (i % 2 == 0);

            // Skip rays depending on mode
            if (!drawAllRays) {
                if (isLongRay && !drawLongRays) {
                    continue;
                }
                if (!isLongRay && !drawShortRays) {
                    continue;
                }
            }

            var angle = i * 22.5;
            var rad = angle * Math.PI / 180.0;

            var inner = isLongRay ? longInner : shortInner;
            var outer = isLongRay ? longOuter : shortOuter;

            var x1 = x + Math.cos(rad) * inner;
            var y1 = y + Math.sin(rad) * inner;

            var x2 = x + Math.cos(rad) * outer;
            var y2 = y + Math.sin(rad) * outer;

            dc.drawLine(x1, y1, x2, y2);
        }
    }

    function drawMoon(dc, x, y, weatherPosition) {
        // size = overall "radius" scale, e.g., 20
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var size = 30;
        // Main moon body
        var moonRadius = size * 0.5;
        dc.fillCircle(x, y, moonRadius);

        // Crescent shadow
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var shadowOffset = moonRadius * 0.6; // how much crescent is cut
        dc.fillCircle(x - shadowOffset, y, moonRadius);
    }

    function drawClouds(dc, x, y, weatherPosition) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var size = 20;              // main radius
        var sideOffset = size * 0.8;
        var verticalLift = size * 0.4;
        var baseOffset = size * 0.6;

        // Left puff
        dc.fillCircle(x - sideOffset, y, size * 0.9);

        // Right puff
        dc.fillCircle(x + sideOffset, y, size * 0.9);

        // Top center puff
        dc.fillCircle(x, y - verticalLift, size);

        // Bottom filler to flatten the base
        dc.fillCircle(x, y + baseOffset, size * 0.85);
    }

    function drawRain(dc, x, y, weatherPosition) {

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        var spread = 18;
        var dropLength = 8;
        var slant = 3;

        // Smooth falling animation
        var yOffset = weatherPosition * 8;

        // --- Front row (longer drops) ---
        dc.drawLine(x - spread,     y + 2 + yOffset,
                    x - spread - slant,     y + 2 + dropLength + yOffset);

        dc.drawLine(x - spread/2,   y + yOffset,
                    x - spread/2 - slant,   y + dropLength + yOffset);

        dc.drawLine(x,              y + 1 + yOffset,
                    x - slant,              y + 1 + dropLength + yOffset);

        dc.drawLine(x + spread/2,   y - 1 + yOffset,
                    x + spread/2 - slant,   y - 1 + dropLength + yOffset);

        dc.drawLine(x + spread,     y + 2 + yOffset,
                    x + spread - slant,     y + 2 + dropLength + yOffset);

        // --- Back row (shorter drops) ---
        var backOffset = 4;
        var shortLength = dropLength * 0.7;

        dc.drawLine(x - spread/1.3, y + backOffset + yOffset,
                    x - spread/1.3 - slant, y + backOffset + shortLength + yOffset);

        dc.drawLine(x + spread/3,   y + backOffset - 1 + yOffset,
                    x + spread/3 - slant,   y + backOffset - 1 + shortLength + yOffset);

        dc.drawLine(x + spread/1.2, y + backOffset + yOffset,
                    x + spread/1.2 - slant, y + backOffset + shortLength + yOffset);
    }

    function drawStorm(dc, x, y, weatherPosition) {

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Smooth 3-step vertical animation
        var by = y - 2 + (weatherPosition * 3);
        var bx = x;

        // --- Main Lightning Bolt ---
        dc.setPenWidth(3);

        dc.drawLine(bx,      by,      bx - 6,  by + 10);
        dc.drawLine(bx - 6,  by + 10, bx + 4,  by + 10);
        dc.drawLine(bx + 4,  by + 10, bx - 3,  by + 22);
        dc.drawLine(bx - 3,  by + 22, bx + 2,  by + 22);
        dc.drawLine(bx + 2,  by + 22, bx - 5,  by + 34);

        // --- Inner Highlight ---
        dc.setPenWidth(1);

        dc.drawLine(bx - 1,  by + 3,  bx - 5,  by + 11);
        dc.drawLine(bx - 2,  by + 14, bx - 4,  by + 22);
    }

    function drawSnow(dc, x, y, weatherPosition) {
        var size = 10;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        // Define snowflake relative positions and sizes
        var flakes = [
            [-20, 8, 0.18],   // new far left
            [-18, 3, 0.2],    // new far left
            [-15, 5, 0.2],    // previous far left
            [-10, 10, 0.18],
            [-3, 2, 0.22],
            [0, 0, 0.25],     // center
            [4, 8, 0.2],
            [8, 12, 0.18],
            [12, 4, 0.2],
            [15, 10, 0.2]     // far right
        ];

        for (var i = 0; i < flakes.size(); i++) {
            var dx = flakes[i][0] * (size / 10);   // horizontal scaling
            var dy = flakes[i][1] * (size / 10);   // vertical scaling
            var radius = flakes[i][2] * size;      // snowflake radius
            dc.fillCircle(x + dx, y + dy, radius);
        }
    }

    function tempFormatter(tempC, settings, metric) {
        if (settings.temperatureUnits == metric) {
            // Display as Celsius
            return tempC.format("%d") + "°C";
        } else {
            // Convert to Fahrenheit
            var tempF = (tempC * 9 / 5) + 32;
            return tempF.format("%d") + "°F";
        }
    }
}
