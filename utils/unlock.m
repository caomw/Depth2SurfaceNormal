function res = unlock(fpath)
lock_fpath = [fpath '.lock'];
if ~exist(lock_fpath)
  res = 0;
  return;
end
unix(['rmdir ' lock_fpath]);
res = 1;
return;

