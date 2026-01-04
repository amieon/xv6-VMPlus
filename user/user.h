/*
 * user.h - 用户空间程序头文件
 * 
 * 该头文件包含了用户空间程序可以使用的系统调用、库函数声明和常量定义。
 * 它是用户程序与操作系统内核交互的接口定义。
 */

/* 内存分配相关常量 */
#define SBRK_ERROR ((char *)-1)  /* sbrk系统调用错误返回值 */

/* 内存保护标志 */
#define PROT_READ  0x1            /* 可读权限 */
#define PROT_WRITE 0x2            /* 可写权限 */

/* 内存映射标志 */
#define MAP_ANON   0x1            /* 匿名映射（无文件支持） */
#define MAP_SHARED   0x2          /* 共享映射 */

/* 结构体前向声明 */
struct stat;                     /* 文件状态结构体 */
struct vmstats_user;             /* 虚拟内存统计信息结构体 */

/*
 * 系统调用声明
 * 
 * 这些函数是用户程序直接调用内核服务的接口
 */

// 进程控制
int fork(void);                  /* 创建新进程 */
int exit(int) __attribute__((noreturn)); /* 终止当前进程 */
int wait(int*);                  /* 等待子进程终止 */
int getpid(void);                /* 获取当前进程ID */

// 文件系统操作
int pipe(int*);                  /* 创建管道 */
int write(int, const void*, int); /* 写入文件 */
int read(int, void*, int);       /* 读取文件 */
int close(int);                  /* 关闭文件描述符 */
int open(const char*, int);      /* 打开文件 */
int mknod(const char*, short, short); /* 创建特殊文件 */
int unlink(const char*);         /* 删除文件 */
int fstat(int fd, struct stat*); /* 获取文件状态 */
int link(const char*, const char*); /* 创建硬链接 */
int mkdir(const char*);          /* 创建目录 */
int chdir(const char*);          /* 更改当前工作目录 */
int dup(int);                    /* 复制文件描述符 */

// 进程通信与信号
int kill(int);                   /* 发送信号 */
int pause(int);                  /* 暂停进程 */
int sleep(int);                  /* 使进程睡眠 */

// 程序执行
int exec(const char*, char**);   /* 执行新程序 */

// 内存管理
char* sys_sbrk(int,int);         /* 扩展进程堆空间（内部系统调用） */
void* mmap(uint64 addr, int len, int prot, int flags,int key); /* 内存映射 */
int munmap(void *addr, int len); /* 取消内存映射 */

// 共享内存与信号量
int shmctl(int key, int cmd);    /* 共享内存控制 */
int sem_open(int key, int init); /* 打开信号量 */
int sem_wait(int key);           /* 等待信号量 */
int sem_post(int key);           /* 释放信号量 */

// 系统信息
int uptime(void);                /* 获取系统运行时间 */
int vmstats(struct vmstats_user* uaddr); /* 获取虚拟内存统计信息 */

/*
 * 库函数声明（来自ulib.c）
 * 
 * 这些函数是用户空间实现的库函数，提供常用功能
 */
int stat(const char*, struct stat*); /* 获取文件状态（包装函数） */
char* strcpy(char*, const char*);    /* 字符串复制 */
void *memmove(void*, const void*, int); /* 内存移动 */
char* strchr(const char*, char c);   /* 查找字符在字符串中的位置 */
int strcmp(const char*, const char*); /* 字符串比较 */
char* gets(char*, int max);          /* 从标准输入读取一行 */
uint strlen(const char*);            /* 计算字符串长度 */
void* memset(void*, int, uint);      /* 内存设置 */
int atoi(const char*);               /* 字符串转整数 */
int memcmp(const void *, const void *, uint); /* 内存比较 */
void *memcpy(void *, const void *, uint); /* 内存复制 */
char* sbrk(int);                     /* 扩展进程堆空间（立即分配） */
char* sbrklazy(int);                 /* 扩展进程堆空间（延迟分配） */

/*
 * 格式化输出函数（来自printf.c）
 */
void fprintf(int, const char*, ...) __attribute__ ((format (printf, 2, 3))); /* 格式化写入文件 */
void printf(const char*, ...) __attribute__ ((format (printf, 1, 2))); /* 格式化输出到标准输出 */

/*
 * 内存分配函数（来自umalloc.c）
 */
void* malloc(uint);                  /* 分配内存 */
void free(void*);                    /* 释放内存 */
