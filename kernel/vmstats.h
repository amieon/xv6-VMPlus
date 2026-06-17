struct vmstats_user {
  uint64 cow_faults;
  uint64 lazy_faults;
  uint64 shm_faults;
  uint64 kalloc_cnt;
  uint64 copyin_bytes;
  uint64 copyout_bytes;

  uint64 fork_copy_pages;    // fork 时真正 memmove 复制的用户页
  uint64 fork_share_pages;   // fork 时共享(不复制)的用户页

  uint64 kfree_cnt;
};

