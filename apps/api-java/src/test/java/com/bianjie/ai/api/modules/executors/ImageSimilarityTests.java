package com.bianjie.ai.api.modules.executors;

import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import static org.assertj.core.api.Assertions.assertThat;

class ImageSimilarityTests {

    @Test
    void treatsReencodedCopiesAsNearlyIdentical() throws IOException {
        BufferedImage image = sampleImage(false);

        assertThat(ImageSimilarity.isNearlyIdentical(encode(image, "png"), encode(image, "jpg"))).isTrue();
    }

    @Test
    void rejectsVisiblyDifferentImages() throws IOException {
        assertThat(ImageSimilarity.isNearlyIdentical(
                encode(sampleImage(false), "png"),
                encode(sampleImage(true), "png")
        )).isFalse();
    }

    private BufferedImage sampleImage(boolean inverted) {
        BufferedImage image = new BufferedImage(160, 120, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = image.createGraphics();
        try {
            graphics.setColor(inverted ? Color.WHITE : new Color(20, 60, 110));
            graphics.fillRect(0, 0, image.getWidth(), image.getHeight());
            graphics.setColor(inverted ? Color.BLACK : new Color(235, 190, 45));
            graphics.fillRect(18, 18, 90, 48);
            graphics.fillOval(90, 62, 52, 42);
        } finally {
            graphics.dispose();
        }
        return image;
    }

    private byte[] encode(BufferedImage image, String format) throws IOException {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        ImageIO.write(image, format, output);
        return output.toByteArray();
    }
}
