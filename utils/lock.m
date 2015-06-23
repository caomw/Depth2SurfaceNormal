function res = lock(fpath)
lock_fpath = [fpath '.lock'];
if exist(fpath) || exist(lock_fpath)
  res = 0;
  return;
end
unix(['mkdir -p ' lock_fpath]);
res = 1;

