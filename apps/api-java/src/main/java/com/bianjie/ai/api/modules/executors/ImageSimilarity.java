package com.bianjie.ai.api.modules.executors;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Arrays;

final class ImageSimilarity {

    private static final int HASH_WIDTH = 9;
    private static final int HASH_HEIGHT = 8;
    private static final int MAX_HASH_DISTANCE = 4;
    private static final int MAX_AVERAGE_COLOR_DISTANCE = 24;

    private ImageSimilarity() {
    }

    static boolean isNearlyIdentical(byte[] first, byte[] second) {
        if (first == null || second == null || first.length == 0 || second.length == 0) {
            return false;
        }
        if (Arrays.equals(first, second)) {
            return true;
        }
        try {
            Signature firstSignature = signature(first);
            Signature secondSignature = signature(second);
            int hashDistance = Long.bitCount(firstSignature.dHash() ^ secondSignature.dHash());
            int colorDistance = Math.max(
                    Math.abs(firstSignature.averageRed() - secondSignature.averageRed()),
                    Math.max(
                            Math.abs(firstSignature.averageGreen() - secondSignature.averageGreen()),
                            Math.abs(firstSignature.averageBlue() - secondSignature.averageBlue())
                    )
            );
            return hashDistance <= MAX_HASH_DISTANCE && colorDistance <= MAX_AVERAGE_COLOR_DISTANCE;
        } catch (IOException exception) {
            return false;
        }
    }

    private static Signature signature(byte[] bytes) throws IOException {
        BufferedImage source = ImageIO.read(new ByteArrayInputStream(bytes));
        if (source == null) {
            throw new IOException("Unsupported image data");
        }

        BufferedImage scaled = new BufferedImage(HASH_WIDTH, HASH_HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = scaled.createGraphics();
        try {
            graphics.setRenderingHint(
                    RenderingHints.KEY_INTERPOLATION,
                    RenderingHints.VALUE_INTERPOLATION_BILINEAR
            );
            graphics.drawImage(source, 0, 0, HASH_WIDTH, HASH_HEIGHT, null);
        } finally {
            graphics.dispose();
        }

        long dHash = 0L;
        long redTotal = 0;
        long greenTotal = 0;
        long blueTotal = 0;
        int bit = 0;
        for (int y = 0; y < HASH_HEIGHT; y++) {
            for (int x = 0; x < HASH_WIDTH; x++) {
                int rgb = scaled.getRGB(x, y);
                redTotal += (rgb >> 16) & 0xff;
                greenTotal += (rgb >> 8) & 0xff;
                blueTotal += rgb & 0xff;
                if (x < HASH_WIDTH - 1) {
                    int left = luminance(rgb);
                    int right = luminance(scaled.getRGB(x + 1, y));
                    if (left > right) {
                        dHash |= 1L << bit;
                    }
                    bit++;
                }
            }
        }

        int pixelCount = HASH_WIDTH * HASH_HEIGHT;
        return new Signature(
                dHash,
                (int) (redTotal / pixelCount),
                (int) (greenTotal / pixelCount),
                (int) (blueTotal / pixelCount)
        );
    }

    private static int luminance(int rgb) {
        int red = (rgb >> 16) & 0xff;
        int green = (rgb >> 8) & 0xff;
        int blue = rgb & 0xff;
        return (red * 299 + green * 587 + blue * 114) / 1000;
    }

    private record Signature(
            long dHash,
            int averageRed,
            int averageGreen,
            int averageBlue
    ) {
    }
}
