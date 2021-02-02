// compile with -march=armv8-a+sve on compatible aarch64 compiler
// linux-aarch64-sve.core was generated by: aarch64-linux-gnu-gcc-8
// commandline: -march=armv8-a+sve -nostdlib -static -g linux-aarch64-sve.c
static void bar(char *boom) {
  char F = 'b';
  asm volatile("fmov     d0,  #0.5\n\t");
  asm volatile("fmov     d1,  #1.5\n\t");
  asm volatile("fmov     d2,  #2.5\n\t");
  asm volatile("fmov     d3,  #3.5\n\t");
  asm volatile("fmov     s4,  #4.5\n\t");
  asm volatile("fmov     s5,  #5.5\n\t");
  asm volatile("fmov     s6,  #6.5\n\t");
  asm volatile("fmov     s7,  #7.5\n\t");
  asm volatile("movi     v8.16b, #0x11\n\t");
  asm volatile("movi     v31.16b, #0x30\n\t");

  *boom = 47; // Frame bar
}

static void foo(char *boom, void (*boomer)(char *)) {
  char F = 'f';
  boomer(boom); // Frame foo
}

void _start(void) {
  char F = '_';
  foo(0, bar); // Frame _start
}
