public class Cache {
    final int CACHE_SETS_COUNT = 32;
    double cacheHitCounter;
    double counter;
    int tactCounter = 0;
    Memory memory = new Memory();
    CacheLine[] segment1 = new CacheLine[CACHE_SETS_COUNT];
    int[] LRULastUse = new int[CACHE_SETS_COUNT];
    CacheLine[] segment2 = new CacheLine[CACHE_SETS_COUNT];

    public Cache() {
        cacheHitCounter = 0;
        counter = 0;
        for (int i = 0; i < CACHE_SETS_COUNT; i++) {
            segment1[i] = new CacheLine();
            segment2[i] = new CacheLine();
            LRULastUse[i] = 2;
        }
    }

    public double percent() {
        return ((cacheHitCounter * ((double) 100)) / counter);
    }

    public int read8(Address a) {
        int tag = a.tag;
        int index = a.index;
        int offset = a.offset;
        counter++;
        tactCounter++;
        tactCounter++;
        if (segment1[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 1;
            tactCounter += 4;
            return binToDec(segment1[index].data[offset]);
        } else if (segment2[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 2;
            tactCounter += 4;
            return binToDec(segment2[index].data[offset]);
        } else if (LRULastUse[index] == 1) {
            if (segment2[index].dirty == 1) {
                tactCounter += 100;
                segment2[index].dirty = 0;
                memory.write_line(segment2[index], segment2[index].tag * 32 + index);
            }
            tactCounter += 100;
            segment2[index] = memory.read_line(tag * 32 + index);
            LRULastUse[index] = 2;
            tactCounter += 4;
            return binToDec(segment2[index].data[offset]);
        } else {
            if (segment1[index].dirty == 1) {
                segment1[index].dirty = 0;
                tactCounter += 100;
                memory.write_line(segment1[index], segment1[index].tag * 32 + index);
            }
            tactCounter += 100;
            segment1[index] = memory.read_line(tag * 32 + index);
            LRULastUse[index] = 1;
            tactCounter += 4;
            return binToDec(segment1[index].data[offset]);
        }
    }

    public int read16(Address a) {
        int tag = a.tag;
        int index = a.index;
        int offset = a.offset;
        counter++;
        tactCounter++;
        tactCounter++;
        if (segment1[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 1;
            tactCounter += 4;
            return binToDec(segment1[index].data[offset] + segment1[index].data[offset + 1]);
        } else if (segment2[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 2;
            tactCounter += 4;
            return binToDec(segment2[index].data[offset] + segment2[index].data[offset + 1]);
        } else if (LRULastUse[index] == 1) {
            if (segment2[index].dirty == 1) {
                segment2[index].dirty = 0;
                tactCounter += 100;
                memory.write_line(segment2[index], segment2[index].tag * 32 + index);
            }
            tactCounter += 100;
            segment2[index] = memory.read_line(tag * 32 + index);
            LRULastUse[index] = 2;
            tactCounter += 4;
            return binToDec(segment2[index].data[offset] + segment2[index].data[offset + 1]);
        } else {
            if (segment1[index].dirty == 1) {
                segment1[index].dirty = 0;
                tactCounter += 100;
                memory.write_line(segment1[index], segment1[index].tag * 32 + index);
            }
            tactCounter += 100;
            segment1[index] = memory.read_line(tag * 32 + index);
            LRULastUse[index] = 1;
            tactCounter += 4;
            return binToDec(segment1[index].data[offset] + segment1[index].data[offset + 1]);
        }
    }

    public int read32(Address a) {
        int tag = a.tag;
        int index = a.index;
        int offset = a.offset;
        counter++;
        tactCounter++;
        tactCounter++;
        if (segment1[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 1;
            tactCounter += 4;
            return binToDec(segment1[index].data[offset] + segment1[index].data[offset + 1]
                    + segment1[index].data[offset + 2] + segment1[index].data[offset + 3]);
        } else if (segment2[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 2;
            tactCounter += 4;
            return binToDec(segment2[index].data[offset] + segment2[index].data[offset + 1]
                    + segment2[index].data[offset + 2] + segment2[index].data[offset + 3]);
        }
        if (LRULastUse[index] == 1) {
            if (segment2[index].dirty == 1) {
                segment2[index].dirty = 0;
                tactCounter += 100;
                memory.write_line(segment2[index], segment2[index].tag * 32 + index);
            }
            tactCounter += 100;
            segment2[index] = memory.read_line(tag * 32 + index);
            LRULastUse[index] = 2;
            tactCounter += 4;
            return binToDec(segment2[index].data[offset] + segment2[index].data[offset + 1]
                    + segment2[index].data[offset + 2] + segment2[index].data[offset + 3]);
        } else {
            if (segment1[index].dirty == 1) {
                segment1[index].dirty = 0;
                tactCounter += 100;
                memory.write_line(segment1[index], segment1[index].tag * 32 + index);
            }
            tactCounter += 100;
            segment1[index] = memory.read_line(tag * 32 + index);
            LRULastUse[index] = 1;
            tactCounter += 4;
            return binToDec(segment1[index].data[offset] + segment1[index].data[offset + 1]
                    + segment1[index].data[offset + 2] + segment1[index].data[offset + 3]);
        }
    }

    public void write8(Address a, int data) {
        int tag = a.tag;
        int index = a.index;
        int offset = a.offset;
        counter++;
        tactCounter++;
        tactCounter++;
        StringBuilder temp = new StringBuilder(toBinWithReverse(data));
        if (temp.length() > 8) {
            temp = new StringBuilder(temp.substring(0, 8));
        } else {
            int length = temp.length();
            temp.append("0".repeat(Math.max(0, 8 - length)));
        }
        if (segment1[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 1;
            tactCounter += 4;
            segment1[index].data[offset] = temp.toString();
        } else if (segment2[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 2;
            tactCounter += 4;
            segment2[index].data[offset] = temp.toString();
        } else {
            if (LRULastUse[index] == 1) {
                if (segment2[index].dirty == 1) {
                    segment2[index].dirty = 0;
                    tactCounter += 100;
                    memory.write_line(segment2[index], segment2[index].tag * 32 + index);
                }
                tactCounter += 100;
                segment2[index] = memory.read_line(tag * 32 + index);
                segment2[index].dirty = 1;
                segment2[index].data[offset] = temp.toString();
                LRULastUse[index] = 2;
                tactCounter += 4;
            } else {
                if (segment1[index].dirty == 1) {
                    segment1[index].dirty = 0;
                    tactCounter += 100;
                    memory.write_line(segment1[index], segment1[index].tag * 32 + index);
                }
                tactCounter += 100;
                segment1[index] = memory.read_line(tag * 32 + index);
                segment1[index].dirty = 1;
                segment1[index].data[offset] = temp.toString();
                LRULastUse[index] = 1;
                tactCounter += 4;
            }
        }
    }

    public void write16(Address a, int data) {
        int tag = a.tag;
        int index = a.index;
        int offset = a.offset;
        counter++;
        tactCounter++;
        tactCounter++;
        StringBuilder temp = new StringBuilder(toBinWithReverse(data));
        if (temp.length() > 16) {
            temp = new StringBuilder(temp.substring(0, 16));
        } else {
            int length = temp.length();
            temp.append("0".repeat(Math.max(0, 16 - length)));
        }
        if (segment1[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 1;
            segment1[index].data[offset] = temp.substring(0, 8);
            segment1[index].data[offset + 1] = temp.substring(8, 16);
            tactCounter += 4;
        } else if (segment2[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 2;
            segment2[index].data[offset] = temp.substring(0, 8);
            segment2[index].data[offset + 1] = temp.substring(8, 16);
            tactCounter += 4;
        } else {
            if (LRULastUse[index] == 1) {
                if (segment2[index].dirty == 1) {
                    segment2[index].dirty = 0;
                    tactCounter += 100;
                    memory.write_line(segment2[index], segment2[index].tag * 32 + index);
                }
                tactCounter += 100;
                segment2[index] = memory.read_line(tag * 32 + index);
                segment2[index].dirty = 1;
                segment2[index].data[offset] = temp.substring(0, 8);
                segment2[index].data[offset + 1] = temp.substring(8, 16);
                LRULastUse[index] = 2;
                tactCounter += 4;

            } else {
                if (segment1[index].dirty == 1) {
                    segment1[index].dirty = 0;
                    tactCounter += 100;
                    memory.write_line(segment1[index], segment1[index].tag * 32 + index);
                }
                tactCounter += 100;
                segment1[index] = memory.read_line(tag * 32 + index);
                segment1[index].dirty = 1;
                segment1[index].data[offset] = temp.substring(0, 8);
                segment1[index].data[offset + 1] = temp.substring(8, 16);
                LRULastUse[index] = 1;
                tactCounter += 4;
            }
        }
    }

    public void write32(Address a, int data) {
        int tag = a.tag;
        int index = a.index;
        int offset = a.offset;
        counter++;
        tactCounter++;
        tactCounter++;
        StringBuilder temp = new StringBuilder(toBinWithReverse(data));
        if (temp.length() > 32) {
            temp = new StringBuilder(temp.substring(0, 32));
        } else {
            int length = temp.length();
            temp.append("0".repeat(Math.max(0, 32 - length)));
        }
        if (segment1[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 1;
            segment1[index].data[offset] = temp.substring(0, 8);
            segment1[index].data[offset + 1] = temp.substring(8, 16);
            segment1[index].data[offset + 2] = temp.substring(16, 24);
            segment1[index].data[offset + 3] = temp.substring(24, 32);
            segment1[index].tag = tag;
            tactCounter += 4;
        } else if (segment2[index].tag == tag) {
            cacheHitCounter++;
            LRULastUse[index] = 2;
            segment2[index].data[offset] = temp.substring(0, 8);
            segment2[index].data[offset + 1] = temp.substring(8, 16);
            segment2[index].data[offset + 2] = temp.substring(16, 24);
            segment2[index].data[offset + 3] = temp.substring(24, 32);
            segment2[index].tag = tag;
            tactCounter += 4;
        } else {
            if (LRULastUse[index] == 1) {
                if (segment2[index].dirty == 1) {
                    segment2[index].dirty = 0;
                    tactCounter += 100;
                    memory.write_line(segment2[index], segment2[index].tag * 32 + index);
                }
                tactCounter += 100;
                segment2[index] = memory.read_line(tag * 32 + index);
                segment2[index].dirty = 1;
                segment2[index].data[offset] = temp.substring(0, 8);
                segment2[index].data[offset + 1] = temp.substring(8, 16);
                tactCounter += 4;
                segment2[index].data[offset + 2] = temp.substring(16, 24);
                segment2[index].data[offset + 3] = temp.substring(24, 32);
                LRULastUse[index] = 1;
            } else {
                if (segment1[index].dirty == 1) {
                    segment1[index].dirty = 0;
                    tactCounter += 100;
                    memory.write_line(segment1[index], segment1[index].tag * 32 + index);
                }
                tactCounter += 100;
                segment1[index] = memory.read_line(tag * 32 + index);
                segment1[index].dirty = 1;
                segment1[index].data[offset] = temp.substring(0, 8);
                segment1[index].data[offset + 1] = temp.substring(8, 16);
                tactCounter += 4;
                segment1[index].data[offset + 2] = temp.substring(16, 24);
                segment1[index].data[offset + 3] = temp.substring(24, 32);
                LRULastUse[index] = 2;
            }
        }
    }

    public String toBinWithReverse(int x) {
        StringBuilder sb = new StringBuilder();
        while (x > 0) {
            sb.append((x % 2));
            x = (x - x % 2) / 2;
        }
        return sb.toString();
    }

    public int binToDec(String x) {
        int a = 1;
        int res = 0;
        for (int i = 0; i < x.length(); i++) {
            res += (x.charAt(i) - '0') * a;
            a *= 2;
        }
        return res;
    }
}

