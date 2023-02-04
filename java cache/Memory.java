public class Memory {
    final int MEMORY_LINE_COUNT=32768;
    CacheLine[] memory =new CacheLine[MEMORY_LINE_COUNT];
    public Memory() {
        for(int i=0;i<MEMORY_LINE_COUNT;i++){
            memory[i]= new CacheLine();
            memory[i].tag=i/32;
        }
    }
    public CacheLine read_line(int i) {
        return memory[i];
    }

    public void write_line(CacheLine cacheLine, int index) {
        memory[index]= cacheLine;
    }
}
