import java.util.HashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) {
        Cache cache = new Cache();
        final int M = 64;
        final int N = 60;
        final int K = 32;
        int tag = 0;
        int index = 0;
        int offset = 0;
        int tactCounter = 0;
        Map<Integer, Address> aAddress = new HashMap<>();
        Map<Integer, Address> bAddress = new HashMap<>();
        Map<Integer, Address> cAddress = new HashMap<>();
        for (int i = 0; i < M * K; i++) {
            aAddress.put(i, new Address(tag, index, offset));
            offset++;
            if (offset == 16) {
                offset = 0;
                index++;
                if (index == 32) {
                    index = 0;
                    tag++;
                }
            }
        }
        for (int i = 0; i < N * K * 2; i++) {
            bAddress.put(i + M * K, new Address(tag, index, offset));
            offset++;
            if (offset == 16) {
                offset = 0;
                index++;
                if (index == 32) {
                    index = 0;
                    tag++;
                }
            }
        }
        for (int i = 0; i < M * N * 4; i++) {
            cAddress.put(i + M * K + N * K * 2, new Address(tag, index, offset));
            offset++;
            if (offset == 16) {
                offset = 0;
                index++;
                if (index == 32) {
                    index = 0;
                    tag++;
                }
            }
        }
        int pa = 0;
        tactCounter++;
        int pc = M * K + N * K * 2;
        tactCounter++;
        tactCounter++;
        for (int y = 0; y < M; y++) {
            tactCounter++;
            for (int x = 0; x < N; x++) {
                int pb = M * K;
                tactCounter++;
                int s = 0;
                tactCounter++;
                tactCounter++;
                for (int k = 0; k < K; k++) {
                    s += cache.read8(aAddress.get(pa + k)) * cache.read16(bAddress.get(pb + (2 * x)));
                    tactCounter += 6;
                    pb += 2 * N;
                    tactCounter++;
                    tactCounter++;
                }
                cache.write32(cAddress.get(pc + (4 * x)), s);
                tactCounter++;
            }
            pa += K;
            tactCounter++;
            pc += 4 * N;
            tactCounter++;
            tactCounter++;
        }
        System.out.println("time: " + (tactCounter + cache.tactCounter));
        System.out.println("percent: " + String.format("%.2f", cache.percent())+"%");
        System.out.println("cache hits count: " + cache.cacheHitCounter);
        System.out.println("cache accesses count: " + cache.counter);
    }
}
