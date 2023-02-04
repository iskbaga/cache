class CacheLine {
    final int CACHE_LINE_SIZE=16;
    public int dirty;
    public int valid;
    public String[] data;
    public int tag;
    public int index;
    public int offset;
    public CacheLine() {
        dirty=0;
        valid=0;
        tag=-1;
        index=0;
        offset=0;
        data=new String[CACHE_LINE_SIZE];
        for(int i=0;i<CACHE_LINE_SIZE;i++){
            data[i]= "00000000";
        }
    }

}