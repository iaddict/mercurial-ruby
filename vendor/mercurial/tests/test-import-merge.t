  $ echo "[extensions]" >> $HGRCPATH
  $ echo "mq=" >> $HGRCPATH

  $ tipparents() {
  > hg parents --template "{rev}:{node|short} {desc|firstline}\n" -r tip
  > }

Test import and merge diffs

  $ hg init repo
  $ cd repo
  $ echo a > a
  $ hg ci -Am adda
  adding a
  $ echo a >> a
  $ hg ci -m changea
  $ echo c > c
  $ hg ci -Am addc
  adding c
  $ hg up 0
  1 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ echo b > b
  $ hg ci -Am addb
  adding b
  created new head
  $ hg up 1
  1 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ hg merge 3
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  (branch merge, don't forget to commit)
  $ hg ci -m merge
  $ hg export . > ../merge.diff
  $ cd ..
  $ hg clone -r2 repo repo2
  adding changesets
  adding manifests
  adding file changes
  added 3 changesets with 3 changes to 2 files
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ cd repo2
  $ hg pull -r3 ../repo
  pulling from ../repo
  searching for changes
  adding changesets
  adding manifests
  adding file changes
  added 1 changesets with 1 changes to 1 files (+1 heads)
  (run 'hg heads' to see heads, 'hg merge' to merge)

Test without --exact and diff.p1 == workingdir.p1

  $ hg up 1
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ hg import ../merge.diff
  applying ../merge.diff
  $ tipparents
  1:540395c44225 changea
  3:102a90ea7b4a addb
  $ hg strip --no-backup tip
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved

Test without --exact and diff.p1 != workingdir.p1

  $ hg up 2
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg import ../merge.diff
  applying ../merge.diff
  $ tipparents
  2:890ecaa90481 addc
  $ hg strip --no-backup tip
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved

Test with --exact

  $ hg import --exact ../merge.diff
  applying ../merge.diff
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved
  $ tipparents
  1:540395c44225 changea
  3:102a90ea7b4a addb
  $ hg strip --no-backup tip
  0 files updated, 0 files merged, 1 files removed, 0 files unresolved

Test with --bypass and diff.p1 == workingdir.p1

  $ hg up 1
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg import --bypass ../merge.diff
  applying ../merge.diff
  $ tipparents
  1:540395c44225 changea
  3:102a90ea7b4a addb
  $ hg strip --no-backup tip

Test with --bypass and diff.p1 != workingdir.p1

  $ hg up 2
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg import --bypass ../merge.diff
  applying ../merge.diff
  $ tipparents
  2:890ecaa90481 addc
  $ hg strip --no-backup tip

Test with --bypass and --exact

  $ hg import --bypass --exact ../merge.diff
  applying ../merge.diff
  $ tipparents
  1:540395c44225 changea
  3:102a90ea7b4a addb
  $ hg strip --no-backup tip

  $ cd ..