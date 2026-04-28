import java.io.FileInputStream;
import java.security.Key;
import java.security.KeyStore;

public class DumpPrivateKey {
    static public void main(String[] args) {

        if (args.length != 4) {
            System.out.println("Usage: " + DumpPrivateKey.class.getName()
                    + " <JKS to use> <alias in JKS> <store pass> <key pass>");
            System.exit(1);
        }

        try {
            KeyStore ks = KeyStore.getInstance("jks");
            ks.load(new FileInputStream(args[0]), args[2].toCharArray());
            Key key = ks.getKey(args[1], args[3].toCharArray());
            System.out.write(key.getEncoded());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
