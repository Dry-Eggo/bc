

extern long __bc_sys1(long a1);
extern long __bc_sys2(long a1, long a2);
extern long __bc_sys3(long a1, long a2, long a3);
extern long __bc_sys4(long a1, long a2, long a3, long a4);
extern long __bc_sys5(long a1, long a2, long a3, long a4, long a5);
extern long __bc_sys6(long a1, long a2, long a3, long a4, long a5, long a6);

static char buf[1] = {0};
static char titos_buf[12] = {0};
extern int putbyte(char n) {
  buf[0] = n;
  return __bc_sys4(1, 1, (long)&buf[0], 1);
}

extern void puts(const char *fmt) {
  int len = 0;
  while (fmt[len] != '\0') {
    char c = fmt[len];
    putbyte(c);
    ++len;
  }
}

extern char *bitos(long n) {
  int i = 0;
  int is_negative = 0;
  if (n == 0) {
    titos_buf[i++] = '0';
    titos_buf[i] = '\0';
    return &titos_buf[0];
  }
  if (n < 0) {
    is_negative = 1;
    n = -n;
  }
  int num = n;
  while (num > 0) {
    titos_buf[i++] = '0' + (num % 10);
    num /= 10;
  }
  if (is_negative == 1) {
    titos_buf[i++] = '-';
  }
  titos_buf[i] = '\0';
  int start = 0, end = i - 1;
  while (start < end) {
    char temp = titos_buf[start];
    titos_buf[start] = titos_buf[end];
    titos_buf[end] = temp;
    start++;
    end--;
  }
  return titos_buf;
}

extern void putint(int i) {
  char *buf = bitos(i);
  puts(buf);
}

extern void texit(int code) {
  __asm__ volatile("mov $60, %eax\n"
                   "syscall\n"
                   "r=(rax)");
}

extern void main();
extern void _start() {
  main();
  texit(0);
}
