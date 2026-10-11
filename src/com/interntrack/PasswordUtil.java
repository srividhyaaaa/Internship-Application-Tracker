package com.interntrack;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
public class PasswordUtil {
    private static final int ITERATIONS = 210000;
    private static final int KEY_LENGTH = 256;
    public static String hashPassword(String password)
            throws NoSuchAlgorithmException, InvalidKeySpecException {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        PBEKeySpec spec = new PBEKeySpec(
                password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
        byte[] hash = SecretKeyFactory.getInstance(
                "PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        spec.clearPassword();
        return ITERATIONS + ":" +
                Base64.getEncoder().encodeToString(salt) + ":" +
                Base64.getEncoder().encodeToString(hash);
    }
    public static boolean verifyPassword(String password, String stored)
            throws NoSuchAlgorithmException, InvalidKeySpecException {
        String[] parts = stored.split(":");
        if (parts.length != 3) {
            return false;
        }
        int iterations = Integer.parseInt(parts[0]);
        byte[] salt = Base64.getDecoder().decode(parts[1]);
        byte[] expectedHash = Base64.getDecoder().decode(parts[2]);
        PBEKeySpec spec = new PBEKeySpec(
                password.toCharArray(), salt, iterations, expectedHash.length * 8);
        byte[] actualHash = SecretKeyFactory.getInstance(
                "PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        spec.clearPassword();
        if (actualHash.length != expectedHash.length) {
            return false;
        }
        int difference = 0;
        for (int i = 0; i < actualHash.length; i++) {
            difference |= actualHash[i] ^ expectedHash[i];
        }
        return difference == 0;
    }
}
